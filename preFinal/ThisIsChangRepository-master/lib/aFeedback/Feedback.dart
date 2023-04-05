import 'package:app01/aFeedback/sendFeedBack.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedBack extends StatefulWidget {
  const FeedBack({super.key});

  @override
  State<StatefulWidget> createState() => _FeedBack();
}

class _FeedBack extends State<FeedBack> {
  final feedBackTxt = TextEditingController();
  late var textUser = "";
  var star = 0;
  var bgStar = Colors.blue.shade900;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    feedBackTxt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 2200,
                // !
                color: Colors.green.shade200,
                // ignore: prefer_const_constructors
                child: Column(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    // ignore: prefer_const_constructors
                    Padding(
                      padding: const EdgeInsets.all(1),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 250,
                // ignore: prefer_const_constructors
                decoration: BoxDecoration(
                  image: const DecorationImage(
                      image: AssetImage("assets/images/ParkKKUFB.png"),
                      fit: BoxFit.fill),
                ),
              ),
            ),
            Positioned(
              top: 235,
              right: 0,
              left: 0,
              child: Container(
                height: 80,
                // width: MediaQuery.of(context).size.width - 35,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 1)
                    ]),
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FloatingActionButton(
                      onPressed: () {
                        star = 1;
                        setState(() {});
                      },
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: star >= 1 ? bgStar : Colors.white,
                      child: Icon(Icons.star,
                          color: Colors.yellow.shade100, size: 36.0),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        star = 2;
                        setState(() {});
                      },
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: star >= 2 ? bgStar : Colors.white,
                      child: Icon(Icons.star,
                          color: Colors.yellow.shade200, size: 36.0),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        star = 3;
                        setState(() {});
                      },
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: star >= 3 ? bgStar : Colors.white,
                      child: Icon(Icons.star,
                          color: Colors.yellow.shade300, size: 36.0),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        star = 4;
                        setState(() {});
                      },
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: star >= 4 ? bgStar : Colors.white,
                      child: Icon(Icons.star,
                          color: Colors.yellow.shade400, size: 36.0),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        star = 5;
                        setState(() {});
                      },
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: star >= 5 ? bgStar : Colors.white,
                      child: Icon(Icons.star,
                          color: Colors.yellow.shade500, size: 36.0),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              //top: 10,
              left: 0,
              right: 0,
              child: Container(
                height: 400,
                // width: MediaQuery.of(context).size.width - 35,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 1)
                    ]),
                child: Column(
                  children: <Widget>[
                    Padding(
                      // ignore: prefer_const_constructors
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 14,
                        obscureText: false,
                        controller: feedBackTxt,
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.black),
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          textUser = value!;
                        },
                        // ignore: prefer_const_constructors
                        decoration: InputDecoration(
                          // ignore: prefer_const_constructors
                          errorStyle: TextStyle(
                            fontSize: 20,
                          ),
                          border: InputBorder.none,
                          icon: null,
                          iconColor: null,
                          labelText: 'Type FeedBack here',
                          labelStyle:
                              const TextStyle(color: Colors.grey, fontSize: 30),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          if (textUser != "") {
                            sendFeedBack.send(FirebaseAuth.instance.currentUser.toString(), textUser, star.toString());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          fixedSize: Size.fromWidth(double.maxFinite),
                        ),
                        child: const Text("Send"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}