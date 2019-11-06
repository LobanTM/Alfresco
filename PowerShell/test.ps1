$RootDomainOU = 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua' #

$CSVpath="C:\Users\dmsadmin1\scripts\data\"
$aDepCSVFile="ad_ch_dep.csv"
$DepCSVFile="ad_dep.csv"
$UserCSVFile="ad_user.csv"

$LogsFile = "C:\Users\dmsadmin1\scripts\result\logs.txt"
$LogsBossFile = "C:\Users\dmsadmin1\scripts\result\boss.txt"


#преобразование файла в unicode
$aUniDepCSVFile="uni_"+$aDepCSVFile
Get-Content ($CSVpath+$aDepCSVFile) | Out-File ($CSVpath+$aUniDepCSVFile) -Encoding "Unicode"
#разбор csv файла
#заголовки
$headerDep = "Surname","Info"
#считывание данных в массив по указанным заголовкам
$aDepCSV = Import-CSV ($CSVpath+$aUniDepCSVFile) -header $headerDep -delimiter ";"

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

$AllUOSOU=Get-ADOrganizationalUnit -filter * -SearchBase $RootDomainOU -Properties * -SearchScope OneLevel

$AllUsers=Get-ADUser -filter * -SearchBase $RootDomainOU -Properties *
$AllGroups=Get-ADGroup -filter {(cn -like "dms-*")} -SearchBase $RootDomainOU -Properties *
$AllMailGroup = Get-ADGroup -filter {(cn -like "mail-*")} -SearchBase $RootDomainOU -Properties *
$AllBossGroup = Get-ADGroup -filter {(cn -like "dms-boss*")} -SearchBase $RootDomainOU -Properties *


#====================================================================
("{0:dd} {0:MMMM} {0:yyyy} {0:T}" -f (Get-Date))|Out-File $LogsFile -Append

Write-Host("========== date last logOn") -ForegroundColor Green

foreach ($a in $aDepCSV){
   # Write-Host ($a.Surname, " ", $a.Info.Split("(")[0])
   
}
<#
foreach($a in $AllUsers ){
        $color = "white"

    $t= (Get-Date -Date "15/10/2019 00:00:00 AM").ToFileTime()

                        #132128281155478002 = 13.09.2019
    if($a.lastLogon -lt $t){$color = "darkgray"}
    if($a.lastLogon -eq 0){$color = "darkred"}

    if($a.lastLogon -gt $((Get-Date).AddDays(-1).tofileTimeUTC()) ){$color = "yellow"}


   Write-Host($a.name," ",[DateTime]::FromFileTime($a.lastLogon)," /", $a.logonCount,"               ", $a.whenCreated) -ForegroundColor $color   
}
#>


$c=@{Expression = {[DateTime]::FromFileTime($_.LastLogon)}; label="last"}
$a = $AllUsers|
    where {$_.lastLogon -gt $((Get-Date).AddDays(-1).tofileTimeUTC())}|
    Sort lastLogon -Descending|
    FT name , $c -AutoSize
#write-host ($a)

#$a|Out-File $LogsFile -Append

 
    $AllUsers|
    where {$_.lastLogon -gt $((Get-Date).AddDays(-1).tofileTimeUTC())}|
    Sort lastLogon -Descending|
    FT name , $c -AutoSize
#>


Write-Host("=======   created today   ============") -ForegroundColor Green 
foreach($a in $AllUsers){
        $color = "white"

    $t= [datetime]::"30/09/2019 00:00:00 AM"                        
    

    if($a.whenCreated -gt $((Get-Date).AddDays(-1)) ){
            $color = "yellow"
                Write-Host($a.name," ", $a.whenCreated) 
            } 
  
}

Write-Host("=======   boss Dep   ============") -ForegroundColor Green
#Out-File $LogsBossFile 
<#
foreach ($group1C in $DepCSV|where {`
                                    #$_.ActiveFlag -like "*Д" -or`
                                     $_.ActiveFlag -like "*В" } ){  #

    $bossNumber = 

    $boss = $UserCSV|where {$_.TabCode -eq $group1C.DepBossNumber }
    Write-Host ($group1C.DepCode, " ------ ", $group1C.DepName, " ------ ", $group1C.DepBossNumber) -ForegroundColor Yellow
    #("       ",  $group1C.DepName)|Out-File $LogsBossFile -Append
    $color= "white"
    if ($boss.activeflag -eq "-"){$color = "darkgray"}
    Write-Host ("       ",$boss.SurName, $boss.FirstSecondName) -ForegroundColor $color
    
    $a = "   "+$boss.SurName+" "+$boss.FirstSecondName
        
    #( $boss.DepName, $a," ")|Out-File $LogsBossFile -Append
    #(" ")|Out-File $LogsBossFile -Append
}
#>

<#
foreach($uAD in $AllUsers){
    $u1C = $UserCSV|where{$_.tabcode -eq $uAD.wWWHomePage}

}
#>

