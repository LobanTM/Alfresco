//CreateAddittionalGROUPS

var groupEveryoneName = "EVERYONE2";

var testGroup = "849";

var groupZams = groups.getGroup("7777 allZams"); 
if (!groupZams)
	groupZams = groups.getGroup(testGroup).createGroup("7777 allZams", "заступники директора");
var groupNachDeps = groups.getGroup("8888 allDeps"); 
if (!groupNachDeps)
	groupNachDeps = groups.getGroup(testGroup).createGroup("8888 allDeps", "начальники департаментів");
var groupNachViddils = groups.getGroup("9999 allViddils"); 
if (!groupNachViddils)
	groupNachViddils = groups.getGroup(testGroup).createGroup("9999 allViddils", "начальники структурних підрозділів");

//groups.getGroup(testGroup). .allUsers .getAllUsers() people.get

for each (var group in groups.getGroup(testGroup).allGroups) {
	//logger.log("исходная група\t"+group.displayName);
	
	var subGroup = createGroupNach(group);	
	if (subGroup) {
		logger.log("створено теку "+ subGroup.displayName+" ("+subGroup.shortName+")");
		
		//додавання користувачів в групу
		logger.log("всі користувачі групи "+ group.displayName+" ("+group.shortName+")")
		for (i = 0; i < group.getChildUsers().length; i = i + 1) {	
		
			var nodeUser = people.getPerson(group.getChildUsers()[i].shortName);
			logger.log("\t\t/" +nodeUser.properties["cm:firstName"]);
			
			
			
			}	
		
		
		
		}
	
}


//groups.getGroup(testGroup).parentGroups.
for each (var group in groups.getGroup(testGroup).allGroups){
	//logger.log("parent for ==> "+group.displayName+" ("+group.shortName+")");
	//---------------------------------------------	
	if ((group.shortName.indexOf("nachDep", 0)>-1)		
		){
			var nodeParentGroup=null;
			for each (var p in group.parentGroups){
				if (p.shortName.indexOf("allDeps", 0)>-1){
						nodeParentGroup = p;
					//logger.log("\t\t"+p.displayName+" ("+p.shortName+")");
					}
				}			
			if (!nodeParentGroup){
					groupNachDeps.addAuthority("GROUP_"+group.shortName);
					logger.log("до " + groupNachDeps.displayName+" ("+groupNachDeps.shortName+")" + " додано групу "+group.displayName+" ("+group.shortName+")");
				}
		}
	//---------------------------------------------
	if ((group.shortName.indexOf("nachVid", 0)>-1)		
		){
			var nodeParentGroup=null;
			for each (var p in group.parentGroups){
				if (p.shortName.indexOf("allViddils", 0)>-1){
						nodeParentGroup = p;				
					}
				}			
			if (!nodeParentGroup){
					groupNachViddils.addAuthority("GROUP_"+group.shortName);
					logger.log("до " + groupNachViddils.displayName+" ("+groupNachViddils.shortName+")" + " додано групу "+group.displayName+" ("+group.shortName+")");
				}
		}
	//---------------------------------------------
	if ((group.shortName.indexOf("zam", 0)>-1)		
		){
			var nodeParentGroup=null;
			for each (var p in group.parentGroups){
				if (p.shortName.indexOf("allZams", 0)>-1){
						nodeParentGroup = p;
					//logger.log("\t\t"+p.displayName+" ("+p.shortName+")");
					}
				}			
			if (!nodeParentGroup){
					groupZams.addAuthority("GROUP_"+group.shortName);
					logger.log("до " + groupZams.displayName+" ("+groupZams.shortName+")" + " додано групу "+group.displayName+" ("+group.shortName+")");
				}
		}
}	


//=========================================================================================================
function createGroupNach(group){
	
	var result = null;

	//logger.log("**" +group.displayName+" ("+group.shortName+")");
	
	if ((group.shortName.indexOf("Dep", 0)==-1)&&(group.shortName.indexOf("nach", 0)==-1)
		&& !groups.getGroup(group.displayName.split(" ")[0]+ " nachDep")
		){
		if (group.displayName.toLowerCase().indexOf("департамент", 0)>-1){			
			result = group.createGroup(group.displayName.split(" ")[0]+ " nachDep", "начальник департаменту");					
			}
		
		if (group.displayName.toLowerCase().indexOf("апарат", 0)>-1){			
			result = group.createGroup(group.displayName.split(" ")[0]+ " nachDep", "керівник апарату");
			}					
		
		if (group.displayName.toLowerCase().indexOf("комплекс", 0)>-1){			
			result = group.createGroup(group.displayName.split(" ")[0]+ " nachDep", "начальник комплексу");		
			}
		}
	
		
	if ((group.shortName.indexOf("Vid", 0)==-1)&&(group.shortName.indexOf("nach", 0)==-1)
		&& !groups.getGroup(group.displayName.split(" ")[0]+ " nachVid")		
		){
		
		if (group.displayName.toLowerCase().indexOf("відділ", 0)>-1){
			result = group.createGroup(group.displayName.split(" ")[0]+ " nachVid", "начальник відділу");
	
			}
		if (group.displayName.toLowerCase().indexOf("служба", 0)>-1){
			result = group.createGroup(group.displayName.split(" ")[0]+ " nachVid", "начальник служби");
	
			}
		if (group.displayName.toLowerCase().indexOf("сектор", 0)>-1){
			result = group.createGroup(group.displayName.split(" ")[0]+ " nachVid", "керівник сектору");
	
			}
		
		
		}
	return result;
}

