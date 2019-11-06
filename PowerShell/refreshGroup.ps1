
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
("{0:dd} {0:MMMM} {0:yyyy} {0:T}" -f (Get-Date))|Out-File $LogsFile -Append
$menuString = "1 - Refresh group, 2 - check group, 3 - check users (AD), 4 - check users (AD+1C), 5 - Boss groups"
$menu = Read-Host($menuString)
$menu|out-File $LogsFile -Append

if($menu -eq "1"){
    "Refresh group"|out-File $LogsFile -Append

    #=======   GROUPS   ==================
    Write-Host ("refresh data for group") -ForegroundColor Green
    foreach ($groupAD in $AllGroups ){
    
        $GCSV = $DepCSV | where {$_.DepCode -eq $groupAD.wWWHomePage}
        if ($GCSV){ #---- група з AD є в 1С
            Write-Host ($groupAD.wWWHomePage, " ------ ", $GCSV.DepName) -ForegroundColor Cyan
            #--- curator
            $a=$GCSV.Manager
            if($a.Length -eq 2){$a = "00"+$a}
            if($a.Length -eq 3){$a = "0"+$a}
            $a = "*"+$a
            $Manager = $UserCSV | where {$_.TabCode -like $a}
            #Write-Host ($GCSV.Manager, " ------ ", $Manager.Surname) -ForegroundColor Magenta

            Set-ADGroup -Identity $groupAD `
							-replace @{	Description=($GCSV.DepIndex+' '+$GCSV.DepName);`
										DisplayNamePrintable=($GCSV.DepIndex+' '+$GCSV.DepFullName);`
										extensionName=$GCSV.DepIndex;` 
                                        info=$Manager.TabCode+" "+$Manager.Surname}

            
            #==== group BOSS
            if (($GCSV.ActiveFlag-like "*Д") -or ($GCSV.ActiveFlag -like "*В")){
                #створити групу начальника, якщо її немає серед members        
                $typeBoss = "Dep"
                Switch($GCSV.ActiveFlag){
                    "Д" {$typeBoss = "Dep"}
                    "В" {$typeBoss = "Vid"}
                    "КД" {$typeBoss = "CoD"}
                    "КВ" {$typeBoss = "CoV"}
                }        
                $nameBossGroup = "dms-boss" + $typeBoss +"-"+ $groupAD.SamAccountName.substring(4)

                #$OUBoss = "ou="+ $groupAD.SamAccountName.substring(4)+","+ $RootDomainOU
                
                $GroupBoss = $AllBossGroup | where {$_.sAMAccountName -eq $nameBossGroup}
                 #Write-Host ($GroupBoss.DistinguishedName, " ------ ") -ForegroundColor Magenta
                if (!$GroupBoss){
                    #create group
                    try{
   # !!!!!!
                        New-ADGroup $nameBossGroup -Path $OUBoss -GroupScope Global
                        ("create group ", $nameBossGroup)|out-file $LogsFile -Append 
                    }
                    catch{
                        # Write-Host ("gorup don't exist") -ErrorAction Continue -ForegroundColor Red
                    }
                }

                $AllBossGroup = Get-ADGroup -filter {(cn -like "dms-boss*")} -SearchBase $RootDomainOU -Properties *
                $GroupBoss = $AllBossGroup | where {$_.sAMAccountName -eq $nameBossGroup}
                if ($GroupBoss){
                    Write-Host ("                   ",$GroupBoss.SamaccountName ) -ForegroundColor Yellow

                    $a = $groupAD.wWWHomePage
                    if ($a.Length -eq 4){$a = "2"+$a}
                    if ($a.Length -eq 3){$a = "20"+$a}
                    if ($a.Length -eq 2){$a = "200"+$a}

                    Set-ADGroup -Identity $GroupBoss -Replace @{Description="начальник "+$groupAD.Description;`
                                                            DisplayNamePrintable=$groupAD.DisplayNamePrintable;`
										                    extensionName=$groupAD.wWWHomePage;` 
                                                            wWWHomePage=$a 
                                                            }
                    #add members to groupBoss
                    # number of boss $GCSV.DepBossNumber
                    $a = $GCSV.DepBossNumber
                    #if ($GCsv.DepBossNumber.Length -eq 2){$a = "000000"+$GCSV.DepBossNumber}
                    #if ($GCsv.DepBossNumber.Length -eq 3){$a = "00000"+$GCSV.DepBossNumber}  

                    if ($GCSV.DepBossNumber -ne ""){
                        $uAD = $AllUsers | where {($_.wWWHomePage -eq $a)} 

                        #Write-Host ("                   ",$uAD.wWWHomePage," == ",$a)

                        $u1C = $UserCSV  | where {($_.TabCode -like $a)} 

                        if (!$uAD){
                            if ($u1C -and ($u1C.ActiveFlag -eq "+")){
                                Write-Host ("                   ","boss(1C):  ", $u1C.Surname ,"| немає в АД") -Foreground DarkGray
                            }else{                                                        
                                Write-Host ("                   ","group hasn't got boss") -Foreground DarkGray}                            
                        }
                        $ok = 0
                        if ($uAD){
                            Write-Host ("                   ","boss --> ", $uAD.Description,"|",$u1C.Surname ) -ForegroundColor Magenta
                            foreach ($M in $groupAD.Members){
                                if ($uAD.DisplayName -eq $M.split(",")[0].substring(3)) {
                                    Write-Host ("                   ",$M.split(",")[0].substring(3)) -ForegroundColor DarkGray
                                    #===== remove $uAD member  from $groupAD
                                    try{
            # !!!!!!
                                        Remove-ADGroupMember -Identity $groupAD -Members $uAD
                                        Write-Host ("                               remove", $uAD.DisplayName ,"from ",$groupAD.SamAccountName)
                                    }
                                    catch{
                                        Write-Host ("                               користувача не було видалено з групи", $groupAD.SamAccountName)
                                        #Write-host $Error[0].Exception
                                    }
                                }                           
                                #Write-Host ("                   ",$M.split(",")[0].substring(3)) -ForegroundColor Cyan
                            }

                            foreach ($M in $GroupBoss.Members){
                                if ($uAD.DisplayName -eq $M.split(",")[0].substring(3)) {$ok = 1
                                    # Write-Host ("                   ",$M.split(",")[0].substring(3)) -ForegroundColor DarkGray 
                                }                            
                            }
                            if ($ok -eq 0){
                                try{
            # !!!!!!
                                    Add-ADGroupMember -Identity $GroupBoss -Members $uAD
                                    ("user ", $uAD, " added at group ", $GroupBoss)|out-file $LogsFile -Append 
                                }
                                catch{
                                    Write-Host ("                               користувача не було додано до групи", $GroupBoss.SamAccountName)
                                    #Write-host $Error[0].Exception
                                }
                            }
                        } #if ($uAD){
                    }

                    #add memberOf to groupAD
                    $ok = 0
                    foreach ($M in $GroupBoss.MemberOf){
                        if ($groupAD.cn -eq $M.split(",")[0].substring(3)){$ok=1
                            #Write-Host ("            ",$M.split(",")[0].substring(3)) -ForegroundColor DarkGray                    
                        }
                    }
                    if($ok -eq 0){
                        try{
                            Add-ADGroupMember -Identity $groupAD -Members $GroupBoss
                            ("group ", $uAD, " added at group ", $GroupBoss)|out-file $LogsFile -Append 
                        }catch{
                            Write-Host ("                      групу", $GroupBoss.cn ,"не було додано до групи", $groupAD.cn)
                        }
                    }

                }
            }                                     
            #==== add users-members
            #=======  внести members в групу
            #$Users1C = $UserCSV | Where {$_.DepCode -eq $groupAD.wWWHomePage} 
            $AllUsers=Get-ADUser -filter * -SearchBase $RootDomainOU -Properties *
            $UsersAD = $AllUsers  | Where {$_.DepartmentNumber -eq $groupAD.wWWHomePage}
             
            if ($UsersAD){
                #write-host("                      ",$groupAD.SamAccountName) -ForegroundColor DarkYellow        
                foreach ($MAD in $UsersAD){           
                    #search userAD (in group $groupAD) in 1C (in group $GCSV)
                    $M1C = $UserCSV | Where {$_.TabCode -eq $MAD.wWWHomePage}
                    if ($M1C){
                        #userAD is 1C --> OK
                        #проверка: входит ли пользователь уже в ету группу                       
                        $color = "White"
                        foreach($memOf in $MAD.MemberOf){                           
                            if ($memOf.split(",")[0].substring(3) -eq $groupAD.SamAccountName){$color = "DarkGray"}                          
                        }
                        #write-host("                       ", $MAD.wWWHomePage, "|", $MAD.Description , " |", $M1C.Surname, "| ") -ForegroundColor $color
                        if ($color -eq "White") {
                            
                            #--- boss                           
                            $ok=0
                            foreach ($d in $DepCSV | where {$_.DepBossNumber -ne ""}){                                
                                $a=$d.DepBossNumber                                
                                if ($MAD.wWWHomePage -eq $a){
                                    $ok=1
                                    $dep = $d
                                    ##write-host ($dep,"   ---   ", $a)
                                    $color = "DarkGray"
                                }
                            }
                                                        
                            if ($ok -eq 0){                                
                                #write-host("                       ", $MAD.Description , " |", $M1C.Surname, "| ") -ForegroundColor $color
                                ## add user to group
                                try{
            # !!!!!!
                                     Add-ADGroupMember -Identity $groupAD -Members $MAD
                                     ("user ", $MAD, " added at group ", $groupAD)|out-file $LogsFile -Append
                                }
                                catch{
                                    Write-Host ("                               користувача не було додано до групи", $groupAD.SamAccountName)
                                    #Write-host $Error[0].Exception
                                }
                            }                             
                                                    
                        }                                          
                    }else{
                        write-host("              not in group 1C  ",$MAD.name) -ForegroundColor Red            
                    }                  
                    # write-host("              ",$M.wWWHomePage," ",$M.Description)
                    write-host("                       ", $MAD.wWWHomePage, "|", $MAD.Description , " |", $M1C.Surname, "| ") -ForegroundColor $color

                } 
            }
            #==== add groups-members 
            if($DepCSV | where {$_.DepCode -eq $_.DepParentCode}){
                ##write-host ("                Links not right") -ForegroundColor Red
            }else{
                $Groups1C = $DepCSV | where {$_.DepParentCode -eq $groupAD.wWWHomePage}
                if($Groups1C){
                    foreach($g1C in $Groups1C){
                        $g = $AllGroups | where {$_.wWWHomaPage -eq $g1C.DepCode}
                        if($g){
                            Add-ADGroupMember -Identity $groupAD -Members $g
                        }
                    }            
                }
            }                                
        } #--- if ($GCSV){ 
        #>
    }

 

Write-Host ("Count users UOS ",$AllUsers.Count)
Write-Host ("Count groups UOS ",$AllGroups.Count)
} # menu = 1

if($menu -eq "2"){

    write-host ("групи з 1С, яких немає в АД") -ForegroundColor Green
    #foreach ($GCSV in $DepCSV | where {($_.ActiveFlag -like "*Д") -or ($_.ActiveFlag -like "*В")}){
    foreach ($GCSV in $DepCSV | where {($_.ActiveFlag -notlike "*Г")}){         
        $color = "red" 
        #from groups DMS
        $groupAD = $AllGroups | Where {$_.wWWHomePage -eq $GCSV.DepCode}
    
        if ($groupAD){
            $color = "yellow"
            
        #    write-host ("          ",$groupAD.wWWHomePage ,"  ",$groupAD.Description,"  ",$groupAD.SamAccountName`
                                #,"  ",$GCSV.DepCode,"  ",$GCSV.DepName
        #                        ) -ForegroundColor $color
        } 
        if (!$groupAD){
            write-host ("      ",$GCSV.ActiveFlag," ", $GCSV.DepCode,"  ",$GCSV.DepName ) -ForegroundColor $color -BackgroundColor White
        }   
    }

    write-host ("групи з АД, яких немає в 1С") -ForegroundColor Green
    foreach ($GrAD in $AllGroups){
        if (($GrAD.wWWHomePage) -and ($GrAD.DistinguishedName.IndexOf("OU=zOldGroup") -eq -1)){   
            $color = "red"
            
            $group1C = $DepCSV | Where {($_.DepCode -eq $GrAD.wWWHomePage) }
    
            if (!$group1C -and $GrAD.wWWHomePage.Length -le 4){
                write-host ( $GrAD.wWWHomePage," /  ",$GrAD.Description ,"  ",$GrAD.DistinguishedName) # -ForegroundColor $color
                #list of members
                foreach ($M in $GrAD.member){
                    write-host ( "           ",$M)-ForegroundColor DarkGray

                }
            }
        }
    }
    write-host ("old групи з АД") -ForegroundColor Green
    
    $AllGroups = Get-ADGroup -filter {(cn -like "dms-*")} -SearchBase $OUOld -Properties *
    foreach ($GrAD in $AllGroups){
        write-host ( $GrAD.wWWHomePage," /  ",$GrAD.Description ,"  ",$GrAD.DistinguishedName)
         foreach ($M in $GrAD.member){
                    write-host ( "           ",$M)-ForegroundColor DarkGray

         }
    }
} # menu = 2

if($menu -eq "3"){
#>
#=========   USERS   =========================================================================
<#write-host ("користувачі з 1С, яких немає в АД") -ForegroundColor Yellow
foreach ($UCSV in $UserCSV | where {($_.ActiveFlag -like "+")}){
         
    $color = "red"
            
    $userAD = $AllUsers | Where {$_.wWWHomePage -eq ""}#$UCSV.TabCode}
    #if ($groupAD){$color = "yellow"}
    #write-host ("          ", $groupAD.wWWHomePage ,"  ",$groupAD.Description`
     #                 ,"  ",$GCSV.DepCode,"  ",$GCSV.DepName
    #           ) -ForegroundColor $color
     #write-host ( $UCSV.TabCode,"  ",$userAD.wWWHomePage , " ", $UCSV.surName )
    if ($userAD){
       write-host ( $UCSV.TabCode,"  ",$UCSV.surName, " haven`t wWWHomePage in AD" ) # -ForegroundColor $color
    }
   
}
write-host ("користувачі з АД, яких немає в 1С") -ForegroundColor Yellow
foreach ($UsAD in $AllUsers){
         
    $color = "red"
            
    $user1C = $UserCSV | Where {$_.TabCode -eq $UsAD.wWWHomePage}
    #if ($groupAD){$color = "yellow"}
    #write-host ("          ", $groupAD.wWWHomePage ,"  ",$groupAD.Description`
     #                 ,"  ",$GCSV.DepCode,"  ",$GCSV.DepName
    #           ) -ForegroundColor $color
    
    if ((!$user1C) -or ($user1C.ActiveFlag -eq "-")){
        write-host ( $UsAD.wWWHomePage , " ", $UsAD.DisplayName, " ", $UsAD.Department ) # -ForegroundColor $color
    }
   
}
#>




    #write-host ("користувачі з АД, які немають wWWHomePage") -ForegroundColor Yellow
    $n=0
    foreach ($userAD in $AllUsers){
         
        if ((!$userAD.wWWHomePage)-or($userAD.wWWHomePage -eq "")){#-and(!($userAD.Name.IndexOf("Адміністратор")-eq-1)-and !($userAD.Name.IndexOf("test")-eq-1))){
            
            if (($userAD.Name.IndexOf("Адміністратор")-eq-1)-and ($userAD.Name.IndexOf("test")-eq-1)){

                if ($n -eq 0){
                     write-host ("користувач з АД, який не має wWWHomePage") -ForegroundColor Yellow
                     $n ++
                }
                write-host ("           ", $userAD.name) # -ForegroundColor $color
            }
        }
    }

    #write-host ("деактивовані користувачі") -ForegroundColor Yellow
    $n=0
    foreach ($userAD in $AllUsers){
         
        if (!$userAD.Enabled){ 
            if ($n -eq 0){
                write-host ("деактивовані користувачі") -ForegroundColor Yellow
                $n ++
                }
            write-host ("           ", $userAD.name, "", $userAD.whenChanged) # -ForegroundColor $color
        }
    }
#============  Members ====================================================================
 write-host ("користувачі, які знаходяться групі, яка не відповідає структурному підрозділу") -ForegroundColor Green

<#
foreach ($GrAD in $AllGroups){
   #write-host ($GrAD.Description)-ForegroundColor DarkYellow
   foreach($M in $GrAD.Members){
        $color = "white"
  #      write-host ("      ",$M.Split(",")[0].Substring(3)) -ForegroundColor white
        
        $user = $AllUsers | where {$_.cn -eq $M.Split(",")[0].Substring(3)}
        if (($user.sn) -and ($GrAD.wWWHomePage) -and ($user.departmentNumber -ne $GrAD.wWWHomePage)){
            write-host ("      ", $user.sn)
            $n=0
            if ($user.MemberOf -gt 1){
                foreach ($memOf in $user.MemberOf){
                    
                    if ($memOf.Split(",")[0].Substring(3,3) -eq "dms"){
                       
                        
                        $groupDep = $AllGroups | where {$_.sAMAccountName -eq $memOf.Split(",")[0].Substring(3)}
                        if($groupDep){

                            $a="*"+$user.departmentNumber
                            if ($groupDep.wWWHomePage -notlike $a){
                                #Write-Host("              !!")
                                write-host ("           ",$GrAD.CN,"/",$GrAD.wWWHomePage,"  (",$user.departmentNumber,")" ) -NoNewline #," " ,$memOf.Split(",")[0].Substring(7)
                                Write-Host("                 ",$groupDep.SamAccountName," ",$groupDep.wWWHomePage)
                                $n ++
                            }else{
                                #Write-Host("")
                                }
                        }else{
                            #Write-Host("")
                            }                        
                        if ($groupDep.wWWHomePage -eq $user.departmentNumber){
                            $color = "Magenta"
                            # Write-Host("            ",$groupDep.Description) -ForegroundColor $color                            
                            }
                    }
                } 
             }      

             # write-host ("      ",$user.cn, " - department -> ", $user.department," - group ->  ", $GrAD.Description ) -ForegroundColor $color
             
             #$properties = @{"SurName"  =$user.sn;
             #                #"Department 1C" =$user.department -join ", ";
             #                #"Group AD"=$GrAD.Description -join ", ";                            
             #               }
             #$obj = New-Object -TypeName psobject -Property $properties #| Format-Table -AutoSize
             #Write-Output $obj 
             #
        }
   }
}
#>

    $n=0
    foreach($userAD in $AllUsers|where{$_.wwwHomePage}){
        $countMemberOfUser = 0
        #write-host($userAD.cn)
        foreach($memOf in $userAD.MemberOf){
            if ($memOf.Split(",")[0].Substring(3,3) -eq "dms"){
                #Write-Host("           ",$memOf.Split(",")[0].Substring(7))

                    $groupDep = $AllGroups | where {$_.sAMAccountName -eq $memOf.Split(",")[0].Substring(3)}
                    
                    if($groupDep){ 
                       # if(
                       #         ($groupDep.wWWHomePage -like $userAD.departmentNumber) #-or 
                       #         #($groupDep.wWWHomePage -eq $userAD.departmentNumber)
                       #    ){                            
                             $countMemberOfUser ++
                              #Write-Host("--           ",$groupDep.cn," (",$groupDep.wWWHomePage,") ")
                       #  }
                    }
                }
        }
        #Write-Host($countMemberOfUser," ",$userAD.cn,"  ",$userAD.departmentNumber, " ")
        if($countMemberOfUser -eq 0){
             write-host ( $userAD.cn ," --- ні в жодній групі") -ForegroundColor Gray
        }
        
        if($countMemberOfUser -eq 1){
             $color="yellow"
                    $groupDep = $AllGroups | where {$_.sAMAccountName -eq $userAD.memberOf.Split(",")[0].Substring(3)}
                    
                    if($groupDep -and ($groupDep.wWWHomePage -notlike "*"+$userAD.departmentNumber)){
                        Write-Host($userAD.cn)-ForegroundColor $color -NoNewline
                        Write-Host(" (",$userAD.departmentNumber ,")   ",$userAD.department) #-ForegroundColor $color
                        Write-Host("           " ,$groupDep.cn," (",$groupDep.wWWHomePage,") ")-ForegroundColor Magenta # $color
                        #$color = "white"
                    }
        }

        if($countMemberOfUser -gt 1){ ## ???????????????????????????????

            if($n -eq 0){
                write-host ("! користувачі більше, ніж в одній групі") -ForegroundColor Gray
                $n ++
            }
            write-host($userAD.cn," (",$userAD.departmentNumber,") ", $userAD.Department)
            #$i=0
            #if($countMemberOfUser -eq 1){$i=1}
            
            foreach($memOf in $userAD.MemberOf){
                if ($memOf.Split(",")[0].Substring(3,3) -eq "dms"){
                    $color="magenta"
                    $groupDep = $AllGroups | where {$_.sAMAccountName -eq $memOf.Split(",")[0].Substring(3)}
                    
                    if($groupDep -and ($groupDep.wWWHomePage -like $userAD.departmentNumber)){
                        $color = "white"
                    }
                    Write-Host("           ",$groupDep.cn," (",$groupDep.wWWHomePage,") ")-ForegroundColor $color
                    
                    }
            }
        }

    }

} # menu = 3
if($menu -eq "4"){

    foreach($userAD in $AllUsers|where{$_.wwwHomePage}){
        #$UserCSV|where{$_.DepCode -eq $subSubGroupCSV.DepCode -and $_.activeflag -eq "+"}
        $user1C = $UserCSV|where{$_.TabCode -eq $userAD.wWWHomePage -and $_.activeflag -eq "+"}

        if($user1C){
           # Write-Host("1C", $user1C.SurName)-ForegroundColor Yellow

            if($userAD.departmentNumber -ne $user1C.DepCode){
                 Write-Host(" ", $user1C.SurName,$user1C.TitleName)-ForegroundColor Yellow
                 Write-Host("     AD",$userAD.departmentNumber,$userAD.department)

                 $memberOfAD = $userAD.MemberOf 
                 $memberOfAD = $AllGroups|where{$_.wWWHomePage -eq $user1C.DepCode}

                 foreach($m in $userAD.MemberOf){
                    $Member = $AllGroups|where{$_.cn -eq $m.split(",")[0].substring(3)}

                    Write-Host("          ",$Member.description)
                 }
                 Write-Host("     1C",$user1C.DepCode,$user1C.DepName)
                 

            }

        }else{
            #Write-Host("AD", $userAD.cn)-ForegroundColor Gray
        }
    }

}

if($menu -eq "5"){
    #=================  Groups boss ==================================================================
    write-host ("Groups boss") -ForegroundColor Green

    $typeBoss = @("dms-bossDepS,dms-bossCoDS",
                "dms-bossCoDS",
                "dms-bossCoVS",
                "dms-bossVidS,dms-bossCoVS")

    foreach ($a in $typeBoss){
    #    write-host ($a)
    #}

    #=== dms-bossDepS
        #$a = "dms-bossDepS,dms-bossCoDS"
        $a1 = $a.split(",")[0]
        $a2 = ""
        if ($a.split(",").length -gt 1){$a2 = $a.split(",")[1]}

        #write-host ("       ",$a1," | ",$a2) -ForegroundColor Cyan

        $AllBossGroup = Get-ADGroup -filter {(cn -like "dms-boss*")} -SearchBase $RootDomainOU -Properties *
        $GroupBoss = $AllBossGroup | Where {$_.sAMAccountName -eq $a1}
        write-host ("    ",$GroupBoss.Description)-ForegroundColor Yellow
        if ($GroupBoss){ 
            $a1 = $a1.substring(0,($a1.length-1))+"-*"
            $BossGroups = $AllBossGroup | where {(($_.sAMAccountName -like $a1))}
            if ($a2 -ne ""){
                $a2 = $a2.substring(0,($a2.length-1))+"-*"
                $BossGroups = $AllBossGroup | where {(($_.sAMAccountName -like $a1)-or ($_.sAMAccountName -like $a2))}
            }
            foreach ($g in $BossGroups){
                #write-host ("              ",$g.cn)
                $ok = 0
                foreach ($M in $GroupBoss.Members){            
                    if ($g.cn -eq $M.split(",")[0].substring(3)){
                        #write-host ("                    ",$M.split(",")[0].substring(3))
                        $ok = 1
                    }
                }
                if ($ok -eq 0){
                    Add-ADGroupMember -Identity $GroupBoss -Members $g
                }        
            }
            foreach ($M in $GroupBoss.Members){
                $g = $AllBossGroup | where {($_.sAMAccountName -eq $M.split(",")[0].substring(3))}
                write-host ("           ",$g.Description) -ForegroundColor DarkGray            
                foreach($u in $g.Members){
                   # write-host ($u) -ForegroundColor Green
                    $mName = $u.split(",")[0].substring(3)
                    $Member = $AllUsers | Where {$_.cn -eq $u.split(",")[0].substring(3)}

                    $zMember = $AllzOUTUsers | where {$_.cn -eq $mName}

                    if($Member -and $Member.Enabled){
                        write-host ("              ",$Member.DisplayName," || ",$Member.mail)
                    }else{
                        if($Member -and !$Member.Enabled -or $zMember){
                                write-host ("                    -- ",$mName,"  deactive ")-ForegroundColor DarkCyan
                            }
                            else{
                                Write-Host ("                    -- ", $mName ," is not in base AD") -ForegroundColor DarkCyan
                                }
                        }
                }
            }
        }
    }

} # menu = 3
#>


#===========================================================================================
<#foreach ($OU in $AllUOSOU  ){   
    #if ($OU.wWWhomePage){
        Write-Host ($OU.wWWhomePage, " ", $OU.Name, " ", $OU.Description)
        $name = "dms-"
        $name += $OU.name
        $Group = Get-ADGroup -filter {(name -like $name)} -SearchBase $OU -Properties * -SearchScope OneLevel #{(name -eq "$name")} 
        if (!$Group){
            Write-Host ("create $name") -ForegroundColor Red
            #Create group 
            
            
            }
        #else        {Write-Host ("$name already exist")}
   
        $Group = Get-ADGroup -filter {(name -like $name)} -SearchBase $OU -Properties * -SearchScope OneLevel
        if ($Group){
            Write-Host ("     $name") -ForegroundColor Yellow 
            $a = $DepCSV | Where {$_.DepCode -eq $Group.wWWHomepage}
            Write-Host ("     ", $a.DepName)           1
            
            #compare list of user         
            
            foreach ($M in $UserCSV | Where {$_.DepCode -eq $a.DepCode}) { # | Get-ADGroupMember -Recursive){

                    $color = "white"

                    if ($M.ActiveFlag -eq "-"){$color = "red"}
                    $userAD = $AllUsers | Where {$_.wWWHomePage -eq $M.TabCode}
                    if ($userAD){$color = "yellow"}
                    write-host ("          ", $M.Surname ,"  ",$M.DepName
                                               # ,"  ",$userAD.Name,"  ",$userAD.Department
                                                ) -ForegroundColor $color
                    $properties  = @{
                                       "1_1C Surname"= $M.Surname;
                                       "2_1C Department"= $M.DepName -join ", ";
                                       #"3_AD Name"= $userAD.Name -join ", ";
                                       #"4_AD Department"= $userAD.Department -join ", ";                         
                                    }
                     $obj = New-Object -TypeName psobject -Property $properties
                    # Write-Output $obj -ForegroundColor $color

            }


            foreach ($M in Get-ADUser -Filter * -SearchBase $OU -Properties * -SearchScope OneLevel) { # | Get-ADGroupMember -Recursive){
                  #  write-host ("          ", $M.Name)



            }
        }
    #}
}#>




<#$name = "dms-TestThree"

#$name = Read-Host ("name groups")

if (!(Get-ADGroup -filter {name -like $name} -SearchBase $RootDomainOU -Properties * -SearchScope OneLevel)){
    New-ADGroup $name -path $RootDomainOU -GroupScope Global
    }else {
    #Write-Host ("$name already exist")
    }

foreach ($G in $DepCSV | sort ){
    Write-Host ($G.ActiveFlag," ",$G.DepName)
}
#>