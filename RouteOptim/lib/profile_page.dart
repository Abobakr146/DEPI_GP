import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  // Reactive variables
  final RxString userName = "John Doe".obs;
  final RxString userEmail = "john.doe@email.com".obs;
  final RxInt trips = 127.obs;
  final RxString distance = "2,450 km".obs;
  final RxString saved = "\$156".obs;
  final RxList<Map<String, dynamic>> vehicles = <Map<String, dynamic>>[].obs;

  ProfilePage({Key? key}) : super(key: key) {
    // Example vehicle
    vehicles.add({
      'model': "2022 Honda Accord (Sedan)",
      'active': true,
      'mpg': "32 MPG",
      'fuel': "Gasoline",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Settings"),
            Text(
              "Manage your preferences",
              style: TextStyle(fontSize: 12.0, color: Colors.white70),
            ),
          ],
        ),
      ), // Optional, use FlexibleSpace if needed
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => Text(
                                userName.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Obx(
                              () => Text(
                                userEmail.value,
                                style: const TextStyle(color: Colors.blueGrey),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(
                                  () => Text(
                                    "Trips\n${trips.value}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    "Distance\n${distance.value}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    "Saved\n${saved.value}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Edit profile logic
                        },
                        child: const Text("Edit"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Preferences Cards
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications,
                    color: Colors.blueAccent,
                  ),
                  title: const Text("Notifications"),
                  subtitle: const Text("Manage alerts and updates"),
                  onTap: () {
                    // TODO: Handle notifications logic
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.place, color: Colors.green),
                  title: const Text("Saved Locations"),
                  subtitle: const Text("Home, work, and favorites"),
                  onTap: () {
                    // TODO: Handle saved locations logic
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.credit_card, color: Colors.purple),
                  title: const Text("Payment Methods"),
                  subtitle: const Text("Cards and payment options"),
                  onTap: () {
                    // TODO: Handle payment methods logic
                  },
                ),
              ),
              const SizedBox(height: 18),
              // Account Section
              const Text(
                "Account",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock, color: Colors.orange),
                  title: const Text("Privacy & Security"),
                  subtitle: const Text("Control your data"),
                  onTap: () {
                    // TODO: Handle privacy/security logic
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.help, color: Colors.deepPurple),
                  title: const Text("Help & Support"),
                  subtitle: const Text("FAQs and contact us"),
                  onTap: () {
                    // TODO: Handle help/support logic
                  },
                ),
              ),
              const SizedBox(height: 18),
              // My Vehicles
              const Text(
                "My Vehicles",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Obx(
                () => Column(
                  children: List.generate(vehicles.length, (index) {
                    final vehicle = vehicles[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: vehicle['active']
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          vehicle['active'] ? "Primary Vehicle" : "Vehicle",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: vehicle['active']
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Active",
                                  style: TextStyle(color: Colors.blueAccent),
                                ),
                              )
                            : null,
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vehicle['model']),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text("Avg. MPG ${vehicle['mpg']}"),
                                const SizedBox(width: 24),
                                Text("Fuel Type ${vehicle['fuel']}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Add Vehicle Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: ListTile(
                  title: const Center(
                    child: Text(
                      "+ Add Another Vehicle",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  onTap: () {
                    // TODO: Handle add vehicle logic
                  },
                ),
              ),
              const SizedBox(height: 14),
              // App Version & Terms
              const Card(
                child: ListTile(
                  title: Text("App Version"),
                  trailing: Text("2.4.1"),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Terms & Conditions"),
                  onTap: () {
                    // TODO: Terms/conditions logic
                  },
                ),
              ),
              const SizedBox(height: 18),
              // Log Out Button
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Log out logic
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      "Log Out",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.withOpacity(0.6)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
