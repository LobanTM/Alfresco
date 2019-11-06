//CreateInheritOfDocuments930-onlyDoc

var ownerName = document.getParent().properties["cm:title"];

var nameParentFolder = document.displayPath.split("/")[2]+"/"
					 +document.displayPath.split("/")[3]+"/"
					 +document.displayPath.split("/")[4]+"/";
var ownerName = companyhome.childByNamePath(nameParentFolder).properties["cm:title"]

	logger.log(ownerName);

if (people.getPerson(ownerName)){

	document.setInheritsPermissions(false);
	document.setPermission("Collaborator", document.properties["cm:creator"]);
	document.setPermission("Coordinator", ownerName);
	document.save();
	
	/*
	var mailAddess = ownerName+"@uos.ua";
	var mail = actions.create("mail");   
	mail.parameters.to = mailAddess;   
	mail.parameters.subject = "додані файли до Спільні файли "+document.getParent().properties["cm:name"];   
	mail.parameters.from = document.properties["cm:creator"]+"@uos.ua";
	mail.parameters.text = "Вам додано файл "+document.name;  
	mail.execute(document); 
	*/
}