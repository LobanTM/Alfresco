
#$RootDomainOU = 'ou=Test,ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
$RootDomainOU = 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
$zOUTDomainOU = 'ou=zOUT,dc=ad,dc=uos,dc=ua'

$AllUOSOU=Get-ADOrganizationalUnit -filter * -SearchBase $RootDomainOU -Properties * -SearchScope OneLevel

$AllUsers=Get-ADUser -filter * -SearchBase $RootDomainOU -Properties *
$AllGroups=Get-ADGroup -filter {(cn -like "dms-*")} -SearchBase $RootDomainOU -Properties *
$AllMailGroup = Get-ADGroup -filter {(cn -like "mail-*")} -SearchBase $RootDomainOU -Properties *
$AllBossGroup = Get-ADGroup -filter {(cn -like "dms-boss*")} -SearchBase $RootDomainOU -Properties *

$AllzOUTUsers=Get-ADUser -filter * -SearchBase $zOUTDomainOU -Properties *

foreach ($OU in $AllUOSOU){
    #Write-Host ($report2) -ForegroundColor Yellow
    #Write-Host ("     -OU- ", $OU.name, " | ", $OU.DistinguishedName) -ForegroundColor Green
    $name = $OU.Name
    AllMemberOfGroup "dms-$name" 1
}

function AllMemberOfGroup($nameGroup, $level){
        $color = "Yellow"
        Switch($level){
        1 {$type = "     "}
        2 {$type = "            "}
        3 {$type = "                   "}
        4 {$type = "                            "}
        }
        $DmsGroup = $AllGroups | where {$_.cn -eq $nameGroup} 
        if ($DmsGroup){
            
            if($DmsGroup.CN.Contains("boss")){$color = "DarkYellow"}

            Write-Host ("$type|---",$level,"-G- ", $DmsGroup.CN) -ForegroundColor $color
            foreach($M in $DmsGroup.Members){
               #$level ++  
                $color = "White"                                          #user
                $mName = $M.split(",")[0].substring(3)
                $tName = $mName.substring(0,3)
                $tMember = "U"
                if($tName -eq "dms") {                                     #group                
                    $color = "Yellow"
                    $tMember = "G"
                 } 
                
                if ($tMember -eq "G"){  
                  #=================================                 
                   AllMemberOfGroup $mName ($level+1)
                      
                }
                if ($tMember -eq "U"){
                    $uMember = $AllUsers | where {$_.cn -eq $mName}
                    if ($uMember){
                     Write-Host ("$type       |---",$level,"-$tMember- ", $uMember.cn) -ForegroundColor $color
                     }else{
                        
                        $zMember = $AllzOUTUsers | where {$_.cn -eq $mName}
                        #Write-Host("!!", $zMember)
                        if($zMember){
                                Write-Host ("$type       |---",$level,"-$tMember- ", $zMember.cn ," in zOUT") -ForegroundColor DarkGray
                            }
                            else{
                                Write-Host ("$type       |---",$level,"-$tMember- ", $mName ," is not in base AD") -ForegroundColor Magenta
                                }
                        }

                }

            }
        }
}
<#
write-host ("Users count", $AllUsers.Count)
#$a = $AllUsers | where {$_.office.split(" ")[1].split("-")[0] -eq "75"}
#Write-Host ("Users count in 75", $a.Count)
$count = 0
foreach($a in $AllUsers){

    if($a.office){
        $color = "white"
        if($a.office.split(" ")[1].split("-")[0] -eq "75"){
            $count ++
            $color = "darkgray"
            }
        if($a.office.split(" ")[1].split("-")[0] -eq "27"){            
            $color = "gray"
            }
        Write-Host($a.name," ",$a.department," ",$a.office.split(" ")[1].split("-")[0])-ForegroundColor $color   
    }
}
Write-Host($count)

#>

