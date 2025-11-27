import 'dart:convert';

RoutingResponse routingResponseFromJson(String str) =>
    RoutingResponse.fromJson(json.decode(str));

String routingResponseToJson(RoutingResponse data) =>
    json.encode(data.toJson());

class RoutingResponse {
  final String code;
  final List<Route> routes;
  final List<Waypoint> waypoints;

  RoutingResponse({
    required this.code,
    required this.routes,
    required this.waypoints,
  });

  factory RoutingResponse.fromJson(Map<String, dynamic> json) =>
      RoutingResponse(
        code: json["code"] ?? "",
        routes: json["routes"] != null
            ? List<Route>.from(json["routes"].map((x) => Route.fromJson(x)))
            : [],
        waypoints: json["waypoints"] != null
            ? List<Waypoint>.from(
                json["waypoints"].map((x) => Waypoint.fromJson(x)),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
    "code": code,
    "routes": List<dynamic>.from(routes.map((x) => x.toJson())),
    "waypoints": List<dynamic>.from(waypoints.map((x) => x.toJson())),
  };
}

class Route {
  final RouteGeometry geometry;
  final double distance;
  final double duration;

  Route({
    required this.geometry,
    required this.distance,
    required this.duration,
  });

  factory Route.fromJson(Map<String, dynamic> json) => Route(
    geometry: RouteGeometry.fromJson(json["geometry"] ?? {}),
    distance: json["distance"]?.toDouble() ?? 0.0,
    duration: json["duration"]?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "geometry": geometry.toJson(),
    "distance": distance,
    "duration": duration,
  };
}

class RouteGeometry {
  final String type;
  final List<List<double>> coordinates;

  RouteGeometry({required this.type, required this.coordinates});

  factory RouteGeometry.fromJson(Map<String, dynamic> json) => RouteGeometry(
    type: json["type"] ?? "",
    coordinates: json["coordinates"] != null
        ? List<List<double>>.from(
            json["coordinates"].map(
              (x) => List<double>.from(x.map((y) => y.toDouble())),
            ),
          )
        : [],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": List<dynamic>.from(
      coordinates.map((x) => List<dynamic>.from(x.map((y) => y))),
    ),
  };
}

class Waypoint {
  final String hint;
  final double distance;
  final String name;
  final List<double> location;

  Waypoint({
    required this.hint,
    required this.distance,
    required this.name,
    required this.location,
  });

  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
    hint: json["hint"] ?? "",
    distance: json["distance"]?.toDouble() ?? 0.0,
    name: json["name"] ?? "",
    location: json["location"] != null
        ? List<double>.from(json["location"].map((x) => x.toDouble()))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "hint": hint,
    "distance": distance,
    "name": name,
    "location": List<dynamic>.from(location.map((x) => x)),
  };
}
