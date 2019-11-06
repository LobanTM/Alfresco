# Скрипт для внесения данньых из 1С в АД для пользователей по табельному номеру (индексное поле)
#

# считьівание данньіх 1С из файла "ad_user.csv", по пути "D:\IT\admins\olegyu\"
# основной домен 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
#			тестовьый домен 'ou=Test,ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
#			домен для удаленньых пользователей 'ou=zOUT,dc=ad,dc=uos,dc=ua'
#
#$UserCSV - массив данных из 1С
#$AllUOSUsers - массив данных из АД
#	за табельним номером шукаємо користувача
#		немає - повідомлення користувача з таким номеро немає в базі 1С
#		більше одного - повідомлення
#		користувач є, а номеру в нього немає - порівнюємо ПІБ
#			знаходимо користуача з таким іменем оновлюємо cn користувача
#	перебіг по користувачах
#		користувач є та він один
#			перенести всі реквізити для цього користувача
#	переміщення деактивованих користувачів до zUOT
#




#путь и имя файла 1С
$CSVpath="C:\Users\dmsadmin1\scripts\data\"
$UserCSVFile="ad_user.csv"
#$DepCSVFile="ad_dep.csv"

$LogsFile = "C:\Users\dmsadmin1\scripts\result\logsTest.txt"

#определение доменов для работьы
$RootDomainOU = 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
$QuitDomainOU = 'ou=zOUT,dc=ad,dc=uos,dc=ua'

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
$AllUOSUsers=Get-ADuser -filter * -SearchBase $RootDomainOU -Properties *

$UsersUpdated=0
$UsersDeactivates=0

("=================================================================================================")|Out-File $LogsFile -Append
("{0:dd} {0:MMMM} {0:yyyy} {0:T}" -f (Get-Date))|Out-File $LogsFile -Append
(" ")|Out-File $LogsFile -Append

