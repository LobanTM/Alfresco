# Скрипт для внесения данных из 1С в АД для груп пользователей по номеру группьі из 1С(индексное поле)
#

# считьівание данньіх 1С из файла "ad_dep.csv", по пути "D:\IT\admins\olegyu\"
# основной домен 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
#			тестовьый домен 'ou=Test,ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
#			
#
#$DepCSV - массив данных из 1С
#$AllUOSOU - массив данных из АД
#			
#
#			
#
#			
#
#			
#
#			
#
#			
#
#			
#
#			
#


$CSVpath="C:\Users\loban.tm\scripts\data\"
$DepCSVFile="ad_dep.csv"
#$RootDomainOU = 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
$RootDomainOU = 'ou=Test,ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'

#преобразование файла в unicode
$UniDepCSVFile="uni_"+$DepCSVFile
Get-Content ($CSVpath+$DepCSVFile) | Out-File ($CSVpath+$UniDepCSVFile) -Encoding "Unicode"

#разбор csv файла
#заголовки
$headerDep = "DepIndex","ActiveFlag","DepCode","DepName","DepFullName","Manager","DepParentCode","DepParentName"
#считывание данных в массив по указанным заголовкам
$DepCSV = Import-CSV ($CSVpath+$UniDepCSVFile) -header $headerDep -delimiter ";"

#считывание данных из АД
$AllUOSOU=Get-ADOrganizationalUnit -filter * -SearchBase $RootDomainOU -Properties *

#$GrUpdated=0
#$OUUpdated=0

# перебір груп користувачів і обробка\синхронізація CN (не можна вставляти в загальний цикл - змінює системно важливий параметр АД!)
foreach ($UOSOU in $AllUOSOU) { #0
  # if ($UOSOU.wWWHomePage) {#1 заповнено код синхронізації
  #      #Шукаємо в файлі відділ за кодом і за ознакою ActiveFlag=1 (не "папка" - саме відділ)  і актуалізуємо реквізити OU та груп
  #      $DepCSVString=$DepCSV | Where {($_.DepCode -eq $UOSOU.wWWHomePage) -and ($_.ActiveFlag -eq '1')}
  #      #2 
        
  #      if ($DepCSVString.Count -eq 0) { Write-Host ("Код  синхронізації",$UOSOU.wWWHomePage,'для OU=',$UOSOU.Name,"у файлі імпорту не знайдено") }
  #      elseif ($DepCSVString.Count -ge 2) {Write-Host ("Помилка у файлі експорту - більше 1 запису с номером групи",$UOSOU.wWWHomePage) } 
  #      else { 
  #         # знайдено унікальну відповідність, заповнюємо
  #         Set-ADOrganizationalUnit -Identity $UOSOU `
	#								-Description ($DepCSVString.DepIndex+' '+$DepCSVString.DepName)`
	#								-replace @{DisplayNamePrintable=($DepCSVString.DepIndex+' '+$DepCSVString.DepFullName);`
	#											extensionName=$DepCSVString.DepIndex}
    #       $OUUpdated++
    #       Write-Host ($DepCSVString)
    #       Write-Host ($UOSOU)
    #       # створення переліку груп (тільки один рівень)
           $AllOUGrps=Get-ADGroup -SearchBase $UOSOU -Filter {cn -like "dms-groupTest2"} -SearchScope OneLevel
           foreach ($OUGrp in $AllOUGrps) {
    #            Set-ADGroup -Identity $OUGrp `
	#						-replace @{	Description=($DepCSVString.DepIndex+' '+$DepCSVString.DepName);`
	#									DisplayNamePrintable=($DepCSVString.DepIndex+' '+$DepCSVString.DepFullName);`
	#									extensionName=$DepCSVString.DepIndex;wWWHomePage=$UOSOU.wWWHomePage}
    #            $GrUpdated++
               # Write-Host ($OUGrp.Name)
               #Set-ADGroup -Identity $OUGrp `
				#			-replace @{	DisplayNamePrintable="test group for Alfresco"`	 }
                Write-Host ("--",$OUGrp.sAMAccuontType)                       

           }
    #       Write-Host ('====================================')
    #    }        
    #}  
    ## не заповнено код синхронізації для OU
    #else {
    #    Write-Host ("Не заповнено код синхронізації для OU",$UOSOU.Name,"Заповніть вручну") -ForegroundColor Yellow
    #}   
} #foreach 
#Write-Host "Оброблено $GrUpdated груп" -ForegroundColor Green
#Write-Host "Оброблено $OUUpdated OU" -ForegroundColor Green
"{0:dd} {0:MMMM} {0:yyyy} {0:T}" -f (Get-Date) 
