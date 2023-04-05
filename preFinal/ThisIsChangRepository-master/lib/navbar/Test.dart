import 'package:app01/Atom/Marker.dart';
import 'package:flutter/material.dart';
import 'package:app01/Atom/SimpleMaps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app01/data/Place.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final controller = TextEditingController();
  late TextEditingController _editingController; // gobalvar

  List<Place> places = allPlace;
  bool _isShow = false;

  @override
  void initState() {
    _editingController = TextEditingController();
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
                        // onPressed:
                        // () {
                        //   Navigator.of(context).push(SimpleMaps());
                        // };
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SimpleMaps()),
                        );
                      },
                      icon: Icon(Icons.arrow_back,
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
                        // onChanged: getDatabase(),
                        // onTap: () {
                        //   getDatabase();
                        // },
                        // key: ,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                              // color: Theme.of(context).primaryColor.withOpacity(0.5)),
                              color: Colors.black45),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        // onChanged: (_) => setState(() {}),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          final place = places[index];

                          return ListTile(
                            title: Text(place.place),
                          );
                        },
                      ),
                    ),

                    _editingController.text.trim().isEmpty
                        ? IconButton(
                            icon: Icon(Icons.search, color: Colors.black),
                            // color:
                            //     Theme.of(context).primaryColor.withOpacity(0.5)),
                            onPressed: getDatabase)
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
              // ListView.builder(
              //   itemCount: places.length,
              //   itemBuilder: (context, index) {
              //     final place = places[index];

              //     return ListTile(
              //       title: Text(place.place),
              //     );
              //   },
              // )
              Container(
                  // child: Expanded(
                  //   child: ListView.builder(
                  //     itemCount: places.length,
                  //     itemBuilder: (context, index) {
                  //       final place = places[index];

                  //       return ListTile(
                  //         title: Text(place.place),
                  //       );
                  //     },
                  //   ),
                  // ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  // Map<String, dynamic> x = {};
   // late Map<String, dynamic> place; //moto // CacheRamUserV-1.0.0R

  String getDatabase() {
    Map<String, dynamic> x = {};
   // List<dynamic> _parkList = SimpleMaps.getPlaceMap()["placeParking"];

    // for (var i = 0; i < listSize; i++) {
    //   print(SimpleMaps.getPlaceMap()[i]["placeID"]);
    // }
    print(SimpleMaps.getPlaceMap()[1]["placeID"]);
    return SimpleMaps.getPlaceMap()[1]["placeID"];
  }

  void searchplace(String query) {
    final suggestions = allPlace.where((place) {
      final placeName = place.place.toLowerCase();
      final input = query.toLowerCase();

      return placeName.contains(input);
    }).toList();
    setState(() {
      places = suggestions;
    });
  }
}
