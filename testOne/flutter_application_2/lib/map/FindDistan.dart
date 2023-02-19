import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String googleApikey =
    "AIzaSyCMBfP4py6zjtDQEUby3HeXWl4jpfv5wTM"; // use in android.xml

void getDistanceMatrix(LatLng origins, LatLng destinations) async {
  try {
    var response = await Dio().get(
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${destinations.latitude.toString()},${destinations.longitude.toString()}&origins=${origins.latitude.toString()},${origins.longitude.toString()}&key=$googleApikey');
    print(response);
    List distan = response.data["rows"];
    print(distan[0]["elements"][0]["distance"]);
    print(distan[0]["elements"][0]["distance"]["text"]);
    print(distan[0]["elements"][0]["distance"]["value"]);
    print(distan[0]["elements"][0]["duration"]);
    print(distan[0]["elements"][0]["duration"]["text"]);
    print(distan[0]["elements"][0]["duration"]["value"]);
  } catch (e) {
    print(e);
  }
}
