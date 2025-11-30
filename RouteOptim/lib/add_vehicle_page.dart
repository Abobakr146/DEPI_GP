import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:route_optim/car_route_page.dart';
import 'package:route_optim/vehicle.dart';
import 'package:route_optim/vehicle_service.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final vehicleNameController = TextEditingController();
  final vehicleNameEmpty = true.obs;

  final ccRangeController = TextEditingController();
  final consumption = 0.0.obs;

  final fuelTypeController = TextEditingController();
  final fuelType = ''.obs;

  final vehicleService = VehicleService();

  final isLoading = false.obs;

  @override
  void dispose() {
    // TODO: implement dispose
    vehicleNameController.dispose();
    ccRangeController.dispose();
    fuelTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add New Vehicle"),
            Text(
              "Provide details about your vehicle",
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 8,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vehicle Name'),
                        TextField(
                          onChanged: (value) {
                            vehicleNameEmpty.value = value.isEmpty;
                          },
                          controller: vehicleNameController,
                          decoration: const InputDecoration(
                              hintText: 'Enter vehicle name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Engine CC Range'),
                        DropdownMenu<double>(
                          width: double.infinity,
                          controller: ccRangeController,
                          label: const Text('Select CC Range'),
                          menuStyle: MenuStyle(
                            maximumSize: WidgetStateProperty.all<Size>(
                              const Size(300, 400),
                            ),
                          ),
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: 5, label: '500-1000 cc'),
                            DropdownMenuEntry(
                                value: 6.75, label: '1000-1500 cc'),
                            DropdownMenuEntry(
                                value: 8.5, label: '1500-2000 cc'),
                            DropdownMenuEntry(
                                value: 10.25, label: '2000-2500 cc'),
                            DropdownMenuEntry(
                                value: 11.75, label: '2500-3000 cc'),
                            DropdownMenuEntry(
                                value: 13.5, label: '3000-3500 cc'),
                            DropdownMenuEntry(
                                value: 15.5, label: '3500-4000 cc'),
                          ],
                          onSelected: (double? value) {
                            consumption.value = value!;
                            print('Selected consumption: $consumption');
                            print('Controller text: ${ccRangeController.text}');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fuel Type'),
                        DropdownMenu<String>(
                          width: double.infinity,
                          controller: fuelTypeController,
                          label: const Text('Select Fuel Type'),
                          menuStyle: MenuStyle(
                            maximumSize: WidgetStateProperty.all<Size>(
                              const Size(300, 400),
                            ),
                          ),
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(
                                value: 'Gasoline 80', label: 'Gasoline 80'),
                            DropdownMenuEntry(
                                value: 'Gasoline 92', label: 'Gasoline 92'),
                            DropdownMenuEntry(
                                value: 'Gasoline 95', label: 'Gasoline 95'),
                            DropdownMenuEntry(
                                value: 'Solar', label: 'Diesel - Solar'),
                          ],
                          onSelected: (String? value) {
                            fuelType.value = value!;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: (!isLoading.value &&
                            !vehicleNameEmpty.value &&
                            consumption.value > 0 &&
                            fuelType.value.isNotEmpty
                        ) ? () async {
                          // TODO: Save vehicle logic and clear fields
                          isLoading.value = true;
                          print('Vehicle Name: ${vehicleNameController.text}');
                          print('Consumption: $consumption L/100km');
                          print('Fuel Type: $fuelType');
                          final vehicle = Vehicle(
                              manufacture: vehicleNameController.text,
                              consumption: consumption.value,
                              fuelType: fuelType.value
                          );
                          final success = await vehicleService.addVehicle(vehicle);
                          if (success) {
                            vehicleNameController.clear();
                            ccRangeController.clear();
                            fuelTypeController.clear();
                            vehicles.add(vehicle);
                            Get.back();
                            isLoading.value = false;
                            Get.snackbar(
                                'Success',
                                'Vehicle added successfully',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white
                            );
                          } else {
                            Get.snackbar(
                                'Error',
                                'Failed to add vehicle',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white
                            );
                          }
                        } : null,
                        child: !isLoading.value
                            ? const Text('Save Vehicle')
                            : const Center(
                            child: CircularProgressIndicator(color: Colors
                                .white,))
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
