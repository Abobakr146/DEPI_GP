import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:route_optim/add_vehicle_page.dart';
import 'package:route_optim/vehicle.dart';

import 'map_page.dart';

class CarRoutePage extends StatefulWidget {
  @override
  State<CarRoutePage> createState() => _CarRoutePageState();
}

class _CarRoutePageState extends State<CarRoutePage> {
  final startController = TextEditingController();

  final waypoints = <TextEditingController>[].obs;

  final destinationController = TextEditingController();

  final selectedVehicle = Rxn<Vehicle>(null);

  final vehicles = <Vehicle>[
    const Vehicle(name: 'Car 1', ccRange: '1000-1500 cc', fuelType: 'Gasoline'),
    const Vehicle(name: 'Car 2', ccRange: '2000-2500 cc', fuelType: 'Diesel'),
    const Vehicle(name: 'Car 3', ccRange: '3000-3500 cc', fuelType: 'Hybrid'),
    const Vehicle(name: 'Car 4', ccRange: '1500-2000 cc', fuelType: 'Electric'),
  ].obs;

  // final RxString selectedVehicleType = ''.obs;

  // final RxString emission = ''.obs;

  bool allInputsFilled() {
    bool startFilled = startController.value.text
        .trim()
        .isNotEmpty;
    bool destFilled = destinationController.value.text
        .trim()
        .isNotEmpty;
    bool waypointsFilled = waypoints.every((c) =>
    c.text
        .trim()
        .isNotEmpty);
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
          padding: const EdgeInsets.all(16.0),
          child: DefaultTabController(
            length: 2,
            child: Column(
              spacing: 8,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF0F2CE8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: "Text Input"),
                      Tab(text: "Map Selection"),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Text Input Tab
                      SingleChildScrollView(
                        child: Obx(
                              () =>
                              Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      title: const Text("Starting Point"),
                                      subtitle: TextField(
                                        controller: startController,
                                        decoration: const InputDecoration(
                                          hintText: "Enter starting location",
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) =>
                                            print(startController.value.text),
                                      ),
                                    ),
                                  ),
                                  waypoints.isNotEmpty
                                      ? Column(
                                    children: List.generate(
                                      waypoints.length,
                                          (index) =>
                                          Card(
                                            margin: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                "Waypoint ${index + 1}",
                                              ),
                                              subtitle: TextField(
                                                controller: waypoints[index],
                                                decoration: const InputDecoration(
                                                  hintText: "Enter waypoint",
                                                  border: InputBorder.none,
                                                ),
                                                onChanged: (value) =>
                                                    print(
                                                      waypoints[index].value
                                                          .text,
                                                    ),
                                              ),
                                              trailing: IconButton(
                                                  icon: const Icon(
                                                    Icons.remove_circle,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    waypoints.removeAt(index);
                                                  }
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
                                      subtitle: TextField(
                                        controller: destinationController,
                                        decoration: const InputDecoration(
                                          hintText: "Enter destination",
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) =>
                                            print(destinationController.value.text),
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
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: vehicles.length,
                                                itemBuilder: (ctx, index) {
                                                  return buildVehicleCard(vehicles[index]);
                                                },

                                              ),
                                            ),
                                            ElevatedButton.icon(
                                                onPressed: () {
                                                  Get.to(() => AddVehiclePage());
                                                },
                                                label: const Text(
                                                    'Add New Vehicle'),
                                                icon: const Icon(Icons.add)
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

                      //*************************************************************** Map Selection Tab

                      SingleChildScrollView(
                        child: Obx(
                              () =>
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      title: const Text("Starting Point"),
                                      subtitle: TextField(
                                        controller: startController,
                                        decoration: const InputDecoration(
                                          hintText: "Enter starting location",
                                          border: InputBorder.none,
                                        ),

                                        onChanged: (value) =>
                                            print(startController.value.text),
                                        readOnly: true,
                                      ),
                                      trailing: IconButton(
                                        onPressed: () {
                                          // TODO: Open map to select starting point
                                          print(
                                            "Open map to select starting point",
                                          );
                                          Get
                                              .to(() => const MapDirectionsPage());
                                        },
                                        icon: const Icon(Icons.location_pin),
                                      ),
                                    ),
                                  ),
                                  waypoints.isNotEmpty
                                      ? Column(
                                    children: List.generate(
                                      waypoints.length,
                                          (index) =>
                                          Card(
                                            margin: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                "Waypoint ${index + 1}",
                                              ),
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
                                                      onChanged: (value) =>
                                                          print(
                                                            waypoints[index]
                                                                .value
                                                                .text,
                                                          ),
                                                      readOnly: true,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      //TODO: Open map to select waypoint
                                                      print(
                                                        "Open map to select waypoint",
                                                      );
                                                      Get.to(
                                                            () =>
                                                        const MapDirectionsPage(),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.location_pin,
                                                    ),
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
                                                  }
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
                                      subtitle: TextField(
                                        controller: destinationController,
                                        decoration: const InputDecoration(
                                          hintText: "Enter destination",
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) =>
                                            print(destinationController.value
                                                .text),
                                        readOnly: true,
                                      ),
                                      trailing: IconButton(
                                        onPressed: () {
                                          // TODO: Open map to select starting point
                                          print(
                                            "Open map to select Destination point",
                                          );
                                          Get
                                              .to(() => const MapDirectionsPage());
                                        },
                                        icon: const Icon(Icons.location_pin),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Card(
                                    // child: ListTile(
                                    //   title: const Text("Vehicle Type"),
                                    //   subtitle: DropdownButtonFormField<String>(
                                    //     value: selectedVehicleType.value,
                                    //     items: vehicleTypes
                                    //         .map(
                                    //           (type) => DropdownMenuItem(
                                    //             value: type,
                                    //             child: Text(type),
                                    //           ),
                                    //         )
                                    //         .toList(),
                                    //     onChanged: onVehicleTypeChanged,
                                    //   ),
                                    // ),
                                  ),
                                  Obx(() {
                                    return ElevatedButton(
                                      onPressed:
                                      (startController
                                          .value
                                          .text
                                          .isNotEmpty &&
                                          destinationController
                                              .value
                                              .text
                                              .isNotEmpty &&
                                          waypoints.every(
                                                (c) => c.text.isNotEmpty,
                                          ))
                                          ? () {
                                        // TODO: Calculate best route
                                        print("Calculating best route...");
                                      }
                                          : null,
                                      child: const Text("Calculate Best Route"),
                                    );
                                  }),
                                  const SizedBox(height: 16),
                                ],
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildVehicleCard(Vehicle vehicle) {
    return Obx(() {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: vehicle == selectedVehicle.value ? const Color(0x9677A3F1) : Colors.white,
        child: ListTile(
          onTap: () {
            selectedVehicle.value = vehicle;
          },
          trailing: vehicle == selectedVehicle.value ? const Icon(
            Icons.check_circle,
            color: Colors.blueAccent,
          ) : null,
          leading: Obx(() {
            return Icon(
                Icons.directions_car,
                color: vehicle == selectedVehicle.value
                    ? Colors.blueAccent
                    : Colors.black
            );
          }),
          title: Obx(() {
            return Text(
              vehicle.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: vehicle == selectedVehicle.value
                      ? Colors.blueAccent
                      : Colors.black
              ),
            );
          }),
          subtitle: Row(
            spacing: 8,
            children: [
              Obx(() {
                return Text(
                    vehicle.ccRange,
                    style: TextStyle(
                        color: vehicle == selectedVehicle.value ? Colors
                            .blueAccent : Colors.black
                    )
                );
              }),
              Obx(() {
                return Icon(
                  Icons.circle,
                  size: 6,
                  color: vehicle == selectedVehicle.value ? Colors
                      .blueAccent : Colors.black,
                );
              }),
              Obx(() {
                return Text(
                    vehicle.fuelType,
                    style: TextStyle(
                        color: vehicle == selectedVehicle.value ? Colors
                            .blueAccent : Colors.black
                    )
                );
              }),
              Obx(() {
                return Icon(
                  Icons.circle,
                  size: 6,
                  color: vehicle == selectedVehicle.value ? Colors
                      .blueAccent : Colors.black,
                );
              }),
                  () {
                switch (vehicle.ccRange) {
                  case '500-1000 cc' || '1000-1500 cc' || '1500-2000 cc':
                    return const Text(
                      'Low Emission',
                      style: TextStyle(
                          color: Colors.green
                      ),
                    );
                  case '2000-2500 cc' || '2500-3000 cc':
                    return Obx(() {
                      return Text(
                        'Medium Emission',
                        style: TextStyle(
                            color: vehicle == selectedVehicle.value ? Colors
                                .orange : Colors.orange
                        ),
                      );
                    });
                  case '3000-3500 cc' || '3500-4000 cc':
                    return Obx(() {
                      return Text(
                        'High Emission',
                        style: TextStyle(
                            color: vehicle == selectedVehicle.value ? Colors
                                .redAccent : Colors.red
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
