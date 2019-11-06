//CreateJoinRuleToFolder

var node = companyhome.childByNamePath("Shared");
var nameIncoming = "структурні підрозділи";

//if (node.exists()){	
	if (!companyhome.childByNamePath("Shared/"+nameIncoming)){
		 node.createNode(nameIncoming, "cm:folder");
	}		

var nodeIncoming = companyhome.childByNamePath("Shared/"+nameIncoming);
	if (!nodeIncoming){
		status.setCode(status.STATUS_BAD_REQUEST, "folder: "+ nameIncoming +" is not exist");
		//return;
	}	
//logger.log(nodeIncoming); 
//==========================================================================================================
	var name123 = "123";

	//if (node.exists()){	
	if (!companyhome.childByNamePath("Shared/"+name123)){
		 node.createNode(name123, "cm:folder");
	}		
	
	var node123 = companyhome.childByNamePath("Shared/"+name123);
	if (!node123){
		status.setCode(status.STATUS_BAD_REQUEST, "folder: "+ name123 +" is not exist");
		//return;
	}	




var listAspects = nodeIncoming.getAspects();


//var node = companyhome.getNodeFromString(listAspects[0]);
//node.properties["cm:name"]

var node = null;
for each(var a in listAspects){
	
	if (a.split("}")[1].indexOf("rules", 0)>-1){
		
		node = utils.getNodeFromString(a);
		//logger.log(node);
		//logger.log(a);
		//return node;
		
	}	
}

logger.log(node);

node123.addAspect("rule:rules");

/*
//nodeIncoming.getChildren()[0].move(destination)
for each (var f in listFolders){	
	logger.log(f.properties["cm:name"]);
	
	var userNode = getUserByFirstNameAndDepatrment(f.properties["cm:name"]);
	
	if (!userNode){		
		logger.log("!!!** "+f.properties["cm:name"]+" user get out") ;		
	}else{
		
		if (userNode.properties["cm:organization"].indexOf(char, from))
		
		logger.log("user " + userNode.properties["cm:firstName"] + " change department " + userNode.properties["cm:organization"]);
	}		
		
	
	var folderChildren = f.getChildren();
	//f.getChildren()[0].getP
	for each (var fc in folderChildren){
		//if (fc.isFolder)
		logger.log(fc.properties["cm:name"]);		
	}	
}




function getUserByFirstNameAndDepatrment(nameFolder){	
	
	var firstNameWithoutInit = nameFolder.split(" ")[0];	
	var initial1 = nameFolder.split(" ")[1].split(".")[0];	
	var initial2 = nameFolder.split(" ")[1].split(".")[1];	
	var department = nameFolder.substr(firstNameWithoutInit.length+6, nameFolder.length-1);		
	
	var usersList = people.getPeople(null);
	for each(var node in usersList){
			user = utils.getNodeFromString(node);
	
		if (user.properties["cm:firstName"].indexOf(firstNameWithoutInit, 0)>-1		   	
			&& user.properties["cm:lastName"].indexOf(initial1, 0)==0
			&& user.properties["cm:lastName"].split(" ")[1].indexOf(initial2, 0)==0
	  		 ){			
		
			var userOrganization = user.properties["cm:organization"].replace(new RegExp("\"", 'g'), "");
			if (userOrganization.indexOf(department, 0)>-1){		
			//logger.log(user.properties["cm:firstName"]+"/"+user.properties["cm:lastName"]+"/"+user.properties["cm:organization"]);
				return user;
			}else {
				return user;
			}
			
			
		}
	}	
}
*/