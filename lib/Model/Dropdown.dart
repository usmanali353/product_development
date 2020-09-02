

class Dropdown{
  int id;
  String name;
  Dropdown(this.id, this.name);

  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"]=name;
    return map;
  }

  Dropdown.fromMap(Map<String,dynamic> data){
    id=data['id'];
    name=data["name"];
  }

}