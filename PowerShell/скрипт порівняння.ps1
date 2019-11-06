$RootDomainOU = 'dc=ad,dc=uos,dc=ua' #ou=Ukroboronservice,

$CSVpath="C:\Users\dmsadmin1\scripts\data\"
$aDepCSVFile="ad_ch_dep.csv"
$DepCSVFile="ad_dep.csv"
$UserCSVFile="ad_user.csv"

$LogsFile = "C:\Users\dmsadmin1\scripts\result\logs.txt"


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
write-host("       1 - повна структура з коментар€ми") -ForegroundColor Green
write-host("       2 - т≥льки р≥зниц€")-ForegroundColor Green
write-host("       3 - таблиц€ р≥зниць")-ForegroundColor Green 
$menuString = "2 "

$menu = Read-Host($menuString) #-ForegroundColor Green
if ($menu -eq ""){$menu = "2"}


write-host("  ")
#1 - повна структура з коментар€ми
#2 - т≥льки р≥зниц€
if($menu -eq "1" -or $menu -eq 2){ 
    $arrayListGroupAD = @()

    $AllGroups|
        where {$_.wWWHomePage -and ($_.wWWHomePage.Length -lt 5)}|
        forEach{ 
            
            $numberGroupAD =$_.wWWHomePage #1 
            
            $color = "darkYellow"
            if ($_.member){$color = "Yellow"} 
            
            if ($_.DistinguishedName.indexOf("zOldGroup") -gt -1){$color = "darkGray"}
            $comment = ""
            
            $a =$_.wWWHomePage
            $name = $_.cn 
            $dn = $_.DistinguishedName
            $description=$_.Description

            $group1C =$DepCSV| where{$_.DepCode -eq $a}

            if (!$group1C){
                
                $color = "darkGray"

                if($menu -eq "2"){
                Write-Host (" ", $_.wWWHomePage,"   ",$_.cn,"   (",$_.Description,") група б≥льше не ≥снуЇ, видалити з AD   ") -ForegroundColor $color
            }
                
                }
            if($menu -eq "1"){
                Write-Host (" ", $_.wWWHomePage,"   ",$description, " ",$Name) -ForegroundColor $color
            }
            
            if ($_.members){
                if($menu -eq "1"){
                    Write-Host ("      AD ____________________________________")
                }
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
                                    $comment = " видалити п≥дпор€дкуванн€"
                                    }
                        } #

                        $element = [PSCustomObject]@{NumberGroup= $numberGroupAD; AD = $numberMemberAD; g1C = $numberMember1C}
                        $arrayListGroupAD += $element
                        if($menu -eq "1"){
                            write-host("        ", $childAD.cn, " ", $childAD.wWWHomePage, " -- ", $child1C.depcode, " /-- ",$child1C.DepParentCode, " ", $comment) -foreground $color
                        }
                        if($menu -eq "2" -and $color -eq "red"){
                            Write-Host (" ", $_.wWWHomePage,"   ",$Name)-ForegroundColor yellow -NoNewline
                            Write-Host ( " (",$description,") ",$dn)-ForegroundColor Gray
                            
                            write-host("               ", $childAD.wwWHomePage," ", $childAD.cn)-ForegroundColor white -NoNewline
                            write-host( " ", $comment)-ForegroundColor $color
                            #"в на€вност≥ ",$childAD.wWWHomePage, " -- ", $child1C.depcode, " /-- ",`

                            #$nameParent=$DepCSV| where{$_.DepCode -eq $child1C.DepParentCode}

                            #write-host("                     ", "(треба перепор€дкувати ",$child1C.DepParentCode, " ",`
                            #$nameParent.DepIndex," ",$nameParent.DepName," )")-ForegroundColor Gray 
                            #Write-Host ("       ____________________________________")-ForegroundColor Blue
                        }
                    }
                    #$child1C = $DepCSV| where{$_.DepCode -eq $a}                  
                }                
            } 
            
            if($group1C){
                if($menu -eq "1"){
                    Write-Host ("      1C ____________________________________")
                }
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
                                        $comment = "п≥дрозд≥л в двох (або б≥льше) групах одночасно"
                                        $MemberOf=""
                                        foreach($m in $childAD.memberOf.split(" ") ){
                                            if($menu -eq "1"){
                                                write-host ("                              ",$m.split(",")[0].substring(3))-ForegroundColor Cyan
                                            }
                                            if($menu -eq "2"){
                                                $MemberOf+="                            | "+$m.split(",")[0].substring(3)+"`n"
                                            }
                                        }
                                    }
                                 }
                                
                                if($name.indexof($childAD.memberOf) -gt -1){
                                    $color = "magenta"
                                    #Write-Host ("                   ", $childAD.memberOf,"   ",$name) -ForegroundColor $color 
                                    $comment = "додати п≥дпор€дкуванн€ (в≥дсунтЇ в AD)"    
                                    }
                               }else{
                                 $element = [PSCustomObject]@{NumberGroup= $numberGroupAD; AD = $numberMemberAD; g1C = $numberMember1C}
                                $arrayListGroupAD += $element   
                                }   
                            if($menu -eq "1"){               
                                Write-Host ("        ", $_.DepCode," ",$childAD.cn, " " ,$_.DepParentCode," ", $comment)-ForegroundColor $color                         
                            }
                            if($menu -eq "2" -and ($color -eq "magenta" -or $color -eq "cyan")){
                                Write-Host (" ", $numberGroupAD,"   ",$Name)-ForegroundColor yellow -NoNewline
                                Write-Host ( " (",$description,") ", $dn) -ForegroundColor gray
                                                                
                                Write-Host ("               ", $_.DepCode," ",$childAD.cn)-ForegroundColor white -NoNewline
                                Write-Host ( " (" ,$_.DepParentCode,") ", $comment)-ForegroundColor $color 
                                if($color -eq "cyan"){
                                    write-host ($MemberOf)-ForegroundColor $color
                                }
                            }
                        }
                    }
                #memberOf


            }

        }

    #$arrayListGroupAD|ft -a    
}

