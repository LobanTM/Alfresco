#$RootDomainOU = 'ou=Test,ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
$RootDomainOU = 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
$OU = "ou="+"Test"+","+ $RootDomainOU
$AllBossGroup = Get-ADGroup -filter {cn -like "dms-boss*"} -SearchBase $RootDomainOU -Properties *
#$AllBossGroup = Get-ADGroup -filter * -SearchBase $RootDomainOU -Properties *

$nameBossGroup = "dms-bossCoV-Comm10"

# $GroupBoss = $AllBossGroups | Where {$_.cn -eq "dms-bossCoV-Comm10"} #dms-bossCoV-Comm10

# Write-Host ($GroupBoss) -ForegroundColor Yellow

    # !!!!!!
       <# if (!$GroupBoss){
            #create group
           try{
                New-ADGroup $nameBossGroup -Path $OU -GroupScope Global
            }
            catch{
                 Write-Host ("gorup $nameBossGroup don't exist") -ErrorAction Continue -ForegroundColor Red
            }

        }
        #>

foreach ($g in $AllBossGroup) {

    if ($g.samaccountName -eq $nameBossGroup){
            Write-Host ("           ", $g.cn)#samaccountName)
            #Set-ADGroup -Identity $g -Replace @{DisplayNamePrintable="nothing"	 }
            Write-Host ("           ", $g.DisplayNamePrintable)
        }

}