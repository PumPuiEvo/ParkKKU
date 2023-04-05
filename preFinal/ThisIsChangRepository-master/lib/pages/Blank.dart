import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class Blank extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<Blank> createState() => _BlankState();
}

class _MyWidgetState extends State<Blank> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}
