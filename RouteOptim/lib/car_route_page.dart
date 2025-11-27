import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:route_optim/add_vehicle_page.dart';
import 'package:route_optim/vehicle.dart';

import 'map_page.dart';

class CarRoutePage extends StatefulWidget {
  const CarRoutePage({super.key});

  @override
  State<CarRoutePage> createState() => _CarRoutePageState();
}

class _CarRoutePageState extends State<CarRoutePage> {
  final startController = TextEditingController();

  final waypoints = <TextEditingController>[].obs;

  final destinationController = TextEditingController();

  final selectedVehicle = Rxn<Vehicle>(null);

  final vehicles = <Vehicle>[
    const Vehicle(
      name: 'Toyota Corolla',
      consumption: 6.75,
      fuelType: 'Petrol',
    ),
    const Vehicle(name: 'Honda Civic', consumption: 8.5, fuelType: 'Diesel'),
    const Vehicle(name: 'Ford Focus', consumption: 5.0, fuelType: 'Hybrid'),
    const Vehicle(
      name: 'Chevrolet Malibu',
      consumption: 11.75,
      fuelType: 'Petrol',
    ),
    const Vehicle(
      name: 'Nissan Altima',
      consumption: 10.25,
      fuelType: 'Diesel',
    ),
    const Vehicle(name: 'BMW 3 Series', consumption: 13.5, fuelType: 'Petrol'),
    const Vehicle(name: 'Audi A4', consumption: 11.5, fuelType: 'Diesel'),
  ].obs;

  final locationsAndDistance = <String>[].obs;

  final locations = <String>[];
  // add start, destination and waypoints to locations list

  var distance = 0.0;

