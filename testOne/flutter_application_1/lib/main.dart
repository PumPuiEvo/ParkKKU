import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/testErr/MyApp2.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
        ),
      ),
    );
  }
}

/*
void main() => runApp(const MyTestmap());

class MyTestmap extends StatefulWidget {
  const MyTestmap({super.key});

  @override
  State<MyTestmap> createState() => _MyTestmapState();
}

class _MyTestmapState extends State<MyTestmap> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _cameraPositionTest1 = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(16.472955, 102.823042),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //mapType: MapType.hybrid,
      body : GoogleMap(
        mapType: MapType.satellite,
        initialCameraPosition: _cameraPositionTest1,
        onMapCreated: (controller) => _controller.complete(controller),
      ),
    );
  }
}
*/