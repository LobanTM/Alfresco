#путь и имя файла 1С
$CSVpath="C:\Users\loban.tm\scripts\data\"
$UserCSVFile="ad_user.csv"
#$DepCSVFile="ad_dep.csv"

#определение доменов для работьы
$RootDomainOU = 'ou=Test,ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
#$QuitDomainOU = 'ou=zOUT,dc=ad,dc=uos,dc=ua'

#преобразование файла в unicode
$UniUserCSVFile="uni_"+$UserCSVFile
#получение содержимого файла
Get-Content ($CSVpath+$UserCSVFile) | Out-File ($CSVpath+$UniUserCSVFile) -Encoding "Unicode"

#разбор csv файла
#заголовки
$headerUser = "ActiveFlag","TabCode","Surname","FirstName","SecName","FirstSecondName","DepCode","DepIndex","DepName","FullDepName","Manager","TitleCode","TitleName"
#считывание данных в массив по указанным заголовкам
$UserCSV = Import-CSV ($CSVpath+$UniUserCSVFile) -header $headerUser -delimiter ";"

#считывание данных из АД
#$AllUOSUsers=Get-ADuser -filter * -SearchBase $RootDomainOU -Properties *

#$UsersUpdated=0
#$UsersDeactivates=0

#1. перебір користувачів і обробка\синхронізація CN (не можна вставляти в загальний цикл - змінює системно важливий параметр АД!)
#foreach ($UOSUser in $AllUOSUsers) { #0
#   if ($UOSUser.wWWHomePage) {#1 є табельний номер
#   
#        #Шукаємо користувача в файлі CSV і актуалізуємо CN
#        $UserCSVString=$UserCSV | Where {$_.TabCode -eq $UOSUser.wWWHomePage}
#			# 0 табельного номеру в базі не знайдено
#        if ($UserCSVString.Count -eq 0) { Write-Host ("Табельний код",$UOSUser.wWWHomePage,"у файлі імпорту не знайдено") }
#			# >1 більше одного запису за однаковим табельним номером
#			elseif ($UserCSVString.Count -ge 2) {Write-Host ("Помилка у файлі експорту - більше 1 запису с табельним номером",$UOSUser.wWWHomePage) } 
#				else { 
#				# 1 знайдено унікальну відповідність, 
#					# перевіряємо, чи не треба деактивувати користувача в АД
#					if (($UOSUser.Enabled) -and ($UserCSVString.ActiveFlag -eq "-"))  {
#						# деактивуємо користувача
#						Disable-ADAccount $UOSUser
#						Write-Host ("Акаунт",$UOSUser.Name,"деактивовано") -ForegroundColor Red
#						$UsersDeactivates++
#					} 
#					# перейменування атрибуту cn у випадку неспівпадіння cn та даних з файлу
#					$InitialsName=$UserCSVString.Surname+' '+$UserCSVString.FirstName[0]+'.'+$UserCSVString.SecName[0]+'.';
#					if ($UOSUser.Name -ne $InitialsName) { #4
#						Write-Host "CN користувача $UOSUser.Name змінено на " -ForegroundColor Red -NoNewline
#						Rename-ADObject -Identity $UOSUser -NewName $InitialsName 
#						$UsersUpdated++
#						Write-Host ($InitialsName)
#
#					} 
#				}         
#    } # є таб номер $UOSUser.wWWHomePage
#	
#    else { # немає табельного номеру
#        
#		#спроба автозаповнення табельного номеру в АД структурі - якщо є унікальний користувач
#        $UserCSVString=$UserCSV | Where {($UOSUser.Name -match ($_.Surname+' '+$_.FirstName[0]))}  # -and ($_.ActiveFlag -eq '+')
#        
#		# чи існує більше одного подібного користувача у файлі імпорту, треба заповнювати вручну
#        if (($UserCSVString.Count -eq 0) -or ($UserCSVString.Count -ge 2))  {
#           Write-Host ($UserCSVString) 
#           Write-Host ("Заповніть вручну табельний номер для користувача",$UOSUser.Name,'-',$UOSUser.Department) -ForegroundColor Yellow 
#        }
#		
#        #вдалося визначити унікальний запис для даного користувача, заповнюємо автоматично
#        else { 
#            Set-ADUser -Identity $UOSUser -replace @{wWWHomePage=$UserCSVString.TabCode}
#            Write-Host ('Для користувача',$UOSUser.Name,'табельний номер автоматично заповнено:',$UserCSVString.Tabcode,$UserCSVString.Surname,$UserCSVString.FirstSecondName) -ForegroundColor Green
#            
#			#перевірка, чи не треба деактивувати користувача в АД
#            if (($UOSUser.Enabled) -and ($UserCSVString.ActiveFlag -eq "-"))  {
#                Disable-ADAccount $UOSUser
#                Write-Host "Акаунт $UOSUser.Name деактивовано" -ForegroundColor Red
#                $UsersDeactivates++
#            }        
#            $InitialsName=$UserCSVString.Surname+' '+$UserCSVString.FirstName[0]+'.'+$UserCSVString.SecName[0]+'.';
#            # перейменування атрибуту cn у випадку неспівпадіння cn та даних з файлу
#            if ($UOSUser.Name -ne $InitialsName) { 
#                    Write-Host "CN користувача $UOSUser.Name змінено на " -ForegroundColor Red -NoNewline
#                    Rename-ADObject -Identity $UOSUser -NewName $InitialsName 
#                    Write-Host ($InitialsName)
#            } 
#        }
#     }    
#} #foreach #0
#Write-Host "Змінено CN для $UsersUpdated користувачів"

