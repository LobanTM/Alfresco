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
utils.disableRules();

for each(var userNode in people.getPeople(null)){
	user = utils.getNodeFromString(userNode);	
	
	var nameFolder = firstNamePlusInitialsPlusDepartment(user);	
	
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
	
	//nodeFolder.setInheritsPermissions(true);
	nodeFolder.setPermission("Contributor", "GROUP_"+groupEveryoneName);
	nodeFolder.setPermission("Coordinator", user.properties["cm:userName"]);	
				
	//if has folder with same owner --> rename folder !!!!
			
	//join rule to folder		
		
}//for

utils.enableRules();

//==================================================================================================
function firstNamePlusInitialsPlusDepartment(nodeUser){
	
	var userName = nodeUser.properties["cm:firstName"]+" "+nodeUser.properties["cm:lastName"];
	if (userName.indexOf("Admin", 0)==-1
	   	&& userName.indexOf("Guest", 0)==-1
		&& userName.indexOf("test", 0)==-1
	   ){
		var userInitials = "";		
	   var userInitialsSplitList = nodeUser.properties["cm:lastName"].split(" "); 
		for (var i=0; i<2; i++){
			if (userInitialsSplitList[i]) {userInitials += userInitialsSplitList[i].substr(0, 1)+".";}
		}	   
		var userName = nodeUser.properties["cm:firstName"]+" "+userInitials;
		
		var userOrganization = nodeUser.properties["cm:organization"];	
		if (userOrganization!=null){			
			//delete all "
			userOrganization = userOrganization.replace(new RegExp("\"", 'g'), "");		
			//take last part of userOrganization = name of viddil
			var userOrganizationSplitList = userOrganization.split(",");
			userOrganization = userOrganizationSplitList[userOrganizationSplitList.length-1];				
			}else
				userOrganization="-";			
			var nameFolder = userName
						  +"-"
						  +userOrganization;
		
		return nameFolder;
				//logger.log(nameFolder);	 	
		}
	else return null;
}	
//==================================================================================================