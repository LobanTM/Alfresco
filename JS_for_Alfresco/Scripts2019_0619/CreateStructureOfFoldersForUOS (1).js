var node = companyhome.childByNamePath("Shared");
var nameIncoming = "структурні підрозділи";

//if (node.exists()){	
	if (!companyhome.childByNamePath("Shared/"+nameIncoming)){
		 node.createNode(nameIncoming, "cm:folder");
	}		

var nodeIncoming = companyhome.childByNamePath("Shared/"+nameIncoming);
	if (!nodeIncoming){
		status.setCode(status.STATUS_BAD_REQUEST, nameIncoming + " is not exist");
		//return;
	}	
logger.log(nodeIncoming); 
//==========================================================================================================
		
var groupEveryoneName = "EVERYONE2";
var paging = utils.createPaging(-1, 0);

//var gr = groups.getAllRootGroups();
var gr = groups.getGroup(groupEveryoneName).getChildGroups();//

	
for each(var group in gr){
	//groups of depertments
	
		/// if ((group.getDisplayName().indexOf(" ", 0) == 3) || (group.getDisplayName().indexOf(" ", 0) == 4)){
			//filter for group
			 
			logger.log(group.getDisplayName());
			logger.log(group.getShortName());
			 
			//create folder
					
			var properties = new Array();
			properties['cm:title'] = group.getShortName();
				 
			var nodeFolder = companyhome.childByNamePath("Shared/"+nameIncoming+"/"+group.getDisplayName()) ;
			if (!nodeFolder){ 
				if (!if (!nodeIncoming.createNode(nameFolder, "cm:folder", properties)){){
					status.setCode(status.STATUS_BAD_REQUEST, group.getDisplayName()+"is not created");
				}
		 	} 
	/*
			nodeFolder = companyhome.childByNamePath("Shared/"+nameIncoming+"/"+group.getDisplayName()) ; 
			//logger.log(nodeFolder);
			
			nodeFolder.setInheritsPermissions(false);
			nodeFolder.setPermission("Contributor", "GROUP_"+groupEveryoneName);
			nodeFolder.setPermission("Coordinator", group.getShortName());
			 			 
			 
			var numberDepartment = group.getDisplayName().substr(0, 4);
					 
			var subGr = groups.getGroups(numberDepartment, paging);
			if (subGr){ 
				
				for each(var subGroup in subGr){
					
					if ((subGroup.getDisplayName().charAt(4) != 32)&&(subGroup.getDisplayName().charAt(6) == 32)){
						//groups of viddils		 			
						logger.log("	" + subGroup.getDisplayName());
						
						//create folder						
						var str = subGroup.getDisplayName().replace("\"", "");						
						
						var propSubFolder = new Array();
						propSubFolder['cm:title'] = subGroup.getShortName();	
						
						var nodeViddil = companyhome.childByNamePath("Shared/"+nameIncoming+"/"+group.getDisplayName()+"/"+str);
						//logger.log(nodeViddil); 
						if (!nodeViddil){ 
							if (!nodeDep.createFolder(str,propSubFolder)){
								status.setCode(status.STATUS_BAD_REQUEST, str+"is not created");
							}							
		 				} 
						
						nodeViddil = companyhome.childByNamePath("Shared/"+nameIncoming+"/"+group.getDisplayName()+"/"+str);
						nodeViddil.setInheritsPermissions(false);
						nodeViddil.setPermission("Contributor", "GROUP_"+groupEveryoneName);
						nodeViddil.setPermission("Coordinator", subGroup.getShortName());
						//logger.log(nodeViddil); 
						
						
						var numberVidiidl = subGroup.getDisplayName().substr(0, 6);						
			 
						var subSubGr = groups.getGroups(numberVidiidl, paging);
						if (subSubGr){ 
							
							for each(var subSubGroup in subSubGr){
					
								if ((subSubGroup.getDisplayName().charAt(6) != 32)&&(subSubGroup.getDisplayName().charAt(4) != 32)){
									//groups of viddils	
									
									var propSubSubFolder = new Array();
									propSubSubFolder['cm:title'] = subSubGroup.getShortName();	
									
									logger.log("		" + subSubGroup.getDisplayName());
									
									//
									if (!companyhome.childByNamePath("Shared/"+nameIncoming+"/"+group.getDisplayName()+"/"+str+"/"+subSubGroup.getDisplayName())){ 
										if (!nodeViddil.createFolder(subSubGroup.getDisplayName(),propSubSubFolder)){
											status.setCode(status.STATUS_BAD_REQUEST, subSubGroup.getDisplayName()+"is not created");
										}
		 							} 
									
								} //if			 
							}//for	
						}//if
						
					}//if
			 
				}//for
			}//if
		*/
			
		/// }//if
		 
		 
}//for

	