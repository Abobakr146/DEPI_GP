import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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

  List<LocationSuggestion> _currentSuggestions = [];
  List<LocationSuggestion> _destSuggestions = [];
  LocationSuggestion? _selectedStart;
  LocationSuggestion? _selectedEnd;
  List<LatLng> _routePoints = [];
  double? _distance;
  Timer? _debounceTimer;
  bool _showCurrentSuggestions = false;
  bool _showDestSuggestions = false;

  @override
  void dispose() {
    _currentLocationController.dispose();
    _destinationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Search location using Nominatim API
  Future<void> _searchLocation(String query, bool isStart) async {
    if (query.length < 3) {
      setState(() {
        if (isStart) {
          _currentSuggestions = [];
        } else {
          _destSuggestions = [];
        }
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=5',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final suggestions = data
            .map((e) => LocationSuggestion.fromJson(e))
            .toList();

        setState(() {
          if (isStart) {
            _currentSuggestions = suggestions;
          } else {
            _destSuggestions = suggestions;
          }
        });
      }
    } catch (e) {
      print('Error searching location: $e');
    }
  }

  // Debounce search
  void _onSearchChanged(String query, bool isStart) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchLocation(query, isStart);
    });
  }

  // Select location from suggestions
  void _selectLocation(LocationSuggestion location, bool isStart) {
    setState(() {
      if (isStart) {
        _selectedStart = location;
        _currentLocationController.text = location.displayName;
        _currentSuggestions = [];
        _showCurrentSuggestions = false;
      } else {
        _selectedEnd = location;
        _destinationController.text = location.displayName;
        _destSuggestions = [];
        _showDestSuggestions = false;
      }
    });

    // Update map view
    final start = isStart ? location : _selectedStart;
    final end = isStart ? _selectedEnd : location;

    if (start != null && end != null) {
      _calculateRoute(start, end);
    } else if (start != null || end != null) {
      final loc = start ?? end!;
      _mapController.move(LatLng(loc.lat, loc.lon), 14);
    }
  }

  // Calculate route using OSRM
  Future<void> _calculateRoute(
    LocationSuggestion start,
    LocationSuggestion end,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/${start.lon},${start.lat};${end.lon},${end.lat}?overview=full&geometries=geojson',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final coordinates = route['geometry']['coordinates'] as List;
          final distanceKm = (route['distance'] / 1000).toStringAsFixed(2);

          setState(() {
            _routePoints = coordinates
                .map((coord) => LatLng(coord[1], coord[0]))
                .toList();
            _distance = double.parse(distanceKm);
          });

          // Fit bounds to show both markers
          final bounds = LatLngBounds(
            LatLng(start.lat, start.lon),
            LatLng(end.lat, end.lon),
          );
          _mapController.fitCamera(
            CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
          );
        }
      }
    } catch (e) {
      print('Error calculating route: $e');
    }
  }

  // Clear location
  void _clearLocation(bool isStart) {
    setState(() {
      if (isStart) {
        _currentLocationController.clear();
        _selectedStart = null;
        _currentSuggestions = [];
      } else {
        _destinationController.clear();
        _selectedEnd = null;
        _destSuggestions = [];
      }
      _distance = null;
      _routePoints = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map and Directions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Search inputs
          Container(
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
                  onChanged: (value) {
                    _onSearchChanged(value, true);
                    setState(() => _showCurrentSuggestions = true);
                  },
                  onFocusChanged: (hasFocus) {
                    setState(() => _showCurrentSuggestions = hasFocus);
                  },
                  onSuggestionTap: (suggestion) =>
                      _selectLocation(suggestion, true),
                  onClear: () => _clearLocation(true),
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
                  onChanged: (value) {
                    _onSearchChanged(value, false);
                    setState(() => _showDestSuggestions = true);
                  },
                  onFocusChanged: (hasFocus) {
                    setState(() => _showDestSuggestions = hasFocus);
                  },
                  onSuggestionTap: (suggestion) =>
                      _selectLocation(suggestion, false),
                  onClear: () => _clearLocation(false),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distance',
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

          // Map
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(30.0444, 31.2357), // Cairo
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),

                    // Attribution (required for OpenStreetMap)
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () {}, // You can add a link here if needed
                        ),
                      ],
                      alignment: AttributionAlignment.bottomRight,
                    ),

                    // Route polyline
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

                    // Markers
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

                // Helper text
                if (_selectedStart == null && _selectedEnd == null)
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
    required Function(String) onChanged,
    required Function(bool) onFocusChanged,
    required Function(LocationSuggestion) onSuggestionTap,
    required VoidCallback onClear,
  }) {
    return Column(
      children: [
        Focus(
          onFocusChange: onFocusChanged,
          child: Container(
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
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: onClear,
                  ),
              ],
            ),
          ),
        ),

        // Suggestions dropdown
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
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  onTap: () => onSuggestionTap(suggestion),
                  title: Text(
                    suggestion.displayName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  dense: true,
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
}

// Location suggestion model
class LocationSuggestion {
  final String displayName;
  final double lat;
  final double lon;

  LocationSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
    );
  }
}
