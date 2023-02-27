import 'dart:async';
import 'dart:math';
import 'package:app01/navbar/Sidebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app01/navbar/Searching.dart';
import 'package:flutter/material.dart';
import 'package:app01/Atom/CustomizeMarkerICon.dart';
import 'package:app01/Atom/TestMaker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:app01/navbar/NavbarController.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app01/Atom/Marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:custom_info_window/custom_info_window.dart';

class SimpleMaps extends StatefulWidget {
  const SimpleMaps({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

//-------------------- Read!! ------------------
// Atom new simple map waiting for editing
class _MyAppState extends State<SimpleMaps> {
  String googleApikey =
      "AIzaSyCMBfP4py6zjtDQEUby3HeXWl4jpfv5wTM"; // use in android.xml
  Completer<GoogleMapController> _controller = Completer();
  static bool gpsON = false;
  bool isExtended = false;
  Set<Marker> _markers = {};
  Set<Polygon> _polygon = {};
  static double btnSize = 36;
  AssetImage arrow_sign = AssetImage("assets/images/arrow_sign.png");

  static double currentLocationLatitude = 16.472955;
  static double currentLocationlongitude = 102.823042;
  static double radiusMark = 0.0031;
  static late Uint8List userProfile;
  static LatLng _center = LatLng(16.472955, 102.823042);
  LatLng _pinPosition = _center;
  static bool polylinesVisible = false;
  static CustomizeMarkerICon currentLocationICon =
      CustomizeMarkerICon('assets/images/noiPic.png', 150);
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {}; // polylines to show direction
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  late Map<String, dynamic> placeCar; //car // CacheRamUserV-1.0.0
  late Map<String, dynamic> placeMoto; //moto // CacheRamUserV-1.0.0

  late Map<String, dynamic> place;
  static void getProFileImage() async {
    final auth = FirebaseAuth.instance;
    try {
      userProfile =
          (await NetworkAssetBundle(Uri.parse(auth.currentUser!.photoURL!))
                  .load(auth.currentUser!.photoURL!))
              .buffer
              .asUint8List();

      //print(auth.currentUser!.photoURL!);
    } catch (e) {
      userProfile = currentLocationICon.getMarkerIConAsBytes();
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
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

  // CacheRamUserV-1.0.0
  Future<void> addMakerCarMoto(bool vehicle) async {
    Map<String, dynamic> place;
    vehicle ? place = placeCar : place = placeMoto;
    //print(place);
    List<dynamic> _parkList = place["placeParking"];
    //print(_parkList);
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
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition, //Position on mark @ChangNoi
        infoWindow: InfoWindow(
          title: _lastMapPosition.toString(), //title message on mark @ChangNoi
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
        markerId: MarkerId("CurrentLocation"),
        position: LatLng(currentLocationLatitude, currentLocationlongitude),
        // ignore: prefer_const_constructors
        infoWindow: InfoWindow(
          title: "Your current location", //title message on mark @ChangNoi
          snippet:
              "This marker shows your current location.", //snippet message on mark @ChangNoi
        ),
        icon: BitmapDescriptor.fromBytes(userProfile), //! change the picture
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
      debugPrint("ERROR $error");
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
      getProFileImage();
      _AddMarkerCurrentLocation();
      currentLocationLatitude = value.latitude;
      currentLocationlongitude = value.longitude;
    });
  }

  // CacheRamUserV-1.0.0
  void getMotoMain() {
    final docRef = GetDataMarker.getDatabaseMoto4();
    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        // print("Check dataaaaaaaaaaaaaaaaaaaaaaa");
        // print(data);
        placeMoto = data;
        // print("Check dataaaaaaaaaaaaaaaaaaaaaaa");
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }
  // CacheRamUserV-1.0.0
  void getCarMain() {
    final docRef = GetDataMarker.getDatabaseCar4();
    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        // print("Check dataaaaaaaaaaaaaaaaaaaaaaa");
        // print(data);
        placeCar = data;
        // print("Check dataaaaaaaaaaaaaaaaaaaaaaa");
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  @override
  void initState() {
    super.initState();
    // CacheRamUserV-1.0.0
    getMotoMain();
    // CacheRamUserV-1.0.0
    getCarMain();
    
  }

  @override
  Widget build(BuildContext context) {
    //print(placeMoto);
    //realTimeLocationTask();

    return MaterialApp(
        home: Scaffold(
      drawer: SideBar(),
      // appBar: AppBar(title: Text("sadad")),
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              onTap: (position) {
                _customInfoWindowController.hideInfoWindow!();
                setState(() {});
              },
              onMapCreated: _onMapCreated,
              zoomGesturesEnabled: true, //zoom in out
              mapType: _currentMapType,
              onCameraMove: _onCameraMove,
              compassEnabled: true,
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15.0,
              ),
              myLocationEnabled: false, // current locate button
              markers: _markers,
              mapToolbarEnabled: true,
            ),
            CustomInfoWindow(
              controller: _customInfoWindowController,
              height: 200,
              width: 150,
              offset: 30,
            ),
            Column(
              children: [
                NavbarController(), //! Navbar
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 16, 16),
                    child: SpeedDial(
                      renderOverlay: false,
                      direction: SpeedDialDirection.right,
                      child: Icon(
                        Icons.radar,
                        size: 36,
                      ),
                      children: [
                        SpeedDialChild(
                          child: FloatingActionButton(
                            onPressed: () {},
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            backgroundColor: Colors.blue,
                            child: Text("500m", style: TextStyle(fontSize: 15)),
                          ),
                        ),
                        SpeedDialChild(
                          child: FloatingActionButton(
                            onPressed: () {},
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            backgroundColor: Colors.blue,
                            child: Text("1km", style: TextStyle(fontSize: 15)),
                          ),
                        ),
                        SpeedDialChild(
                          child: FloatingActionButton(
                            onPressed: () {},
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            backgroundColor: Colors.blue,
                            child: Text("All", style: TextStyle(fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Padding(
            //   padding: EdgeInsets.all(10),
            //   child: Align(
            //     alignment: Alignment.centerRight,
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: <Widget>[
            //         SizedBox(height: 10),
            //         // ignore: prefer_const_constructors
            //         FloatingActionButton(
            //           onPressed: () async {
            //             _markers.clear();
            //             addMakerCarMoto(_markers,true,LatLng(currentLocationLatitude, currentLocationlongitude),0.002);
            //           },
            //           materialTapTargetSize: MaterialTapTargetSize.padded,
            //           backgroundColor: Colors.red,
            //           child: Icon(Icons.car_rental_outlined, size: 36.0),
            //         ),
            //         SizedBox(height: 10),
            //         // ignore: prefer_const_constructors
            //         FloatingActionButton(
            //           onPressed: () async {
            //             _markers.clear();
            //             addMakerCarMoto(_markers,false,LatLng(currentLocationLatitude, currentLocationlongitude),0.002);
            //           },
            //           materialTapTargetSize: MaterialTapTargetSize.padded,
            //           backgroundColor: Colors.blue,
            //           child: const Icon(Icons.motorcycle, size: 36),
            //         ),
            //         // SizedBox(height: 10),
            //       ],
            //     ),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 10),
                    // ignore: prefer_const_constructors
                    FloatingActionButton(
                      onPressed: () async {
                        _markers.clear();
                        _markers.clear();
                        _onAddMarkerpin(); // to save current pin
                        addMakerCarMoto(true);
                      },
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.car_rental_outlined, size: 36.0),
                    ),
                    SizedBox(height: 10),
                    // ignore: prefer_const_constructors
                    FloatingActionButton(
                      onPressed: () {
                        _markers.clear();
                        _onAddMarkerpin(); // to save current pin
                        addMakerCarMoto(false);
                      },
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.motorcycle, size: 36),
                    ),
                    // SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            //!Focus to Pin
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 10, 16),
              // padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton.small(
                      onPressed: () async {
                        animateCameraCurrentLocation();
                      },
                      // child: Icon(Icons.location_on, size: 36),
                      child: ImageIcon(AssetImage("assets/images/location.png"),
                          size: 20),
                    ),
                    //!CurrentLocation
                    SizedBox(height: 70),
                  ],
                ),
              ),
            ),

            Padding(
              // padding: EdgeInsets.only(bottom: 16, top: 16, right: 16, left: 5),
              padding: EdgeInsets.fromLTRB(10, 16, 16, 16),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: FloatingActionButton.small(
                      // mini: true,
                      onPressed: _onMapTypeButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      child: Icon(Icons.map, size: 25.0),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: SpeedDial(
                      renderOverlay: false,
                      direction: SpeedDialDirection.right,
                      label: Text("Pin the location"),
                      child: ImageIcon(arrow_sign, size: 20),
                      activeLabel: Text('Back'),
                      activeChild: ImageIcon(arrow_sign, size: 20),
                      animationAngle: 0, // rotate the icon
                      buttonSize: Size(45, 45),
                      childrenButtonSize: Size(50, 50),
                      // animationDuration: Duration(seconds: 1),
                      children: [
                        SpeedDialChild(
                          child: FloatingActionButton(
                            onPressed: () async {
                              gpsON = false;
                              _markers.clear();
                            },
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.lock),
                          ),
                        ),
                        SpeedDialChild(
                          child: FloatingActionButton(
                            onPressed: _onAddMarkerButtonPressed,
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            backgroundColor: Colors.green,
                            child: Icon(Icons.add_location, size: 36.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