  bool allInputsFilled() {
    bool startFilled = startController.value.text.trim().isNotEmpty;
    bool destFilled = destinationController.value.text.trim().isNotEmpty;
    bool waypointsFilled = waypoints.every((c) => c.text.trim().isNotEmpty);
    return startFilled && destFilled && waypointsFilled;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //dispose all TextEditing Controllers
    startController.dispose();
    destinationController.dispose();
    for (var controller in waypoints) {
      controller.dispose();
    }
    super.dispose();
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
                                      controller: startController,
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
                                          // TODO: Open map to select starting point
                                          print(
                                            "Open map to select starting point",
                                          );
                                          navigateToMapPage();
                                        },
                                        icon: const Icon(Icons.location_pin),
                                      ),
                                      IconButton(
                                        onPressed: () {

                                          // TODO: Get current location using geolocator package and put the text in the destinationController
                                          print("Open map to select starting point");

                                        },
                                        icon: const Icon(Icons.my_location),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          waypoints.isNotEmpty ? Column(
                            children: List.generate(
                              waypoints.length,
                                  (index) => Card(
                                margin: const EdgeInsets.only(bottom: 10,),
                                child: ListTile(
                                  title: Text("Waypoint ${index + 1}",),
                                  subtitle: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller:
                                          waypoints[index],
                                          decoration:
                                          const InputDecoration(
                                            hintText:
                                            "Enter waypoint",
                                            border:
                                            InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              // TODO: Open map to select starting point
                                              print(
                                                "Open map to select starting point",
                                              );
                                              navigateToMapPage();
                                            },
                                            icon: const Icon(Icons.location_pin),
                                          ),
                                          IconButton(
                                            onPressed: () {

                                              // TODO: Get current location using geolocator package and put the text in the destinationController
                                              print("Open map to select starting point");

                                            },
                                            icon: const Icon(Icons.my_location),
                                          ),
                                        ],
                                      )
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
                                      controller: destinationController,
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
                                          // TODO: Open map to select starting point
                                          print(
                                            "Open map to select starting point",
                                          );
                                          navigateToMapPage();
                                        },
                                        icon: const Icon(Icons.location_pin),
                                      ),
                                      IconButton(
                                        onPressed: () {

                                          // TODO: Get current location using geolocator package and put the text in the destinationController
                                          print("Open map to select starting point");

                                        },
                                        icon: const Icon(Icons.my_location),
                                      ),
                                    ],
                                  )
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
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    const Text('Choose Vehicle'),
                                    Expanded(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: vehicles.length,
                                        itemBuilder: (ctx, index) {
                                          return buildVehicleCard(
                                            vehicles[index],
                                          );
                                        },
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Get.to(() => AddVehiclePage());
                                      },
                                      label: const Text('Add New Vehicle'),
                                      icon: const Icon(Icons.add),
                                    ),
                                    // **********************************************************************************************************
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Obx(() {
                          //   return ElevatedButton(
                          //     onPressed:
                          //     (startController.text.isNotEmpty &&
                          //         destinationController.text.isNotEmpty &&
                          //         waypoints.every((c) => c.text.isNotEmpty,)) ? () {
                          //       // TODO: Calculate best route
                          //       print("Calculating best route...");
                          //     } : null,
                          //     child: const Text("Get Best Route"),
                          //   );
                          // }),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }

  void gatherLocations(){
    locations.clear();
    locations.add(startController.text.trim());
    for (var controller in waypoints) {
      locations.add(controller.text.trim());
    }
    locations.add(destinationController.text.trim());
  }

  Future<void> navigateToMapPage() async {
    gatherLocations();
    locationsAndDistance.value = await Get.to(() => const MapDirectionsPage(), arguments: locations);
    if(locationsAndDistance.isNotEmpty){
      Get.snackbar('Result', 'Locations Saved', colorText: Colors.white, backgroundColor: Colors.green);
      startController.text = locationsAndDistance[0];
      locationsAndDistance.removeAt(0);
      distance = locationsAndDistance.last.toDouble();
      locationsAndDistance.removeLast();
      destinationController.text = locationsAndDistance.last;
      locationsAndDistance.removeLast();
      // add waypoints using the remaining locations in locationsAndDistance
      waypoints.clear();
      for (var location in locationsAndDistance) {
        waypoints.add(TextEditingController(text: location));
      }
    }
  }

  Widget buildVehicleCard(Vehicle vehicle) {
    return Obx(() {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: vehicle == selectedVehicle.value
            ? const Color(0x9677A3F1)
            : Colors.white,
        child: ListTile(
          onTap: () {
            selectedVehicle.value = vehicle;
          },
          trailing: vehicle == selectedVehicle.value
              ? const Icon(Icons.check_circle, color: Colors.blueAccent)
              : null,
          leading: Obx(() {
            return Icon(
              Icons.directions_car,
              color: vehicle == selectedVehicle.value
                  ? Colors.blueAccent
                  : Colors.black,
            );
          }),
          title: Obx(() {
            return Text(
              vehicle.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: vehicle == selectedVehicle.value
                    ? Colors.blueAccent
                    : Colors.black,
              ),
            );
          }),
          subtitle: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Obx(() {
                return Text(
                  '${vehicle.consumption} L/100km',
                  style: TextStyle(
                    color: vehicle == selectedVehicle.value
                        ? Colors.blueAccent
                        : Colors.black,
                  ),
                );
              }),
              Obx(() {
                return Icon(
                  Icons.circle,
                  size: 6,
                  color: vehicle == selectedVehicle.value
                      ? Colors.blueAccent
                      : Colors.black,
                );
              }),
              Obx(() {
                return Text(
                  vehicle.fuelType,
                  style: TextStyle(
                    color: vehicle == selectedVehicle.value
                        ? Colors.blueAccent
                        : Colors.black,
                  ),
                );
              }),
              Obx(() {
                return Icon(
                  Icons.circle,
                  size: 6,
                  color: vehicle == selectedVehicle.value
                      ? Colors.blueAccent
                      : Colors.black,
                );
              }),
                  () {
                switch (vehicle.consumption) {
                  case 5 || 6.75 || 8.5:
                    return const Text(
                      'Low Emission',
                      style: TextStyle(color: Colors.green),
                    );
                  case 10.25 || 11.75:
                    return Obx(() {
                      return Text(
                        'Medium Emission',
                        style: TextStyle(
                          color: vehicle == selectedVehicle.value
                              ? Colors.orange
                              : Colors.orange,
                        ),
                      );
                    });
                  case 13.5 || 11.5:
                    return Obx(() {
                      return Text(
                        'High Emission',
                        style: TextStyle(
                          color: vehicle == selectedVehicle.value
                              ? Colors.redAccent
                              : Colors.red,
                        ),
                      );
                    });
                  default:
                    return const Text('Emissions: Unknown');
                }
              }(),
            ],
          ),
        ),
      );
    });
  }
}
