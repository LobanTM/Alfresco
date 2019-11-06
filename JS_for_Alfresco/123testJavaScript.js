//123testJavaScript

utils.disableRules();
//var nodeRootFolder = userFolderExist("123");

var smartFolderTest = "Smart Folder Test Loban"
var nodeMyFilesUser = companyhome.childByNamePath("User Homes/loban.tm/"+smartFolderTest);

	if (!nodeMyFilesUser)
	if (!companyhome.childByNamePath("User Homes/loban.tm").createFolder(smartFolderTest)){
		status.setCode(status.STATUS_BAD_REQUEST, "folder: "+ "loban.tm/"+smartFolderTest +" is not exist");
		//return;
	}	
	nodeMyFilesUser = companyhome.childByNamePath("User Homes/loban.tm/"+smartFolderTest);

//logger.log(nodeDoc.move(nodeMyFilesUser));

logger.log(nodeMyFilesUser.displayPath);

//nodeMyFilesUser.aspects.smf:smartFolderTemplate



//for each (var a in nodeMyFilesUser.aspects){	
//	logger.log(a); //.split("}")[1]);
//}

var prop = new Array();

var nodeJsonTest = companyhome.childByNamePath("Data Dictionary/Smart Folder Templates/smartFolderTest.json");
logger.log(nodeJsonTest);

prop["cm:template"] = companyhome.childByNamePath("Data Dictionary/Smart Folder Templates/smareFolderTest.json");

nodeMyFilesUser.addAspect("smf:customConfigSmartFolder", prop);
	//nodeMyFilesUser.get


for each (var a in nodeMyFilesUser.getAspects()){	
	logger.log(a); 
}

/*
var properties = new Array();
properties["cm:title"] = "loban.tm";

nodeRootFolder.createNode("0.05", "cm:folder", properties);

	for each(var f in nodeRootFolder.getChildren()){
		//if (f.properties["cm:name"].indexOf(nameRootFolder, 0)==0){
			//logger.log(nameRootFolder);
			//logger.log(f.properties["cm:name"].indexOf(nameRootFolder, 0));
			logger.log(f.properties["cm:name"]);
		//}	
	}
*/
utils.enableRules();

//==================================================================================================
function userFolderExist(nameFolder){
	var nodeShared = companyhome.childByNamePath("Shared");
	var nameRootFolder = nameFolder;//"кориcтувачі";

	var nodeRootFolder = companyhome.childByNamePath("Shared/"+nameRootFolder);
	
	//logger.log(nodeRootFolder);
	
	if (!nodeRootFolder) nodeShared.createNode(nameRootFolder, "cm:folder");
	
	nodeRootFolder = companyhome.childByNamePath("Shared/"+nameRootFolder);
	if (!nodeRootFolder) status.setCode(status.STATUS_BAD_REQUEST, "folder: "+ nameRootFolder +" is not exist");		
	
	nodeRootFolder = companyhome.childByNamePath("Shared/"+nameRootFolder);
	
	logger.log(nodeRootFolder);
	
	return nodeRootFolder;
	//logger.log(nodeIncoming); 
/*
	for each(var f in nodeShared.getChildren()){
		if (f.properties["cm:name"].indexOf(nameRootFolder, 0)==0){
			//logger.log(nameRootFolder);
			//logger.log(f.properties["cm:name"].indexOf(nameRootFolder, 0));
			logger.log(f.properties["cm:name"]);
		}
	
	}	
*/		
}

function userFolderExist2(nameFolder){
	var nodeShared = companyhome.childByNamePath("Shared");
	var nameRootFolder = nameFolder;//"кориcтувачі";

	var nodeRootFolder = companyhome.childByNamePath("Shared/"+nameRootFolder);	

	//logger.log(nodeIncoming); 

	for each(var f in nodeShared.getChildren()){
		//if (f.properties["cm:name"].indexOf(nameRootFolder, 0)==0){
			//logger.log(nameRootFolder);
			//logger.log(f.properties["cm:name"].indexOf(nameRootFolder, 0));
			logger.log(f.properties["cm:name"]);
			for each(var ff in f.getChildren()){
				logger.log(ff.properties["cm:name"]);
			}
		//}
	
	}	
		
}
//=================================================================================================


/*var nodes = search.luceneSearch('@name:123');

for each(var node in nodes) {
    logger.log(node.name + ' 	(' + node.typeShort + '): 	' + node.nodeRef);
}
//===============================================================================



//===============================================================================
// log the docs that currently contain the word 'Alfresco' to a log file
var logFile = space.childByNamePath("alf docs.txt");
if (logFile == null){
   logFile = space.createFile("alf docs.txt");
	}
if (logFile != null){
   // execute a lucene search across the repo for the text 'alfresco'
   var docs = search.luceneSearch("TEXT:alfresco");
   var log = "";
   for (var i=0; i<docs.length; i++)   {
      log += "Name: " + docs[i].name + "\tPath: " + docs[i].displayPath + "\r\n";
   		}
   logFile.content += log;
	}
	
//===============================================================================

*/