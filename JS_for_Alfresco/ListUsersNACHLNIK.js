//ListUsersNACHLNIK

var listNach =  ["Начальник",  "Завідувач",  "Керівник",  "бухгалтер", 			"Головний бухгалтер", "Головний інженер"];
var listNach1 = ["начальника", "завідувача", "керівника", "головного бухгалтера","", 				  "головного інженера"];
var listNachGroup = ["nach"];

var listZastNach = ["Заступник"];
var listZastNachGroup = ["zam"];

var listDep =  ["департамент",  "апарат"];
var listDep1 = ["департаменту", "апарату"];
var listDepGroup = ["Dep"];

var listViddil =  ["відділ",  "служб",  "груп",  "канцеляр",   "бухгалтер",  "центр"];
var listViddil1 = ["відділу", "служби", "групи", "канцелярії", "", 			 "центру"];
var listViddilGroup = ["Viddil"];

var i = 1;

//for each (var v in groups.getGroup("930").getParentGroups())
//	logger.log(v.shortName);
//	logger.log(groups.getGroup("930").getParentGroups()[0].shortName);


logger.log("=======================================")
for each(var group in groups.getGroup("EVERYONE2").getChildGroups(utils.createPaging(-1, 0), "displayName")){
	logger.log(group.displayName+" ("+group.shortName+")");
	
	for each (var u in group.getChildUsers()){		
		
		for each (var l in groupNach(u)){
			logger.log(l);
		
		}
		i++;
	}
	
	for each(var subGroup in group.getChildGroups(utils.createPaging(-1, 0), "displayName")){
		logger.log("\t"+"\t"+subGroup.displayName+" ("+subGroup.shortName+")");
		for each (var uSubGroup in subGroup.getChildUsers()){	
			
			for each (var l in groupNach(uSubGroup))
				logger.log("\t"+"\t"+"\t"+l);
			i++;
		}
	
	}
}

//=================================================================================================
function groupNach(user){
	var result = "\t"+user.fullName+" / ";
	var nameGroupNach = [];
	var i = 0;
	
	var o = "--";
	if (user.person.properties["cm:organization"]){
		o = user.person.properties["cm:organization"];
		o = o.split(", ")[o.split(",").length-1];
	}	
	
	for each (var job in user.person.properties["cm:jobtitle"].split("-")){	
		var nach = null;
		var zam = null;
		var dep = null;
		var viddil = null;
		
		for each (var n in listNach) 		if (job.toLowerCase().indexOf(n.toLowerCase(), 0)>-1) nach = n;
		for each (var z in listZastNach) 	if (job.toLowerCase().indexOf(z.toLowerCase(), 0)>-1) zam = z;
		for each (var d in listDep) 		if (job.toLowerCase().indexOf(d.toLowerCase(), 0)>-1) dep = listDep1[listDep.indexOf(d, 0)];
		for each (var v in listViddil) 		if (job.toLowerCase().indexOf(v.toLowerCase(), 0)>-1) viddil = listViddil1[listViddil.indexOf(v, 0)];
	
	
		if (zam) nach = listNach1[listNach.indexOf(nach, 0)];
	
		if (nach && !dep && !viddil){
			for each (var d in listDep) if (o.toLowerCase().indexOf(d, 0)>-1) dep = listDep1[listDep.indexOf(d, 0)];
			for each (var v in listViddil) if (o.toLowerCase().indexOf(v, 0)>-1) viddil = listViddil1[listViddil.indexOf(v, 0)];
		}		
		
		//result += job;
		if (zam || nach || dep || viddil){
			result += " ==> створити групу ==> ";
			//result += "("+groups.getGroup(user.person.properties["cm:organizationId"]).shortName+")";
			//result += user.person.properties["cm:organization"].split(" ")[0];			
			nameGroupNach[i] = user.person.properties["cm:organization"].split(" ")[0]+" ";
		}	
		
		var numGroup = groups.getGroup(user.person.properties["cm:organizationId"]).shortName;	
		
		if (zam) {
			//result += zam ;
			nameGroupNach[i] += "zam";
			numGroup = groups.getGroup(user.person.properties["cm:organizationId"]).getParentGroups()[0].shortName;			
		}
		if (nach) {
			//result += " "+ nach ;
			nameGroupNach[i] += "nach";
		}
		if (dep) {
			//result += " "+dep ;
			nameGroupNach[i] += "Dep";
		}
		if (viddil){
			//result += " "+viddil ;
			nameGroupNach[i] += "Viddil";
		}
		//result += "|*|";
		
		if (zam || nach || dep || viddil){			
			nameGroupNach[i] += " ===>> "+user.fullName+"("+job+") "+" {"+numGroup+"}";
		}
		i++;
	}	
	
	//return result;	
	return nameGroupNach;
}