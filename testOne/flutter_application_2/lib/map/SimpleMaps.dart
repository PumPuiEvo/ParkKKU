import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'CustomizeMarkerICon.dart';

class SimpleMaps extends StatefulWidget {
  const SimpleMaps({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<SimpleMaps> {
  Completer<GoogleMapController> _controller = Completer();
  static bool gpsON = false;
  Set<Marker> _markers = {};
  Set<Polygon> _polygon = {};

  static double currentLatitude = 16.472955;
  static double currentLongitude = 102.823042;
  static double radiusMark = 0.0031;

  static LatLng _center = LatLng(16.472955, 102.823042);
  LatLng _pinPosition = _center;

  CustomizeMarkerICon currentLocationICon =
      CustomizeMarkerICon('assets/images/noiPic.png', 100);

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {}; // polylines to show direction

  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    //----------
    _customInfoWindowController.googleMapController = controller;
  }

  //set camera
  LatLng _lastMapPosition = _center;
  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
    _customInfoWindowController.onCameraMove!();
  }

  MapType _currentMapType = MapType.hybrid;
  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  Future<void> addMakerCarMoto(bool vehicle) async {
    String path;
    vehicle
        ? path = 'assets/parkPlace/car.json'
        : path = 'assets/parkPlace/motorcycle.json';

    // Fetch content from the json file
    final String response = await rootBundle.loadString(path);
    final data = await json.decode(response);
    List _parkList = data["placeParking"];
    // debugPrint("jsonLoad");

    var listSize = _parkList.length;
    for (var i = 0; i < listSize; i++) {
      double latitude = _parkList[i]["Latitude"] as double;
      double longitude = _parkList[i]["Longitude"] as double;

      // radius to add
      if (sqrt((pow((_pinPosition.latitude - latitude), 2)) +
              pow((_pinPosition.longitude - longitude), 2)) >
          radiusMark) {
        continue;
      }
      //debugPrint("Marker add");
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_parkList[i]["placeID"] as String),
        position: LatLng(latitude, longitude),
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                        width: 300,
                        height: 100,
                        child: Container(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("Name :",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(_parkList[i]["placeID"]),
                                const Text("Status :",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const Text("<No data>")
                              ]),
                        )),
                  ),
                  Container(
                      width: 100,
                      height: 40,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        children: <Widget>[
                          FloatingActionButton(
                            onPressed: () async {
                              _markers.clear();
                              // set new pin
                              _pinPosition = LatLng(latitude, longitude);
                              _onAddMarkerpin();
                            },
                            backgroundColor: Colors.green,
                            child: Icon(Icons.add_location, size: 36.0),
                          ),
                          FloatingActionButton(
                            onPressed: () async {
                              null;
                            },
                            child: Icon(Icons.gps_fixed, size: 40),
                          ),
                        ],
                      ))
                ],
              ),
              LatLng(latitude, longitude)); // args 2
          setState(() {});
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        visible: true,
      ));
    }
  }

  //------------------------------currentLocation part
  LocationData? currentLocation;
  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        setState(() {});
      },
    );
  }

  // set maker //pin
  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: const MarkerId("Your Pin Location"),
        position: _lastMapPosition, //Position on mark @ChangNoi
        infoWindow: const InfoWindow(
          title: "Your Pin Location", //title message on mark @ChangNoi
          snippet: 'message', //snippet message on mark @ChangNoi
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
      _pinPosition = _lastMapPosition;
    });
  }

  // marker pin
  void _onAddMarkerpin() {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: const MarkerId("Your Pin Location"),
        position: _pinPosition, //Position on mark @ChangNoi
        infoWindow: const InfoWindow(
          title: "Your Pin Location", //title message on mark @ChangNoi
          snippet: 'message', //snippet message on mark @ChangNoi
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  void _AddMarkerCurrentLocation() async {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: const MarkerId("CurrentLocation"),
        position: LatLng(currentLatitude, currentLongitude),
        // ignore: prefer_const_constructors
        infoWindow: InfoWindow(
          title: "Your current location", //title message on mark @ChangNoi
          snippet:
              "This marker shows your current location.", //snippet message on mark @ChangNoi
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        visible: gpsON, // if GPS ON it's viisble
      ));
    });
  }

  // created method for getting user current location
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {
      gpsON = true;
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      //debugPrint("ERROR $error");
      gpsON = false;
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<void> syncLocation() async {
    getUserCurrentLocation().then((value) async {
      // ignore: avoid_print
      //debugPrint("${value.latitude} ${value.longitude}");
      currentLatitude = value.latitude;
      currentLongitude = value.longitude;

      // specified current users location
      // ignore: unnecessary_new
      CameraPosition cameraPosition = new CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 16,
      );

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {});
    });
  }

  Future<void> animateCameraCurrentLocation() async {
    debugPrint("$currentLatitude $currentLongitude");
    // specified current users location
    // ignore: unnecessary_new
    CameraPosition cameraPosition = new CameraPosition(
      target: LatLng(currentLatitude, currentLongitude),
      zoom: 16,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {});
  }

  void realTimeLocationTask() async {
    getUserCurrentLocation().then((value) async {
      // ignore: avoid_print
      //debugPrint("${value.latitude} ${value.longitude}");
      _AddMarkerCurrentLocation();
      currentLatitude = value.latitude;
      currentLongitude = value.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    realTimeLocationTask();
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('Maps Sample App'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onTap: (position) {
              _customInfoWindowController.hideInfoWindow!();
            },
            onMapCreated: _onMapCreated,
            zoomGesturesEnabled: true, //zoom in out
            mapType: _currentMapType,
            onCameraMove: _onCameraMove,
            compassEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            myLocationEnabled: true, // current locate button
            markers: _markers,
            polylines: Set<Polyline>.of(polylines.values), //polylines
            myLocationButtonEnabled: false,
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 200,
            width: 150,
            offset: 30,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(children: <Widget>[
                FloatingActionButton(
                  onPressed: _onMapTypeButtonPressed,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.map, size: 36.0),
                ),
                FloatingActionButton(
                  onPressed: () {
                    radiusMark = 0.0031;
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.black,
                  child: Text("400 M"),
                ),
                FloatingActionButton(
                  onPressed: () {
                    radiusMark = 180;
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.black,
                  child: Text("All"),
                ),
              ]),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 5),
                  FloatingActionButton(
                    onPressed: _onAddMarkerButtonPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.add_location, size: 36.0),
                  ),
                  SizedBox(height: 1.0),
                  //CurrentLocation
                  FloatingActionButton(
                    onPressed: () async {
                      animateCameraCurrentLocation();
                    },
                    child: Icon(Icons.location_on, size: 40),
                  ),
                  SizedBox(height: 16.0),
                  // ignore: prefer_const_constructors
                  FloatingActionButton(
                    onPressed: () async {
                      _markers.clear();
                      _onAddMarkerpin(); // to save current pin
                      addMakerCarMoto(true);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.car_rental_outlined, size: 36.0),
                  ),
                  SizedBox(height: 1.0),
                  // ignore: prefer_const_constructors
                  FloatingActionButton(
                    onPressed: () async {
                      _markers.clear();
                      _onAddMarkerpin(); // to save current pin
                      addMakerCarMoto(false);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Color.fromARGB(255, 18, 1, 0),
                    child: const Icon(Icons.motorcycle, size: 36.0),
                  ),
                  SizedBox(height: 1.0),
                  // ignore: prefer_const_constructors
                  FloatingActionButton(
                    onPressed: () {
                      gpsON = false;
                      _markers.clear();
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.blue,
                    child: Text("off gps icon"),
                  ),
                  SizedBox(height: 1.0),
                  // ignore: prefer_const_constructors
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {});
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Color.fromARGB(255, 0, 0, 0),
                    child: Text("Go"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // getter method
  static LatLng getCurrentDataLocation() {
    return LatLng(currentLatitude, currentLongitude);
  }
}
