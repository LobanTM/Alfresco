//CheckUser

var groupEveryoneName = "EVERYONE2";
//=======================================================================================
//people.getPeople(null)[0].
for each (var u in people.getPeople(null)){
	var user = utils.getNodeFromString(u);
	
	
	//getGroupByUser(user, "");	
	
	for each (var userGroup in getGroupsByUser(user, "")){
		
		if (user.properties["cm:organization"]){		
	
		var structDepartmentOfUser = user.properties["cm:organizationId"]+" "+user.properties["cm:organization"].split(", ")[user.properties["cm:organization"].split(",").length-1];	
			
		if (userGroup.indexOf(structDepartmentOfUser)==-1)	{
			
			var log ="|" + user.properties["cm:firstName"]+"|";
			
			if (log.length<8 ) log += "\t";
			
				log += "\t"+" || "+userGroup
				
			//if (log.length<40) log += "\t";
			if (log.length<44) log += "\t";			
			if (log.length<49) log += "\t";			
			if (log.length<54) log += "\t";
			//if (log.length<56) log += "\t";
				  	 
				log += " || "+structDepartmentOfUser;
			
			logger.log(log);
			}
		}
	}
	
}

function getGroupsByUser(user, nameGroup){
	var list = [];
	
	for each (var g in groups.getGroup(groupEveryoneName).getChildGroups()){		
		
		for each (var m in g.getAllUsers()){
			//if (user)
			if (user.properties["cm:userName"].indexOf(m.person.properties["cm:userName"],0)>-1){
			//if ((user.properties["cm:organizationId"]+" "+user.properties["cm:organization"]).indexOf(g.getDisplayName(), 0)==-1)	
			list.push(g.getDisplayName());
			//logger.log("\t"+user.properties["cm:userName"]+"\t"+g.getDisplayName());				
			//logger.log("\t!!!"+user.properties["cm:userName"]+"\t"+m.person.properties["cm:userName"]);				
			}			
		}
		
		for each (var subG in g.getChildGroups()){
			for each (var m in subG.getAllUsers()){
				//if (user)
				if (user.properties["cm:userName"].indexOf(m.person.properties["cm:userName"],0)>-1){
				
					//if ((user.properties["cm:organizationId"]+" "+user.properties["cm:organization"]).indexOf(subG.getDisplayName(), 0)==-1)	{
					list.pop();					
					list.push(subG.getDisplayName());
						//logger.log("\t"+user.properties["cm:userName"]+"\t"+g.getDisplayName());				
						//logger.log("\t!!!"+user.properties["cm:userName"]+"\t"+m.person.properties["cm:userName"]);
					//}
				}			
			}
		}
		
	}		
	return list;	
}
	
