import 'dart:convert';
import 'dart:io';
import 'package:ars_dialog/ars_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:productdevelopment/Login.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:productdevelopment/Model/TrialRequests.dart';
import 'package:productdevelopment/Model/Notifications.dart';
import '../Dashboard.dart';
import '../DetailsPage.dart';
import 'package:productdevelopment/Model/ClientVisitSchedule.dart';
 class Network_Operations{
  static void signIn(BuildContext context,String email,String password) async {
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    var body=jsonEncode({"email":email,"password":password});
    try{
    var response=await http.post(Uri.parse(Utils.getBaseUrl()+"Account/Login"),body:body,headers: {"Content-type":"application/json"}).timeout(
    Duration(minutes: 1),
    onTimeout: () {
    // Time has run out, do what you wanted to do.
    return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
    },
    );
    print(response.statusCode);
     if(response.statusCode==200){
       SharedPreferences.getInstance().then((prefs){
         prefs.setString("token", jsonDecode(response.body)['result']);
         prefs.setString("email", email);
       });
       if(Platform.isAndroid){
         var claims=Utils.parseJwt(jsonDecode(response.body)['result']);
         //Utils.showSuccess(context, "Login Successful");
         FirebaseMessaging.instance.getToken().then((token){
           pd.dismiss();
           addFCMToken(context, claims['nameid'], token, jsonDecode(response.body)['result']).then((value){
             Utils.showSuccess(context, "Login Successful");
           });
         });
       }else if(Platform.isIOS){
         Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
       }

     }else if(response.body!=null){
       pd.dismiss();
       Utils.showError(context, "Invalid Email or Password");
     }else{
       pd.dismiss();
       Utils.showError(context, response.statusCode.toString());
     }
    }catch(e) {
      pd.dismiss();
      print(e.toString());
      Utils.showError(context,e.toString());
    }finally{
      pd.dismiss();
    }
  }
  static void register(BuildContext context,String email,String password,String name) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    var body=jsonEncode({"email":email,"password":password,"firstname":name,"confirmPassword":password});
    try{
      var response=await http.post(Uri.parse(Utils.getBaseUrl()+"account/Register"),body:body,headers: {"Content-type":"application/json"});
      if(response.statusCode==200){
        Utils.showSuccess(context, "User Registration successful");
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
    }
  }
  static Future<List<Dropdown>> getDropDowns(BuildContext context,String token,String endpoint)async{
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Configuration/"+endpoint+"Dropdown"),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        List<Dropdown> list=List();
        list.clear();
        for(int i=0;i<data.length;i++){
          list.add(Dropdown(data[i]["id"],data[i]["name"],data[i]["stringId"]));
        }
        final ids = list.map((e) => e.name).toSet();
        list.retainWhere((x) => ids.remove(x.name));
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
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/GetAllRequests"),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        List<Request> requests=[];
        for(int i=0;i<jsonDecode(response.body)['response'].length;i++){
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
   // ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    try {
      var response = await http.get(Uri.parse(Utils.getBaseUrl() + "Request/ChangeStatusOfRequest/$requestId?StatusId=$status"), headers: {"Authorization": "Bearer " + token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if (response.statusCode == 200) {
       // Navigator.pop(context,"Refresh");
         //Utils.showSuccess(context, "Status Changed");
      }
    }catch(e){
      print(e);
      Utils.showError(context, "Status not Changed");
    }
  }
  static void saveRequest(BuildContext context,String token,Request request) async {
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try {
      final body = jsonEncode({
        "requestId": request.requestId,
        "date": DateTime.now(),
        "marketId": request.marketId,
        "event": request.event,
        "userId": request.userId,
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
        "multipleClients":request.multipleClients,
        "ImageSelectedForColor":request.ImageSelectedForColor,
        "image":request.image,
      }, toEncodable: Utils.myEncode);
       debugPrint(body);
       var response =await http.post(Uri.parse(Utils.getBaseUrl()+"Request/RequestSave"),body: body,headers:{"Content-Type": "application/json", "Authorization": "Bearer " + token}).timeout(
         Duration(minutes: 1),
         onTimeout: () {
           // Time has run out, do what you wanted to do.
           return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
         },
       );
       if(response.statusCode==200){
         pd.dismiss();
         Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>Dashboard()),(Route<dynamic> route) => false);
         Utils.showSuccess(context, "Request Created Successfully");
       }else{
         pd.dismiss();
         print(response.body.toString());
         Utils.showError(context, response.statusCode.toString());
       }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
  }
  static void updateRequest(BuildContext context,String token,Request request) async {
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try {
      final body = jsonEncode({
        "requestId": request.requestId,
        "date": DateTime.now(),
        "marketId": request.marketId,
        "event": request.event,
        "userId": request.userId,
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
        "multipleClients":request.multipleClients,
        "ImageSelectedForColor":request.ImageSelectedForColor,
        "image":request.image,
      }, toEncodable: Utils.myEncode);
      debugPrint(body);
      var response =await http.post(Uri.parse(Utils.getBaseUrl()+"Request/RequestSave?IsUpateMode=true"),body: body,headers:{"Content-Type": "application/json", "Authorization": "Bearer " + token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>Dashboard()),(Route<dynamic> route) => false);
        Utils.showSuccess(context, "Request Updated Successfully");
      }else{
        pd.dismiss();
        print(response.body.toString());
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
  }
  static Future<void> addDesignersAndObservationToRequest(BuildContext context,int requestId,List<dynamic> designers,String designerObservations,String token,String modelName,String modelCode,String remarks) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      final body = jsonEncode({
        "requestId":requestId,
        "MultipleDesigners":designers,
        "DesignerObservation":designerObservations,
        "modelName":modelName,
        "modelCode":modelCode,
        "Remarks":remarks
      },toEncodable: Utils.myEncode);
      print(body);
      var response=await http.post(Uri.parse(Utils.getBaseUrl()+"Request/RequestDesignerSave"),body: body,headers: {"Content-type":"application/json","Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
       pd.dismiss();
       Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>Dashboard()),(Route<dynamic> route) => false);
       Utils.showSuccess(context, response.body.toString());
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
    }

  }
  static Future<void> addRequestSchedule(BuildContext context,String token,int requestId,DateTime startDate,DateTime endDate,bool IsUpdateMode,String remarks) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      final body=jsonEncode({
        "requestId":requestId,
        "TargetStartDate":startDate,
        "TargetEndDate":endDate,
         "IsUpdateMode":IsUpdateMode,
        "Remarks":remarks
      },toEncodable: Utils.myEncode);
      print(body);
      var response=await http.post(Uri.parse(Utils.getBaseUrl()+"Request/RequestSetSchedule"),body: body,headers: {"Content-type":"application/json","Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );

      if(response.statusCode==200){
        pd.dismiss();

        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>Dashboard()),(Route<dynamic> route) => false);
        Utils.showSuccess(context, response.body.toString());
        // changeStatusWithRemarks(context, token, requestId, statusId,remarks).then((value){
        //
        // });
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
        print(response.body.toString());
      }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
      print(e.toString());
    }
  }
  static void getRequestById(BuildContext context,String token,int requestId) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/GetRequestById/$requestId"),headers: {"Content-type":"application/json","Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        Request request;
        request=Request.fromMap(jsonDecode(response.body));
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailsPage(request)));
      }else{
        pd.dismiss();
        Utils.showError(context, "No Request Found against this Id");
      }
    }catch(e){
      pd.dismiss();
      print(e.toString());
    }

  }
  static Future<String> getRequestForGM(BuildContext context,String token,int PageSize,int PageNumber,{String startDate,String endDate})async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      String url;
      if(startDate!=null&&endDate!=null){
        url=Utils.getBaseUrl()+"Request/GetAllRequestsForGM?PageSize=$PageSize&PageNumber=$PageNumber&StartDate=$startDate&EndDate=$endDate";
      }else{
        url=Utils.getBaseUrl()+"Request/GetAllRequestsForGM?PageSize=$PageSize&PageNumber=$PageNumber";
      }
      var response=await http.get(Uri.parse(url),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
         return response.body;
      }else {
        pd.dismiss();
        Utils.showError(context,"No Requests Found");
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<String> getRequestForGMSearchable(BuildContext context,String token,int PageSize,int PageNumber,String searchQuery,{String startDate,String endDate})async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      String url;
      if(startDate!=null&&endDate!=null){
        url=Utils.getBaseUrl()+"Request/GetAllRequestsForGM?PageSize=$PageSize&PageNumber=$PageNumber&StartDate=$startDate&EndDate=$endDate&SearchString=$searchQuery";
      }else{
        url=Utils.getBaseUrl()+"Request/GetAllRequestsForGM?PageSize=$PageSize&PageNumber=$PageNumber&SearchString=$searchQuery";
      }
      var response=await http.get(Uri.parse(url),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        return response.body;
      }else {
        pd.dismiss();
        Utils.showError(context,"No Requests Found");
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<String> getRequestByStatusGM(BuildContext context,String token,int statusId,int pageNumber,int pageSize,{String startDate,String endDate}) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      String url;
      if(startDate!=null&&endDate!=null){
        url=Utils.getBaseUrl()+"Request/GetAllRequestsForGM?StatusId=$statusId&PageNumber=$pageNumber&PageSize=$pageSize&StartDate=$startDate&EndDate=$endDate";
      }else{
        url=Utils.getBaseUrl()+"Request/GetAllRequestsForGM?StatusId=$statusId&PageNumber=$pageNumber&PageSize=$pageSize";
      }
      var response=await http.get(Uri.parse(url),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        print(response.body);
         return response.body;
      }else{
        pd.dismiss();
        Utils.showError(context,"No Requests Found");
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<String> getRequestByStatusGMSearchable(BuildContext context,String token,int statusId,int pageNumber,int pageSize,String query,{String startDate,String endDate}) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      String url;
      if(startDate!=null&&endDate!=null){
        url=Utils.getBaseUrl()+"Request/GetAllRequestsForGM?StatusId=$statusId&PageNumber=$pageNumber&PageSize=$pageSize&StartDate=$startDate&EndDate=$endDate&SearchString=$query";
      }else{
        url=Utils.getBaseUrl()+"Request/GetAllRequestsForGM?StatusId=$statusId&PageNumber=$pageNumber&PageSize=$pageSize&SearchString=$query";
      }
      var response=await http.get(Uri.parse(url),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        return response.body;
      }else{
        Utils.showError(context,"No Requests Found");
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<void> trialClient(BuildContext context,String token,List<dynamic> clientIds,int requestId,String remarks,DateTime ClientVisitDate,DateTime actualStartDate,DateTime actualEndDate,String newModelName,String newModelCode)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      final body=jsonEncode({
       "requestId":requestId,
        "MultipleClients":clientIds,
        "ClientVisitDate":ClientVisitDate,
        "ActualStartDate": actualStartDate,
        "ActualEndDate": actualEndDate,
        "newModelName":newModelName,
        "newModelCode": newModelCode,
        "Remarks":remarks
      },toEncodable: Utils.myEncode);
      print(body);
      var response=await http.post(Uri.parse(Utils.getBaseUrl()+"Request/RequestClientSave"),body: body,headers: {"Content-Type":"application/json","Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
        Utils.showSuccess(context, "Model Approved");
      }else{
        pd.dismiss();
        if(response.body!=null){
          print(response.body);
        }
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e.toString());
    }finally{
      pd.dismiss();
    }
  }
  static Future<String> getTrialRequests(BuildContext context,String token,int requestId,int pageNumber,int pageSize)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/GetAllTrialRequests?RequestId=$requestId&PageNumber=$pageNumber&PageSize=$pageSize"),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        return response.body;
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<String> getTrialRequestsSearchable(BuildContext context,String token,int requestId,int pageNumber,pageSize,String query)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/GetAllTrialRequests?RequestId=$requestId&PageNumber=$pageNumber&PageSize=$pageSize&SearchString=$query"),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        return response.body;
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<List<Dropdown>> getDesignerDropDowns(BuildContext context,String token,String endpoint)async{
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Configuration/Get"+endpoint+"Dropdown"),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
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
  static Future<Map<String,dynamic>> getRequestCount(BuildContext context,String token,{String startDate,String endDate})async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show(useSafeArea: false);
    String url;
    if(startDate!=null&&endDate!=null){
      url=Utils.getBaseUrl()+"Request/GetRequestsCountForDashboard?StartDate=$startDate&EndDate=$endDate";
      print(url);
    }else{
      url=Utils.getBaseUrl()+"Request/GetRequestsCountForDashboard";
    }
    try{
      var response=await http.get(Uri.parse(url),headers:{"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        print(response.body.toString());
        return jsonDecode(response.body);
      }else{
        pd.dismiss();
        Utils.showError(context,response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
   return null;
  }
  static Future<void> addRequestImages(BuildContext context,String token,int colorId,String colorImage)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      final body=jsonEncode({
        "id":colorId,
        "colorImage":colorImage
      },toEncodable: Utils.myEncode);
      var response=await http.post(Uri.parse(Utils.getBaseUrl()+"Request/RequestColorSave"),body: body,headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        Utils.showSuccess(context, "Image Added Successfully");
      }else{
        pd.dismiss();
        Utils.showError(context,response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
  }
  static Future<Map<String,dynamic>> getRequestCountIndividualUser(BuildContext context,String token)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/GetRequestsCountForIndividual"),headers:{"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        return jsonDecode(response.body);
      }else{
        pd.dismiss();
        Utils.showError(context,response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<String> getRequestByStatusIndividualUser(BuildContext context,String token,int statusId,int pageNumber,int pageSize,{String startDate,String endDate}) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      String url;
      if(startDate!=null&&endDate!=null){
        url=Utils.getBaseUrl()+"Request/GetAllRequests?StatusId=$statusId?PageNumber=$pageNumber&PageSize=$pageSize&StartDate=$startDate&EndDate=$endDate";
      }else{
        url=Utils.getBaseUrl()+"Request/GetAllRequests?StatusId=$statusId?PageNumber=$pageNumber&PageSize=$pageSize";
      }
      var response=await http.get(Uri.parse(url),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        return response.body;
      }else{
       pd.dismiss();
       Utils.showError(context,"No Requests Found");
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<String> getRequestByStatusIndividualUserSearchable(BuildContext context,String token,int statusId,String query,int pageNumber,int pageSize,{String startDate,String endDate}) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      String url;
      if(startDate!=null&&endDate!=null){
        url=Utils.getBaseUrl()+"Request/GetAllRequests?StatusId=$statusId?PageNumber=$pageNumber&PageSize=$pageSize&StartDate=$startDate&EndDate=$endDate&SearchString=$query";
      }else{
        url=Utils.getBaseUrl()+"Request/GetAllRequests?StatusId=$statusId?PageNumber=$pageNumber&PageSize=$pageSize&SearchString=$query";
      }
      var response=await http.get(Uri.parse(url),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        return response.body;
      }else {
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<void> changeStatusWithRemarks(BuildContext context,String token,int requestId,int status,String remarks)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      final body=jsonEncode({
        "StatusId":status,
        "RequestId":requestId,
        "Remarks":remarks,
      },toEncodable: Utils.myEncode);
      var response=await http.post(Uri.parse(Utils.getBaseUrl()+"Request/SaveRequestRemark"),body: body,headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();

        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
        Utils.showSuccess(context, "Request Status Changed");
      }else{
        pd.dismiss();
        Utils.showError(context,response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
  }
  static Future<void> changeStatusClientWithRemarks(BuildContext context,String token,int requestId,int status,String remarks,DateTime ActualClientVisitDate,List<dynamic> MultipleReasons)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      final body=jsonEncode({
        "StatusId":status,
        "RequestClientId":requestId,
        "Remarks":remarks,
        "ActualClientVisitDate":ActualClientVisitDate,
        "MultipleReasons": MultipleReasons
      },toEncodable: Utils.myEncode);
      var response=await http.post(Uri.parse(Utils.getBaseUrl()+"Request/SaveRequestRemark"),body: body,headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();

        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
        Utils.showSuccess(context, "Request Status Changed");
      }else if(response.body!=null&&response.body.isNotEmpty){
        pd.dismiss();
        Utils.showError(context,response.body);
      }else{
        pd.dismiss();
        Utils.showError(context,response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
  }
  static Future<String> getClientRequestsByStatus(BuildContext context,String token,int statusId,int pageNumber,int pageSize,{String startDate,String endDate})async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      String url;
      if(startDate!=null&&endDate!=null){
        url=Utils.getBaseUrl()+"Request/RequestClientsGetAll?StatusId=$statusId&PageNumber=$pageNumber&PageSize=$pageSize&StartDate=$startDate&EndDate=$endDate";
      }else{
        url=Utils.getBaseUrl()+"Request/RequestClientsGetAll?StatusId=$statusId&PageNumber=$pageNumber&PageSize=$pageSize";
      }
      var response=await http.get(Uri.parse(url),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        return response.body;
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<String> getClientRequestsByStatusSearchable(BuildContext context,String token,int statusId,int pageNumber,int pageSize,String searchQuery,{String startDate,String endDate})async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      String url;
      if(startDate!=null&&endDate!=null){
        url=Utils.getBaseUrl()+"Request/RequestClientsGetAll?StatusId=$statusId&PageNumber=$pageNumber&PageSize=$pageSize&StartDate=$startDate&EndDate=$endDate&SearchString=$searchQuery";
      }else{
        url=Utils.getBaseUrl()+"Request/RequestClientsGetAll?StatusId=$statusId&PageNumber=$pageNumber&PageSize=$pageSize&SearchString=$searchQuery";
      }
      var response=await http.get(Uri.parse(url),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        return response.body;
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<List<TrialRequests>> getClientRequests(BuildContext context,String token)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/RequestClientsGetAll"),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        List<TrialRequests> requests=[];
        for(int i=0;i<jsonDecode(response.body).length;i++){
          requests.add(TrialRequests.fromJson(jsonDecode(response.body)[i]));
        }
        return requests;
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static void undoStatus(BuildContext context,String token,int remarkId) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      print(Utils.getBaseUrl()+"Request/ClientVisibility/$remarkId");
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/ClientVisibility/$remarkId"),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
        Utils.showSuccess(context,"Request Status Reverted");
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<List<Dropdown>> getClientsForTrial(BuildContext context,String token,int requestId)async{
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/GetRequestClientsDropdown/$requestId"),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
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
  static Future<void> addFCMToken(BuildContext context,String userId,String fcmToken,String token) async{
      try{
        final body=jsonEncode({
          "Token":fcmToken,
          "UserId":userId
        },toEncodable: Utils.myEncode);
        var response=await http.post(Uri.parse(Utils.getBaseUrl()+"Account/UserTokenForFCMSave"),body: body,headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
          Duration(minutes: 1),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
          },
        );
        if(response.statusCode==200){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
        }else{
          Utils.showError(context,response.statusCode.toString());
        }
    }catch(e){
      Utils.showError(context, e.toString());
    }
  }
  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    dynamic data;
    if (message.containsKey('data')) {
      // Handle data message
       data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
       data = message['notification'];
    }
      print(data.toString());
    return data;
    // Or do other work.
  }
  static Future<void> deleteFCMToken(BuildContext context,String userId,String fcmToken,String token) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      final body=jsonEncode({
        "Token":fcmToken,
        "UserId":userId
      },toEncodable: Utils.myEncode);
      var response=await http.post(Uri.parse(Utils.getBaseUrl()+"Account/DeleteUserTokenForFCM"),body: body,headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Login()), (route) => false);
      }else{
        pd.dismiss();
        Utils.showError(context,response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }

  }
  static Future<List<Notifications>> getUserNotifications(BuildContext context,String token)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response =await http.get(Uri.parse(Utils.getBaseUrl()+"Account/GetAllNotificationsOfUser"),headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        List<Notifications> notifications=[];
        for(int i=0;i<jsonDecode(response.body).length;i++){
          notifications.add(Notifications.fromJson(jsonDecode(response.body)[i]));
        }
        return notifications;
      }else{
        pd.dismiss();
        Utils.showError(context,"No Notifications Found");
      }
    }catch(e){
      pd.dismiss();
      print(e.toString());
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<void> readNotification(BuildContext context,String token,int notificationId,int requestId) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Account/ReadNotification/$notificationId"),headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        //getRequestById(context, token, requestId);
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
  }
  static Future<Request> getRequestByIdNotifications(BuildContext context,String token,int requestId) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/GetRequestById/$requestId"),headers: {"Content-type":"application/json","Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        Request request;
        request=Request.fromMap(jsonDecode(response.body));
       // Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailsPage(request)));
        return request;
      }else{
        pd.dismiss();
        Utils.showError(context, "No Request Found against this Id");
      }
    }catch(e){
      pd.dismiss();
      print(e.toString());
    }finally{
      pd.dismiss();
    }

  }
  static Future<List<ClientVisitSchedule>> getClientVisitSchedule(BuildContext context,String token,String date,String endDate)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response =await http.get(Uri.parse(Utils.getBaseUrl()+"Request/GetRequestClientsSchedule?Date=$date&&endDate=$endDate"),headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        print(response.body);
        List<ClientVisitSchedule> clientVisitSchedule=[];
        for(int i=0;i<jsonDecode(response.body)['result'].length;i++){
          clientVisitSchedule.add(ClientVisitSchedule.fromJson(jsonDecode(response.body)['result'][i]));
        }
        return clientVisitSchedule;
      }else{
        pd.dismiss();
        Utils.showError(context,response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e.toString());
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<List<Dropdown>> getModelsDropDowns(BuildContext context,String token,String endpoint)async{
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/"+endpoint+"Dropdown/5"),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
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
  static void addClientsToTrial(BuildContext context,String token,List<dynamic> multipleModels,List<dynamic> multipleClients,DateTime expectedClientVisitDate) async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      final body=jsonEncode({
        "MultipleModels":multipleModels,
        "MultipleClients":multipleClients,
        "ExpectedClientVisitDate":expectedClientVisitDate
      },toEncodable: Utils.myEncode);
      print(body);
      var response=await http.post(Uri.parse(Utils.getBaseUrl()+"Request/ClientsSaveAfterModelApproval"),body: body,headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
      }else{
        pd.dismiss();
        Utils.showError(context,response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
      print(e);
    }finally{
      pd.dismiss();
    }
  }
  static Future<List<Dropdown>> getEmployeesDropDown(BuildContext context,String token)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Account/GetUsersExceptClientDropdown"),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      var data= jsonDecode(response.body);
      if(response.statusCode==200){
        pd.dismiss();
        List<Dropdown> list=List();
        list.clear();
        for(int i=0;i<data.length;i++){
          list.add(Dropdown(data[i]["id"],data[i]["name"],data[i]["stringId"]));
        }
        print(data.toString());
        return list;
      }else{
        pd.dismiss();
        Utils.showError(context,"No Employees Found");
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<void> assignUserToRejectedModel(BuildContext context,String token,int clientId,String userId)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      final body=jsonEncode({
        "UserId":userId,
        "RequestClientId":clientId,
      },toEncodable: Utils.myEncode);
      print(body);
      var response=await http.post(Uri.parse(Utils.getBaseUrl()+"Request/UsersForClientsRejectSave"),body: body,headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        Utils.showSuccess(context,"User Alloted");
        //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
      }else{
        pd.dismiss();
        Utils.showError(context,response.body.toString());
      }
    }catch(e){
      pd.dismiss();
      Utils.showError(context, e.toString());
      print(e);
    }finally{
      pd.dismiss();
    }
  }
  static Future<String> getAssignedRejectedModels(BuildContext context,String token,int PageSize,int PageNumber)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/AssignedClientRejectionGetAllByUserId?PageSize=$PageSize&PageNumber=$PageNumber"),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );

      if(response.statusCode==200){
        pd.dismiss();
        print(response.body);
        return response.body;
      }else {
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<String> getAssignedRejectedModelsSearchable(BuildContext context,String token,int PageSize,int PageNumber,String searchQuery)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/AssignedClientRejectionGetAllByUserId?PageSize=$PageSize&PageNumber=$PageNumber&SearchString=$searchQuery"),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );

      if(response.statusCode==200){
        pd.dismiss();
        return response.body;
      }else {
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<void> changeStatusOfAssignedModel(BuildContext context,String token,int clientId,int statusId)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/ChangeUsersAssignedToClientsRejectionAction/$clientId?ActionId=$statusId"),headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        Utils.showSuccess(context,"Request Status Changed");
      }else{
        pd.dismiss();
        Utils.showError(context, response.body.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
  }
  static Future<void> changeStatusOfAssignedModelWithJustification(BuildContext context,String token,int clientId,int statusId,int isJustified)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/ChangeUsersAssignedToClientsRejectionAction/$clientId?ActionId=$statusId&just=$isJustified"),headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        Utils.showSuccess(context,"Request Status Changed");
      }else{
        pd.dismiss();
        Utils.showError(context, response.body.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
  }
  static Future<String> getTrialRequestsWithJustification(BuildContext context,String token,int isJustified,int PageSize,int PageNumber,{String startDate,String endDate})async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      String url;
      if(startDate!=null&&endDate!=null){
        url=Utils.getBaseUrl()+"Request/GetAllTrialRequests?just=$isJustified&PageSize=$PageSize&PageNumber=$PageNumber&StartDate=$startDate&EndDate=$endDate";
      }else{
        url=Utils.getBaseUrl()+"Request/GetAllTrialRequests?just=$isJustified&PageSize=$PageSize&PageNumber=$PageNumber";
      }
      print(url);
      var response=await http.get(Uri.parse(url),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        return response.body;
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
        return null;
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<String> getTrialRequestsWithJustificationSearchable(BuildContext context,String token,int isJustified,int PageSize,int PageNumber,String searchQuery,{String startDate,String endDate})async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      String url;
      if(startDate!=null&&endDate!=null){
        url=Utils.getBaseUrl()+"Request/GetAllTrialRequests?just=$isJustified&PageSize=$PageSize&PageNumber=$PageNumber&StartDate=$startDate&EndDate=$endDate&SearchString=$searchQuery";
      }else{
        url=Utils.getBaseUrl()+"Request/GetAllTrialRequests?just=$isJustified&PageSize=$PageSize&PageNumber=$PageNumber&SearchString=$searchQuery";
      }
      var response=await http.get(Uri.parse(url),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        return response.body;
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
        return null;
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<void> changeClientExpectedVisitDate(BuildContext context,String token,int id,DateTime newDate)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.get(Uri.parse(Utils.getBaseUrl()+"Request/ChangeClientExpectedVisitDate?Id="+id.toString()+"&ClientVisitDate="+newDate.toString()),headers:{"Authorization":"Bearer "+token}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
        Utils.showSuccess(context,"Expected Client Visit Date Changed");
      }else{
        pd.dismiss();
        Utils.showError(context, response.statusCode.toString());
        return null;
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
    return null;
  }
  static Future<dynamic> checkUpdate()async{
    try{
      var response= await http.get(Uri.parse("https://drive.google.com/uc?export=download&id=1z-tOeG4egZl6iFWj8BNmDN6CuyGDAfqz")).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        print(response.body);
        return jsonDecode(response.body);
      }
    }catch(e){
      print(e.toString());
    }
    return null;
  }
  static Future<void> deleteRequestById(BuildContext context,String token,int requestId)async{
    ProgressDialog pd=ProgressDialog(context,message:Text( "Please Wait..."),dismissable: true);
    pd.show();
    try{
      var response=await http.delete(Uri.parse(Utils.getBaseUrl()+"Request/DeleteRequestById/$requestId"),headers: {"Content-Type":"application/json","Authorization":"Bearer $token"}).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error Request Timed Out', 500); // Replace 500 with your http code.
        },
      );
      if(response.statusCode==200){
        pd.dismiss();
      }else{
        pd.dismiss();
        Utils.showError(context, response.body.toString());
      }
    }catch(e){
      pd.dismiss();
      print(e);
      Utils.showError(context, e.toString());
    }finally{
      pd.dismiss();
    }
  }
}