

class Dropdown{
  int id;
  String name,stringId;
  Dropdown(this.id, this.name,this.stringId);

  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"]=name;
    map["stringId"]=stringId;
    return map;
  }

  Dropdown.fromMap(Map<String,dynamic> data){
    id=data['id'];
    name=data["name"];
    stringId=data['stringId'];
  }

}