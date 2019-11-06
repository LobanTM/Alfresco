//CreateInheritOfFolderUOS.js

//var nodeShared = companyhome.childByNamePath("Shared");
var nameIncoming = "структурні підрозділи";
var nodeIncoming = companyhome.childByNamePath("Shared/"+nameIncoming);
	if (!nodeIncoming){
		status.setCode(status.STATUS_BAD_REQUEST, nameIncoming + " is not exist");
		//return;
	}	


		//create GROUP_EVERYONE2 with all users, add by groups
		var groupEveryoneName = "EVERYONE2";

		if (! groups.getGroup(groupEveryoneName)){
			groups.createRootGroup(groupEveryoneName, groupEveryoneName);	
		}
		var groupEveryone = groups.getGroup(groupEveryoneName);

		var gr = groups.getAllRootGroups();
		for each (var group in gr){		
		
			if (/^\d+$/.test(group.shortName)){ //group.shortName include ONLY NUMBER	
	
			groupEveryone.addAuthority(group.fullName);
			//logger.log(group.shortName);
			}//if	
		}

var nodeContent = nodeIncoming.getChildren();

//var cont = nodeContent[0];
//cont.getChildren();

for each (var c in nodeContent){	
	
	//logger.log(findGroupByFullName(c.getName()).displayName.split(" ")[0]);	
	var nodeGroupC = findGroupByFullName(c.getName().split(" ")[0]);
	if (nodeGroupC){
	c.setInheritsPermissions(false);
	c.setPermission("Write", "GROUP_"+groupEveryoneName);
	c.setPermission("Read", "GROUP_"+groupEveryoneName);	
	c.setPermission("Write", nodeGroupC.fullName);	
		
	
		
		
		
		var nodeSubContent = c.getChildren();
		for each (var sc in nodeSubContent){		
	
			var nodeGroupSubC = findGroupByFullName(sc.getName().split(" ")[0]);
			if (nodeGroupSubC){
			sc.setInheritsPermissions(false);
			sc.setPermission("Write", "GROUP_"+groupEveryoneName);
			sc.setPermission("Read", "GROUP_"+groupEveryoneName);
			sc.setPermission("Write", nodeGroupSubC.fullName); 		
				
				var nodeSubSubContent = sc.getChildren();
				for each (var ssc in nodeSubSubContent){		
	
					var nodeGroupSubSubC = findGroupByFullName(ssc.getName().split(" ")[0]);
					if (nodeGroupSubSubC){
					ssc.setInheritsPermissions(false);
					ssc.setPermission("Write", "GROUP_"+groupEveryoneName);
					ssc.setPermission("Read", "GROUP_"+groupEveryoneName);
					ssc.setPermission("Write", nodeGroupSubSubC.fullName);				
				
					}	
				}		
				
			}	
		}
		
	}
	
}

var nodeMembers = people.getGroup("GROUP_443");

if(nodeMembers){
    model.members = people.getMembers(nodeMembers); 	
	
	for each (var mem in model.members){		
		var m =  mem.properties['cm:userName'];	
		logger.log(m);
	}	
}

//=================================================================================
function findGroupByFullName(fullName){	
	var nodeGroups = groups.getGroups(null, utils.createPaging(-1, 0));	
	for each (var g in nodeGroups){	
		//logger.log(g.displayName);
		//logger.log(g.fullName.substr(6));	
		if (g.displayName.indexOf(fullName, 0) >-1){
			//logger.log(g.displayName);
			return groups.getGroup("GROUP_"+g.fullName.substr(6));
		}	
	}
}