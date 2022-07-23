// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:html' as html;
//
// abstract class DownloadService {
//   Future<void> download({required String url});
// }
//
// class WebDownloadService implements DownloadService {
//   @override
//   Future<void> download({required String url}) async {
//     html.AnchorElement anchorElement =  html.AnchorElement(href: url);
//     anchorElement.download = url;
//     //html.window.open(url, "_blank");
//   }
// }
//
// class MobileDownloadService implements DownloadService {
//   @override
//   Future<void> download({required String url}) async {
//     bool hasPermission = await _requestWritePermission();
//     if (!hasPermission) return;
//
//     print(url);
//
//     Dio dio = Dio();
//     var dir = await getApplicationDocumentsDirectory();
//
//     // You should put the name you want for the file here.
//     // Take in account the extension.
//     String fileName = 'myFile';
//     await dio.download(url, "${dir.path}/$fileName");
//   }
//
//   Future<bool> _requestWritePermission() async {
//     await Permission.storage.request();
//     return await Permission.storage.request().isGranted;
//   }
// }