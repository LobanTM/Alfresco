//JSONSmartFolder

var smartFolderList = [{name:"Зовнішні документи", 	
					 	child:[ {id:"222",
					 			name:"публічні документи", 
								description:"документи всіх відкритих сайтів",
								nameSite:"info-site",
								nameFolder:"" 
						   		},
				 		  		{id:"223",
					 			name:"департамент фінансів", 
								description:"документи департаменту фінансів",
								nameSite:"fin-dep",
								nameFolder:"" 
						   		},
				 		  		{id:"224",
					 			name:"Договір", 
								description:"other documents",
								nameSite:"ppvts",
								nameFolder:"Договір" 
						   		}							   
						 	  ]
					    }			    
			   		 ]


//===============================================================================
var namePathSmartFolderTemplates = "smartFolderTest.json";

var nodeShared = companyhome.childByNamePath("Data Dictionary/Smart Folder Templates");

var nodeSmartFolder = nodeShared.childByNamePath(namePathSmartFolderTemplates);
											
if (nodeSmartFolder == null){
  	 nodeSmartFolder = nodeShared.createFile(namePathSmartFolderTemplates);
	}
if (nodeSmartFolder != null){   	
	
   //=======================================
   	var log = JSONFormat(smartFolderList);
   
	
   	nodeSmartFolder.content = log;
}else 
	logger.log(namePathSmartFolderTemplates + " does not exist");
	
//===============================================================================


function JSONFormat(list){
	
	for each (var node in list){
	
		var text = //node.name;
			"{"
			+"\n\"name\" : \""+node.name+"\","
			+"\n\"nodes\" : [";	
		
		var i = 0;
		for each (var childNode in node.child){	
			if (i>0) text += ",";i++;
			text +=folderNode(childNode.id, childNode.name,childNode.description,childNode.nameSite, childNode.nameFolder);			
		}			
		text += "\n	]";
		text += "\n}";
		
	}	
	return text;
}

function folderNode(numberNode, nameNode, description,nameSite, nameFolder){	
	
	var nameFolderF = "*";						
	//check folder companyHome/nameSite/documentLibrary/nameFolder isEXIST?
	if (companyhome.childByNamePath("Sites/"+nameSite+"/documentLibrary/"+nameFolder))
		 nameFolderF = "cm:"+nameFolder;	
	
	return 	 "{"
			+"\n	\"id\" : \""+numberNode+"\","
			+"\n	\"name\" : \""+nameNode+"\","
			+"\n	\"description\" : \""+description+"\","
			+"\n	\"search\" : {\"language\" : \"fts-alfresco\","
			+"\n		\"query\" : \"(PATH:\'/app:company_home/st:sites/cm:"+nameSite+"/cm:documentLibrary/" + nameFolderF + "\') \""
			+"\n		}"
			+"\n	}"
}


