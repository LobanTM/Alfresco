//CheckUser

var groupEveryoneName = "EVERYONE2";
//=======================================================================================
logger.log("userName \t\t// структурний підрозділ\t\t\t|| група ");
logger.log("=======================================================================================");

for each (var u in people.getPeople(null)){	
	var user = utils.getNodeFromString(u);
	
	
	//display userName, viddil and list of users groups
	
	var o = "--";	
	if (user.properties["cm:organization"])  o = user.properties["cm:organization"];	
	
	if (listUsersGroup(user).length == 0){
		logger.log(user.properties["cm:firstName"]+" "
				   //+ user.properties["cm:lastName"] 
				  +"\t\t//"
			   //+user.properties["cm:organizationId"]+" "
				//+user.properties["cm:organization"]+" "   
				   
			   +o.split(", ")[o.split(",").length-1]
				  );
		logger.log("\t\t\t\t\t\t\t\t\t"+"груп немає");
	}
	
	for each (var g in listUsersGroup(user)){	//list all users GROUPS	
				
		if (groups.getGroup("GROUP_"+g)){
			
			
			//diffence viddils and groups	
			if ((listUsersGroup(user).length>1)									//user has count groups more one
				//||(g.indexOf(user.properties["cm:organizationId"], 0)==-1)	 //group has number not same like user.orgId
			   ){
				
				//logger.log(groups.getGroup("GROUP_"+g).displayName);
				
				logger.log(user.properties["cm:firstName"] +"\t\t//"
			   	//	+user.properties["cm:organization"]+" "
					+o.split(" ")[0]+" "	   
					+o.split(", ")[o.split(",").length-1]
						  );				
				
				logger.log("\t\t\t\t\t\t\t\t\t"+groups.getGroup("GROUP_"+g).displayName);
			}
			
		}
			
	}
	
}


//============== FUNCTIONS ===================================================
function listUsersGroup(user){
	var list = [];		   
	var i = 1;
	for each (var p in user.getParents()){
				
		if (p.type.indexOf("authorityContainer", 0)>-1){				
			for (var l in p.properties) {				
				
				/*if(l.split("}")[1].indexOf("authorityDisplayName", 0)>-1){				
					var str = p.properties[l];					
					if (str.indexOf("site", 0)==-1)					
						list.push(i+" -> "+p.properties[l]);
				}
				*/
				if(l.split("}")[1].indexOf("authorityName", 0)>-1){
					var str = p.properties[l].split("_")[p.properties[l].split("_").length-1];					
					if (str.toLowerCase().indexOf("site", 0)==-1)					
						list.push(str);
				}
			}
		i++;	
		}		
	}
	return list;
}


	
