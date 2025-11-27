//pk.eyJ1IjoiaGlzaGFtaGF0ZW0iLCJhIjoiY21pYm82ZzJqMHVvbTJsczQwZnBwd20zOSJ9.S39J9fY023DATGzHegv1GA
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// ⚠️ IMPORTANT: Get your free Mapbox token from https://www.mapbox.com/
// Replace 'YOUR_MAPBOX_ACCESS_TOKEN' with your actual token
const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiaGlzaGFtaGF0ZW0iLCJhIjoiY21pYm82ZzJqMHVvbTJsczQwZnBwd20zOSJ9.S39J9fY023DATGzHegv1GA';

// Main Map Directions Page
class MapDirectionsPage extends StatefulWidget {
  const MapDirectionsPage({Key? key}) : super(key: key);

  @override
  State<MapDirectionsPage> createState() => _MapDirectionsPageState();
}

class _MapDirectionsPageState extends State<MapDirectionsPage> {
  final MapController _mapController = MapController();
  final TextEditingController _currentLocationController =
      TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final List<TextEditingController> _waypointControllers = [];

  List<LocationSuggestion> _currentSuggestions = [];
  List<LocationSuggestion> _destSuggestions = [];
  List<List<LocationSuggestion>> _waypointSuggestions = [];

  LocationSuggestion? _selectedStart;
  LocationSuggestion? _selectedEnd;
  List<LocationSuggestion?> _selectedWaypoints = [];

  List<LatLng> _routePoints = [];
  double? _distance;
  Timer? _debounceTimer;

  bool _showCurrentSuggestions = false;
  bool _showDestSuggestions = false;
  List<bool> _showWaypointSuggestions = [];

  bool _isSelectingFromMap = false;
  int _selectingIndex = -1; // -1: start, -2: end, 0+: waypoint index

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _currentLocationController.dispose();
    _destinationController.dispose();
    for (var controller in _waypointControllers) {
      controller.dispose();
    }
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // Add waypoint
  void _addWaypoint() {
    setState(() {
      _waypointControllers.add(TextEditingController());
      _selectedWaypoints.add(null);
      _waypointSuggestions.add([]);
      _showWaypointSuggestions.add(false);
    });
  }

  // Remove waypoint
  void _removeWaypoint(int index) {
    setState(() {
      _waypointControllers[index].dispose();
      _waypointControllers.removeAt(index);
      _selectedWaypoints.removeAt(index);
      _waypointSuggestions.removeAt(index);
      _showWaypointSuggestions.removeAt(index);
    });

    // Recalculate route
    if (_selectedStart != null && _selectedEnd != null) {
      _calculateRouteWithWaypoints();
    }
  }

  // Search location using Mapbox Geocoding API
  Future<void> _searchLocation(String query, int index) async {
    if (query.length < 2) {
      setState(() {
        if (index == -1) {
          _currentSuggestions = [];
        } else if (index == -2) {
          _destSuggestions = [];
        } else {
          _waypointSuggestions[index] = [];
        }
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json?access_token=$MAPBOX_ACCESS_TOKEN&limit=5&autocomplete=true',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> features = data['features'] ?? [];
        final suggestions = features
            .map((e) => LocationSuggestion.fromMapbox(e))
            .toList();

        setState(() {
          if (index == -1) {
            _currentSuggestions = suggestions;
          } else if (index == -2) {
            _destSuggestions = suggestions;
          } else {
            _waypointSuggestions[index] = suggestions;
          }
        });
      }
    } catch (e) {
      print('Error searching location: $e');
    }
  }

  // Debounce search
  void _onSearchChanged(String query, int index) {
    if (query.isEmpty) {
      setState(() {
        if (index == -1) {
          _currentSuggestions = [];
        } else if (index == -2) {
          _destSuggestions = [];
        } else {
          _waypointSuggestions[index] = [];
        }
      });
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchLocation(query, index);
    });
  }

  // Reverse geocode (get address from coordinates)
  Future<void> _reverseGeocode(LatLng position, int index) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${position.longitude},${position.latitude}.json?access_token=$MAPBOX_ACCESS_TOKEN&limit=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> features = data['features'] ?? [];

