//pk.eyJ1IjoiaGlzaGFtaGF0ZW0iLCJhIjoiY21pYm82ZzJqMHVvbTJsczQwZnBwd20zOSJ9.S39J9fY023DATGzHegv1GA
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'map_directions_controller.dart';
import 'map_service.dart';

class MapDirectionsPage extends StatelessWidget {
  const MapDirectionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MapDirectionsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map and Directions'),
        elevation: 1,
        actions: [
          Obx(() {
            if (controller.selectedStart.value != null &&
                controller.selectedEnd.value != null) {
              return TextButton.icon(
                onPressed: controller.returnWithData,
                icon: const Icon(Icons.check),
                label: const Text('Done'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: SingleChildScrollView(
                  controller: controller.scrollController,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _SearchField(
                          controller: controller.currentLocationController,
                          icon: Icons.location_on,
                          iconColor: Colors.green,
                          hint: 'Your current location',
                          index: -1,
                          mapController: controller,
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.waypointControllers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _SearchField(
                                  controller: controller.waypointControllers[index],
                                  icon: Icons.location_pin,
                                  iconColor: Colors.orange,
                                  hint: 'Waypoint ${index + 1}',
                                  index: index,
                                  mapController: controller,
                                  showRemove: true,
                                  onRemove: () => controller.removeWaypoint(index),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: controller.addWaypoint,
                          icon: const Icon(Icons.add_location_alt, size: 18),
                          label: const Text('Add Waypoint'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: BorderSide(color: Colors.blue.shade300),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SearchField(
                          controller: controller.destinationController,
                          icon: Icons.navigation,
                          iconColor: Colors.red,
                          hint: 'Enter destination location',
                          index: -2,
                          mapController: controller,
                        ),
                        Obx(() {
                          if (controller.distance.value != null) {
                            return Container(
                              margin: const EdgeInsets.only(top: 12),
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
                                        '${controller.distance.value} km',
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
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        mapController: controller.mapController,
                        options: MapOptions(
                          initialCenter: const LatLng(30.0444, 31.2357),
                          initialZoom: 12,
                          onTap: controller.onMapTap,
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
                          const RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution('© Mapbox'),
                              TextSourceAttribution('© OpenStreetMap'),
                            ],
                            alignment: AttributionAlignment.bottomRight,
                          ),
                          Obx(
                            () => controller.routePoints.isEmpty
                                ? const SizedBox.shrink()
                                : PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: controller.routePoints,
                                        color: Colors.blue,
                                        strokeWidth: 5,
                                      ),
                                    ],
                                  ),
                          ),
                          Obx(
                            () => MarkerLayer(markers: _buildMarkers(controller)),
                          ),
                        ],
                      ),
                    ),
                    _MapSelectionIndicator(controller: controller),
                    _EmptyStateIndicator(controller: controller),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<Marker> _buildMarkers(MapDirectionsController controller) {
    final markers = <Marker>[];

    // Start marker
    if (controller.selectedStart.value != null) {
      markers.add(
        Marker(
          point: LatLng(
            controller.selectedStart.value!.lat,
            controller.selectedStart.value!.lon,
          ),
          width: 40,
          height: 40,
          child: const _MarkerWidget(label: 'S', color: Colors.green),
        ),
      );
    }

    // Waypoint markers
    for (int i = 0; i < controller.selectedWaypoints.length; i++) {
      final waypoint = controller.selectedWaypoints[i];
      if (waypoint != null) {
        markers.add(
          Marker(
            point: LatLng(waypoint.lat, waypoint.lon),
            width: 40,
            height: 40,
            child: _MarkerWidget(label: '${i + 1}', color: Colors.orange),
          ),
        );
      }
    }

    // End marker
    if (controller.selectedEnd.value != null) {
      markers.add(
        Marker(
          point: LatLng(
            controller.selectedEnd.value!.lat,
            controller.selectedEnd.value!.lon,
          ),
          width: 40,
          height: 40,
          child: const _MarkerWidget(label: 'D', color: Colors.red),
        ),
      );
    }

    return markers;
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final String hint;
  final int index;
  final MapDirectionsController mapController;
  final bool showRemove;
  final VoidCallback? onRemove;

  const _SearchField({
    required this.controller,
    required this.icon,
    required this.iconColor,
    required this.hint,
    required this.index,
    required this.mapController,
    this.showRemove = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              // color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                spacing: 8,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                        mapController.onSearchChanged(value, index);
                        // Show suggestions when typing
                        if (index == -1) {
                          mapController.showCurrentSuggestions.value = true;
                        } else if (index == -2) {
                          mapController.showDestSuggestions.value = true;
                        } else {
                          if (index <
                              mapController.showWaypointSuggestions.length) {
                            mapController.showWaypointSuggestions[index] = true;
                            mapController.showWaypointSuggestions.refresh();
                          }
                        }
                      },
                      onTap: () {
                        // Show suggestions when tapping the field
                        if (index == -1) {
                          mapController.showCurrentSuggestions.value = true;
                          // Trigger search if there's already text
                          if (controller.text.isNotEmpty) {
                            mapController.searchLocation(controller.text, index);
                          }
                        } else if (index == -2) {
                          mapController.showDestSuggestions.value = true;
                          if (controller.text.isNotEmpty) {
                            mapController.searchLocation(controller.text, index);
                          }
                        } else {
                          if (index <
                              mapController.showWaypointSuggestions.length) {
                            mapController.showWaypointSuggestions[index] = true;
                            mapController.showWaypointSuggestions.refresh();
                            if (controller.text.isNotEmpty) {
                              mapController.searchLocation(controller.text, index);
                            }
                          }
                        }
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
                    onPressed: () => mapController.enableMapSelection(index),
                    tooltip: 'Select from map',
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      if (value.text.isNotEmpty) {
                        return IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: () {
                            mapController.clearLocation(index);
                            // Hide suggestions when clearing
                            if (index == -1) {
                              mapController.showCurrentSuggestions.value = false;
                            } else if (index == -2) {
                              mapController.showDestSuggestions.value = false;
                            } else {
                              if (index <
                                  mapController.showWaypointSuggestions.length) {
                                mapController.showWaypointSuggestions[index] =
                                    false;
                                mapController.showWaypointSuggestions.refresh();
                              }
                            }
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
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
          ),
          Obx(() {
            List<LocationSuggestion> suggestions;
            bool showSuggestions;

            if (index == -1) {
              suggestions = mapController.currentSuggestions;
              showSuggestions = mapController.showCurrentSuggestions.value;
            } else if (index == -2) {
              suggestions = mapController.destSuggestions;
              showSuggestions = mapController.showDestSuggestions.value;
            } else {
              suggestions = mapController.waypointSuggestions.length > index
                  ? mapController.waypointSuggestions[index]
                  : [];
              showSuggestions =
                  mapController.showWaypointSuggestions.length > index
                  ? mapController.showWaypointSuggestions[index]
                  : false;
            }

            if (showSuggestions && suggestions.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  // border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  separatorBuilder: (context, idx) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, idx) {
                    final suggestion = suggestions[idx];
                    return InkWell(
                      onTap: () {
                        mapController.selectLocation(suggestion, index);
                        // Hide suggestions after selection
                        if (index == -1) {
                          mapController.showCurrentSuggestions.value = false;
                        } else if (index == -2) {
                          mapController.showDestSuggestions.value = false;
                        } else {
                          if (index <
                              mapController.showWaypointSuggestions.length) {
                            mapController.showWaypointSuggestions[index] = false;
                            mapController.showWaypointSuggestions.refresh();
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              mapController.getIconForPlaceType(
                                suggestion.placeType,
                              ),
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
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

// Cached marker widget with const constructor
class _MarkerWidget extends StatelessWidget {
  final String label;
  final Color color;

  const _MarkerWidget({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
            // color: Colors.white,
            width: 3
        ),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            // color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Map selection indicator widget
class _MapSelectionIndicator extends StatelessWidget {
  final MapDirectionsController controller;

  const _MapSelectionIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isSelectingFromMap.value) {
        return const SizedBox.shrink();
      }

      final color = controller.selectingIndex.value == -1
          ? Colors.green
          : controller.selectingIndex.value == -2
          ? Colors.red
          : Colors.orange;

      return Positioned(
        top: 16,
        left: 0,
        right: 0,
        child: Center(
          child: RepaintBoundary(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      Icons.touch_app,
                      // color: Colors.white,
                      size: 20
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Tap on map to select location',
                    style: TextStyle(
                      // color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Empty state indicator widget
class _EmptyStateIndicator extends StatelessWidget {
  final MapDirectionsController controller;

  const _EmptyStateIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.selectedStart.value != null ||
          controller.selectedEnd.value != null ||
          controller.isSelectingFromMap.value) {
        return const SizedBox.shrink();
      }

      return Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Center(
          child: RepaintBoundary(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Text(
                'Enter locations to see route',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          ),
        ),
      );
    });
  }
}