#1. перебір користувачів і обробка\синхронізація CN (не можна вставляти в загальний цикл - змінює системно важливий параметр АД!)
foreach ($UOSUser in $AllUOSUsers) { #0
   if ($UOSUser.wWWHomePage) {#1 є табельний номер
        
        #Шукаємо користувача в файлі CSV і актуалізуємо CN
        $UserCSVString=$UserCSV | Where {$_.TabCode -eq $UOSUser.wWWHomePage}
			# 0 табельного номеру в базі не знайдено
        if ($UserCSVString.Count -eq 0) { 
           Write-Host ("Табельний код",$UOSUser.wWWHomePage,"у файлі імпорту не знайдено") 
           $a = $UOSUser.wWWHomePage
           ("Табельний код $a у файлі імпорту не знайдено") |Out-File $LogsFile -Append     
           }
			# >1 більше одного запису за однаковим табельним номером
		elseif ($UserCSVString.Count -ge 2) {
           Write-Host ("Помилка у файлі експорту - більше 1 запису с табельним номером",$UOSUser.wWWHomePage)
           $a = $UOSUser.wWWHomePage 
           ("Помилка у файлі експорту - більше 1 запису с табельним номером $a") |Out-File $LogsFile -Append         
           } 
			else { 
			# 1 знайдено унікальну відповідність, 
				# перевіряємо, чи не треба деактивувати користувача в АД
				if (($UOSUser.Enabled) -and ($UserCSVString.ActiveFlag -eq "-"))  {
					# деактивуємо користувача
				#== Disable-ADAccount $UOSUser
					Write-Host ("Акаунт",$UOSUser.Name,"деактивовано") -ForegroundColor Red
                    $a = $UOSUser.Name
                    ("Акаунт $a деактивовано")|Out-File $LogsFile -Append                     
					$UsersDeactivates++
				} 
				# перейменування атрибуту cn у випадку неспівпадіння cn та даних з файлу
				$InitialsName=$UserCSVString.Surname+' '+$UserCSVString.FirstName[0]+'.'+$UserCSVString.SecName[0]+'.';
				if ($UOSUser.Name -ne $InitialsName) { #4
                    $a=$UOSUser.Name
                    $b=$InitialsName
                    ("CN користувача $a змінено на $b")|Out-File $LogsFile -Append
					Write-Host "CN користувача $UOSUser.Name змінено на " -ForegroundColor Red -NoNewline
				#== Rename-ADObject -Identity $UOSUser -NewName $InitialsName 
					$UsersUpdated++
					Write-Host ($InitialsName)
				} 
			}         
    } # є таб номер $UOSUser.wWWHomePage	
    else { # немає табельного номеру       
        
		#спроба автозаповнення табельного номеру в АД структурі - якщо є унікальний користувач
        $UserCSVString=$UserCSV | Where {($UOSUser.Name -match ($_.Surname+' '+$_.FirstName[0]+'.'+$_.SecName[0]+'.'))}  
        
		# чи існує більше одного подібного користувача у файлі імпорту, треба заповнювати вручну
        if (($UserCSVString.Count -eq 0) -or ($UserCSVString.Count -ge 2))  {

            #
            foreach($a in $UserCSVString){
                Write-Host ("               ",$a.TabCode,": ",$a.SurName, " ", $a.FirstSecondName)
            }

            #
            

           #Write-Host ($UserCSVString) 
           #Write-Host ("немає табельного номеру", $UOSUser.Name) -ForegroundColor Red

           if(($UOSUser.cn -notlike "*Адміністратор*")-and($UOSUser.cn -notlike "*test*")){

                Write-Host ("Заповніть вручну табельний номер для користувача",$UOSUser.Name,'-',$UOSUser.Department) -ForegroundColor Yellow
           
                $a = $UOSUser.Name 
                $b = $UOSUser.Department
                ("Заповніть вручну табельний номер для користувача $a - $b" )|Out-File $LogsFile -Append
           }
        }
		
        #вдалося визначити унікальний запис для даного користувача, заповнюємо автоматично
        else { 
        #== Set-ADUser -Identity $UOSUser -replace @{wWWHomePage=$UserCSVString.TabCode}
            Write-Host ('Для користувача',$UOSUser.Name,'табельний номер автоматично заповнено:',$UserCSVString.Tabcode,$UserCSVString.Surname,$UserCSVString.FirstSecondName) -ForegroundColor Green
            $name=$UOSUser.Name
            $a=$UserCSVString.Tabcode
            $b=$UserCSVString.Surname
            $c=$UserCSVString.FirstSecondName
            ("Для користувача $name табельний номер автоматично заповнено: $a $b $c" )|Out-File $LogsFile -Append

			#перевірка, чи не треба деактивувати користувача в АД
            if (($UOSUser.Enabled) -and ($UserCSVString.ActiveFlag -eq "-"))  {
            #== Disable-ADAccount $UOSUser
                Write-Host "Акаунт $UOSUser.Name деактивовано" -ForegroundColor Red
                $a = $UOSUser.Name
                ("Акаунт $a деактивовано")|Out-File $LogsFile -Append  
                $UsersDeactivates++
            }        
            $InitialsName=$UserCSVString.Surname+' '+$UserCSVString.FirstName[0]+'.'+$UserCSVString.SecName[0]+'.';
            # перейменування атрибуту cn у випадку неспівпадіння cn та даних з файлу
            if ($UOSUser.Name -ne $InitialsName) {
                    $a =  $UOSUser.Name
                    Write-Host "CN користувача $a змінено на " -ForegroundColor Red -NoNewline
               #==  Rename-ADObject -Identity $UOSUser -NewName $InitialsName 
                    Write-Host ($InitialsName)
            } 
        }
     }    
} #foreach #0
Write-Host "Змінено CN для $UsersUpdated користувачів"
("Змінено CN для $UsersUpdated користувачів")|Out-File $LogsFile -Append

$UsersUpdated=0

#2. перебір користувачів і обробка\синхронізація реквізитів
# повторое считывание пользователей из АД после возможных изменений
$AllUOSUsers=Get-ADuser -filter * -SearchBase $RootDomainOU -Properties *

