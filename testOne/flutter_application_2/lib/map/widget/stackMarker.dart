import 'package:flutter/material.dart';

Widget stackMarkerPin() {
  return Stack(
    alignment: Alignment.bottomCenter,
    children: <Widget>[
      Padding(
        padding: EdgeInsets.all(2),
        child: Container(
          height: 200,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            margin: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 2,
                  height: 2,
                  decoration: ShapeDecoration(
                    shape: CircleBorder(),
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
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
                  null;
                },
                backgroundColor: Colors.green,
                child: Icon(Icons.add_location, size: 36.0),
              ),
              FloatingActionButton(
                onPressed: () async {
                  null;
                },
                child: Icon(Icons.location_on, size: 40),
              ),
            ],
          ))
    ],
  );
}
