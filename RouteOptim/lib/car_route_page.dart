import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CarRoutePage extends StatelessWidget {
  // Reactive variables for location controllers
  final Rx<TextEditingController> startController = TextEditingController().obs;
  final RxList<TextEditingController> waypoints = <TextEditingController>[].obs;
  final Rx<TextEditingController> destinationController =
      TextEditingController().obs;

  // Reactive list for vehicle types
  final RxList<String> vehicleTypes = <String>[].obs;
  final RxString selectedVehicleType = ''.obs;

  // Reactive vehicle info
  final RxString avgMpg = ''.obs;
  final RxString fuelType = ''.obs;
  final RxString emission = ''.obs;

  CarRoutePage({Key? key}) : super(key: key) {
    // Dummy data for demonstration
    vehicleTypes.addAll(["Sedan", "SUV", "Truck"]);
    selectedVehicleType.value = vehicleTypes.first;
    avgMpg.value = '32';
    fuelType.value = 'Gasoline';
    emission.value = 'Medium';
  }

  void addWaypoint() {
    waypoints.add(TextEditingController());
  }

  void removeWaypoint(int index) {
    waypoints.removeAt(index);
  }

  void onVehicleTypeChanged(String? value) {
    selectedVehicleType.value = value ?? '';
    // TODO: Fetch vehicle info based on selection
    // Example for dummy switching:
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
      appBar: AppBar(leading: BackButton(), title: const Text("Car Route")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue,
                  ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Starting Point
                          Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text("Starting Point"),
                              subtitle: TextField(
                                controller: startController.value,
                                decoration: InputDecoration(
                                  hintText: "Enter starting location",
                                  border: InputBorder.none,
                                ),
                                readOnly: false,
                                onTap: () {
                                  // TODO: Add geolocation/search logic
                                },
                              ),
                            ),
                          ),
                          // Waypoints
                          Obx(
                            () => Column(
                              children: List.generate(
                                waypoints.length,
                                (index) => Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    title: Text("Waypoint ${index + 1}"),
                                    subtitle: TextField(
                                      controller: waypoints[index],
                                      decoration: InputDecoration(
                                        hintText: "Enter waypoint",
                                        border: InputBorder.none,
                                      ),
                                      readOnly: false,
                                      onTap: () {
                                        // TODO: Add geolocation/search logic
                                      },
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => removeWaypoint(index),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Add Waypoint Button
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.add),
                              title: const Text("Add Waypoint"),
                              onTap: addWaypoint,
                            ),
                          ),
                          // Destination
                          Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text("Destination"),
                              subtitle: TextField(
                                controller: destinationController.value,
                                decoration: InputDecoration(
                                  hintText: "Enter destination",
                                  border: InputBorder.none,
                                ),
                                readOnly: false,
                                onTap: () {
                                  // TODO: Add geolocation/search logic
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Vehicle Type Dropdown
                          Obx(
                            () => Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: "Vehicle Type",
                                    border: InputBorder.none,
                                  ),
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
                          ),
                          const SizedBox(height: 16),
                          // Vehicle Info Row
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Avg. MPG",
                                          style: const TextStyle(
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
                                        Text(
                                          "Fuel Type",
                                          style: const TextStyle(
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
                                        Text(
                                          "Emission",
                                          style: const TextStyle(
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
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: null, // TODO: Enable after validation
                              child: const Text("Calculate Best Route"),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    // Map Selection Tab
                    Center(
                      child: Text(
                        "TODO: Embed map selection widget here",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
