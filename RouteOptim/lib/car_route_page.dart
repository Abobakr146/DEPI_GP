import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:route_optim/add_vehicle_page.dart';
import 'package:route_optim/vehicle.dart';
import 'package:route_optim/vehicle_service.dart';

import 'map_page.dart';


final vehicles = <Vehicle>[].obs;


class CarRoutePage extends StatefulWidget {
  const CarRoutePage({super.key});

  @override
  State<CarRoutePage> createState() => _CarRoutePageState();
}

class _CarRoutePageState extends State<CarRoutePage> {
  final startController = TextEditingController().obs;

  final waypoints = <TextEditingController>[].obs;

  final destinationController = TextEditingController().obs;

  final selectedVehicle = Rxn<Vehicle>(null);

  final locationsAndDistance = <String>[].obs;

  final locations = <String>[];
  // add start, destination and waypoints to locations list

  var distance = 0.0;

  final startFilled = false.obs;
  final destFilled = false.obs;
  final waypointsFilled = false.obs;
  final vehiclesSelected = false.obs;
  final vehiclesLoading = false.obs;
  final vehiclesFound = false.obs;

  final vehicleService = VehicleService();

  @override
  void dispose() {
    // TODO: implement dispose
    //dispose all TextEditing Controllers
    startController.value.dispose();
    destinationController.value.dispose();
    for (var controller in waypoints) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    vehiclesLoading.value = true;
    try {
      final response = await vehicleService.loadAllVehicles();
      vehicles.clear();
      vehicles.value = response;
      vehiclesFound.value = response.isNotEmpty;
    } catch (e) {
      print('Error loading vehicles: $e');
      vehiclesFound.value = false;
    } finally {
      vehiclesLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Car Route",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 8,
              children: [
                SingleChildScrollView(
                  child: Obx(
                    () => Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: const Text("Starting Point"),
                            subtitle: Row(
                              spacing: 8,
                              children: [
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) {
                                      startFilled.value = value
                                          .trim()
                                          .isNotEmpty;
                                    },
                                    controller: startController.value,
                                    decoration: const InputDecoration(
                                      hintText: "Enter starting location",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        print(
                                          "Open map to select starting point",
                                        );
                                        navigateToMapPage();
                                      },
                                      icon: const Icon(Icons.location_pin),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        print(
                                          "Get current location for starting point",
                                        );
                                        startController.value.text =
                                            await getCurrentLocationText();
                                        if (startController
                                            .value
                                            .text
                                            .isNotEmpty) {
                                          Get.snackbar(
                                            'Success',
                                            'Current location added as starting point',
                                            colorText: Colors.white,
                                            backgroundColor: Colors.green,
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.my_location),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        waypoints.isNotEmpty
                            ? Column(
                                children: List.generate(
                                  waypoints.length,
                                  (index) => Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      title: Text("Waypoint ${index + 1}"),
                                      subtitle: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              onChanged: (value) {
                                                waypointsFilled
                                                    .value = waypoints.every(
                                                  (c) =>
                                                      c.text.trim().isNotEmpty,
                                                );
                                              },
                                              controller: waypoints[index],
                                              decoration: const InputDecoration(
                                                hintText: "Enter waypoint",
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  print(
                                                    "Open map to select starting point",
                                                  );
                                                  navigateToMapPage();
                                                },
                                                icon: const Icon(
                                                  Icons.location_pin,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  print(
                                                    "Get current location for waypoint",
                                                  );
                                                  waypoints[index].text =
                                                      await getCurrentLocationText();
                                                  if (waypoints[index]
                                                      .text
                                                      .isNotEmpty) {
                                                    Get.snackbar(
                                                      'Success',
                                                      'Current location added as waypoint',
                                                      colorText: Colors.white,
                                                      backgroundColor:
                                                          Colors.green,
                                                    );
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.my_location,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          waypoints.removeAt(index);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        ElevatedButton.icon(
                          onPressed: () {
                            waypoints.add(TextEditingController());
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add Waypoint"),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: const Text("Destination"),
                            subtitle: Row(
                              spacing: 8,
                              children: [
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) {
                                      destFilled.value = value
                                          .trim()
                                          .isNotEmpty;
                                    },
                                    controller: destinationController.value,
                                    decoration: const InputDecoration(
                                      hintText: "Enter destination",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        print(
                                          "Open map to select starting point",
                                        );
                                        navigateToMapPage();
                                      },
                                      icon: const Icon(Icons.location_pin),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        print(
                                          "Get current location for destination",
                                        );
                                        destinationController.value.text =
                                            await getCurrentLocationText();
                                        if (destinationController
                                            .value
                                            .text
                                            .isNotEmpty) {
                                          Get.snackbar(
                                            'Success',
                                            'Current location added as destination',
                                            colorText: Colors.white,
                                            backgroundColor: Colors.green,
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.my_location),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 300,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  const Text('Choose Vehicle'),
                                  Expanded(
                                    child: Obx(() {
                                      if (vehiclesLoading.value) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (vehicles.isEmpty) {
                                        return const Center(
                                          child: Text('No vehicles found. Please add a vehicle.'),
                                        );
                                      } else {
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: vehicles.length,
                                          itemBuilder: (ctx, index) {
                                            return buildVehicleCard(vehicles[index]);
                                          },
                                        );
                                      }
                                    }),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Get.to(() => const AddVehiclePage());
                                    },
                                    label: const Text('Add New Vehicle'),
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Obx(() {
                          return ElevatedButton(
                            onPressed:
                                (startFilled.value &&
                                    destFilled.value &&
                                    (waypoints.isEmpty ||
                                        waypointsFilled.value) &&
                                    vehiclesSelected.value)
                                ? () {
                                    // TODO: Calculate best route
                                    print("Calculating best route...");
                                  }
                                : null,
                            child: const Text("Get Best Route"),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void gatherLocations() {
    locations.clear();
    locations.add(startController.value.text.trim());
    for (var controller in waypoints) {
      locations.add(controller.text.trim());
    }
    locations.add(destinationController.value.text.trim());
  }

  Future<String> getCurrentLocationText() async {
    getLocationPermission();
    final pos = await Geolocator.getCurrentPosition();
    final placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    if (placemarks.isNotEmpty) {
      final placemark = placemarks.first;
      final address =
          '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      return address;
    } else {
      return 'Unknown location';
    }
  }

  Future<void> navigateToMapPage() async {
    gatherLocations();
    locationsAndDistance.value = await Get.to(
      () => const MapDirectionsPage(),
      arguments: locations,
    );
    if (locationsAndDistance.isNotEmpty) {
      Get.snackbar(
        'Result',
        'Locations Saved',
        colorText: Colors.white,
        backgroundColor: Colors.green,
      );

      // Extract the distance (last element)
      distance = double.parse(locationsAndDistance.last);
      locationsAndDistance.removeLast();

      // Now we have: [start, waypoint1, waypoint2, ..., destination]
      // First element is start
      startController.value.text = locationsAndDistance.first;
      startFilled.value = true;
      locationsAndDistance.removeAt(0);

      // Last element is destination
      if (locationsAndDistance.isNotEmpty) {
        destinationController.value.text = locationsAndDistance.last;
        destFilled.value = true;
        locationsAndDistance.removeLast();
      }

      // Everything remaining is waypoints
      waypoints.clear();
      if (locationsAndDistance.isNotEmpty) {
        waypointsFilled.value = true;
        for (var location in locationsAndDistance) {
          waypoints.add(TextEditingController(text: location));
        }
      } else {
        waypointsFilled.value = false;
      }
    }
  }

  Widget buildVehicleCard(Vehicle vehicle) {
    return Obx(() {
      final bool isSelected = vehicle == selectedVehicle.value;
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: isSelected ? const Color(0x9677A3F1) : Colors.white,
        child: ListTile(
          onTap: () {
            selectedVehicle.value = vehicle;
            vehiclesSelected.value = true;
          },
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Colors.blueAccent)
              : null,
          leading: Icon(
            Icons.directions_car,
            color: isSelected ? Colors.blueAccent : Colors.black,
          ),
          title: Text(
            vehicle.manufacture,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blueAccent : Colors.black,
            ),
          ),
          subtitle: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                '${vehicle.consumption} L/100km',
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.black,
                ),
              ),
              Icon(
                Icons.circle,
                size: 6,
                color: isSelected ? Colors.blueAccent : Colors.black,
              ),
              Text(
                vehicle.fuelType,
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.black,
                ),
              ),
              Icon(
                Icons.circle,
                size: 6,
                color: isSelected ? Colors.blueAccent : Colors.black,
              ),
              // Emission label
              () {
                if (vehicle.consumption <= 8.5) {
                  return const Text(
                    'Low Emission',
                    style: TextStyle(color: Colors.green),
                  );
                } else if (vehicle.consumption <= 11.75) {
                  return Text(
                    'Medium Emission',
                    style: TextStyle(
                      color: isSelected ? Colors.orange : Colors.orange,
                    ),
                  );
                } else {
                  return Text(
                    'High Emission',
                    style: TextStyle(
                      color: isSelected ? Colors.redAccent : Colors.red,
                    ),
                  );
                }
              }(),
            ],
          ),
        ),
      );
    });
  }

  // Function to get location permission
  Future<void> getLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      Get.snackbar('Error', 'Location services are disabled');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        Get.snackbar('Error', 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Get.snackbar(
        'Error',
        'Location permissions are permanently denied, we cannot request permissions.',
      );
      return;
    }
  }
}
