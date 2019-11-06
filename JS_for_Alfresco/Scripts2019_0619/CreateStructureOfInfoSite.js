/*
task: create structure of folder for Information Site
done: list of name root folders (name includes a parts of name group, can write to this folder )

solution: check Information site is exist
		loop by list
		for each root folder 
				create folder in "Sites/Infomation-site/documentLibrary/", if one did not exist
				set perissions:
					delete all permission by inherit -> setInheritsPermissions(false);	
					set permission WRITE for only group, include name folder, take shortName
				
				create subFolders for this root folder

*/


var infoSiteName = "Infomation-site";
var listNode = [
				{name	:"Бухгалтерія"	, //number	:"3.2.", 	
				 child 	:[ {name:"Шаблони", number:""},
				 		  {name:"Довідки", number:""}]},
			    {name	:"Канцелярія",	 //number	:"1.7.1.2.",	
				 child 	: [{name:"Вхідна кореспонденція", number:""},
				 		  {name:"Накази", number:""}]},
			    {name	:"Відділ кадрів", //number	:"1.7.1.1.",	
				 child 	:[ {name:"Заяви", number:""},
				 		  {name:"Довідки", number:""}]},
			    {name	:"Склад",		// number	:"3.3.",		
				 child 	:[ {name:"Службові", number:""},
				 		  {name:"Заяви", number:""}]},
			    {name	:"Відділ Інформаційних Технологій", //number	:"3.1.3.",	
				 child 	:[{name:"Службові", number:""},
				 		  {name:"Заяви", number:""}]}
			   ]

var nodeInfoSite = companyhome.childByNamePath("Sites/"+infoSiteName+"/documentLibrary/");
if (!nodeInfoSite) {
	status.setCode(status.STATUS_BAD_REQUEST, infoSiteName+" is not exist");	
}

for each (var nodeName in listNode){
	var node = companyhome.childByNamePath("Sites/"+infoSiteName+"/documentLibrary/"+nodeName.name) ; 
	if (!node){		
		if (!nodeInfoSite.createFolder(nodeName.name)){
					status.setCode(status.STATUS_BAD_REQUEST, nodeName.name+" is not created");
		}
	}
	node = companyhome.childByNamePath("Sites/"+infoSiteName+"/documentLibrary/"+nodeName.name) ; 
	if (!node){
		status.setCode(status.STATUS_BAD_REQUEST, nodeName.name+" is not exist");		
	}	
	logger.log(nodeName.name);	
	//permissions
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
	
}