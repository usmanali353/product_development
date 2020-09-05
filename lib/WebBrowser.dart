import 'package:flutter/material.dart';

import 'package:progress_dialog/progress_dialog.dart';

import 'package:webview_flutter/webview_flutter.dart';

class WebBrowser extends StatefulWidget {

  var url;



  WebBrowser(this.url);



  @override

  _WebBrowserState createState() => _WebBrowserState(url);

}



class _WebBrowserState extends State<WebBrowser> {

  var url;

  ProgressDialog pd;

  _WebBrowserState(this.url);

  @override

  void initState() {

    pd=ProgressDialog(context,isDismissible: true,type: ProgressDialogType.Normal);

    super.initState();

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

        body: SafeArea(

          child:  WebView(

            initialUrl: url,

            javascriptMode: JavascriptMode.unrestricted,

            onPageStarted: ((str){

              pd.show();

            }),

            onPageFinished: ((str){

              pd.hide();

            }),

            onWebViewCreated: ((webviewController){

              webviewController.canGoBack().then((value){

                if(value){

                  webviewController.goBack();

                }

              });

            }),

          ),



        )

    );

  }

}