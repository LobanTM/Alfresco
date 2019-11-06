#list group from AD
$RootDomainOUAll = 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
#считывание данных из АД
$AllUOSGroup=Get-ADGroup -filter * -SearchBase $RootDomainOUAll -Properties *
#$AllUOSGroup2=Get-ADGroup -filter * -SearchBase $RootDomainOUAll -Properties *
Write-Host (" ========================================================================================================================================== ")


foreach ($GroupAD in $AllUOSGroup | Where {$_.Name -like "dms-AparatDyrektora"}) {#FinEconomDept"}) { #*"}) {

    Write-Host (" ",$GroupAD.wWWHomePage ,"/",$GroupAD.Name,"/",$GroupAD.ObjectClass ) -ForegroundColor Green

    #Write-Host ("DN:      ",$GroupAD.DN)#.Description, "/",$GroupAD.displayNamePrintable )
    foreach ($MemberGpoup in $GroupAD.Member){
        #if ($MemberGpoup.GetType(){}
                # $MemberGpoup.GetType() = System.String
        Write-Host ("    -1-",$MemberGpoup.ToString())#,"/",$MemberGpoup.)
        $MemberName = $MemberGpoup.ToString().split(",")[0].substring(3)
        #Write-Host ("    ==",$MemberName)

        $Member = $AllUOSGroup | Where {$_.CN -like $MemberName}
        if (!$Member){
           # Write-Host ("    ----")
        }elseif($Member.Count -eq 0){
            Write-Host ("       not group")
        }elseif ($Member.Count -eq 1){
            Write-Host ("       1 ++",$Member.Name)
        }else{
            Write-Host ("       ",$Member.wWWHomePage,"/",$Member.Name,"/",$Member.ObjectClass) -ForegroundColor Green
            foreach ($MemberSubGroup in $Member.member){
                Write-Host ("                   -2-",$MemberSubGroup.ToString())
            }

        }
    }
}
"{0:dd} {0:MMMM} {0:yyyy} {0:T}" -f (Get-Date) 