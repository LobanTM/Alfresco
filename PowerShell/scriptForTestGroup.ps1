# Скрипт для внесения данных из 1С в АД для груп пользователей по номеру группьі из 1С(индексное поле)
#

# считьівание данньіх 1С из файла "ad_dep.csv", по пути "D:\IT\admins\olegyu\"
# основной домен 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
#			тестовьый домен 'ou=Test,ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
#			
#
#$DepCSV - массив данных из 1С
#$AllUOSOU - массив данных из АД
#			

$CSVpath="C:\Users\loban.tm\scripts\data\"
$DepCSVFile="ad_depNEW.csv"

$RootDomainOUAll = 'ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'
$RootDomainOU = 'ou=Test,ou=Ukroboronservice,dc=ad,dc=uos,dc=ua'

#преобразование файла в unicode
$UniDepCSVFile="uni_"+$DepCSVFile
Get-Content ($CSVpath+$DepCSVFile) | Out-File ($CSVpath+$UniDepCSVFile) -Encoding "Unicode"

#разбор csv файла
#заголовки
$headerDep = "DepIndex","Type","DepCode","DepName","DepFullName","Manager","DepParentCode","DepParentName","Boss","BossName"

#считывание данных в массив по указанным заголовкам
$GroupCSV = Import-CSV ($CSVpath+$UniDepCSVFile) -header $headerDep -delimiter ";"

#считывание данных из АД
$AllUOSGroup=Get-ADGroup -filter * -SearchBase $RootDomainOUAll -Properties *
$AllUOSUsers=Get-ADuser -filter * -SearchBase $RootDomainOUAll -Properties *

#аналитическое сравнение двух списков групп
#если найдено совпадение групп по номеру, ЗЕЛЕНЫЙ
#								  иначе - КРАСНЫЙ
foreach ($GCSV in $GroupCSV | Where {$_.DepCode -ge 0}) { #($_.DepParentCode -eq "")}){# -and 
                                     
       # Write-Host (" ",$GCSV.DepCode, "   ", $GCSV.DepIndex,"",$GCSV.DepName)
    $GroupAD = $AllUOSGroup | Where {($_.Name -like "dms*") -and ($_.wWWHomePage -eq $GCSV.DepCode)} # {# AparatDyrektora"}) { #*"}) {-FinEconomDept

    if (!$GroupAD){# -and ($GroupAD.Count -ge 1)){
                                  #Write-Host (" ",$GroupAD.DepCode, " ", $GroupAD.DepIndex,"",$GroupAD.DepName)
                                  Write-Host (" ",$GCSV.DepCode, "   ", $GCSV.DepIndex,"",$GCSV.DepName) -ForegroundColor Red
    }elseif($GroupAD.Count -eq 0){#Write-Host (" 0",$GroupAD.DepCode, " ", $GroupAD.DepIndex,"",$GroupAD.DepName)
    }elseif($GroupAD.Count -eq 1){#Write-Host (" 1",$GroupAD.DepCode, " ", $GroupAD.DepIndex,"",$GroupAD.DepName)
    }else{                        ##Write-Host (" ",$GroupAD.wWWHomePage, " ", $GroupAD.Description)#,"",$GroupAD.DepName)
                                  Write-Host (" ",$GCSV.DepCode, "   ", $GCSV.DepIndex,"",$GCSV.DepName) -ForegroundColor Green
    }

}

#====================================================================================================================================

#массив данных из АД
foreach ($GroupAD in $AllUOSGroup | Where {$_.Name -like "dms-*"}) {
    #Write-Host (" ",$GroupAD.name)
 }

foreach ($GroupAD in $AllUOSGroup | Where {$_.Name -like "dms-FinEconomDept"}) {# AparatDyrektora"}) { #*"}) {
 #   Write-Host (" ",$GroupAD.wWWHomePage ,"/",$GroupAD.Name,"/",$GroupAD.ObjectClass ) -ForegroundColor Green
    foreach ($MemberGpoup in $GroupAD.Member){        
       # Write-Host ("    -1-",$MemberGpoup.ToString())#,"/",$MemberGpoup.)
        $MemberName = $MemberGpoup.ToString().split(",")[0].substring(3)        
        $Member = $AllUOSGroup | Where {$_.CN -like $MemberName}
        if (!$Member){ # Write-Host ("    ----")           
        }elseif($Member.Count -eq 0) {# Write-Host ("       not group")           
        }elseif ($Member.Count -eq 1){#Write-Host ("       1 ++",$Member.Name)            
        }else{ #Write-Host ("       ",$Member.wWWHomePage,"/",$Member.Name,"/",$Member.ObjectClass) -ForegroundColor Green   
            foreach ($MemberSubGroup in $Member.member){
                #Write-Host ("                   -2-",$MemberSubGroup.ToString())
                $NameSubMember = $MemberSubGroup.ToString().split(",")[0].substring(3)
                #Write-Host ("                   --",$NameSubMember)
                $SubMemberGroup = $AllUOSGroup | Where {$_.CN -like $NameSubMember}
                if (!$SubMemberGroup){ # Write-Host ("    ----")                   
                }elseif($SubMemberGroup.Count -eq 0){#Write-Host ("       not group")                         
                }elseif ($SubMemberGroup.Count -eq 1){#Write-Host ("       1 ++",$SubMemberGroup.Name)                        
                }else{
               #        Write-Host ("                    -2-",$SubMemberGroup.ToString().split(",")[0].substring(3))
               #        #Write-Host ("       ",$Member.wWWHomePage,"/",$Member.Name,"/",$Member.ObjectClass) -ForegroundColor Green
       
                }
            }
        }
    }
}

