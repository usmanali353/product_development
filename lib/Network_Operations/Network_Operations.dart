import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:productdevelopment/DetailPage.dart';
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
          list.add(Dropdown(data[i]["id"],data[i]["name"],data[i]["name"]));
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
  static Future<void> changeStatusOfRequest(BuildContext context,String token,int requestId,int status) async{
   // ProgressDialog pd=ProgressDialog(context);
    try {
      var response = await http.get(Utils.getBaseUrl() + "Request/ChangeStatusOfRequest/$requestId?StatusId=$status", headers: {"Authorization": "Bearer " + token});
      if (response.statusCode == 200) {
       // Navigator.pop(context,"Refresh");
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
    try {
      final body = jsonEncode({
        "requestId": request.requestId,
        "date": DateTime.now(),
        "marketId": request.marketId,
        "event": request.event,
        "userId": request.userId,
        "image":request.image,
        "technicalConcentration": request.technicalConcentration,
        "statusId": request.statusId,
        "classificationId": request.classificationId,
        "rangeId": request.rangeId,
        "technologyId": request.technologyId,
        "structureId": request.structureId,
        "edgeId": request.edgeId,
        "multipleColors": request.multipleColors,
        "multipleSizes": request.multipleSizes,
        "multipleDesignTopoligies": request.multipleDesignTopoligies,
        "multipleSuitability": request.multipleSuitability,
        "thickness": request.thickness,
        "surfaceId": request.surfaceId,
        "multipleDesigners": request.multipleDesigners,
        "designerObservation": request.designerObservation,
        "customerObservation": request.customerObservation,
        "client":request.client
      }, toEncodable: Utils.myEncode);
       print(body);
       var response =await http.post(Utils.getBaseUrl()+"Request/RequestSave",body: body,headers:{"Content-Type": "application/json", "Authorization": "Bearer " + token});
       if(response.statusCode==200){
         pd.hide();
         Utils.showSuccess(context, "Request Saved Successfully");
         Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>Dashboard()),(Route<dynamic> route) => false);
       }else{
         pd.hide();
         Utils.showError(context, response.statusCode.toString());
       }
    }catch(e){
      pd.hide();
      Utils.showError(context, e.toString());
    }
  }
  static Future<void> approveRequestClient(BuildContext context,String token,int requestId,int approved) async {
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    try{
      var response = await http.get(Utils.getBaseUrl() + "Request/ChangeStatusOfTrialRequest/$requestId?Approved=$approved", headers: {"Authorization": "Bearer " + token});
      if (response.statusCode == 200) {
        pd.hide();
        Navigator.pop(context,"Refresh");
        Utils.showSuccess(context, "Request Approved");
      }else{
        pd.hide();
        print(response.statusCode);
      //  Utils.showError(context,response.body.toString());
      }
    }catch(e){
      pd.hide();
      Utils.showError(context, e.toString());
    }
  }
  static Future<void> addDesignersAndObservationToRequest(BuildContext context,int requestId,List<dynamic> designers,String designerObservations,String token,String modelName,String modelCode) async{
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    try{
      final body = jsonEncode({
        "requestId":requestId,
        "MultipleDesigners":designers,
        "DesignerObservation":designerObservations,
        "modelName":modelName,
        "modelCode":modelCode
      },toEncodable: Utils.myEncode);
      var response=await http.post(Utils.getBaseUrl()+"Request/RequestDesignerSave",body: body,headers: {"Content-type":"application/json","Authorization":"Bearer "+token});
      if(response.statusCode==200){
       pd.hide();
       Utils.showSuccess(context, response.body.toString());
       Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>Dashboard()),(Route<dynamic> route) => false);
      }else{
        pd.hide();
        Utils.showError(context, response.body.toString());
        print(response.body.toString());
      }
    }catch(e){
      pd.hide();
      Utils.showError(context, e.toString());
    }

  }
  static Future<void> addRequestSchedule(BuildContext context,String token,int requestId,DateTime startDate,DateTime endDate,DateTime actualStartDate,DateTime actualEndDate) async{
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    try{
      final body=jsonEncode({
        "requestId":requestId,
        "TargetStartDate":startDate,
        "TargetEndDate":endDate,
        "ActualStartDate": actualStartDate,
        "ActualEndDate": actualEndDate,
      },toEncodable: Utils.myEncode);
      var response=await http.post(Utils.getBaseUrl()+"Request/RequestSetSchedule",body: body,headers: {"Content-type":"application/json","Authorization":"Bearer "+token});
      if(response.statusCode==200){
        pd.hide();
        Utils.showSuccess(context, response.body.toString());
        changeStatusOfRequest(context, token, requestId, 4).then((value){
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>Dashboard()),(Route<dynamic> route) => false);
        });
      }else{
        pd.hide();
        Utils.showError(context, response.body.toString());
        print(response.body.toString());
      }
    }catch(e){
      pd.hide();
      Utils.showError(context, e.toString());
      print(e.toString());
    }
  }
  static void getRequestById(BuildContext context,String token,int requestId) async{
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    try{
      var response=await http.get(Utils.getBaseUrl()+"Request/GetRequestById/$requestId",headers: {"Content-type":"application/json","Authorization":"Bearer "+token});
      if(response.statusCode==200){
        pd.hide();
        Request request;
        request=Request.fromMap(jsonDecode(response.body));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DetailPage(request)));
      }else{
        pd.hide();
        Utils.showError(context, "No Request Found against this Id");
      }
    }catch(e){
      pd.hide();
      print(e.toString());
    }

  }
  static Future<List<Request>> getRequestForGM(BuildContext context,String token)async{
    try{
      var response=await http.get(Utils.getBaseUrl()+"Request/GetAllRequestsForGM",headers:{"Authorization":"Bearer "+token});
      if(response.statusCode==200){
        var req=jsonDecode(response.body);
        List<Request> requests=[];
        for(int i=0;i<req['allRequests'].length;i++){
          requests.add(Request.fromMap(req['allRequests'][i]));
        }
        return requests;
      }
    }catch(e){
      print(e);
      Utils.showError(context, e.toString());
    }
    return null;
  }
  static Future<List<Request>> getRequestByStatus(BuildContext context,String token,int statusId) async{
    try{
      var response=await http.get(Utils.getBaseUrl()+"Request/GetAllRequestsForGM?StatusId=$statusId",headers:{"Authorization":"Bearer "+token});
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
  static void trialClient(BuildContext context,String token,List<dynamic> clientIds,int requestId)async{
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    try{
      final body=jsonEncode({
       "requestId":requestId,
        "MultipleClients":clientIds
      });
      var response=await http.post(Utils.getBaseUrl()+"Request/RequestClientSave",body: body,headers: {"Content-Type":"application/json","Authorization":"Bearer "+token});
      if(response.statusCode==200){
        pd.hide();
        Utils.showSuccess(context, "Request Saved Successfully");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
      }else{
        pd.hide();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      print(e.toString());
    }
  }
  static Future<List<dynamic>> getClients(BuildContext context,String token)async{
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    try{
      var response=await http.get(Utils.getBaseUrl()+"Request/GetRequestClientsDropdown",headers: {"Content-Type":"application/json","Authorization":"Bearer "+token});
      if(response.statusCode==200){
        pd.hide();
       var clientsMap= jsonDecode(response.body);
       List<dynamic> clients=[];
        for (var entry in clientsMap.entries) {
          clients.add({
            "display":entry.value,
            "value":entry.key
          });
        }
       print(clients);
      return clients;
      }else{
        pd.hide();
        Utils.showError(context, response.statusCode.toString());
      }

    }catch(e){
      Utils.showError(context, e.toString());
      print(e.toString());
    }
    return null;
  }
  static Future<List<Request>> getTrialRequests(BuildContext context,String token,int requestId)async{
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    try{
      var response=await http.get(Utils.getBaseUrl()+"Request/GetAllTrialRequests?RequestId=$requestId",headers:{"Authorization":"Bearer "+token});
      if(response.statusCode==200){
        pd.hide();
        List<Request> requests=[];
        for(int i=0;i<jsonDecode(response.body).length;i++){
          requests.add(Request.fromMap(jsonDecode(response.body)[i]));
        }
        return requests;
      }else{
        pd.hide();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      print(e);
      Utils.showError(context, e.toString());
    }
    return null;
  }
  static Future<List<dynamic>> getAll(BuildContext context,String token,String endPoint)async{
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    try{
      var response=await http.get(Utils.getBaseUrl()+"configuration/GetAll$endPoint",headers:{"Authorization":"Bearer "+token});
      if(response.statusCode==200){
        pd.hide();
        return jsonDecode(response.body);
      }else{
        pd.hide();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.hide();
     Utils.showError(context, e.toString());
    }
   return null;
  }
  static Future<Map<String,dynamic>> getRangeById(BuildContext context,String token,int rangeId)async{
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    try{
      var response=await http.get(Utils.getBaseUrl()+"configuration/GetRangeById/$rangeId",headers: {"Content-type":"application/json","Authorization":"Bearer "+token});
      if(response.statusCode==200){
        pd.hide();
       return jsonDecode(response.body);
      }else{
        pd.hide();
        Utils.showError(context, "No Range Found against this Id");
      }
    }catch(e){
      pd.hide();
      print(e.toString());
    }
    return null;
  }
  static Future<List<Dropdown>> getDesignerDropDowns(BuildContext context,String token,String endpoint)async{
    try{
      var response=await http.get(Utils.getBaseUrl()+"Configuration/Get"+endpoint+"Dropdown",headers:{"Authorization":"Bearer "+token});
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        List<Dropdown> list=List();
        list.clear();
        for(int i=0;i<data.length;i++){
          list.add(Dropdown(data[i]["id"],data[i]["name"],data[i]["stringId"]));
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
  static Future<Map<String,dynamic>> getRequestCount(BuildContext context,String token)async{
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    try{
      var response=await http.get(Utils.getBaseUrl()+"Request/GetRequestsCountForDashboard",headers:{"Content-Type":"application/json","Authorization":"Bearer $token"});
      if(response.statusCode==200){
        pd.hide();
        print(response.body.toString());
        return jsonDecode(response.body);
      }else{
        pd.hide();
        Utils.showError(context, response.body.toString());
      }
    }catch(e){
      pd.hide();
      Utils.showError(context, e.toString());
    }
   return null;
  }
}