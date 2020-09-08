import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils{
  static Future<PickedFile> getImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    return image;
  }
  static Future<bool> check_connectivity () async{
    bool result = await DataConnectionChecker().hasConnection;
    return result;
  }
  static bool validateStructure(String value){
    RegExp regExp = new RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^\w\s]).{6,}$');
    return regExp.hasMatch(value);
  }
  static bool validateEmail(String value){
    RegExp regExp=  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return regExp.hasMatch(value);
  }
  static String getBaseUrl(){
    return "http://192.236.147.77:8086/api/";
  }
  static void showError(BuildContext context,String message) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 5),
      backgroundColor: Colors.red,
    ).show(context);
  }
  static void showSuccess(BuildContext context,String message) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 5),
      backgroundColor: Colors.green,
    ).show(context);
  }
  static dynamic myEncode(dynamic item) {
    if(item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }
  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }
  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }
  static int getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
  static Future<File> urlToFile(BuildContext context,String imageUrl) async {
ProgressDialog pd=ProgressDialog(context);
pd.show();
try{
  var rng = new Random();

  Directory tempDir = await getTemporaryDirectory();

  String tempPath = tempDir.path;

  File file = new File('$tempPath'+ (rng.nextInt(10000)).toString() +'.png');

  http.Response response = await http.get(imageUrl);
  if(response.statusCode==200){
    pd.hide();
    await file.writeAsBytes(response.bodyBytes);
  }else{
    pd.hide();
    Utils.showError(context, response.statusCode.toString());
  }
  return file;
}catch(e){
  pd.hide();
  print(e.toString());
}
   return null;
  }
}