import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
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
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Dashboard()));
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
  static void SaveRequest(BuildContext context,String token,int requestID, marketID, String Event, String TechConcentration,
      int statusID, double thickness, surfaceID, int classificationID, int rangeID, int technologyID, int structureID,
      int edgeID, String image, List multipleColors, List multipleSize, List multipleDesignTopology, List multipleSuitability,int surafaceId ) async {
    try{
      final body = jsonEncode({
        "requestId":requestID,
        "date":DateTime.now(),
        "marketId":marketID,
        "event": Event,
        "technicalConcentration": TechConcentration,
        //"userId": userID,
        "statusId": statusID,
        "classificationId": classificationID,
        "rangeId": rangeID,
        "technologyId": technologyID,
        "structureId": structureID,
        "edgeId": edgeID,
        "image": image,
        "multipleColors": multipleColors,
        "multipleSizes": multipleSize,
        "multipleDesignTopoligies": multipleDesignTopology,
        "multipleSuitability": multipleSuitability,
        "thickness":thickness,
        "surfaceId":surfaceID
      },toEncodable: Utils.myEncode);

      var response=await http.post(Utils.getBaseUrl()+"Request/RequestSave",body: body,headers:{"Content-type":"application/json","Authorization":"Bearer "+token});
      if(response.statusCode==200){
        Navigator.pop(context);
        Navigator.pop(context);
        Utils.showSuccess(context, "Request Saved Successfully");
      }else{
        print(response.body.toString());
      }
    }catch(e) {
     // pd.hide();
      Utils.showError(context, "Not Svaed");
      print(e);

     // Utils.showError(context, e.toString());
    }
  }

  static Future<List<dynamic>> getRequest(BuildContext context,String token)async{
    try{
      var response=await Dio().get(Utils.getBaseUrl()+"Request/GetAllRequests",options:Options(headers:{"Authorization":"Bearer "+token}));
      if(response.statusCode==200){
        return response.data;
        print(response.data);

      }
    }catch(e){
      print(e);
      Utils.showError(context, e.toString());
    }
    return null;
  }
  static void changeStatusOfRequest(BuildContext context,String token,int requestId,int status) async{
    ProgressDialog pd=ProgressDialog(context);
    pd.show();
    try {
      var response = await http.get(Utils.getBaseUrl() +
          "Request/ChangeStatusOfRequest/$requestId?StatusId=$status", headers: {"Authorization": "Bearer " + token});
      if (response.statusCode == 200) {
        pd.hide();
        Navigator.pop(context,"Refresh");
         Utils.showSuccess(context, "Status Changed");
      }
    }catch(e){
      pd.hide();
      print(e);
      Utils.showError(context, "Status not Changed");
    }
  }
}