import 'package:universal_html/html.dart' as html;

class WebDownloadService {
  @override
  Future<void> download({required String url, required String fileName}) async {

    html.AnchorElement anchorElement = html.AnchorElement(href: url);

    // final html.Storage _localStorage = html.window.localStorage;
    // _localStorage[fileName] = url;
    // html.window.localStorage
    //   (url, "_blank");
    // html.download = url;
    html.window.open(url, "_blank");
  }
}