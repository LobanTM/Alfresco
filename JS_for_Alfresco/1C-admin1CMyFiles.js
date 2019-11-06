//1C-admin1CMyFiles
var infoSiteName = "admin1C";

var nodeAdmin1CMyFiles = companyhome.childByNamePath("User Homes/"+infoSiteName);

if (!nodeAdmin1CMyFiles) {
	status.setCode(status.STATUS_BAD_REQUEST, infoSiteName+" is not exist");	
}

for each (var u in people.getPeople(null)){
	var user = utils.getNodeFromString(u);
	var userName = user.properties["cm:userName"];
			
				//!!! ONLY FOR USER 1C =============================================== !!!
	if (userName.indexOf("admin1C", 0)==-1
	   	&& userName.indexOf("guest", 0)==-1
		&& userName.indexOf("test", 0)==-1
	   ){
	
		var nameFolder = "User Homes/"+infoSiteName+"/"+user.properties["cm:userName"];	
	
		if (!companyhome.childByNamePath(nameFolder)){		
			if (!nodeAdmin1CMyFiles.createFolder(user.properties["cm:userName"])){
					status.setCode(status.STATUS_BAD_REQUEST, user.properties["cm:userName"]+" is not created");
			}
		}
		var nodeFolder = companyhome.childByNamePath(nameFolder);	
	
	
		if (!nodeFolder) {
			status.setCode(status.STATUS_BAD_REQUEST, nameFolder+" is not exist");		
		}	
	
		logger.log(nodeFolder.name);	
	
	
		//permissions
		nodeFolder.setPermission("Coordinator", user.properties["cm:userName"]);
	
		}
	
	/*
	if (groups.getGroup("GROUP_UOS")){
		node.setInheritsPermissions(false);	
		node.setPermission("Read", "GROUP_UOS");
	}	
	
	node.setPermission("Write", "GROUP_"+groups.getGroups("*"+nodeName.name+"*", utils.createPaging(1, 0))[0].getShortName());	
	
	//children folders
	for each (var childNode in nodeName.child){
		var nodeFolder = companyhome.childByNamePath("Sites/"+infoSiteName+"/documentLibrary/"+nodeName.name+"/"+childNode.name);
		if (!nodeFolder){		
			if (!node.createFolder(childNode.name)){
					status.setCode(status.STATUS_BAD_REQUEST, childNode.name+" is not created");
			}
		}
		//logger.log(childNode.name);
		nodeFolder = companyhome.childByNamePath("Sites/"+infoSiteName+"/documentLibrary/"+nodeName.name+"/"+childNode.name);
		nodeFolder.setInheritsPermissions(true);
	}
	*/
}