#3 - таблиц€ р≥зниць
if($menu -eq "3"){
    $arrayListGroup = @()
    foreach($groupAD in $AllGroups|where{$_.wWWHomePage -and ($_.wWWHomePage.Length -lt 5) }){#
        
        $flag="G"
        $NumberGroupAD=$groupAD.wWWHomePage
        $numberGroup1C=""
        $memberAD="-"
        $member1C="-"
        $comment=""

        $group1C = $DepCSV|where{$_.DepCode -eq $groupAD.wWWHomePage}

        if($group1C){$numberGroup1C=$group1C.DepCode  
            }else{$comment="not 1C ("+$groupAD.Description+")"
                    $element = [PSCustomObject]@{Flag=$flag;NumberGroupAD=$NumberGroupAD; NumberGroup1C=$numberGroup1C; memberAD = $memberAD; member1C = $member1C;comment=$comment}
                    $arrayListGroup += $element
                    }
        
        #members
        if($groupAD.Members){
            $flag="M"
            foreach ($mAD in $groupAD.Members){
                #if(!$mAD.split(",")[0].substring(3)-eq""){
                    $memberGroupAD = $AllGroups|where{($_.cn  -eq $mAD.split(",")[0].substring(3)-and ($_.wWWHomePage.Length -lt 5))}
                    if ($memberGroupAD){

                        $memberAD = $memberGroupAD.wWWHomePage #+"/"+$memberGroupAD.cn
                        $numberGroup1C=""
                        $group1C = $DepCSV|where{$_.DepCode -eq $groupAD.wWWHomePage}
                         if($group1C){$numberGroup1C=$group1C.DepCode  
                            }else{$comment=$groupAD.wWWHomePage+" not 1C ("+$groupAD.Description+")" 

                            }
                        #search group in 1C
                        $member1C="-"
                        $memberGroup1C = $DepCSV|where{$_.DepCode -eq $memberGroupAD.wWWHomePage}
                        if($memberGroup1C){
                            $member1C=$memberGroup1C.DepCode
                            #Write-Host $memberAD+"/"+$member1C
                        }else{
                            $comment = "$memberAD is not 1C ("+$memberGroupAD.Description+")"
                        }

                        if($group1C -and $memberGroup1C -and ($memberGroup1C.DepParentCode -ne $group1C.DepCode)){
                             $comment = "link is not 1C ("+$group1C.DepName+"-"+$memberGroup1C.DepName+")"
                        }

                        $element = [PSCustomObject]@{Flag=$flag;NumberGroupAD=$NumberGroupAD; NumberGroup1C=$numberGroup1C; memberAD = $memberAD; member1C = $member1C;comment=$comment}
                        $arrayListGroup += $element
                        
                    }

                #}
            }
        }
        

        #$element = [PSCustomObject]@{Flag=$flag;NumberGroupAD=$groupAD.wWWHomePage; NumberGroup1C=$numberGroup1C; memberAD = $memberAD; member1C = $member1C;comment=$comment}
        #$arrayListGroup += $element
        


        
    }
    foreach($group1C in $DepCSV){

        $flag="G"
        $NumberGroupAD=""
        $numberGroup1C=""
        $memberAD="-"
        $member1C="-"
        $comment=""

        $groupAD = $AllGroups|where{$_.wWWHomePage-eq $group1C.DepCode}
        if($groupAD){$NumberGroupAD=$groupAD.wWWHomePage  
            }else{$comment="not AD ("+$group1C.DepName+")"
                    $element = [PSCustomObject]@{Flag=$flag;NumberGroupAD=$NumberGroupAD; NumberGroup1C=$group1C.DepCode; memberAD = $memberAD; member1C = $member1C;comment=$comment}
                    $arrayListGroup += $element
                    }
    }


    $arrayListGroup|where {$_.flag -eq "G"}|ft NumberGroupAD,NumberGroup1C,comment -a
    $arrayListGroup|
        where {$_.flag -eq "M" -and $_.comment -ne ""}|
        ft NumberGroupAD, memberAD,comment   -a
}
