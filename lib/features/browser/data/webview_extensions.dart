import 'package:flutter_inappwebview/flutter_inappwebview.dart';

extension InAppWebViewControllerExt on InAppWebViewController {
  // returns full page HTML; fallback to evaluating document.documentElement.outerHTML
  Future<String?> getHtml() async {
    try {
      final res = await this.evaluateJavascript(source: "document.documentElement.outerHTML");
      return res?.toString();
    } catch (e) {
      return null;
    }
  }
}