#$UsersUpdated=0

#2. перебір користувачів і обробка\синхронізація реквізитів
# повторое считывание пользователей из АД после возможных изменений
$AllUOSUsers=Get-ADuser -filter * -SearchBase $RootDomainOU -Properties *

foreach ($UOSUser in $AllUOSUsers) { 
   if ($UOSUser.wWWHomePage)      {# перевірка чи є табельний номер
       #Шукаємо користувача в файлі CSV і актуалізуємо реквізити
       $UserCSVString=$UserCSV | Where {$_.TabCode -eq $UOSUser.wWWHomePage}
       if (($UserCSVString) -and ($UserCSVString.Count -lt 2))  {
             Set-ADUser -Identity $UOSUser -Surname ($UserCSVString.Surname) `
											-Department ($UserCSVString.DepName) `
											-Title ($UserCSVString.TitleName) `
											-replace @{	GivenName=$UserCSVString.FirstSecondName;`
														DisplayName=$UOSUser.Name;`
														DisplayNamePrintable=($UserCSVString.DepIndex+' '+$UserCSVString.FullDepName);`
														DepartmentNumber=$UserCSVString.DepCode;`
														Description=($UserCSVString.Surname+' '+$UserCSVString.FirstSecondName)
														}
            #прописуємо квоти, якщо реквізит pager не заповнено (def.quota 10737418240 bytes)
              if (!$UOSUser.pager) {Set-ADUser -Identity $UOSUser -replace @{pager='10737418240'}}
         #     $UsersUpdated++
            Write-Host ("Користувач",$UOSUser)#.Name, $UOSUser.wWWHomePage)        
            Write-Host ("********",$UserCSVString)

        }
       

        # додаємо Київ до реквізиту Office, формат Київ №буд-№офісу
        #if (!$UOSUser.Office -or ($UOSUser.Office[0] -match "[1-9]"))  {
            #Write-Host $UOSUser.Office
        #    Set-ADUser -Identity $UOSUser -Office ("Київ "+$UOSUser.Office)
        #} 
    } 
} 

# переміщення деактивованих користувачыв до zUOT
#foreach ($UOSUser in $AllUOSUsers) { 
#    if (!$UOSUser.Enabled)      {
#        Move-ADObject -Identity $UOSUser -TargetPath $QuitDomainOU
#        Write-Host ("Користувача",$UOSUser.Name,"перенесено в zOUT")
#    }
#}

#Write-Host "Оброблено $UsersUpdated користувачів"
#Write-Host "Деактивовано $UsersDeactivates користувачів" -ForegroundColor Red