<#
$name = "Лобань Т.М."#
$name = Read-Host("Name of user")
$name=$name.split(" ")[0]
$UserAD = $AllUsers|where{$_.cn -like "$name*"}

if($UserAD){
    Write-Host("=======    AD    ========")-ForegroundColor Yellow
    foreach($u in $UserAD){
        write-host ($u.wWWHomePage,$u.cn," ",$u.Department,"(",$u.departmentNumber,")")
        if($u.MemberOf){
            foreach($m in $u.MemberOf){
                
                $memberGroupAD = $AllGroups|where{$_.cn -eq $m.split(",")[0].substring(3) }
                if ($memberGroupAD){
                    $color = "gray"
                    if($memberGroupAD.wWWHomePage -ne $u.departmentNumber){#$color = "gray"}
                        write-host ("                ",$memberGroupAD.description,"(",$memberGroupAD.wWWHomePage,")")-ForegroundColor   $color
                    }
                }
            }
        }
        
    }
}else{write-host ("user ",$name," is not AD")-ForegroundColor Cyan}

$User1C = $UserCSV|where{$_.SurName -like "$name*"}

if($User1C){
    Write-Host("=======    1C    ========")-ForegroundColor Yellow
    foreach($u in $User1C){
        write-host ($u.TabCode,$u.Surname," ",$u.FirstSecondName," ",$u.DepName," (",$u.DepCode,")")
    }
}else{write-host ("user $name is not 1C")-ForegroundColor Cyan}
#>


<#
#===================================================================================
foreach($a in $AllUsers| where {($_.distinguishedName -like "*UO*")}){
    #write-host(" -- ",$a )
}

foreach ($groupAD in $AllGroups|where {!$_.MemberOf} ){  #
    #Write-Host ($groupAD.wWWHomePage, " ------ ", $groupAD.DistinguishedName) -ForegroundColor Cyan
}

$a = @{Expression = {$_.DistinguishedName.split(",")[0].substring(3)}; label="dn"}
#$AllGroups|where {!$_.MemberOf}|sort extensionName |ft wWWHomePage, $a, DisplayNamePrintable -AutoSize 

$array = @()
$DepCSV|
        #where {($_.DepParentCode -eq "")-or($_.DepParentCode -eq $_.DepCode)}|
        where{($_.DepParentCode -ne "")-and($_.DepParentCode -ne $_.DepCode)}|
        forEach {
            #Write-Host ("--- ", $_.DepCode)
            $a =$_.DepCode        
            $listChild =@()
            $DepCSV|
                where{($_.DepParentCode -eq $a)-and($_.DepParentCode -ne $_.DepCode)}|
                forEach{
                    #$listChild += [PSCustomObject]@{ Number = ($_.DepCode)}#;Name = ($_.DepName)}
                    $listChild += $_.DepCode
                }
            $array += [PSCustomObject]@{Index= $_.DepIndex; Number = ($_.DepCode);Name = ($_.DepName); Child = $listChild}
        } 
#$array.GetEnumerator()|sort index | ft -a

$AllGroups|
        #where {}|
        forEach{
            $a =$_.wWWHomePage 
        #    Write-Host ("---> ", $_.wWWHomePage,"   ",$_.displayNamePrintable)
            #$member = $_.members
            #Write-Host ("         ",$member ) -foreground DarkGray #,"   ",$_.displayNamePrintable)
            if ($_.members){
                foreach($m in $_.members.split("`n")){
        #            write-host("       ", $m) -foreground DarkGray
                }
            }      
            $group1C =$DepCSV| where{$_.DepCode -eq $a}
            if($group1C){
                # Write-Host ("      member: ", $_.DepParentCode)
                $DepCSV|
                    #where{($_.DepParentCode -eq $a)-and($_.DepParentCode -ne $_.DepCode)}|
                    forEach{
                        #Write-Host ("      member: ", $_.DepCode,"   ",$_.DepFullName)

                    }
            }
        }
$arrayListGroupAD = @()

