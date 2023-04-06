import 'dart:async';
import 'dart:math';
import 'package:app01/Atom/Prodata.dart';
import 'package:app01/Atom/measure.dart';
import 'package:app01/aFeedback/Feedback.dart';
import 'package:app01/aFeedback/MapUtils.dart';
import 'package:app01/navbar/Item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app01/Atom/CustomizeMarkerICon.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:app01/navbar/NavbarController.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/services.dart';
import 'package:app01/Atom/Marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:provider/provider.dart';

import 'FindDistan.dart';

const List<Widget> vehicle = <Widget>[
  ImageIcon(AssetImage("assets/images/car.png")),
  ImageIcon(AssetImage("assets/images/moto.png"))
];

class SimpleMaps extends StatefulWidget {
  const SimpleMaps({super.key});

  @override
  _MyAppState createState() => _MyAppState();

  static GlobalKey test() {
    return _MyAppState._globalKey;
  }

  void openDrawerCus() {
    _MyAppState().openDrawerCus();
  }

  void closeDrawerCus() {
    _MyAppState().closeDrawerCus();
  }

  void testAnimateH() {
    _MyAppState().testAnimate();
  }

  static List<dynamic> getPlaceMap() {
    return _MyAppState().placeMainList;
  }

  static Completer<GoogleMapController> getGoogleMapController() {
    return _MyAppState()._controller;
  }

  static void setMapCrr() {
    // ignore: invalid_use_of_protected_member
    _MyAppState().animateCameraCurrentLocation();
  }

  static Set<Marker> getSetMarker() {
    return _MyAppState()._markers;
  }

  static void addSetMarker(double la, double long) {
    _MyAppState()._markers.add(Marker(
          // This marker id can be anything that uniquely identifies each marker.
          markerId: const MarkerId("Your Pin Location"),
          position: LatLng(la, long), //Position on mark @ChangNoi
          infoWindow: const InfoWindow(
            title: "Your Pin Location", //title message on mark @ChangNoi
            snippet: 'message', //snippet message on mark @ChangNoi
          ),
          icon: BitmapDescriptor.defaultMarker,
        ));
  }

  static void testPrint() {
    _MyAppState().animateCameraCurrentLocation();
    print("+++++++++++++++++++++++++++++++++++++++++++++");
  }
}

class _MyAppState extends State<SimpleMaps> {
  //String googleApikey = "AIzaSyCMBfP4py6zjtDQEUby3HeXWl4jpfv5wTM";// use in android.xml
  String googleApikey =
      "AIzaSyCMBfP4py6zjtDQEUby3HeXWl4jpfv5wTM"; // use in android.xml
  Completer<GoogleMapController> _controller = Completer();
  static bool gpsON = false;
  bool isExtended = false;
  Set<Marker> _markers = {};
  static double btnSize = 36;
  AssetImage arrow_sign = AssetImage("assets/images/arrow_sign.png");
  final List<bool> _selectedVehicle = <bool>[false, false];

  final List<bool> isSelected = <bool>[false, true, false];
  static GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  static double currentLocationLatitude = 16.472955;
  static double currentLocationlongitude = 102.823042;
  static double radiusMark = 500;
  static late Uint8List userProfile;
  static LatLng _center = LatLng(16.472955, 102.823042);
  bool motoIconPress = false;
  bool carIconPress = false;
  late Map<String, dynamic> placeCar; //car // CacheRamUserV-1.0.0
  late Map<String, dynamic> placeMoto; //moto // CacheRamUserV-1.0.0
  late Map<String, dynamic> placeMap; //moto // CacheRamUserV-1.0.0

  Set<Polygon> _polygon = {};
  static bool polylinesVisible = false;
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {}; // polylines to show direction

  LatLng _pinPosition = _center;
  LatLng _pinMark = _center;
  static CustomizeMarkerICon currentLocationICon =
      CustomizeMarkerICon('assets/images/noiPic.png', 150);
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
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

  // camera on move
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

