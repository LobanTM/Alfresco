//UpdateFoldersSharedFiles

//for by folders
//	if folder exist - find user
//						if user exists --> rename folder
//						else (user not exists) --> move all files to User Home/<userName>/incoming
//												  folder - delete
//for by users
//	if user exist - find folder: folder.title==userName 
//						if folder exist --> remane folder
//						else ceate folder (Shared/<usersList>/<userName>+<user.organization>)


var nameRootFolder = "кориcтувачі"
var nodeRootFolder = userFolderExist(nameRootFolder);

utils.disableRules();

//for by folders			
for each (var f in nodeRootFolder.getChildren()){		
	
	var name = f.properties["cm:name"];						//name of folder (include first Name + Initials of User and Department)
	var ownerName = f.properties["cm:title"];				//only userName

	//var testDocument = f.createFile("test+"+ownerName+".txt");	
	if (ownerName){											//if folder has title (include userName)
		var nodeUser = people.getPerson(ownerName)			//find user by userName			
		
////  	moveToUserMyFiles(ownerName, f);
	
		//check user
		if (nodeUser){ 													//user exist			
			var newNameFolder = firstNamePlusInitialsPlusDepartment(nodeUser);		
		
			if (newNameFolder.indexOf(name,0)<0){			//user name - the same, but department is different 	
				logger.log(name +"	-->	"+ newNameFolder);
			
				f.setName(newNameFolder);	//rename folder	
				f.save();
			}	
			
			for each (var c in f.getChildren()){				
				c.setInheritsPermissions(false);
				c.setPermission("Coordinator", ownerName);						
			}		
		
		}else{											//user not exist
			logger.log("!!! "+ ownerName + "	get out")
			
			var myFilesOwnerPath = "Shared/"+nameRootFolder+"/"+name;
			
			moveToUserMyFiles(ownerName, myFilesOwnerPath);	
				
				
			//f.setName("-"+f.properties["cm:name"]);	//rename folder	
			//f.save();
			//delete folder		
			//logger.log("delete folder "+f.properties["cm:name"]+" "+f.remove());
					
		}
	}//if (ownerName){
		else logger.log(name + " folder has not owner");

}

for each(var nodeUser in people.getPeople(null)){
	u = utils.getNodeFromString(nodeUser);			
	
	if(u.properties["cm:userName"].indexOf("UOS",0)<0){
	
		var nameFolder = firstNamePlusInitialsPlusDepartment(u);
		if (nameFolder){

			var nodeFolder = companyhome.childByNamePath("Shared/"+nameRootFolder+"/"+nameFolder) ;
		
			var properties = new Array();
			properties["cm:title"] = u.properties["cm:userName"];		
	
			if (!nodeFolder){
			
				//for by folders
				/*for each (var f in nodeRootFolder.getChildren()){	
				
					if (f.properties["cm:title"].indexOf(u.properties["cm:userName"],0)<0){				//user has other organization
					
						f.setName(nameFolder);			//rename folder	
						f.save();
						for each (var c in f.getChildren()){				
							c.setInheritsPermissions(false);
							c.setPermission("Coordinator", f.properties["cm:title"]);						
						}
					}
				}
				*/
				if (!nodeRootFolder.createNode(nameFolder, "cm:folder", properties)){					//folder not exist
					status.setCode(status.STATUS_BAD_REQUEST, nameFolder+" is not created");
					}			
			}
		
			nodeFolder = companyhome.childByNamePath("Shared/"+nameRootFolder+"/"+nameFolder) ;
			nodeFolder.setInheritsPermissions(true);
			nodeFolder.setPermission("Contributor", "GROUP_EVERYONE2");
			nodeFolder.setPermission("Coordinator", u.properties["cm:userName"]);
		
			//====   LINK   =================================================================================================
		/*	var targetNode = companyhome.childByNamePath("User Homes/"+ u.properties["cm:userName"]+"/.Посилання"); //куда поместить link ()
			//nodeFolder - тека, на яку буде посилання
			if(targetNode){
				var nameLink = "."+nameFolder+".url";
				//создание link
				var propertiesLink = [];
				propertiesLink["cm:name"]= nameLink;
				propertiesLink["cm:title"]= u.properties["cm:userName"];
				propertiesLink["cm:destination"]= nodeFolder.nodeRef.toString();
		
				var linkNode =  companyhome.childByNamePath("User Homes/"+ u.properties["cm:userName"]+"/"+nameLink);
				if(!linkNode){
					linkNode = targetNode.createNode(nameLink,"{http://www.alfresco.org/model/application/1.0}filelink", propertiesLink);
					linkNode.save();
		
					//logger.log(linkNode);
				}	
			}
		*/	
			//===============================================================================================================
		
		}//if (nameFolder)
	}
	
}//for


utils.enableRules();

//==================================================================================================

//==================================================================================================

//==================================================================================================
function moveToUserMyFiles(ownerName, folderSharedName){
	//move files to --> User Home/<ownerName>/incoming
	
	//for each (var c in folderShared.getChildren()){
		
		var folderShared = companyhome.childByNamePath(folderSharedName);
	
		//var nameFolderFromShare = "LastFilesFromShared";
	
		var nodeIncoming = companyhome.childByNamePath("User Homes/"+ ownerName);// +"/"+folderShared);
		//if (!nodeIncoming)
		//if (!companyhome.childByNamePath("User Homes/"+ ownerName).createFolder(nameFolderFromShare)){
		//	status.setCode(status.STATUS_BAD_REQUEST, "folder: "+  ownerName + "/"+nameFolderFromShare +" is not exist");
		//	//return;
		//}	
		//nodeIncoming = companyhome.childByNamePath("User Homes/"+ ownerName +"/"+nameFolderFromShare);			
		
		logger.log(folderShared.move(nodeIncoming) +" move to " + nodeIncoming.name);//+"User Homes/"+ ownerName);// +"/"+folderShared);
	
		
	
		//?? what do, if content with this name already exist ??
	//}	
	
}
//==================================================================================================
/*
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
		if (userOrganization){			
			//delete all "
			userOrganization = userOrganization.replace(new RegExp("\"", 'g'), "");		
			//take last part of userOrganization = name of viddil
			var separator = ", ";
			if (userOrganization.indexOf(separator, 0)==-1) separator = ". ";			
			
			var userOrganizationSplitList = userOrganization.split(separator);			
			userOrganization = userOrganizationSplitList[userOrganizationSplitList.length-1];
			if (userOrganization.indexOf(".")>-1){
				userOrganization = userOrganization.split(" ")[1]
			}
			
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
*/
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
function userFolderExist(nameFolder){
	var nodeShared = companyhome.childByNamePath("Shared");
	var nameRootFolder = nameFolder;//"кориcтувачі";

	var nodeRootFolder = companyhome.childByNamePath("Shared/"+nameRootFolder);
	
	if (!nodeRootFolder) nodeShared.createNode(nameRootFolder, "cm:folder");
	
	nodeRootFolder = companyhome.childByNamePath("Shared/"+nameRootFolder);
	if (!nodeRootFolder) status.setCode(status.STATUS_BAD_REQUEST, "folder: "+ nameRootFolder +" is not exist");	
	
	return nodeRootFolder;
	//logger.log(nodeIncoming); 
}
//=================================================================================================