$AllGroups|
        where {$_.wWWHomePage}|
        forEach{ 
            
            $numberGroupAD =$_.wWWHomePage #1 
            
            $color = "darkYellow"
            if ($_.member){$color = "Yellow"} 
            
            if ($_.DistinguishedName.indexOf("zOldGroup") -gt -1){$color = "darkGray"}
            $comment = ""
            $a =$_.wWWHomePage
            $name = $_.cn 
            $dn = $_.DistinguishedName
            $group1C =$DepCSV| where{$_.DepCode -eq $a}
            if (!$group1C){$color = "darkGray"}

            Write-Host (" ", $_.wWWHomePage,"   ",$_.description, " ",$Name) -ForegroundColor $color
            
            if ($_.members){
                Write-Host ("      AD ____________________________________")
                foreach($m in $_.members.split("`n")){
                    #write-host("       ", $m) -foreground DarkGray
                    $comment = ""
                    $b = $m.split(",")[0].substring(3)
                    $childAD =$AllGroups|where {$_.cn -eq $b} 
                    if ($childAD){
                        
                        $numberMemberAD = $childAD.wWWHomePage #2
                        $numberMember1C = 0                    #3

                        $child1C = $DepCSV| where{$_.DepCode -eq $childAD.wWWHomePage} # -and $_.DepParentCode -eq $group1C.DepCode}
                        $color = "darkGray"
                        if($child1C) {
                            if ($child1C.DepParentCode -eq $a){ 
                                $color = "white"
                                $numberMember1C = $child1C.depcode  #3
                                }else{
                                    #delete member
                                    #Remove-ADGroupMember -Identity $name -Members $childAD
                                    $color = "red"
                                    $comment = " видалити підпорядкування"
                                    }
                        } #

                        $element = [PSCustomObject]@{NumberGroup= $numberGroupAD; AD = $numberMemberAD; g1C = $numberMember1C}
                        $arrayListGroupAD += $element
                        write-host("          ", $childAD.cn, " ", $childAD.wWWHomePage, " -- ", $child1C.depcode, " /-- ",$child1C.DepParentCode, " ", $comment) -foreground $color
                    }
                    #$child1C = $DepCSV| where{$_.DepCode -eq $a}                  
                }                
            } 
            
            if($group1C){
                Write-Host ("      1C ____________________________________")
                $comment = ""
                $color = "magenta"
                if ($_.wWWHomePage -eq $group1C.DepCode) {$color = "white"}                 
                #Write-Host ("      ", $_.wWWHomePage,"   ",$group1C.DepCode)-ForegroundColor $color

                $color = "magenta"                
                if ($_.description -eq $group1C.DepIndex+" "+$group1C.DepName) {$color = "white"}                 
                #Write-Host ("      ", $_.description,"   ",$group1C.DepIndex+" "+$group1C.DepName)-ForegroundColor $color

                $color = "magenta"                
                if ($_.displayNamePrintable -eq $group1C.DepIndex+" "+$group1C.DepFullName) {$color = "white"}                 
                #Write-Host ("      ", $_.displayNamePrintable,"   ",$group1C.DepIndex+" "+$group1C.DepFullName)-ForegroundColor $color

                #member
                $DepCSV|
                    where{($_.DepParentCode -eq $a)-and($_.DepParentCode -ne $_.DepCode)}|
                    forEach{
                        #Write-Host ("      member: ", $_.DepCode,"   ",$_.DepFullName)
                        $comment = ""
                        $numberMember1C = $_.DepCode         #3
                        $numberMemberAD = 0                  #2

                        $b = $_.DepCode 
                        $childAD = $AllGroups|where {$_.wWWHomePage -eq $b}
                        if($childAD){
                            
                            $numberMemberAD = $childAD.wWWHomePage #2

                            #memberof 
                            #Write-Host ($childAD.memberOf) -ForegroundColor Green

                            $color = "darkGray"
                            if ($_.DepCode -eq $childAD.wWWHomePage) {
                                $color = "white"

                                if($childAD.memberOf){
                                    if($childAD.memberOf.split(" ").count -gt 1){
                                        $color = "cyan"
                                        $comment = "підрозділ в двох (або більше) групах одночасно"
                                        foreach($m in $childAD.memberOf.split(" ") ){
                                            write-host ($m)-ForegroundColor Cyan
                                        }
                                    }
                                 }
                                
                                if($name.indexof($childAD.memberOf) -gt -1){
                                    $color = "magenta"
                                    #Write-Host ("                   ", $childAD.memberOf,"   ",$name) -ForegroundColor $color 
                                    $comment = "підпорядкування відсунтє в AD"    
                                    }
                               }else{
                                 $element = [PSCustomObject]@{NumberGroup= $numberGroupAD; AD = $numberMemberAD; g1C = $numberMember1C}
                                $arrayListGroupAD += $element   
                                }              
                            Write-Host ("                   ", $_.DepCode,"   ",$childAD.cn, " " ,$_.DepParentCode," ", $comment)-ForegroundColor $color                         
                            
                        }
                    }
                #memberOf


            }

        }

#$arrayListGroupAD|ft -a
#>

#[DateTime]::ParseExact("07/05/2015", "MM/dd/yyyy", $null)
#[DateTime]"07/05/2015"
#'{0:MM/dd/yy}' -f (Get-Date)

#$la  = 132130968062752232 132128281155478002
#[Management.ManagementDateTimeConverter]::ToDateTime($la)
#([WMI] '').ConvertToDateTime($la)
#[DateTime]::FromFileTime($la)

#(Get-Date).AddDays(-90).ToFileTimeUTC()

write-host("{0:dd} {0:MMMM} {0:yyyy} {0:T}" -f (Get-Date)) -ForegroundColor DarkGray 

#$t= (Get-Date -Date "13/09/2019 00:00:00 AM").ToFileTime()
#Write-Host ($t) -ForegroundColor Blue
#$la  = 132139616234796705
#$t= [DateTime]::FromFileTime($la) 
#Write-Host ($t) -ForegroundColor Blue
