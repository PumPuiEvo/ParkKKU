import 'package:app01/data/Place.dart';
import 'package:app01/navbar/Sidebar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Searching extends StatefulWidget {
  const Searching({super.key});

  @override
  State<Searching> createState() => _SearchingState();
}

class _SearchingState extends State<Searching> {
  final controller = TextEditingController();
  late TextEditingController _editingController;

  List<Place> places = allPlace;
  bool _isShow = false;

  @override
  void initState() {
    _editingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(
            horizontal: 10, vertical: MediaQuery.of(context).size.width / 10),
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: 54,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: Icon(Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColor.withOpacity(0.5)),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            // ),
            Expanded(
              child: TextField(
                controller: _editingController,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (_) => setState(() {searchplace(_editingController.text);}),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                      color: Theme.of(context).primaryColor.withOpacity(0.5)),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            _editingController.text.trim().isEmpty
                ? IconButton(
                    icon: Icon(Icons.search,
                        color: Theme.of(context).primaryColor.withOpacity(0.5)),
                    onPressed: null)
                : IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: Icon(Icons.clear,
                        color: Theme.of(context).primaryColor.withOpacity(0.5)),
                    onPressed: () => setState(() {
                          _editingController.clear();
                        })),
          ],
        ),
      ),
    );
  }
Map<String, dynamic> placeKhao = {};
void getDatabaseCar() {
  final docRef = FirebaseFirestore.instance.collection("parkPlace").doc("place");
  docRef.get().then(
    (DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      placeKhao = data;
    },
    onError: (e) => print("Error getting document: $e"),
  );
}
//พิมพ์หาสถานที่
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