        if (features.isNotEmpty) {
          final location = LocationSuggestion.fromMapbox(features[0]);
          _selectLocation(location, index);
        }
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }
  }

  // Enable map selection mode
  void _enableMapSelection(int index) {
    setState(() {
      _isSelectingFromMap = true;
      _selectingIndex = index;
      _showCurrentSuggestions = false;
      _showDestSuggestions = false;
      for (int i = 0; i < _showWaypointSuggestions.length; i++) {
        _showWaypointSuggestions[i] = false;
      }
    });
  }

  // Handle map tap
  void _onMapTap(TapPosition tapPosition, LatLng position) {
    if (_isSelectingFromMap) {
      _reverseGeocode(position, _selectingIndex);
      setState(() {
        _isSelectingFromMap = false;
      });
    }
  }

  // Select location from suggestions
  void _selectLocation(LocationSuggestion location, int index) {
    setState(() {
      if (index == -1) {
        _selectedStart = location;
        _currentLocationController.text = location.displayName;
        _currentSuggestions = [];
        _showCurrentSuggestions = false;
      } else if (index == -2) {
        _selectedEnd = location;
        _destinationController.text = location.displayName;
        _destSuggestions = [];
        _showDestSuggestions = false;
      } else {
        _selectedWaypoints[index] = location;
        _waypointControllers[index].text = location.displayName;
        _waypointSuggestions[index] = [];
        _showWaypointSuggestions[index] = false;
      }
    });

    // Update map view
    if (_selectedStart != null &&
        _selectedEnd == null &&
        _selectedWaypoints.every((w) => w == null)) {
      _mapController.move(LatLng(_selectedStart!.lat, _selectedStart!.lon), 14);
    } else if (_selectedEnd != null && _selectedStart == null) {
      _mapController.move(LatLng(_selectedEnd!.lat, _selectedEnd!.lon), 14);
    }

    // Calculate route if start and end are selected
    if (_selectedStart != null && _selectedEnd != null) {
      _calculateRouteWithWaypoints();
    }
  }

  // Calculate route with waypoints using OSRM
  Future<void> _calculateRouteWithWaypoints() async {
    try {
      // Build coordinates string: start;waypoint1;waypoint2;...;end
      List<String> coordinates = [];
      coordinates.add('${_selectedStart!.lon},${_selectedStart!.lat}');

      for (var waypoint in _selectedWaypoints) {
        if (waypoint != null) {
          coordinates.add('${waypoint.lon},${waypoint.lat}');
        }
      }

      coordinates.add('${_selectedEnd!.lon},${_selectedEnd!.lat}');

      final coordString = coordinates.join(';');

      final response = await http.get(
        Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/$coordString?overview=full&geometries=geojson',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final coords = route['geometry']['coordinates'] as List;
          final distanceKm = (route['distance'] / 1000).toStringAsFixed(2);

          setState(() {
            _routePoints = coords
                .map((coord) => LatLng(coord[1], coord[0]))
                .toList();
            _distance = double.parse(distanceKm);
          });

          // Fit bounds to show all points
          _fitBoundsToAllPoints();
        }
      }
    } catch (e) {
      print('Error calculating route: $e');
    }
  }

  // Fit map bounds to show all points
  void _fitBoundsToAllPoints() {
    List<LatLng> allPoints = [];
    if (_selectedStart != null)
      allPoints.add(LatLng(_selectedStart!.lat, _selectedStart!.lon));
    if (_selectedEnd != null)
      allPoints.add(LatLng(_selectedEnd!.lat, _selectedEnd!.lon));
    for (var waypoint in _selectedWaypoints) {
      if (waypoint != null) allPoints.add(LatLng(waypoint.lat, waypoint.lon));
    }

    if (allPoints.length >= 2) {
      final bounds = LatLngBounds.fromPoints(allPoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    }
  }

  // Clear location
  void _clearLocation(int index) {
    setState(() {
      if (index == -1) {
        _currentLocationController.clear();
        _selectedStart = null;
        _currentSuggestions = [];
      } else if (index == -2) {
        _destinationController.clear();
        _selectedEnd = null;
        _destSuggestions = [];
      } else {
        _waypointControllers[index].clear();
        _selectedWaypoints[index] = null;
        _waypointSuggestions[index] = [];
      }
      _distance = null;
      _routePoints = [];
    });
  }

  // Get all selected locations as a list
  List<String> _getSelectedLocationsAndDistanceList() {
    List<String> locations = [];
    if (_selectedStart != null) locations.add(_selectedStart!.displayName);
    for (var waypoint in _selectedWaypoints) {
      if (waypoint != null) locations.add(waypoint.displayName);
    }
    if (_selectedEnd != null) locations.add(_selectedEnd!.displayName);
    if (_distance != null) locations.add('$_distance');
    return locations;
  }

  // Return to previous page with data
  void _returnWithData() {
    final locations = _getSelectedLocationsAndDistanceList();
    print(locations);
    Get.back(result: locations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map and Directions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (_selectedStart != null && _selectedEnd != null)
            TextButton.icon(
              onPressed: _returnWithData,
              icon: const Icon(Icons.check),
              label: const Text('Done'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
        ],
      ),
      body: Column(
        children: [
          // Scrollable search inputs section
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Current location input
                    _buildSearchField(
                      controller: _currentLocationController,
                      icon: Icons.location_on,
                      iconColor: Colors.green,
                      hint: 'Your current location',
                      suggestions: _currentSuggestions,
                      showSuggestions: _showCurrentSuggestions,
                      index: -1,
                      onChanged: (value) {
                        _onSearchChanged(value, -1);
                        setState(() => _showCurrentSuggestions = true);
                      },
                      onSuggestionTap: (suggestion) =>
                          _selectLocation(suggestion, -1),
                      onClear: () => _clearLocation(-1),
                    ),
                    const SizedBox(height: 12),

                    // Waypoints
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _waypointControllers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildSearchField(
                            controller: _waypointControllers[index],
                            icon: Icons.location_pin,
                            iconColor: Colors.orange,
                            hint: 'Waypoint ${index + 1}',
                            suggestions: _waypointSuggestions[index],
                            showSuggestions: _showWaypointSuggestions[index],
                            index: index,
                            onChanged: (value) {
                              _onSearchChanged(value, index);
                              setState(
                                () => _showWaypointSuggestions[index] = true,
                              );
                            },
                            onSuggestionTap: (suggestion) =>
                                _selectLocation(suggestion, index),
                            onClear: () => _clearLocation(index),
                            showRemove: true,
                            onRemove: () => _removeWaypoint(index),
                          ),
                        );
                      },
                    ),

                    // Add waypoint button
                    OutlinedButton.icon(
                      onPressed: _addWaypoint,
                      icon: const Icon(Icons.add_location_alt, size: 18),
                      label: const Text('Add Waypoint'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue.shade300),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Destination input
                    _buildSearchField(
                      controller: _destinationController,
                      icon: Icons.navigation,
                      iconColor: Colors.red,
                      hint: 'Enter destination location',
                      suggestions: _destSuggestions,
                      showSuggestions: _showDestSuggestions,
                      index: -2,
                      onChanged: (value) {
                        _onSearchChanged(value, -2);
                        setState(() => _showDestSuggestions = true);
                      },
                      onSuggestionTap: (suggestion) =>
                          _selectLocation(suggestion, -2),
                      onClear: () => _clearLocation(-2),
                    ),

                    // Distance display
                    if (_distance != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.route, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Distance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_distance km',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Map
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(30.0444, 31.2357),
                    initialZoom: 12,
                    onTap: _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token={accessToken}',
                      additionalOptions: const {
                        'accessToken': MAPBOX_ACCESS_TOKEN,
                      },
                      userAgentPackageName: 'com.example.map_directions_app',
                      tileProvider: NetworkTileProvider(),
                    ),

                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('© Mapbox', onTap: () {}),
                        TextSourceAttribution('© OpenStreetMap', onTap: () {}),
                      ],
                      alignment: AttributionAlignment.bottomRight,
                    ),

                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.blue,
                            strokeWidth: 5,
                          ),
                        ],
                      ),

                    MarkerLayer(
                      markers: [
                        if (_selectedStart != null)
                          Marker(
                            point: LatLng(
                              _selectedStart!.lat,
                              _selectedStart!.lon,
                            ),
                            width: 40,
                            height: 40,
                            child: _buildMarker('S', Colors.green),
                          ),
                        for (int i = 0; i < _selectedWaypoints.length; i++)
                          if (_selectedWaypoints[i] != null)
                            Marker(
                              point: LatLng(
                                _selectedWaypoints[i]!.lat,
                                _selectedWaypoints[i]!.lon,
                              ),
                              width: 40,
                              height: 40,
                              child: _buildMarker('${i + 1}', Colors.orange),
                            ),
                        if (_selectedEnd != null)
                          Marker(
                            point: LatLng(_selectedEnd!.lat, _selectedEnd!.lon),
                            width: 40,
                            height: 40,
                            child: _buildMarker('D', Colors.red),
                          ),
                      ],
                    ),
                  ],
                ),

                if (_isSelectingFromMap)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _selectingIndex == -1
                              ? Colors.green
                              : _selectingIndex == -2
                              ? Colors.red
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.touch_app,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tap on map to select location',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (_selectedStart == null &&
                    _selectedEnd == null &&
                    !_isSelectingFromMap)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          'Enter locations to see route',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hint,
    required List<LocationSuggestion> suggestions,
    required bool showSuggestions,
    required int index,
    required Function(String) onChanged,
    required Function(LocationSuggestion) onSuggestionTap,
    required VoidCallback onClear,
    bool showRemove = false,
    VoidCallback? onRemove,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onTap: () {
                    setState(() {
                      if (index == -1) {
                        _showCurrentSuggestions = true;
                      } else if (index == -2) {
                        _showDestSuggestions = true;
                      } else {
                        _showWaypointSuggestions[index] = true;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.map, size: 20, color: Colors.blue.shade600),
                onPressed: () => _enableMapSelection(index),
                tooltip: 'Select from map',
              ),
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: onClear,
                ),
              if (showRemove && onRemove != null)
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: onRemove,
                  tooltip: 'Remove waypoint',
                ),
            ],
          ),
        ),

        if (showSuggestions && suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: suggestions.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, idx) {
                final suggestion = suggestions[idx];
                return InkWell(
                  onTap: () => onSuggestionTap(suggestion),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getIconForPlaceType(suggestion.placeType),
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (suggestion.placeName != null)
                                Text(
                                  suggestion.placeName!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              Text(
                                suggestion.displayName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMarker(String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  IconData _getIconForPlaceType(String? placeType) {
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

// Location suggestion model
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

  factory LocationSuggestion.fromMapbox(Map<String, dynamic> json) {
    final coordinates = json['geometry']['coordinates'] as List;
    return LocationSuggestion(
      displayName: json['place_name'] ?? '',
      lat: coordinates[1],
      lon: coordinates[0],
      placeName: json['text'] ?? '',
      placeType: json['place_type']?.first ?? '',
    );
  }

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
    );
  }
}
