import 'dart:async';

import 'package:app01/Atom/Marker.dart';
import 'package:app01/Atom/SimpleMaps.dart';
import 'package:app01/data/Place.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../Atom/ProData.dart';
import '../aFeedback/MapUtils.dart';

class Searching extends StatefulWidget {
  const Searching({super.key});

  @override
  State<Searching> createState() => _SearchingState();
}

class _SearchingState extends State<Searching> {
  final controller = TextEditingController();
  late TextEditingController _editingController; // gobalvar

  List<Place> places = allPlace;
  bool _isShow = false;

  @override
  void initState() {
    getPlaceMain();
    _editingController = TextEditingController();
  }

  late List<dynamic> placeMainList;
  Future<void> getPlaceMain() async {
    final docRef = GetDataMarker.getPlace();
    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        placeMainList = data["placeParking"];
        print("----------------------------------------");
        print(placeMainList);
        print("----------------------------------------");
      },
      onError: (e) => print("Error getting document:222 $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 54,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 10),
                        blurRadius: 50,
                        color: Theme.of(context).primaryColor.withOpacity(0.23),
                      )
                    ]),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.only(right: 20),
                      onPressed: () {
                        SimpleMaps().openDrawerCus();
                      },
                      icon: Icon(Icons.menu,
                          // color: Theme.of(context).primaryColor.withOpacity(0.5)),
                          color: Colors.black),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                    ),
                    // ),

                    Expanded(
                      child: TextField(
                        controller: _editingController,
                        textAlignVertical: TextAlignVertical.center,
                        // onChanged: searchplace,
                        onTap: () {
                          showSearch(
                              context: context,
                              delegate: MySearchDelegate(placeMainList));
                        },
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                              // color: Theme.of(context).primaryColor.withOpacity(0.5)),
                              color: Colors.black45),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),

                    _editingController.text.trim().isEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                            // color:
                            //     Theme.of(context).primaryColor.withOpacity(0.5)),
                            // onPressed: () => getDatabase())
                            onPressed: () => {})
                        : IconButton(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            icon: Icon(Icons.clear,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.5)),
                            onPressed: () => setState(() {
                                  _editingController.clear();
                                })),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Map<String, dynamic> placeKhao = {};
  // static DocumentReference<Map<String, dynamic>> getDatabase() {
  //   Map<String, dynamic> x = {};
  //   final docRef =
  //       FirebaseFirestore.instance.collection("parkPlace").doc("place");
  //   docRef.get().then(
  //     (DocumentSnapshot doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       x = data;
  //       // print(x);
  //       print(x["placeParking"].length);
  //     },
  //     onError: (e) => print("Error getting document: $e"),
  //   );
  //   // print(docRef);
  //   // print(SimpleMaps.getPlaceMap().length);
  //   return docRef;
  // }

  // void searchplace(String query) {
  //   final suggestions = allPlace.where((place) {
  //     final placeName = place.place.toLowerCase();
  //     final input = query.toLowerCase();

  //     return placeName.contains(input);
  //   }).toList();
  //   setState(() {
  //     places = suggestions;
  //   });
  // }
}

class MySearchDelegate extends SearchDelegate<String> {
  late List<dynamic> places; // keep data place from DB.
  //Completer<GoogleMapController> _controller = SimpleMaps.getGoogleMapController();

  MySearchDelegate(List<dynamic> places) {
    this.places = places;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            if (query.isEmpty) {
              close(context, '');
            } else {
              query = '';
            }
          },
          icon: Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () => close(context, ''), icon: Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) => Center(
        child: Text(
          query,
          style: TextStyle(fontSize: 64),
        ),
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    // final markerProv = Provider.of<ProData>(context);
    List<String> placeT = places
        .map((item) => item["placeID"].toString())
        .toList()
        .where((searchPlace) {
      final result = searchPlace.toLowerCase();
      final input = query.toLowerCase();
      return result.contains(input);
    }).toList();

    return ListView.builder(
      // physics: FixedExtentScrollPhysics(),
      itemCount: placeT.length,
      itemBuilder: (context, index) {
        final test = placeT[index];

        return ListTile(
          title: Text(
            test.toString(),
            style: TextStyle(fontSize: 20),
          ),
          // when click it's will activate some thing
          onTap: () async {
            query = test.toString();
            // data on tap
            print(places[index]);
            print(places[index]["Latitude"]);
            print(places[index]["Longitude"]);

            CameraPosition cameraPosition = new CameraPosition(
              target:
                  LatLng(places[index]["Latitude"], places[index]["Longitude"]),
              zoom: 16,
            );
            // print("camerafinish");
            close(context, '');

            // try {
            //   GoogleMapController controllerTem =
            //       await SimpleMaps.getGoogleMapController().future;
            //   controllerTem.animateCamera(
            //       CameraUpdate.newCameraPosition(cameraPosition));
            // } catch (e) {
            //   print("------------------------------------");
            //   print(e);
            // }
            // SimpleMaps.getGoogleMapController().future.then((controllerTem) {
            //   controllerTem.animateCamera(
            //       CameraUpdate.newCameraPosition(cameraPosition));
            //   print("----*+++++++++++++");
            //   // set the loading state back to false when the operation completes
            // }).catchError((e) {
            //   print("------------------------------------");
            //   print(e);
            //   // set the loading state back to false when there's an error
            // });

            //SimpleMaps.addSetMarker(places[index]["Latitude"], places[index]["Longitude"]);

            // SimpleMaps.setMapCrr();
            // final GoogleMapController controllerTemMap = await controllerTem;
            //controllerTem.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            // //SimpleMaps.setStateThis();
            //_MyAppState().animationAngle

            // Provider.of<ProData>(context).test(places[index]["Latitude"], places[index]["Longitude"]);
            // Provider.of<ProData>(context).clear();

            
            // SimpleMaps().testAnimateH(/*places[index]["Latitude"], places[index]["Longitude"]*/);


            //SimpleMaps().openDrawerCus();

            // final markerProv = Provider.of<ProData>(context);
            // print(markerProv.getMarker());
            // print("-------------Prov+++");
            // print(markerProv);
            MapUtils.openMapOutApp(places[index]["Latitude"], places[index]["Longitude"]);
          },
        );
      },
    );
  }
}
