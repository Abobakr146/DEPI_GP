import 'dart:convert';

GeocodingResponse geocodingResponseFromJson(String str) =>
    GeocodingResponse.fromJson(json.decode(str));

String geocodingResponseToJson(GeocodingResponse data) =>
    json.encode(data.toJson());

class GeocodingResponse {
  final String type;
  final List<Feature> features;

  GeocodingResponse({required this.type, required this.features});

  factory GeocodingResponse.fromJson(Map<String, dynamic> json) =>
      GeocodingResponse(
        type: json["type"] ?? "",
        features: json["features"] != null
            ? List<Feature>.from(
                json["features"].map((x) => Feature.fromJson(x)),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
    "type": type,
    "features": List<dynamic>.from(features.map((x) => x.toJson())),
  };
}

class Feature {
  final String id;
  final String type;
  final List<String> placeType;
  final String placeName;
  final String text;
  final Geometry geometry;
  final dynamic properties;
  final String? address;

  Feature({
    required this.id,
    required this.type,
    required this.placeType,
    required this.placeName,
    required this.text,
    required this.geometry,
    this.properties,
    this.address,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
    id: json["id"] ?? "",
    type: json["type"] ?? "",
    placeType: json["place_type"] != null
        ? List<String>.from(json["place_type"].map((x) => x))
        : [],
    placeName: json["place_name"] ?? "",
    text: json["text"] ?? "",
    geometry: Geometry.fromJson(json["geometry"] ?? {}),
    properties: json["properties"],
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "place_type": List<dynamic>.from(placeType.map((x) => x)),
    "place_name": placeName,
    "text": text,
    "geometry": geometry.toJson(),
    "properties": properties,
    "address": address,
  };
}

class Geometry {
  final String type;
  final List<double> coordinates;

  Geometry({required this.type, required this.coordinates});

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    type: json["type"] ?? "",
    coordinates: json["coordinates"] != null
        ? List<double>.from(json["coordinates"].map((x) => x.toDouble()))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
  };
}
