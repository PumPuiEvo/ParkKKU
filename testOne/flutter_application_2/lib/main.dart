import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/SimpleMaps.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main(){
  runApp(SimpleMaps());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  //GoogleMapController? mapController; //contrller for Google map
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyCMBfP4py6zjtDQEUby3HeXWl4jpfv5wTM";
  
  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylinesX = {}; //polylines to show direction

  LatLng startLocation = LatLng(16.475614, 102.819933);  
  LatLng endLocation = LatLng(16.471453, 102.822357); 
                            

  @override
  void initState() {

     markers.add(Marker( //add start location marker
        markerId: MarkerId(startLocation.toString()),
        position: startLocation, //position of marker
        infoWindow: InfoWindow( //popup info 
          title: 'Starting Point ',
          snippet: 'Start Marker',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      markers.add(Marker( //add distination location marker
        markerId: MarkerId(endLocation.toString()),
        position: endLocation, //position of marker
        infoWindow: InfoWindow( //popup info 
          title: 'Destination Point ',
          snippet: 'Destination Marker',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));
      
      getDirections(); //fetch direction polylines from Google API
      
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  getDirections() async {
      List<LatLng> polylineCoordinates = [];
     
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleAPiKey,
          PointLatLng(startLocation.latitude, startLocation.longitude),
          PointLatLng(endLocation.latitude, endLocation.longitude),
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
    );
    polylinesX[id] = polyline;
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
          appBar: AppBar( 
             title: Text("Route Driection in Google Map"),
             backgroundColor: Colors.deepPurpleAccent,
          ),
          body: GoogleMap( //Map widget from google_maps_flutter package
                    zoomGesturesEnabled: true, //enable Zoom in, out on map
                    initialCameraPosition: CameraPosition( //innital position in map
                      target: startLocation, //initial position
                      zoom: 16.0, //initial zoom level
                    ),
                    markers: markers, //markers to show on map
                    polylines: Set<Polyline>.of(polylinesX.values), //polylines
                    mapType: MapType.normal, //map type
                    onMapCreated:_onMapCreated
              ),
       );
  }
}