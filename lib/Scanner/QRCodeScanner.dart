import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
class QRCodeScanner extends StatefulWidget {
  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}
const flashOn = 'FLASH ON';
const flashOff = 'FLASH OFF';
const frontCamera = 'FRONT CAMERA';
const backCamera = 'BACK CAMERA';
class _QRCodeScannerState extends State<QRCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController controller;

  var flashState = flashOn;
  var cameraState = frontCamera;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ACMC Customer"),
        actions: [
           IconButton(icon:Icon(flashState==flashOff?Icons.flash_off:Icons.flash_on),onPressed: (){
        if (controller != null) {
          controller.toggleFlash();
          if (_isFlashOn(flashState)) {
            setState(() {
              flashState = flashOff;
            });
          } else {
            setState(() {
              flashState = flashOn;
            });
          }
        }
           }),
           IconButton(icon:Icon(Icons.flip_camera_ios),onPressed: (){
             if (controller != null) {
               controller.flipCamera();
               if (_isBackCamera(cameraState)) {
                 setState(() {
                   cameraState = frontCamera;
                 });
               } else {
                 setState(() {
                   cameraState = backCamera;
                 });
               }
             }

          }),
        ],
      ),
        body:NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (notification) {
            Future.microtask(() => controller?.updateDimensions(qrKey));
            return false;
          },
          child: SizeChangedLayoutNotifier(
            key: const Key('qr-size-notifier'),
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
               overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
            ),
          ),
        ),
      );
  }
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
        if(qrText!=""&&qrText.length>0)
          controller.pauseCamera();
          Navigator.pop(context,qrText);
      });
    });
  }
  bool _isFlashOn(String current) {
    return flashOn == current;
  }
  bool _isBackCamera(String current) {
    return backCamera == current;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
