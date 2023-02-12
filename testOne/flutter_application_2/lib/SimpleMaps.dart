import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/CustomizeMarkerICon.dart';
import 'package:flutter_application_2/TestMaker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'MarkerJSON.dart';

class SimpleMaps extends StatefulWidget {
  const SimpleMaps({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<SimpleMaps> {
  String googleApikey =
      "AIzaSyCMBfP4py6zjtDQEUby3HeXWl4jpfv5wTM"; // use in android.xml
  Completer<GoogleMapController> _controller = Completer();
  static bool gpsON = false;
  Set<Marker> _markers = {};
  Set<Polygon> _polygon = {};

  static double currentLocationLatitude = 16.472955;
  static double currentLocationlongitude = 102.823042;

  static LatLng _center = LatLng(16.472955, 102.823042);
  LatLng _pinPosition = _center;
  static bool polylinesVisible = false;

  CustomizeMarkerICon currentLocationICon =
      CustomizeMarkerICon('assets/images/noiPic.png', 100);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  MapType _currentMapType = MapType.hybrid;
  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
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
  //---------------------------------

  Future<LocationData?> _currentLocation2() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    Location location = new Location();

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    return await location.getLocation();
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

  void _AddMarkerCurrentLocation() async {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: const MarkerId("CurrentLocation"),
        position: LatLng(currentLocationLatitude, currentLocationlongitude),
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

  //set camera
  LatLng _lastMapPosition = _center;
  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
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
      debugPrint("${value.latitude} ${value.longitude}");
      currentLocationLatitude = value.latitude;
      currentLocationlongitude = value.longitude;

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
    debugPrint("$currentLocationLatitude $currentLocationlongitude");
    // specified current users location
    // ignore: unnecessary_new
    CameraPosition cameraPosition = new CameraPosition(
      target: LatLng(currentLocationLatitude, currentLocationlongitude),
      zoom: 16,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {});
  }

  void realTimeLocationTask() async {
    getUserCurrentLocation().then((value) async {
      // ignore: avoid_print
      debugPrint("${value.latitude} ${value.longitude}");
      _AddMarkerCurrentLocation();
      currentLocationLatitude = value.latitude;
      currentLocationlongitude = value.longitude;
    });
  }

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction
  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApikey,
      PointLatLng(currentLocationLatitude, currentLocationlongitude),
      PointLatLng(_pinPosition.latitude, _pinPosition.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
      visible: polylinesVisible,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getDirections(); //fetch direction polylines from Google API
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
            onMapCreated: _onMapCreated,
            zoomGesturesEnabled: true, //zoom in out
            mapType: _currentMapType,
            onCameraMove: _onCameraMove,
            compassEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            myLocationEnabled: false, // current locate button
            markers: _markers,
            polylines: Set<Polyline>.of(polylines.values), //polylines
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: FloatingActionButton(
                onPressed: _onMapTypeButtonPressed,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                backgroundColor: Colors.amber,
                child: Icon(Icons.map, size: 36.0),
              ),
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
                      addMakerCarMoto(_markers, true);
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
                      addMakerCarMoto(_markers, false);
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
                      setState(() {
                        if (polylinesVisible == true) {
                          polylinesVisible = false;
                        } else {
                          polylinesVisible = true;
                        }
                      });
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
}
