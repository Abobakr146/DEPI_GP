// To parse this JSON data, do
//
//     final vehicle = vehicleFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<Vehicle> vehicleFromJson(String str) => List<Vehicle>.from(json.decode(str).map((x) => Vehicle.fromJson(x)));

String vehicleToJson(List<Vehicle> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Vehicle {
  final String manufacture;
  final String fuelType;
  final double consumption;
  String? userId;

  Vehicle({
    required this.manufacture,
    required this.fuelType,
    required this.consumption,
    this.userId,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    manufacture: json["manufacture"],
    fuelType: json["fuel_type"],
    consumption: json["consumption"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "manufacture": manufacture,
    "fuel_type": fuelType,
    "consumption": consumption,
    "user_id": userId,
  };
}
