//456testJS

var testGroup = "EVERYONE2";

//groups.getGroup(testGroup).getChildUsers()

for each (var group in groups.getGroup(testGroup).allGroups) {
	
	logger.log(group.displayName+" ("+group.shortName+")");
	
	
	
	//(group.getChildUsers()[0].shortName.toLowerCase())
		
	
	for (i = 0; i < group.getChildUsers().length; i = i + 1) {	
		
		var nodeUser = people.getPerson(group.getChildUsers()[i].shortName);
		logger.log("\t\t/" +nodeUser.properties["cm:firstName"]+" "+nodeUser.properties["cm:jobtitle"]);
		
		if ((nodeUser.properties["cm:jobtitle"].toLowerCase().indexOf("начальник", 0)>-1)
		   &&(nodeUser.properties["cm:jobtitle"].toLowerCase().indexOf("заступник", 0)==-1)
		   &&(group.displayName.toLowerCase().indexOf("департамент", 0))
		   ) {
			logger.log("== "+ nodeUser.properties["cm:userName"]+ " ==> занести в групу " +group.displayName);
			}
				
		}	
}			
		
		


	
