

$RootDomainOUAll = 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'

$AllUOSUsers=Get-ADuser -filter * -SearchBase $RootDomainOUAll -Properties *

foreach ($UOSUser in $AllUOSUsers) {
    if ([int]$UOSUser.wWWHomePage -eq "3786"){
        Write-Host ("|||",$UOSUser.wWWHomePage)

        Write-Host ("User >> ",$UOSUser)
    }
}