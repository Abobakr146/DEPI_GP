import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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

  List<LocationSuggestion> _currentSuggestions = [];
  List<LocationSuggestion> _destSuggestions = [];
  LocationSuggestion? _selectedStart;
  LocationSuggestion? _selectedEnd;
  List<LatLng> _routePoints = [];
  double? _distance;
  Timer? _debounceTimer;
  bool _showCurrentSuggestions = false;
  bool _showDestSuggestions = false;
  bool _isSelectingFromMap = false;
  bool _isSelectingStart = true;

  @override
  void dispose() {
    _currentLocationController.dispose();
    _destinationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Search location using Mapbox Geocoding API
  Future<void> _searchLocation(String query, bool isStart) async {
    if (query.length < 2) {
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
      // Using Mapbox Geocoding API for better results
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

  // Reverse geocode (get address from coordinates)
  Future<void> _reverseGeocode(LatLng position, bool isStart) async {
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
          _selectLocation(location, isStart);
        }
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }
  }

  // Enable map selection mode
  void _enableMapSelection(bool isStart) {
    setState(() {
      _isSelectingFromMap = true;
      _isSelectingStart = isStart;
      // Hide suggestions when entering map selection mode
      _showCurrentSuggestions = false;
      _showDestSuggestions = false;
    });
  }

  // Handle map tap
  void _onMapTap(TapPosition tapPosition, LatLng position) {
    if (_isSelectingFromMap) {
      _reverseGeocode(position, _isSelectingStart);
      setState(() {
        _isSelectingFromMap = false;
      });
    }
  }

  // Debounce search
  void _onSearchChanged(String query, bool isStart) {
    if (query.isEmpty) {
      setState(() {
        if (isStart) {
          _currentSuggestions = [];
        } else {
          _destSuggestions = [];
        }
      });
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchLocation(query, isStart);
    });
  }

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

    // Update map view and show marker immediately
    final start = isStart ? location : _selectedStart;
    final end = isStart ? _selectedEnd : location;

    // If only one location selected, center on it
    if (start != null && end == null) {
      _mapController.move(LatLng(start.lat, start.lon), 14);
    } else if (end != null && start == null) {
      _mapController.move(LatLng(end.lat, end.lon), 14);
    }

    // If both locations selected, calculate route and fit bounds
    if (start != null && end != null) {
      _calculateRoute(start, end);
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
                  options: MapOptions(
                    initialCenter: const LatLng(30.0444, 31.2357), // Cairo
                    initialZoom: 12,
                    onTap: _onMapTap,
                  ),
                  children: [
                    // Mapbox Tile Layer
                    TileLayer(
                      urlTemplate:
                          'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token={accessToken}',
                      additionalOptions: const {
                        'accessToken': MAPBOX_ACCESS_TOKEN,
                      },
                      userAgentPackageName: 'com.example.map_directions_app',
                      tileProvider: NetworkTileProvider(),
                    ),

                    // Attribution (Mapbox)
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('© Mapbox', onTap: () {}),
                        TextSourceAttribution('© OpenStreetMap', onTap: () {}),
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

                // Map selection mode indicator
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
                          color: _isSelectingStart ? Colors.green : Colors.red,
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
                              'Tap on map to select ${_isSelectingStart ? 'start' : 'destination'} location',
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

                // Helper text
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
    required Function(String) onChanged,
    required Function(bool) onFocusChanged,
    required Function(LocationSuggestion) onSuggestionTap,
    required VoidCallback onClear,
  }) {
    final bool isStart = icon == Icons.location_on;

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
                      if (isStart) {
                        _showCurrentSuggestions = true;
                      } else {
                        _showDestSuggestions = true;
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
              // Map selection button
              IconButton(
                icon: Icon(Icons.map, size: 20, color: Colors.blue.shade600),
                onPressed: () => _enableMapSelection(isStart),
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
            ],
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

  // Get appropriate icon for place type
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

  // From Mapbox Geocoding API
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

  // Fallback for Nominatim (if needed)
  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
    );
  }
}
