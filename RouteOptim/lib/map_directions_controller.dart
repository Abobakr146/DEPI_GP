import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'map_service.dart';
import 'geocoding_response.dart';

class LocationSuggestion {
  final String displayName;
  final double lat;
  final double lon;
  final String? placeName;
  final String? placeType;

  LocationSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
    this.placeName,
    this.placeType,
  });

  factory LocationSuggestion.fromFeature(Feature feature) {
    return LocationSuggestion(
      displayName: feature.placeName,
      lat: feature.geometry.coordinates[1],
      lon: feature.geometry.coordinates[0],
      placeName: feature.text,
      placeType: feature.placeType.isNotEmpty ? feature.placeType.first : null,
    );
  }
}

class MapDirectionsController extends GetxController {
  final MapService _mapService = MapService();
  final MapController mapController = MapController();
  final TextEditingController currentLocationController =
      TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final RxList<TextEditingController> waypointControllers =
      <TextEditingController>[].obs;

  final RxList<LocationSuggestion> currentSuggestions =
      <LocationSuggestion>[].obs;
  final RxList<LocationSuggestion> destSuggestions = <LocationSuggestion>[].obs;
  final RxList<List<LocationSuggestion>> waypointSuggestions =
      <List<LocationSuggestion>>[].obs;

  final Rx<LocationSuggestion?> selectedStart = Rx<LocationSuggestion?>(null);
  final Rx<LocationSuggestion?> selectedEnd = Rx<LocationSuggestion?>(null);
  final RxList<LocationSuggestion?> selectedWaypoints =
      <LocationSuggestion?>[].obs;

  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final Rx<double?> distance = Rx<double?>(null);
  Timer? debounceTimer;

  final RxBool showCurrentSuggestions = false.obs;
  final RxBool showDestSuggestions = false.obs;
  final RxList<bool> showWaypointSuggestions = <bool>[].obs;