<#
foreach ($UOSOU in Get-ADOrganizationalUnit -filter * -SearchBase $AllUOSOU -Properties * -SearchScope OneLevel) {
    $name=$UOSOU.name
    Write-Host ("     -OU- $name") -ForegroundColor Green
    $AllOUGrps=Get-ADGroup -filter {(cn -like "dms-*")} -SearchBase $UOSOU  -Properties * -SearchScope OneLevel 
    $OUGrp = $AllOUGrps | Where {$_.Name -like "dms-test$name"}
    #if (!$OUGrp) {New-ADGroup "dms-test$name" -path $UOSOU -GroupScope Global}# -PassThru}# -Verbose}
    $OUGrp1 = $AllOUGrps | Where {$_.Name -like "dms-$name"}
    if ($OUGrp1){Write-Host ("          -G-",$OUGrp1.name)  }

     #create group DMS
     #search group dms-OU -> not - create

    # New-ADGroup "dms-test$name" -path $UOSOU -GroupScope Global -PassThru -Verbose
    
     #add all user to group
     foreach ($MemberUser in Get-ADUser -filter * -SearchBase $UOSOU -Properties * -SearchScope OneLevel){
        #if ($MemberGpoup.GetType(){}
                # $MemberGpoup.GetType() = System.String
 #       Write-Host ("       -U-",$MemberUser.name)
       # Add-ADGroupMember -Identity "dms-test$name" -Members $MemberUser -PassThru
     }


     #create group MAIL
  #   New-ADGroup "mail-test$name" -path $UOSOU -GroupScope Global -PassThru -Verbose
     #add all user to group

     #next level
     foreach ($MemberOU in Get-ADOrganizationalUnit -filter * -SearchBase $UOSOU -Properties * -SearchScope OneLevel){

        $AllOUMemberGrps=Get-ADGroup -filter {(cn -like "dms-*")} -SearchBase $MemberOU  -Properties * -SearchScope OneLevel #| Get-ADGroupMember # -Recursive
             Write-Host ("          -OU- ", $MemberOU.name) -ForegroundColor Green
             $name = $MemberOU.name
             $OUGrp1 = $AllOUMemberGrps | Where {$_.Name -like "dms-$name"}
          if ($OUGrp1){Write-Host ("               -G-",$OUGrp1.name)  }

     }

}
#>



#=============================================================================================================================
function Find-ADMemberOUsForOU($OUName, $RootDomain){        
     Return Get-ADOrganizationalUnit -filter * -SearchBase $RootDomain -Properties * -SearchScope OneLevel | Where {($_.DistinguishedName -like "$OUName")}  
}
function Find-ADDMSGroupForOU($name, $RootOU){             
     #if (! (Get-ADGroup -filter {name -like $name} -SearchBase $RootOU -Properties * -SearchScope OneLevel)){New-ADGroup $name -path $UOSOU -GroupScope Global}
     $Group = Get-ADGroup -filter {name -like $name} -SearchBase $RootOU -Properties * -SearchScope OneLevel 
     if (!$Group) {Return 0}
     else {        Return $Group} 
}
function Find-ADUsersForOU($RootOU){      
     $Users = Get-ADUser -filter * -SearchBase $RootOU -Properties * -SearchScope OneLevel 
     if (!$Users) {Return 0}
     else {        Return $Users} 
}



"{0:dd} {0:MMMM} {0:yyyy} {0:T}" -f (Get-Date) 

<#
 $wshell = New-Object -ComObject Wscript.Shell
 $Output = $wshell.Popup($name, 0,"title",0)   
 
 
 
 
  $AllOUGrps=Get-ADGroup -filter {(cn -like "dms-*")} -SearchBase $UOSOU  -Properties * -SearchScope OneLevel #| Get-ADGroupMember # -Recursive



  

    #            Set-ADGroup -Identity $OUGrp `
	#						-replace @{	Description=($DepCSVString.DepIndex+' '+$DepCSVString.DepName);`
	#									DisplayNamePrintable=($DepCSVString.DepIndex+' '+$DepCSVString.DepFullName);`
	#									extensionName=$DepCSVString.DepIndex;wWWHomePage=$UOSOU.wWWHomePage}
    #            $GrUpdated++
               # Write-Host ($OUGrp.Name)
               #Set-ADGroup -Identity $OUGrp `
				#			-replace @{	DisplayNamePrintable="test group for Alfresco"`	 }
                #Write-Host ("   -G-",$OUGrp.DistinguishedName)  
                
           #}


#>