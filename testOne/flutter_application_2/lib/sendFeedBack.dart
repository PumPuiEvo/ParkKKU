import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class sendFeedBack {
  sendFeedBack._();

  static Future<void> send(String user, String comment, String star) async {
    String url = "https://script.google.com/macros/s/AKfycbzHMzRWkZSZXYkGHdAP492WvTrNTcQLAxyoeSMgkIjHba7eQ-BoJWBGSmxFqGBv5WA/exec?";
    url += "UserData=\"$user\"";
    url += "&";
    url += "Comment=\"$comment\"";
    url += "&";
    url += "Star=\"$star\"";
    print(url);
    if(await canLaunchUrlString(url)){
      await launchUrlString(url);
    } else {
      throw 'Cannot open url';
    }
  }
}