  final RxBool isSelectingFromMap = false.obs;
  final RxInt selectingIndex = (-1).obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    final locations = Get.arguments as List<String>? ?? [];
    if (locations.isNotEmpty) {
      // First location is start
      currentLocationController.text = locations[0];
      _geocodeAndSetLocation(locations[0], -1);

      // Last location is destination
      if (locations.length > 1) {
        destinationController.text = locations.last;
        _geocodeAndSetLocation(locations.last, -2);
      }

      // Everything in between are waypoints
      for (int i = 1; i < locations.length - 1; i++) {
        addWaypoint();
        waypointControllers[i - 1].text = locations[i];
        _geocodeAndSetLocation(locations[i], i - 1);
      }
    }
  }

  // Helper method to geocode a location string and mark it on the map
  Future<void> _geocodeAndSetLocation(String locationText, int index) async {
    if (locationText.isEmpty) return;

    final response = await _mapService.searchLocation(locationText);
    if (response != null && response.features.isNotEmpty) {
      final location = LocationSuggestion.fromFeature(response.features.first);

      if (index == -1) {
        selectedStart.value = location;
      } else if (index == -2) {
        selectedEnd.value = location;
      } else {
        selectedWaypoints[index] = location;
      }

      // Calculate route if we have start and end
      if (selectedStart.value != null && selectedEnd.value != null) {
        await calculateRouteWithWaypoints();
      }
    }
  }

  @override
  void onClose() {
    currentLocationController.dispose();
    destinationController.dispose();
    for (var controller in waypointControllers) {
      controller.dispose();
    }
    debounceTimer?.cancel();
    scrollController.dispose();
    _mapService.dispose();
    super.onClose();
  }

  void addWaypoint() {
    waypointControllers.add(TextEditingController());
    selectedWaypoints.add(null);
    waypointSuggestions.add([]);
    showWaypointSuggestions.add(false);
  }

  void removeWaypoint(int index) {
    // Validate index before attempting removal
    if (index < 0 || index >= waypointControllers.length) {
      print('Invalid waypoint index: $index');
      return;
    }

    waypointControllers[index].dispose();
    waypointControllers.removeAt(index);
    selectedWaypoints.removeAt(index);
    waypointSuggestions.removeAt(index);
    showWaypointSuggestions.removeAt(index);

    if (selectedStart.value != null && selectedEnd.value != null) {
      calculateRouteWithWaypoints();
    }
  }

  Future<void> searchLocation(String query, int index) async {
    if (query.length < 2) {
      if (index == -1) {
        currentSuggestions.clear();
      } else if (index == -2) {
        destSuggestions.clear();
      } else {
        waypointSuggestions[index] = [];
      }
      return;
    }

    final response = await _mapService.searchLocation(query);
    if (response != null) {
      final suggestions = response.features
          .map((feature) => LocationSuggestion.fromFeature(feature))
          .toList();

      if (index == -1) {
        currentSuggestions.value = suggestions;
      } else if (index == -2) {
        destSuggestions.value = suggestions;
      } else {
        waypointSuggestions[index] = suggestions;
        waypointSuggestions.refresh();
      }
    }
  }

  void onSearchChanged(String query, int index) {
    if (query.isEmpty) {
      if (index == -1) {
        currentSuggestions.clear();
      } else if (index == -2) {
        destSuggestions.clear();
      } else {
        waypointSuggestions[index] = [];
        waypointSuggestions.refresh();
      }
      return;
    }

    debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchLocation(query, index);
    });
  }

  Future<void> reverseGeocode(LatLng position, int index) async {
    final response = await _mapService.reverseGeocode(position);
    if (response != null && response.features.isNotEmpty) {
      final location = LocationSuggestion.fromFeature(response.features.first);
      selectLocation(location, index);
    }
  }

  void enableMapSelection(int index) {
    isSelectingFromMap.value = true;
    selectingIndex.value = index;
    showCurrentSuggestions.value = false;
    showDestSuggestions.value = false;
    for (int i = 0; i < showWaypointSuggestions.length; i++) {
      showWaypointSuggestions[i] = false;
    }
  }

  void onMapTap(TapPosition tapPosition, LatLng position) {
    if (isSelectingFromMap.value) {
      reverseGeocode(position, selectingIndex.value);
      isSelectingFromMap.value = false;
    }
  }

  void selectLocation(LocationSuggestion location, int index) {
    if (index == -1) {
      selectedStart.value = location;
      currentLocationController.text = location.displayName;
      currentSuggestions.clear();
      showCurrentSuggestions.value = false;
    } else if (index == -2) {
      selectedEnd.value = location;
      destinationController.text = location.displayName;
      destSuggestions.clear();
      showDestSuggestions.value = false;
    } else {
      selectedWaypoints[index] = location;
      waypointControllers[index].text = location.displayName;
      waypointSuggestions[index] = [];
      showWaypointSuggestions[index] = false;
      waypointSuggestions.refresh();
      showWaypointSuggestions.refresh();
    }

    if (selectedStart.value != null &&
        selectedEnd.value == null &&
        selectedWaypoints.every((w) => w == null)) {
      mapController.move(
        LatLng(selectedStart.value!.lat, selectedStart.value!.lon),
        14,
      );
    } else if (selectedEnd.value != null && selectedStart.value == null) {
      mapController.move(
        LatLng(selectedEnd.value!.lat, selectedEnd.value!.lon),
        14,
      );
    }

    if (selectedStart.value != null && selectedEnd.value != null) {
      calculateRouteWithWaypoints();
    }
  }

  Future<void> calculateRouteWithWaypoints() async {
    List<LatLng> coordinates = [];
    coordinates.add(LatLng(selectedStart.value!.lat, selectedStart.value!.lon));

    for (var waypoint in selectedWaypoints) {
      if (waypoint != null) {
        coordinates.add(LatLng(waypoint.lat, waypoint.lon));
      }
    }

    coordinates.add(LatLng(selectedEnd.value!.lat, selectedEnd.value!.lon));

    final response = await _mapService.calculateRoute(coordinates);
    if (response != null && response.routes.isNotEmpty) {
      final route = response.routes.first;
      final coords = route.geometry.coordinates;
      final distanceKm = (route.distance / 1000);

      routePoints.value = coords
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList();
      distance.value = double.parse(distanceKm.toStringAsFixed(2));

      fitBoundsToAllPoints();
    }
  }

  void fitBoundsToAllPoints() {
    List<LatLng> allPoints = [];
    if (selectedStart.value != null) {
      allPoints.add(LatLng(selectedStart.value!.lat, selectedStart.value!.lon));
    }
    if (selectedEnd.value != null) {
      allPoints.add(LatLng(selectedEnd.value!.lat, selectedEnd.value!.lon));
    }
    for (var waypoint in selectedWaypoints) {
      if (waypoint != null) allPoints.add(LatLng(waypoint.lat, waypoint.lon));
    }

    if (allPoints.length >= 2) {
      final bounds = LatLngBounds.fromPoints(allPoints);
      mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    }
  }

  void clearLocation(int index) {
    if (index == -1) {
      currentLocationController.clear();
      selectedStart.value = null;
      currentSuggestions.clear();
    } else if (index == -2) {
      destinationController.clear();
      selectedEnd.value = null;
      destSuggestions.clear();
    } else {
      waypointControllers[index].clear();
      selectedWaypoints[index] = null;
      waypointSuggestions[index] = [];
      waypointSuggestions.refresh();
    }
    distance.value = null;
    routePoints.clear();
  }

  List<String> getSelectedLocationsAndDistanceList() {
    List<String> locations = [];
    if (selectedStart.value != null)
      locations.add(selectedStart.value!.displayName);
    for (var waypoint in selectedWaypoints) {
      if (waypoint != null) locations.add(waypoint.displayName);
    }
    if (selectedEnd.value != null)
      locations.add(selectedEnd.value!.displayName);
    if (distance.value != null) locations.add('${distance.value}');
    return locations;
  }

  void returnWithData() {
    final locations = getSelectedLocationsAndDistanceList();
    print(locations);
    Get.back(result: locations);
  }

  IconData getIconForPlaceType(String? placeType) {
    if (placeType == null) return Icons.place;

    switch (placeType) {
      case 'country':
        return Icons.public;
      case 'region':
      case 'district':
        return Icons.location_city;
      case 'place':
      case 'locality':
        return Icons.location_on;
      case 'neighborhood':
        return Icons.home;
      case 'address':
        return Icons.home_outlined;
      case 'poi':
        return Icons.business;
      default:
        return Icons.place;
    }
  }
}
