import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'main.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  // final RxString userName = "John Doe".obs;
  // final RxString userEmail = "john.doe@email.com".obs;
  // final RxInt trips = 127.obs;
  // final RxString distance = "2,450 km".obs;
  // final RxString saved = "\$156".obs;
  // final RxList<Map<String, dynamic>> vehicles = <Map<String, dynamic>>[].obs;
  final name = user!.name.obs;
  final email = user!.email.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Profile"),
            Text(
              "Manage your preferences",
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
      ), // Optional, use FlexibleSpace if needed
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Column(
              spacing: 8,
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
                                    () =>
                                    Text(
                                      name.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                              ),
                              Obx(
                                    () =>
                                    Text(
                                      email.value,
                                      style: const TextStyle(
                                          color: Colors.blueGrey),
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Obx(
                                          () =>
                                          Text(
                                            "Trips\n${trips.length}",
                                            style: const TextStyle(fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Obx(
                                          () =>
                                          Text(
                                            "Distance\n${totalDistance.value}",
                                            style: const TextStyle(fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Obx(
                                          () =>
                                          Text(
                                            "Saved\n${totalMoneySaved.value}",
                                            style: const TextStyle(fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
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
                const SizedBox(height: 12),
                // Account Section
                const Text(
                  "Account",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // Preferences Cards
                Card(
                  child: ListTile(
                    leading: Obx(() {
                      return Icon(
                        theme.value == Brightness.dark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: theme.value == Brightness.dark
                            ? Colors.indigo
                            : Colors.orange,
                      );
                    }),
                    title: Obx(() {
                      return Text(
                        theme.value == Brightness.dark
                            ? "Dark Mode"
                            : "Light Mode",
                      );
                    }),
                    subtitle: Obx(() {
                      return Text(
                        theme.value != Brightness.dark
                            ? "Switch to Light Mode"
                            : "Switch to Dark Mode",
                      );
                    }),
                    onTap: () {
                      // TODO: Handle theme switching logic
                      Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                      theme.value = Get.isDarkMode ? Brightness.dark : Brightness.light;
                    },
                  ),
                ),
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
                    leading: const Icon(Icons.help, color: Colors.deepPurple),
                    title: const Text("Help & Support"),
                    subtitle: const Text("Contact us at support@gmail.com"),
                    onTap: () {
                      // TODO: Handle help/support logic
                    },
                  ),
                ),
                // Log Out Button
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Log out logic
                          authService.logout();
                          Get.offAll(() => LoginPage());
                          Get.snackbar(
                            'Bye!',
                            'Come Back Again!',
                            backgroundColor: Colors.green.withValues(alpha: 0.1),
                            colorText: Colors.green[800],
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          "Log Out",
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.red.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
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
}
