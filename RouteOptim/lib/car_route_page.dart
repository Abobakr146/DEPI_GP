import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'map_page.dart';

class CarRoutePage extends StatelessWidget {
  final Rx<TextEditingController> startController = TextEditingController().obs;
  final RxList<TextEditingController> waypoints = <TextEditingController>[].obs;
  final Rx<TextEditingController> destinationController =
      TextEditingController().obs;

  final RxList<String> vehicleTypes = <String>[].obs;
  final RxString selectedVehicleType = ''.obs;
  final RxString avgMpg = ''.obs;
  final RxString fuelType = ''.obs;
  final RxString emission = ''.obs;

  CarRoutePage({Key? key}) : super(key: key) {
    vehicleTypes.addAll(["Sedan", "SUV", "Truck"]);
    selectedVehicleType.value = vehicleTypes.first;
    avgMpg.value = '32';
    fuelType.value = 'Gasoline';
    emission.value = 'Medium';
  }

  bool allInputsFilled() {
    bool startFilled = startController.value.text.trim().isNotEmpty;
    bool destFilled = destinationController.value.text.trim().isNotEmpty;
    bool waypointsFilled = waypoints.every((c) => c.text.trim().isNotEmpty);
    return startFilled && destFilled && waypointsFilled;
  }

  void addWaypoint() {
    waypoints.add(TextEditingController());
  }

  void removeWaypoint(int index) {
    waypoints.removeAt(index);
  }

  void onVehicleTypeChanged(String? value) {
    selectedVehicleType.value = value ?? '';
    if (value == "Sedan") {
      avgMpg.value = "32";
      fuelType.value = "Gasoline";
      emission.value = "Medium";
    } else if (value == "SUV") {
      avgMpg.value = "24";
      fuelType.value = "Diesel";
      emission.value = "High";
    } else if (value == "Truck") {
      avgMpg.value = "18";
      fuelType.value = "Diesel";
      emission.value = "High";
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
          padding: const EdgeInsets.all(16.0),
          child: DefaultTabController(
            length: 2,
            child: Column(
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
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: const Text("Starting Point"),
                                  subtitle: TextField(
                                    controller: startController.value,
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
                                        (index) => Card(
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
                                              onChanged: (value) => print(
                                                waypoints[index].value.text,
                                              ),
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  removeWaypoint(index),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              ElevatedButton.icon(
                                onPressed: addWaypoint,
                                icon: const Icon(Icons.add),
                                label: const Text("Add Waypoint"),
                              ),
                              Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: const Text("Destination"),
                                  subtitle: TextField(
                                    controller: destinationController.value,
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
                              Card(
                                child: ListTile(
                                  title: const Text("Vehicle Type"),
                                  subtitle: DropdownButtonFormField<String>(
                                    value: selectedVehicleType.value,
                                    items: vehicleTypes
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: onVehicleTypeChanged,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Avg. MPG",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            avgMpg.value,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Fuel Type",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            fuelType.value,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Emission",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            emission.value,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Obx(() {
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
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      //*************************************************************** Map Selection Tab
                      SingleChildScrollView(
                        child: Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: const Text("Starting Point"),
                                  subtitle: TextField(
                                    controller: startController.value,
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
                                      Get.to(() => MapDirectionsPage());
                                    },
                                    icon: const Icon(Icons.location_pin),
                                  ),
                                ),
                              ),
                              waypoints.isNotEmpty
                                  ? Column(
                                      children: List.generate(
                                        waypoints.length,
                                        (index) => Card(
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
                                                    onChanged: (value) => print(
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
                                                      () => MapDirectionsPage(),
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
                                              onPressed: () =>
                                                  removeWaypoint(index),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              ElevatedButton.icon(
                                onPressed: addWaypoint,
                                icon: const Icon(Icons.add),
                                label: const Text("Add Waypoint"),
                              ),
                              Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: const Text("Destination"),
                                  subtitle: TextField(
                                    controller: destinationController.value,
                                    decoration: const InputDecoration(
                                      hintText: "Enter destination",
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) =>
                                        print(destinationController.value.text),
                                    readOnly: true,
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      // TODO: Open map to select starting point
                                      print(
                                        "Open map to select Destination point",
                                      );
                                      Get.to(() => MapDirectionsPage());
                                    },
                                    icon: const Icon(Icons.location_pin),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Card(
                                child: ListTile(
                                  title: const Text("Vehicle Type"),
                                  subtitle: DropdownButtonFormField<String>(
                                    value: selectedVehicleType.value,
                                    items: vehicleTypes
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: onVehicleTypeChanged,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Avg. MPG",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            avgMpg.value,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Fuel Type",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            fuelType.value,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Emission",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            emission.value,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Obx(() {
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
                              ),
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
}
