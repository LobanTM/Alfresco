#$RootDomainOU = 'ou=Test,ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
$RootDomainOU = 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
$zOUTDomainOU = 'ou=zOUT,dc=ad,dc=uos,dc=ua'
   
$OUBoss = "ou=Boss,ou="+"Test"+","+ $RootDomainOU 
$OUOld = "ou=zOldGroup,ou="+"Test"+","+ $RootDomainOU

$CSVpath="C:\Users\dmsadmin1\scripts\data\"
$DepCSVFile="ad_dep.csv"
$UserCSVFile="ad_user.csv"

$LogsFile = "C:\Users\dmsadmin1\scripts\result\logsRefreshGroup.txt"

#преобразование файла в unicode
$UniDepCSVFile="uni_"+$DepCSVFile
Get-Content ($CSVpath+$DepCSVFile) | Out-File ($CSVpath+$UniDepCSVFile) -Encoding "Unicode"
#разбор csv файла
#заголовки
$headerDep = "DepIndex","ActiveFlag","DepCode","DepName","DepFullName","Manager","DepParentCode","DepBossNumber"
#считывание данных в массив по указанным заголовкам
$DepCSV = Import-CSV ($CSVpath+$UniDepCSVFile) -header $headerDep -delimiter ";"
#==============================

#преобразование файла в unicode
$UniUserCSVFile="uni_"+$UserCSVFile
#получение содержимого файла
Get-Content ($CSVpath+$UserCSVFile) | Out-File ($CSVpath+$UniUserCSVFile) -Encoding "Unicode"

#разбор csv файла
#заголовки
$headerUser = "ActiveFlag","TabCode","Surname","FirstName","SecName","FirstSecondName","DepCode","DepIndex","DepName","FullDepName","Manager","TitleCode","TitleName"
#считывание данных в массив по указанным заголовкам
$UserCSV = Import-CSV ($CSVpath+$UniUserCSVFile) -header $headerUser -delimiter ";"

#====================================
#считывание данных из АД
$AllUOSOU=Get-ADOrganizationalUnit -filter * -SearchBase $RootDomainOU -Properties *
$AllUsers=Get-ADUser -filter * -SearchBase $RootDomainOU -Properties *
$AllGroups=Get-ADGroup -filter {(cn -like "dms-*")} -SearchBase $RootDomainOU -Properties *
$AllMailGroup = Get-ADGroup -filter {(cn -like "mail-*")} -SearchBase $RootDomainOU -Properties *
$AllBossGroup = Get-ADGroup -filter {(cn -like "dms-boss*")} -SearchBase $RootDomainOU -Properties *

$AllzOUTUsers=Get-ADUser -filter * -SearchBase $zOUTDomainOU -Properties *

#==================================================================
Write-Host("{0:dd} {0:MMMM} {0:yyyy} {0:T}" -f (Get-Date)) -ForegroundColor Blue
#("{0:dd} {0:MMMM} {0:yyyy} {0:T}" -f (Get-Date))|Out-File $LogsFile -Append
#$menuString = "1 - Refresh group, 2 - check group, 3 - Boss groups"
#$menu = Read-Host($menuString)
#$menu|out-File $LogsFile -Append

#read OU
#create group for OU
foreach($ou in $AllUOSOU|where{$_.wWWHomePage}){
    $color = "white"
   
    
    #if ($ou.Description){
        #$group1C = $DepCSV|where{($_.DepIndex+" "+$_.DepName) -eq $ou.Description}
        $group1C = $DepCSV|where{$_.DepCode -eq $ou.wWWHomePage}
             #if ($group1C){
                  # Set-ADOrganizationalUnit -Identity $ou `
			      #				 -Description ($group1C.DepIndex+' '+$group1C.DepName)`
			      #				 -replace @{DisplayNamePrintable=($group1C.DepIndex+' '+$group1C.DepFullName);`
			      #							extensionName=$group1C.DepIndex}
             #}

        $message =""
        if(!$group1C){
            $color = "red"
            $message = "group is not 1C"
        }
    #}
    
    $a=$ou.name
    $groupAD = $AllGroups|where{$_.name -eq "dms-$a"}
    if (!$groupAD){
        $color = "magenta"  
        #create group dms
        #if ("dms-$a" -eq "dms-SubSubTest"){
               # Write-Host("dms-$a","|",$ou)-ForegroundColor Yellow
            try{
                New-ADGroup "dms-$a" -Path $ou -GroupScope Global
            }
            catch{}                   
         #}
        # Write-Host("dms-$a","|",$ou)-ForegroundColor $color                    
    }
    $groupAD = $AllGroups|where{$_.name -eq "dms-$a"}
    if($groupAD){
        
    }
#===    Write-Host($ou.wWWhomePage," ",$ou.name,"   --->   ",$groupAD.Name," ",$message)-ForegroundColor $color -NoNewline

    if($groupAD){
        if($groupAD.wWWHomePage -ne $ou.wWWHomePage){         
            Set-ADGroup -Identity $groupAD `
			    				-replace @{	#Description=($DepCSVString.DepIndex+' '+$DepCSVString.DepName);`
				    						#DisplayNamePrintable=($DepCSVString.DepIndex+' '+$DepCSVString.DepFullName);`
					    					#extensionName=$DepCSVString.DepIndex;`
                                            wWWHomePage=$ou.wWWHomePage}
         }
        $b = $groupAD.DistinguishedName.Substring($groupAD.DistinguishedName.IndexOf(",")+1)
        #Write-Host $b
        if($ou.DistinguishedName -ne $b){
#====            Write-Host ("        ", $b) -ForegroundColor Gray
        }else{
#====            write-host ("")
            }
    }

    
    
}

#$a=@{Expression={$_.DistinguishedName.split(",")[0]}; label = "dn"}
#$AllGroups|
#         where{$_.wWWHomePage}|# -eq "39"}|
#         ft wWWHomePage,name, description, info  -AutoSize #|
#         #ForEach-Object -Process{} 
#$a=@{Expression={$AllUsers|where{$_.tabcode -eq }}; label = "boss"}
$DepCSV |
        sort DepIndex |
        #where{}|
        Select-Object DepCode, DepName,DepBossNumber |
        #ft DepCode, DepName |
        ForEach-Object -Process{
            $a = $_.DepBossNumber
            $owner = $UserCSV|where {$_.TabCode -eq $a} #-f $owner
            "{0} `t {1} `t {2}" -f 
            $_.DepCode, $_.DepName, $owner.surname
           #$owner.surname
        }