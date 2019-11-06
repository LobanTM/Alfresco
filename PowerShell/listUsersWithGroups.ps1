$RootDomainOU = 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
#считывание данных из АД
$AllUOSOU=Get-ADOrganizationalUnit -filter * -SearchBase $RootDomainOU -Properties *

#поиск пользователей
$UserDisplayName = "*"
$AllUser = (Get-ADUser -filter * -SearchBase $RootDomainOU  -Properties * | Where {$_.name -like "$UserDisplayName"} | select -ExpandProperty name | sort)
Write-Host "Next user: " ($AllUser -join ", ")

#поиск груп
$AllGroup = (Get-ADGroup -filter {(cn -like "dms-*") } -SearchBase $RootDomainOU -Properties * | select -ExpandProperty name | sort)
Write-Host "Next group: " ($AllGroup -join ", ")

foreach ($u in $AllUser){
    #поиск груп, в которых состоят пользователи
    [System.Collections.ArrayList]$GroupList = $AllGroup
    foreach ($g in $AllGroup){
        if (!($u -in (Get-ADGroup -Filter {(cn -like "dms-*") -and (name -eq $g)}  | Get-ADGroupMember -Recursive).name)){
            $GroupList.Remove("$g")
        }          
    }
    #отображение в формате
    $properties = @{"UserName"=$u;
                    "UserGroups"=$GroupList -join ", ";
                    }
    $obj = New-Object -TypeName psobject -Property $properties
    Write-Output $obj
}




"{0:dd} {0:MMMM} {0:yyyy} {0:T}" -f (Get-Date) 