$i=0;
#foreach ($GCSV in $GroupCSV | Where {($_.DepParentCode -eq "") -and ($_.DepCode -ge 0)}){
foreach ($GCSV in $GroupCSV | Where {($_.DepCode -eq "737")}){
    $i++;
     if ($GCSV.Type -like         "*d"){     #Write-Host (" ", $GCSV.DepIndex,"",$GCSV.DepName) -ForegroundColor Green        
        }elseif ($GCSV.Type -like "*v"){     #Write-Host (" ", $GCSV.DepIndex," ",$GCSV.DepName) -ForegroundColor Yellow            
        }else{                               #Write-Host (" ",$GCSV.DepIndex," ",$GCSV.DepName)             
        } 
     foreach ($MemberGroup in $GroupCSV | Where {($_.DepParentCode -eq $GCSV.DepCode) -and ($_.DepCode -ge 0)}){
        if ($MemberGroup.Type -like "*v")   { #Write-Host ("       ",$MemberGroup.DepIndex," ",$MemberGroup.DepName) -ForegroundColor Yellow 
        }else{                                #Write-Host ("       ",$MemberGroup.DepIndex," ",$MemberGroup.DepName)
        }
        foreach ($MemberSubGroup in $GroupCSV | Where {($_.DepParentCode -eq $MemberGroup.DepCode) -and ($_.DepCode -ge 0)}){
                                              #Write-Host ("            ",$MemberSubGroup.DepIndex," ",$MemberSubGroup.DepName)
        }            
     }
     

    #Write-Host ($i,"==",$GCSV.DepName)
    #$Group = $AllUOSGroup # | Where {($_.Name -eq $GCSV.DepName) }    #-and ()
    #if (!$Group){#.Count -eq 0){
                #create group
                #Write-Host ("create group -- ",$GCSV.DepName)
                #New-ADGroup $GCSV.DepName -Path $RootDomainOU -scope g #`
							        #-desc { Description=($GCSV.DepFullName);`
									#	#DisplayNamePrintable=($DepCSVString.DepIndex+' '+$DepCSVString.DepFullName);`
									#	#extensionName=$DepCSVString.DepIndex;
                                    #    wWWHomePage=$GCSV.DepCode
                                    #    }
   # }
   # $Group = $AllUOSGroup | Where {($_.Name -eq $GCSV.DepName) } 
    #if ($Group){
   #         $User = $AllUOSUsers | Where {([int]$_.wWWHomePage -eq $GCSV.UserNumber)}
           # Write-Host ("Group >> ",$Group)
           # Write-Host ("UserNumber >> ",$GCSV.UserNumber, " = ",[int]$User.wWWHomePage )

    #       Write-Host ("User >> ",$User)
    #        if ($GCSV.UserNumber -eq [int]$User.wWWHomePage){
                #Set-ADGroup -Identity $Group `
				#			       -replace @{ Description=($GCSV.DepFullName);`
									#	#DisplayNamePrintable=($DepCSVString.DepIndex+' '+$DepCSVString.DepFullName);`
									#	#extensionName=$DepCSVString.DepIndex;
               #                         wWWHomePage=$GCSV.DepCode
                                     #   members=$User
               #                         }
            

            # Write-Host ($Group.Members)
            #if($Group.Members.IndexOf($User) -eq 0){
            #    Add-ADGroupMember -Identity $Group -member $User
           # }
     #      }
            
    #}     
}

#Write-Host "Оброблено $GrUpdated груп" -ForegroundColor Green
#Write-Host "Оброблено $OUUpdated OU" -ForegroundColor Green
"{0:dd} {0:MMMM} {0:yyyy} {0:T}" -f (Get-Date) 
