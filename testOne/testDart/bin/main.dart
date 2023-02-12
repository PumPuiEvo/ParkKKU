import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

late List parkList;
Future<String> loadData() async {
  var data = await rootBundle.loadString("assets/parkPlace/car.json");
    parkList = json.decode(data);
  return "success";
}