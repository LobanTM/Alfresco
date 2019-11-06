//CreateStructureOfFolderForUOSByUsers

var groupEveryoneName = "EVERYONE2";


var node = companyhome.childByNamePath("Shared");
var nameIncoming = "кориcтувачі";

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
var usersList = people.getPeople(null);

for each(var userNode in usersList){
	user = utils.getNodeFromString(userNode);	
	
	var userName = user.properties["cm:firstName"]+" "+user.properties["cm:lastName"];
	if (userName.indexOf("Administrator", 0)==-1
	   	&& userName.indexOf("Guest", 0)==-1
		&& userName.indexOf("test", 0)==-1
	   ){
		var userInitials = "";		
	   var userInitialsSplitList = user.properties["cm:lastName"].split(" "); 
		for (var i=0; i<2; i++){
			if (userInitialsSplitList[i]) {userInitials += userInitialsSplitList[i].substr(0, 1)+".";}
		}	   
		var userName = user.properties["cm:firstName"]+" "+userInitials;
		
		var userOrganization = user.properties["cm:organization"];	
		if (userOrganization!=null){			
			//delete all "
			userOrganization = userOrganization.replace(new RegExp("\"", 'g'), "");		
			//take last part of userOrganization = name of viddil
			var userOrganizationSplitList = userOrganization.split(",");
			userOrganization = userOrganizationSplitList[userOrganizationSplitList.length-1];				
			}else
				userOrganization="-";			
			var nameFolder = userName
						  +" "
						  +userOrganization;	
				logger.log(nameFolder);	 
				//create folder
	
			var properties = new Array();
			properties['cm:title'] = user.properties["cm:userName"];
			properties['cm:description'] = user.properties["cm:jobTitle"];
			
		
			var nodeFolder = companyhome.childByNamePath("Shared/"+nameIncoming+"/"+nameFolder) ;
			if (!nodeFolder){ 
				if (!nodeIncoming.createNode(nameFolder, "cm:folder", properties)){
					status.setCode(status.STATUS_BAD_REQUEST, nameFolder+"is not created");
				}
		 	}		
			nodeFolder = companyhome.childByNamePath("Shared/"+nameIncoming+"/"+nameFolder) ; 
			//logger.log(nodeFolder); 
			nodeFolder.setInheritsPermissions(false);
			nodeFolder.setPermission("Contributor", "GROUP_"+groupEveryoneName);
			nodeFolder.setPermission("Coordinator", user.properties["cm:userName"]);	
		
		//join rule to folder
		
		
		
	}//if	
	
}//for