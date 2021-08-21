import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:productdevelopment/DetailsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Network_Operations.dart';

class DynamicLinkService {
  static Future handleDynamicLinks(BuildContext context) async {
    // 1. Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.getInitialLink();

    // 2. handle link that has been retrieved
    _handleDeepLink(data, context);

    // 3. Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          // 3a. handle link that has been retrieved
          _handleDeepLink(dynamicLink, context);
        }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });
  }

  static void _handleDeepLink(PendingDynamicLinkData data,
      BuildContext context) {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print(deepLink.toString());
      print(int.parse(deepLink.toString().split("?")[1].replaceAll("RequestId=", "")));
          SharedPreferences.getInstance().then((prefs){
           Network_Operations.getRequestByIdNotifications(context,prefs.getString("token"),int.parse(deepLink.toString().split("?")[1].replaceAll("RequestId=", ""))).then((req){
             Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(context)=>DetailsPage(req)), (route) => false);
           });
          });
    }
  }
}