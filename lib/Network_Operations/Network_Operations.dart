import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Dashboard.dart';

 class Network_Operations{
  static void signIn(BuildContext context,String email,String password) async {
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    var body=jsonEncode({"email":email,"password":password});
    try{
    var response=await http.post(Utils.getBaseUrl()+"Account/Login",body:body,headers: {"Content-type":"application/json"});
     if(response.statusCode==200){
       pd.hide();
       SharedPreferences.getInstance().then((prefs){
         prefs.setString("token", jsonDecode(response.body)['result']);
         prefs.setString("email", email);
       });
       Utils.showSuccess(context, "Login Successful");
       Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>Dashboard()),(Route<dynamic> route) => false);
     }else{
       pd.hide();
     }
    }catch(e) {
      pd.hide();
      Utils.showError(context, e.toString());
    }
  }
  static void register(BuildContext context,String email,String password,String name) async{
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    var body=jsonEncode({"email":email,"password":password,"firstname":name,"confirmPassword":password});
    try{
      var response=await http.post(Utils.getBaseUrl()+"account/Register",body:body,headers: {"Content-type":"application/json"});
      if(response.statusCode==200){
        Utils.showSuccess(context, "User Registration successful");
      }else{
        pd.hide();
        Utils.showError(context, response.body.toString());
      }
    }catch(e){
      pd.hide();
      Utils.showError(context, e.toString());
    }
  }
  static Future<List<Dropdown>> getDropDowns(BuildContext context,String token,String endpoint)async{
    try{
      var response=await http.get(Utils.getBaseUrl()+"Configuration/"+endpoint+"Dropdown",headers:{"Authorization":"Bearer "+token});
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        List<Dropdown> list=List();
        list.clear();
        for(int i=0;i<data.length;i++){
          list.add(Dropdown(data[i]["id"],data[i]["name"]));
        }
        print(data.toString());
        return list;
      }
    }catch(e){
      print(e);
      Utils.showError(context, e.toString());
    }
    return null;
  }
  static Future<List<Request>> getRequest(BuildContext context,String token)async{
    try{
      var response=await http.get(Utils.getBaseUrl()+"Request/GetAllRequests",headers:{"Authorization":"Bearer "+token});
      if(response.statusCode==200){
        List<Request> requests=[];
        for(int i=0;i<jsonDecode(response.body).length;i++){
          requests.add(Request.fromMap(jsonDecode(response.body)[i]));
        }
        return requests;
      }
    }catch(e){
      print(e);
      Utils.showError(context, e.toString());
    }
    return null;
  }
  static void changeStatusOfRequest(BuildContext context,String token,int requestId,int status) async{
   // ProgressDialog pd=ProgressDialog(context);
    try {
      var response = await http.get(Utils.getBaseUrl() + "Request/ChangeStatusOfRequest/$requestId?StatusId=$status", headers: {"Authorization": "Bearer " + token});
      if (response.statusCode == 200) {
        Navigator.pop(context,"Refresh");
         Utils.showSuccess(context, "Status Changed");
      }
    }catch(e){
      print(e);
      Utils.showError(context, "Status not Changed");
    }
  }
  static void saveRequest(BuildContext context,String token,Request request) async {
    ProgressDialog pd=new ProgressDialog(context);
    pd.show();

    try{
      final body = jsonEncode({
        "requestId":request.requestId,
        "date":DateTime.now(),
        "marketId":request.marketId,
        "event": request.event,
        "userId":request.userId,
        "technicalConcentration": request.technicalConcentration,
        "statusId": request.statusId,
        "classificationId": request.classificationId,
        "rangeId": request.rangeId,
        "technologyId": request.technologyId,
        "structureId": request.structureId,
        "edgeId": request.edgeId,
        "image": request.image,
        "multipleColors": request.multipleColors,
        "multipleSizes": request.multipleSizes,
        "multipleDesignTopoligies": request.multipleDesignTopoligies,
        "multipleSuitability": request.multipleSuitability,
        "thickness":request.thickness,
        "surfaceId":request.surfaceId,
        "multipleDesigners":request.multipleDesigners,
        "designerObservation":request.designerObservation,
        "customerObservation":request.customerObservation
      },toEncodable: Utils.myEncode);
      print(body);
      var req=http.MultipartRequest('POST', Uri.parse(Utils.getBaseUrl()+"Request/RequestSave"));
      req.fields['jsonString'] = body;
      req.files.add(await http.MultipartFile.fromPath('File', request.image));
      req.headers.addAll({"Content-type":"application/json","Authorization":"Bearer "+token});
      var res = await req.send();
      print(res.reasonPhrase);
      if(res.statusCode==200){
        pd.hide();
        Utils.showSuccess(context, "Request Saved Successfully");
//        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>Dashboard()),(Route<dynamic> route) => false);
//        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>Dashboard()),(Route<dynamic> route) => false);
      }else{
        pd.hide();
        Utils.showError(context, res.reasonPhrase);
        print(req.fields.toString());
      }
//      var response=await http.post(Utils.getBaseUrl()+"Request/RequestSave",body: body,headers:{"Content-type":"application/json","Authorization":"Bearer "+token});
//      print(response.statusCode.toString());
//      if(response.statusCode==200){
//        Navigator.pop(context);
//        Navigator.pop(context);
//        Utils.showSuccess(context, "Request Saved Successfully");
//      }else{
//        pd.hide();
//        print(response.body.toString());
//      }
    }catch(e) {
       pd.hide();
      Utils.showError(context, "Not Svaed");
      print(e);
    }
  }
  static void approveRequestClient(BuildContext context,String token,int requestId,int approved) async {
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    try{
      var response = await http.get(Utils.getBaseUrl() + "Request/ChangeStatusOfTrialRequest/$requestId?Approved=$approved", headers: {"Authorization": "Bearer " + token});
      if (response.statusCode == 200) {
        pd.hide();
        Navigator.pop(context,"Refresh");
        Utils.showSuccess(context, "Request Approved");
      }
    }catch(e){
      pd.hide();
      print(e);
      Utils.showError(context, e.toString());
    }
  }
}