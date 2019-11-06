
#$RootDomainOU = 'ou=Test,ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
$RootDomainOU = 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'

$AllUOSOU=Get-ADOrganizationalUnit -filter * -SearchBase $RootDomainOU -Properties *

foreach ($OU in $AllUOSOU){
    #Write-Host ($report2) -ForegroundColor Yellow
    Write-Host ("     -OU- ", $OU.name) -ForegroundColor Green
    $name = $OU.Name
    $DmsGroup = Find-ADDMSGroupForOU "dms-$name" $OU
    if ($DmsGroup){Write-Host ("      |---G- ", $DmsGroup.name) -ForegroundColor Yellow}
    else {         Write-Host ("      |---G- ", "dms-$name not exist") -ForegroundColor Red}
    
    
    foreach ($U in Find-ADUsersForOU $OU){
        $countUsersOU = 0
        foreach ($Ug in $DmsGroup.member){
            if ($U.cn -eq $Ug.ToString().split(",")[0].substring(3)){
                $countUsersOU ++
                Write-Host ("      |---U+ ", $U.cn, "   ======   ",$Ug.ToString().split(",")[0].substring(3))
            }else{
               # Write-Host ("      |---U- ", $U.name)
                }
        }
        if (($countUsersOU -eq 0) -and ($U)){
            #пользователи есть в OU, но отсутствуют в группе dms-
            Write-Host ("      |---U- ", $U.name, " is not in group ") -ForegroundColor Red
        }
    }
    foreach ($MemberOU in Find-ADMemberOUsForOU "*" $OU){
        Write-Host ("      |-------OU- ", $MemberOU.name) -ForegroundColor Green
        $name = $MemberOU.Name
        $DmsSubGroup=Find-ADDMSGroupForOU "dms-$name" $MemberOU
        if ($DmsSubGroup){Write-Host ("      |       |---G- ", $DmsSubGroup.name) -ForegroundColor Yellow}
        else {            Write-Host ("      |       |---G- ", "dms-$name not exist") -ForegroundColor Red}

        #Write-Host ("      |     |-G- ", $DmsSubGroup.name) -ForegroundColor Yellow
        foreach ($U in Find-ADUsersForOU $MemberOU){
            $countUsersOU = 0
            foreach ($Ug in $DmsSubGroup.member){
                if ($U.cn -eq $Ug.ToString().split(",")[0].substring(3)){
                    $countUsersOU ++
                   Write-Host ("      |       |---U+ ", $U.cn, "   ======   ",$Ug.ToString().split(",")[0].substring(3))                   
                }else{
                  # Write-Host ("      |---U- ", $U.name)
                   }
             }
             if (($countUsersOU -eq 0) -and ($U)){
            #пользователи есть в OU, но отсутствуют в группе dms-
                Write-Host ("      |       |---U- ", $U.name, " is not in group ") -ForegroundColor Red
             }
        }
        foreach ($SubMemberOU in Find-ADMemberOUsForOU "*" $MemberOU){
            Write-Host ("      |--------------OU- ", $SubMemberOU.name) -ForegroundColor Green
            $name = $SubMemberOU.Name
            $DmsSubSubGroup=Find-ADDMSGroupForOU "dms-$name" $SubMemberOU
            if ($DmsSubSubGroup){Write-Host ("      |              |---G- ", $DmsSubSubGroup.name) -ForegroundColor Yellow}
            else {               Write-Host ("      |              |---G- ", "dms-$name not exist") -ForegroundColor Red}
            #Write-Host ("      |            |-G- ", $DmsSubSubGroup.name) -ForegroundColor Yellow
            foreach ($U in Find-ADUsersForOU $SubMemberOU){
                $countUsersOU = 0
                foreach ($Ug in $DmsSubSubGroup.member){
                if ($U.cn -eq $Ug.ToString().split(",")[0].substring(3)){
                    $countUsersOU ++
                   Write-Host ("      |              |---U+ ", $U.cn, "   ======   ",$Ug.ToString().split(",")[0].substring(3))
                }else{
                  # Write-Host ("      |-U- ", $U.name)
                   }
                }
                
               if (($countUsersOU -eq 0) -and ($U)){
                #пользователи есть в OU, но отсутствуют в группе dms-
                     Write-Host ("      |              |---U- ", $U.name, " is not in group ") -ForegroundColor Red
                }
               
            }
        }
    }
}
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