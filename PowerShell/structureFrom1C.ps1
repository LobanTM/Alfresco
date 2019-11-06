
$CSVpath="C:\Users\dmsadmin1\scripts\data\"
$DepCSVFile="ad_dep.csv"

#преобразование файла в unicode
$UniDepCSVFile="uni_"+$DepCSVFile
Get-Content ($CSVpath+$DepCSVFile) | Out-File ($CSVpath+$UniDepCSVFile) -Encoding "Unicode"
#разбор csv файла
#заголовки
$headerDep = "DepIndex","ActiveFlag","DepCode","DepName","DepFullName","Manager","DepParentCode","DepBossNumber"
#считывание данных в массив по указанным заголовкам
$DepCSV = Import-CSV ($CSVpath+$UniDepCSVFile) -header $headerDep -delimiter ";"

$UserCSVFile="ad_user.csv"
#преобразование файла в unicode
$UniUserCSVFile="uni_"+$UserCSVFile
Get-Content ($CSVpath+$UserCSVFile) | Out-File ($CSVpath+$UniUserCSVFile) -Encoding "Unicode"
#разбор csv файла
#заголовки
$headerUser = "ActiveFlag","TabCode","Surname","FirstName","SecName","FirstSecondName","DepCode","DepIndex","DepName","FullDepName","Manager","TitleCode","TitleName"
#считывание данных в массив по указанным заголовкам
$UserCSV = Import-CSV ($CSVpath+$UniUserCSVFile) -header $headerUser -delimiter ";"

$dep = ""# Read-Host ("enter type")



foreach ($GroupCSV in $DepCSV | Where {$_.ActiveFlag -like "*$dep"}){
    $Color = 0
    #Write-Host ($GroupCSV.DepName) -ForegroundColor $Color

    $UserBoss = $UserCSV | Where {$_.TabCode -eq $GroupCSV.DepBossNumber}

    if ($GroupCSV.ActiveFlag -like "*В"){$Color = 1}
    if ($GroupCSV.ActiveFlag -like "*Д"){$Color = 2}

     #отображение в формате
    $properties = @{"Type"=$GroupCSV.ActiveFlag -join ", ";
                    "DepNumber"=$GroupCSV.DepCode -join ", ";
                    "DepName"=$GroupCSV.DepName -join ", ";
                    "Boss"= $UserBoss.SurName -join ", ";
                    } 
    $obj = New-Object -TypeName psobject -Property $properties
   ## Write-Output $obj
    #$obj |ft  DepName,DepNumber,Type,Boss -AutoSize
    # | ColorDep($Color) 
}
#$a = @{Expression = {$UserCSV | Where {$_.TabCode -eq DepBossNumber}}}
#$UserBoss = @{Expression = {($UserCSV | Where {$_.TabCode -eq ($DepCSV| where {}).DepBossNumber}).surname}; label = "boss"}
#$DepCSV|
# ft depName, DepCode, ActiveFlag, $UserBoss -AutoSize


#[System.Enum]::GetNames([System.ConsoleColor])

foreach ($user in $UserCSV){
    $Color = "Green"
    #Write-Host ($user) -ForegroundColor $Color

    #$UserBoss = $UserCSV | Where {$_.TabCode -eq $GroupCSV.DepBossNumber}

     #отображение в формате
    <#$properties = @{"FirstName"=$user.FirstName;
                    "SurName"=$user.SurName -join ", ";
                    "TabNumber"= $user.TabNumber -join ", ";
                    }
    $obj = New-Object -TypeName psobject -Property $properties
    Write-Output $obj
    #>


}
# Write-Output "+++" | ColorDep(0)

function ColorDep($number){
    process {
        $Color = "White"

        if($number -eq "Д"){$Color = "Green"}
        if($number -eq "КД"){$Color = "DarkGreen"}
        if($number -eq "В"){$Color = "Yellow"}
        if($number -eq "КВ"){$Color = "DarkYellow"}
        if($number -eq "Г"){$Color = "Gray"}
        if($number -eq "КГ"){$Color = "DarkGray"}       
       return $color    
    }
}

