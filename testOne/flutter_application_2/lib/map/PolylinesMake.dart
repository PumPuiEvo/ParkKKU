import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void getPolylinesMake(List<LatLng> polylinesCoordinate, double originlatitude,
    double originlongitude, double destinationlatitude, double destinationlongitude) async {
  String googleApikey = "AIzaSyCMBfP4py6zjtDQEUby3HeXWl4jpfv5wTM";
  PolylinePoints polylinePoints = PolylinePoints();

  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApikey,
      PointLatLng(originlatitude, originlongitude),
      PointLatLng(destinationlatitude, destinationlongitude));

  if (result.points.isNotEmpty) {
    result.points.forEach(
      (PointLatLng point) =>
        polylinesCoordinate.add(LatLng(point.latitude, point.longitude)));
  }
}
