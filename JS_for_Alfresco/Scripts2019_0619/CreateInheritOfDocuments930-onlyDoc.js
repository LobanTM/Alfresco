//CreateInheritOfDocuments930-onlyDoc

var ownerName = document.getParent().properties["cm:title"];

if (people.getPerson(ownerName)){

	document.setInheritsPermissions(false);
	document.setPermission("Consumer", document.properties["cm:creator"]);
	document.setPermission("Coordinator", ownerName);
	document.save();
}