import 'package:flutter/material.dart';

class AddVehiclePage extends StatefulWidget {
  AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final vehicleNameController = TextEditingController();

  final ccRangeController = TextEditingController();

  final fuelTypeController = TextEditingController();

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
              style: TextStyle(fontSize: 12.0, color: Colors.black54),
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
                            controller: vehicleNameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter vehicle name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
                          DropdownMenu<String>(
                            controller: ccRangeController,
                            label: const Text('Select CC Range'),
                            menuStyle: MenuStyle(
                              maximumSize: WidgetStateProperty.all<Size>(
                                const Size(300, 400),
                              ),
                            ),
                            inputDecorationTheme: InputDecorationTheme(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                            ),
                            dropdownMenuEntries: const [
                              DropdownMenuEntry(value: '500-1000 cc', label: '500-1000 cc'),
                              DropdownMenuEntry(value: '1000-1500 cc', label: '1000-1500 cc'),
                              DropdownMenuEntry(value: '1500-2000 cc', label: '1500-2000 cc'),
                              DropdownMenuEntry(value: '2000-2500 cc', label: '2000-2500 cc'),
                              DropdownMenuEntry(value: '2500-3000 cc', label: '2500-3000 cc'),
                              DropdownMenuEntry(value: '3500-4000 cc', label: '3500-4000 cc'),
                            ],
                            onSelected: (String? value) {
                              ccRangeController.text = value!;
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
      ),
    );
  }
}
