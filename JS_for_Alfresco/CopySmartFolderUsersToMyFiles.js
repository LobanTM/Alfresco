//CopySmartFolderUsersToMyFiles

var nodeFile = companyhome.childByNamePath("User Homes/dmsadmin1/IncomingSmartFolder");

//пройти по всем пользователям и скопировать им єту папку

logger.log(nodeFile.copy(companyhome.childByNamePath("User Homes/loban.tm")));