import 'package:app01/Atom/SimpleMaps.dart';
import 'package:app01/aFeedback/Feedback.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget item(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;
  final auth = FirebaseAuth.instance;
  Widget userImage;
  try {
    userImage = CircleAvatar(
      backgroundImage: NetworkImage(auth.currentUser!.photoURL!),
    );
    print(auth.currentUser!.photoURL!);
  } catch (e) {
    userImage = const Icon(
      Icons.person,
      size: 50,
      color: Color.fromARGB(255, 117, 117, 117),
    );
  }
  return Drawer(
    child: ListView(
      // Remove padding
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text("KKU PARK INFO"),
          accountEmail: Text((user?.email!).toString()),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.red,
            minRadius: 50,
            maxRadius: 75,
            child: ClipOval(
              child: userImage,
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
            image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage("assets/images/sideBar.png")),
          ),
        ),
        ListTile(
          leading: Icon(Icons.notifications),
          title: Text('Feedback'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedBack(),
              ),
            );
            SimpleMaps().closeDrawerCus();
            print("Feedback");
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () => SimpleMaps().closeDrawerCus(),
        ),
        ListTile(
          title: Text('Sign out'),
          leading: Icon(Icons.exit_to_app),
          onTap: () => FirebaseAuth.instance.signOut(),
        ),
      ],
    ),
  );
}