foreach ($UOSUser in $AllUOSUsers) { 
    if ($UOSUser.wWWHomePage)      {# перевірка чи є табельний номер
        #Шукаємо користувача в файлі CSV і актуалізуємо реквізити
        $UserCSVString=$UserCSV | Where {$_.TabCode -eq $UOSUser.wWWHomePage}
        if (($UserCSVString) -and ($UserCSVString.Count -lt 2))  {

              #check DepartmentNumber vs $UserCSVString.DepCode
              if ($UOSUser.DepartmentNumber -ne $UserCSVString.DepCode){
                $a=$UOSUser.name
                $b=$UOSUser.Department
                $c=$UserCSVString.DepName
                ("$a from $b to ---> $c" )|Out-File $LogsFile -Append
                Write-Host  ("   ",$a ) -ForegroundColor white -NoNewline
                Write-Host  (" from " ) -ForegroundColor darkblue -NoNewline
                Write-Host  ( $b  ) -ForegroundColor gray -NoNewline
                Write-Host  (" to ---> " ) -ForegroundColor darkblue -NoNewline
                Write-Host  ( $c  ) -ForegroundColor gray 
              }
              #check title vs $UserCSVString.TitleName
              if ($UOSUser.title -ne $UserCSVString.TitleName){
                $a=$UOSUser.name
                $b=$UOSUser.title
                $c=$UserCSVString.TitleName
                ("$a from $b to ---> $c" )|Out-File $LogsFile -Append
                #Write-Host  ("$a from $b to ---> $c" ) -ForegroundColor gray
                Write-Host  ("   ",$a ) -ForegroundColor white -NoNewline
                Write-Host  (" from " ) -ForegroundColor darkblue -NoNewline
                Write-Host  ( $b  ) -ForegroundColor gray -NoNewline
                Write-Host  (" to ---> " ) -ForegroundColor darkblue -NoNewline
                Write-Host  ( $c  ) -ForegroundColor gray 
              }
              <#==  Set-ADUser -Identity $UOSUser -Surname ($UserCSVString.Surname) `
											-Department ($UserCSVString.DepName) `
											-Title ($UserCSVString.TitleName) `
											-replace @{	GivenName=$UserCSVString.FirstSecondName;`
														DisplayName=$UOSUser.Name;`
														DisplayNamePrintable=($UserCSVString.DepIndex+' '+$UserCSVString.FullDepName);`
														DepartmentNumber=$UserCSVString.DepCode;`
														Description=($UserCSVString.Surname+' '+$UserCSVString.FirstSecondName)
														}
              ==#>  
              #прописуємо квоти, якщо реквізит pager не заповнено (def.quota 10737418240 bytes)
              if (!$UOSUser.pager) {Set-ADUser -Identity $UOSUser -replace @{pager='10737418240'}}

              #$a=$UOSUser.name
              #("refresh data for $a" )|Out-File $LogsFile -Append

              $UsersUpdated++
        }
        # додаємо Київ до реквізиту Office, формат Київ №буд-№офісу
        if (!$UOSUser.Office -or ($UOSUser.Office[0] -match "[1-9]"))  {
            #Write-Host $UOSUser.Office
            #== Set-ADUser -Identity $UOSUser -Office ("Київ "+$UOSUser.Office)
        } 
    } 
} 

# переміщення деактивованих користувачыв до zUOT
foreach ($UOSUser in $AllUOSUsers) { 
    if (!$UOSUser.Enabled)      {
        #==  Move-ADObject -Identity $UOSUser -TargetPath $QuitDomainOU
        Write-Host ("Користувача",$UOSUser.Name,"перенесено в zOUT")
    }
}

Write-Host "Оброблено $UsersUpdated користувачів"
( "Оброблено $UsersUpdated користувачів")|Out-File $LogsFile -Append
Write-Host "Деактивовано $UsersDeactivates користувачів" -ForegroundColor Red
("Деактивовано $UsersDeactivates користувачів")|Out-File $LogsFile -Append