  getDirections(LatLng start, LatLng stop) async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApikey,
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(stop.latitude, stop.longitude),
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
      width: 6,
      visible: polylinesVisible,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  Future<void> addMakerCarMoto(bool vehicle) async {
    Map<String, dynamic> place;
    late BitmapDescriptor iconOfVehicle;
    if (vehicle) {
      iconOfVehicle = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(1, 1)), "assets/images/carPinRed2.png");
      place = placeCar;
    } else {
      iconOfVehicle = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(1, 1)),
          "assets/images/motoPinGreen2.png");
      place = placeMoto;
    }
    //print(place);
    List<dynamic> _parkList = place["placeParking"];
    //String path;
    //place = await GetDataMarker.getPlace(vehicle);
    // // Fetch content from the json file
    // final String response = await rootBundle.loadString(path);
    // final data = await json.decode(response);
    var listSize = _parkList.length;
    for (var i = 0; i < listSize; i++) {
      double latitude = _parkList[i]["Latitude"] as double;
      double longitude = _parkList[i]["Longitude"] as double;

      // radius to add
      if (measure(_pinMark.latitude, _pinMark.longitude, latitude, longitude) >
          radiusMark) {
        continue;
      }
      // measure(_pinMark.latitude, _pinMark.longitude, latitude, longitude);
      //debugPrint("Marker add");
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_parkList[i]["placeID"] as String),
        position: LatLng(latitude, longitude),
        //infoWindow: InfoWindow(title: "test", snippet: "testt"),
        onTap: () async {
          setState(() async {
            getDirections(
                LatLng(currentLocationLatitude, currentLocationlongitude),
                LatLng(latitude, longitude));
            polylinesVisible = true;
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(_parkList[i]["placeID"]),
                                  const Text("Distan & Duration",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(await getDistanceMatrix(
                                      LatLng(currentLocationLatitude,
                                          currentLocationlongitude),
                                      LatLng(latitude, longitude))),
                                ]),
                          )),
                    ),
                    Container(
                        // padding: EdgeInsets.only(top: 0),
                        width: 100,
                        height: 40,
                        alignment: Alignment.topRight,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(),
                          color: Colors.transparent,
                        ),
                        child: Row(
                          children: <Widget>[
                            FloatingActionButton(
                              onPressed: () async {
                                MapUtils.openMapOutApp(latitude, longitude);
                              },
                              backgroundColor: Colors.blueAccent.shade700,
                              child: Icon(Icons.arrow_circle_right, size: 36.0),
                            ),
                          ],
                        ))
                  ],
                ),
                LatLng(latitude, longitude)); // args 2
          });
        },
        icon: iconOfVehicle,
        visible: true,
      ));
    }
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

  late List<dynamic> placeMainList;
  Future<void> getPlaceMain() async {
    final docRef = GetDataMarker.getPlace();
    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        // print("Check dataaaaaaaaaaaaaaaaaaaaaaa");
        // print(data);
        placeMap = data;
        placeMainList = placeMap["placeParking"];
        print("----------------------------------------");
        print(placeMainList);
        print("----------------------------------------");
      },
      onError: (e) => print("Error getting document:222 $e"),
    );
  }

  @override
  void initState() {
    super.initState();
    // CacheRamUserV-1.0.0
    getMotoMain();
    // CacheRamUserV-1.0.0
    getCarMain();
    getPlaceMain();
  }

  void _onAddMarkerpin() {
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
      _pinMark = _lastMapPosition;
    });
  }

  void _onAddMarkerpinDe() {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: const MarkerId("Your Pin Location"),
        position: _pinMark, //Position on mark @ChangNoi
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
        visible: false, // if GPS ON it's viisble
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
      // debugPrint("${value.latitude} ${value.longitude}");
      getProFileImage();
      _AddMarkerCurrentLocation();
      currentLocationLatitude = value.latitude;
      currentLocationlongitude = value.longitude;
    });
  }

  static GlobalKey<ScaffoldState> ggMapK = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    realTimeLocationTask();
    final markerProv = Provider.of<ProData>(context);
    markerProv.addAllMaker(_markers);
    return MaterialApp(
        home: Scaffold(
      resizeToAvoidBottomInset: false,
      key: _globalKey,
      drawer: item(context),
      body: SafeArea(
        child: Container(
          child: Stack(
            children: <Widget>[
              GoogleMap(
                onTap: (position) {
                  _customInfoWindowController.hideInfoWindow!();
                  isDialOpen.value = false;
                  polylinesVisible = false;
                  polylines.clear();
                  setState(() {});
                },
                key: ggMapK,
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
                myLocationEnabled: true, // current locate button
                markers: markerProv.getMarker(),
                polylines: Set<Polyline>.of(polylines.values),
                mapToolbarEnabled: false,
              ),
              CustomInfoWindow(
                controller: _customInfoWindowController,
                height: 200,
                width: 150,
                offset: 30,
              ),
              Center(
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: <Widget>[
                    //! Pinpoint
                    if (isDialOpen.value)
                      Positioned(
                        top: MediaQuery.of(context).size.height / 2 - 75,
                        left: MediaQuery.of(context).size.width / 2 - 75,
                        child: Container(
                          width: 150,
                          height: 150,
                          child: RotatedBox(
                            quarterTurns: 0,
                            child: IconButton(
                              icon: Icon(Icons.keyboard_arrow_up,
                                  size: 70.0, color: Colors.white),
                              onPressed: null,
                            ),
                          ),
                        ),
                      ),
                    if (isDialOpen.value)
                      Positioned(
                        top: MediaQuery.of(context).size.height / 2 - 75,
                        left: MediaQuery.of(context).size.width / 2 - 75,
                        child: Container(
                          width: 150,
                          height: 150,
                          child: RotatedBox(
                            quarterTurns: 0,
                            child: IconButton(
                              icon: Icon(Icons.keyboard_arrow_up,
                                  size: 60.0, color: Colors.red),
                              onPressed: null,
                            ),
                          ),
                        ),
                      ),
                    Positioned(child: Text("Some text"), bottom: -25),
                  ],
                ),
              ),
              Column(
                children: [
                  NavbarController(), //! navbar
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 16, 16),
                      child: SpeedDial(
                        renderOverlay: false,
                        direction: SpeedDialDirection.right,
                        childPadding: EdgeInsets.all(5),
                        childrenButtonSize: Size(75, 50),
                        backgroundColor: Color(0xFF1C82AD),
                        openCloseDial: isDialOpen,
                        child: Icon(
                          Icons.radar,
                          size: 36,
                        ),
                        children: [
                          SpeedDialChild(
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                setState(() {
                                  radiusMark = 500;
                                  _markers.clear();
                                  markerProv.clear();
                                  _customInfoWindowController.hideInfoWindow!();
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              backgroundColor: Color(0xFF1C82AD),
                              label: Text("500m"),
                            ),
                          ),
                          SpeedDialChild(
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                setState(() {
                                  radiusMark = 1000;
                                  _markers.clear();
                                  markerProv.clear();
                                  _customInfoWindowController.hideInfoWindow!();
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              backgroundColor: Color(0xFF1C82AD),
                              label: Text("1km"),
                            ),
                          ),
                          SpeedDialChild(
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                setState(() {
                                  radiusMark = 7000 * 1000;
                                  _markers.clear();
                                  markerProv.clear();
                                  _customInfoWindowController.hideInfoWindow!();
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              backgroundColor: Color(0xFF1C82AD),
                              label: Text("All"),
                            ),
                          ),
                          SpeedDialChild(
                            child: FloatingActionButton.extended(
                              label: Text("Range",
                                  style: TextStyle(color: Colors.black)),
                              onPressed: null,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              //!Focus to Pin
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 7, 1),
                // padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton.small(
                        backgroundColor: Color(0xFF0e2f44),
                        onPressed: () async {
                          animateCameraCurrentLocation();
                        },
                        // child: Icon(Icons.location_on, size: 36),
                        child: ImageIcon(
                            AssetImage("assets/images/location.png"),
                            size: 20),
                      ),
                      //!CurrentLocation
                      // SizedBox(height: 70),
                      SizedBox(height: 1),

                      Container(
                        padding: EdgeInsets.zero,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          // border: Border.all(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: ToggleButtons(
                          direction: axisDirectionToAxis(AxisDirection.up),

                          // direction: vertical ? Axis.vertical : Axis.horizontal,
                          onPressed: (int index) {
                            setState(() {
                              // if (index == 0) {
                              //   _markers.clear();
                              //   addMakerCarMoto(false); //Car
                              // } else {
                              //   _markers.clear();
                              //   addMakerCarMoto(true); //Motorcycle
                              // }
                              // List<bool> count = [true,false];
                              if (index == 0 && carIconPress == false) {
                                addMakerCarMoto(true); //Car
                                addMakerCarMoto(true); //Car
                                carIconPress = true;
                                motoIconPress = false;
                              } else if (index == 1 && motoIconPress == false) {
                                addMakerCarMoto(false); // Motorcycle
                                addMakerCarMoto(false); // Motorcycle
                                motoIconPress = true;
                                carIconPress = false;
                              } else {
                                motoIconPress = false;
                                carIconPress = false;
                              }

                              for (int i = 0;
                                  i < _selectedVehicle.length;
                                  i++) {
                                if (i == index) {
                                  _selectedVehicle[i] = !_selectedVehicle[i];
                                } else {
                                  _selectedVehicle[i] = false;
                                }
                                // _selectedVehicle[i] = i == index;
                              }
                              _markers.clear();
                              markerProv.clear();
                            });
                            _onAddMarkerpinDe();
                          },

                          borderRadius:
                              const BorderRadius.all(Radius.circular(20.0)),
                          selectedBorderColor: Colors.white,
                          fillColor: Colors.white,
                          selectedColor: Colors.green[800],
                          color: Colors.grey[850],
                          isSelected: _selectedVehicle,

                          children: vehicle,
                        ),
                      ),
                      SizedBox(height: 20),
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
                        backgroundColor: Color(0xFF0e2f44),
                        // mini: true,
                        onPressed: _onMapTypeButtonPressed,
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        child: Icon(Icons.layers, size: 25.0),
                      ),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: SpeedDial(
                        renderOverlay: false,
                        direction: SpeedDialDirection.right,
                        label: Text("Pin the location"),
                        backgroundColor: Color(0xFF02A8A8),
                        child: ImageIcon(arrow_sign, size: 20),
                        activeLabel: Text('Back'),
                        activeChild: ImageIcon(arrow_sign, size: 20),
                        animationAngle: 0, // rotate the icon
                        buttonSize: Size(45, 45),
                        childrenButtonSize: Size(50, 50),
                        openCloseDial: isDialOpen,
                        onOpen: () {
                          setState(() {
                            isDialOpen.value = true;
                          });
                        },
                        onClose: () {
                          setState(() {
                            isDialOpen.value = false;
                          });
                        },
                        children: [
                          SpeedDialChild(
                            child: FloatingActionButton(
                              onPressed: () async {
                                setState(() {
                                  gpsON = false;
                                  _markers.clear();
                                  markerProv.clear();
                                  _customInfoWindowController.hideInfoWindow!();
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              backgroundColor: Color(0xFFFF8B13),
                              child: Icon(Icons.delete),
                            ),
                          ),
                          SpeedDialChild(
                            child: FloatingActionButton(
                              onPressed: () {
                                _onAddMarkerpin();
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              backgroundColor: Color(0xFF03C988),
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
      ),
    ));
  }

  void openDrawerCus() {
    _globalKey.currentState?.openDrawer();
    setState(() {
      isDialOpen.value = false;
    });
  }

  void closeDrawerCus() {
    _globalKey.currentState?.closeDrawer();
    setState(() {
      isDialOpen.value = false;
    });
  }

  void testAnimate() {
    // markerProv.addMaker(Marker(
    //   // This marker id can be anything that uniquely identifies each marker.
    //   markerId: const MarkerId("Your Pin Location"),
    //   position: _lastMapPosition, //Position on mark @ChangNoi
    //   infoWindow: const InfoWindow(
    //     title: "Your Pin Location", //title message on mark @ChangNoi
    //     snippet: 'message', //snippet message on mark @ChangNoi
    //   ),
    //   icon: BitmapDescriptor.defaultMarker,
    // ));
    ggMapK.currentState?.setState(() {
      animateCameraCurrentLocation();
    });
    print(_lastMapPosition);
    print("++++++++++++\n+\n++\n+");
  }
}