$managerControl = ""
foreach ($GroupCSV in $DepCSV | sort DepIndex){
    if(($GroupCSV.DepParentCode -eq "")-or($GroupCSV.DepParentCode -eq $GroupCSV.DepCode)){
        #level 1
        $color =  ColorDep $GroupCSV.ActiveFlag
        
        $manager = $UserCSV|where{($_.TabCode -eq $GroupCSV.Manager)} #-and($_.ActiveFlag -eq "+")}
        $colorManager = "DarkCyan"
        if ($manager.ActiveFlag -eq "+"){
            $colorManager = "Magenta"
        }

        if ($managerControl -ne $manager){
            $managerControl = $manager

            Write-Host($manager.Surname)-ForegroundColor $colorManager
        }
        write-host("      ",$GroupCSV.DepIndex," ",$GroupCSV.DepName)-ForegroundColor $color

        #write-host("      ","1--- ")
        foreach($user in $UserCSV|where{$_.DepCode -eq $GroupCSV.DepCode -and $_.activeflag -eq "+"}){
             $colorUser = "darkgray"
             if($AllUsers|where{$_.wWWHomePage -eq $user.TabCode}){
                $colorUser = "white"
             #   write-host("           ",$user.Surname,$user.FirstSecondName,$user.TitleName) -ForegroundColor $colorUser
             }             
             write-host("           ",$user.Surname,$user.FirstSecondName,$user.TitleName) -ForegroundColor $colorUser
        }

        foreach($subGroupCSV in $DepCSV|where{(($_.DepParentCode -eq $GroupCSV.DepCode)-and($_.DepParentCode -ne $_.DepCode))}|sort DepIndex){
            #level2
            $color =  ColorDep $subGroupCSV.ActiveFlag
            write-host("           ",$subGroupCSV.DepIndex," ",$subGroupCSV.DepName)-ForegroundColor $color

             #write-host("                 ","2-- ")
             foreach($user in $UserCSV|where{$_.DepCode -eq $subGroupCSV.DepCode -and $_.activeflag -eq "+"}){
                $colorUser = "darkgray"
                if($AllUsers|where{$_.wWWHomePage -eq $user.TabCode}){
                    $colorUser = "white"
                #    write-host("              ",$user.Surname,$user.FirstSecondName,$user.TitleName)-ForegroundColor $colorUser
                }             
                write-host("              ",$user.Surname,$user.FirstSecondName,$user.TitleName)-ForegroundColor $colorUser
             }

            foreach($subSubGroupCSV in $DepCSV|where{(($_.DepParentCode -eq $subGroupCSV.DepCode)-and($_.DepParentCode -ne $_.DepCode))}|sort DepIndex){
                #level3
                $color =  ColorDep $subSubGroupCSV.ActiveFlag
                write-host("                 ",$subSubGroupCSV.DepIndex," ",$subSubGroupCSV.DepName)-ForegroundColor $color

                #write-host("                 ","3-- ")
                foreach($user in $UserCSV|where{$_.DepCode -eq $subSubGroupCSV.DepCode -and $_.activeflag -eq "+"}){
                    $colorUser = "darkgray"
                    if($AllUsers|where{$_.wWWHomePage -eq $user.TabCode}){
                        $colorUser = "white"
                    #    write-host("                   ",$user.Surname,$user.FirstSecondName,$user.TitleName)-ForegroundColor $colorUser
                    }             
                    write-host("                   ",$user.Surname,$user.FirstSecondName,$user.TitleName)-ForegroundColor $colorUser
                }    

            }
        }
    }
}

write-host("{0:dd} {0:MMMM} {0:yyyy} {0:T}" -f (Get-Date)) -ForegroundColor DarkGray 