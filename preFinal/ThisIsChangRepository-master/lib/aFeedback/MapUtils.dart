import 'package:url_launcher/url_launcher_string.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMapOutApp(double latitude, double longitude) async {
    String googleMapUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    if(await canLaunchUrlString(googleMapUrl)){
      await launchUrlString(googleMapUrl);
    } else {
      throw 'Cannot open map';
    }
  }
}

