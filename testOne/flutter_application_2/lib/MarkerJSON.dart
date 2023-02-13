import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

Future<void> addMakerCarMoto(
    Set setIn, bool vehicle, LatLng pinPosition, double radius) async {
  String path;
  vehicle
      ? path = 'assets/parkPlace/car.json'
      : path = 'assets/parkPlace/motorcycle.json';
  List _parkList = [];

  // Fetch content from the json file
  final String response = await rootBundle.loadString(path);
  final data = await json.decode(response);
  _parkList = data["placeParking"];
  // debugPrint("jsonLoad");

  var listSize = _parkList.length;
  for (var i = 0; i < listSize; i++) {
    double latitude = _parkList[i]["Latitude"] as double;
    double longitude = _parkList[i]["Longitude"] as double;
    bool seeMarker = true;

    // radius to add
    if (sqrt((pow((pinPosition.latitude - latitude), 2)) +
            pow((pinPosition.longitude - longitude), 2)) <
        radius) {
      seeMarker = true; // in radius
    } else {
      seeMarker = false; /* non in radius*/ 
    }
    
    //debugPrint("Marker add");
    setIn.add(Marker(
      // This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId(_parkList[i]["placeID"] as String),
      position: LatLng(latitude, longitude),
      // ignore: prefer_const_constructors
      infoWindow: InfoWindow(
        title: _parkList[i]["placeID"], //title message on mark @ChangNoi
        snippet:
            "This marker park of ${_parkList[i]["placeID"]}", //snippet message on mark @ChangNoi
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      visible: seeMarker,
    ));
  }
}
