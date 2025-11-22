import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:route_optim/car_route_page.dart';
import 'package:route_optim/profile_page.dart';
import 'package:route_optim/trips.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final trips =
      <Trip>[].obs; // ......... load all trips from database .........

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: const Text(
            'RouteOptim',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          trailing: IconButton(
            onPressed: () {
              Get.to(() => ProfilePage());
            },
            icon: const Icon(Icons.person),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 8,
                  children: [
                    Card(
                      color: const Color(0xFF0F2CE8),
                      child: Column(
                        children: [
                          const ListTile(
                            leading: Text(
                              'Last Trip',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Icon(Icons.history, color: Colors.white),
                          ),
                          Obx(
                            () => trips.isNotEmpty
                                ? Text(
                                    trips.last.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const Center(
                                    child: Text(
                                      'No trips yet. Start your first trip!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                          Obx(
                            () => trips.isNotEmpty
                                ? ListTile(
                                    // ......... display last trip's distance, fuel, and cost .........
                                    leading: Text(
                                      'Distance: ${trips.last.distance} km',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    title: Text(
                                      'Fuel Used: ${trips.last.fuelUsed} L',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Text(
                                      'Cost: \$${trips.last.cost}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Travel Mode',
                      style: TextStyle(fontSize: 16),
                    ),
                    Card(
                      color: Colors.white,
                      child: Center(
                        child: ListTile(
                          leading: const Icon(
                            Icons.directions_car,
                            color: Colors.blue,
                          ),
                          title: const Text(
                            'Car Route',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Optimize Fuel Consumption'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Get.to(() => CarRoutePage());
                          },
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      child: Center(
                        child: ListTile(
                          leading: const Icon(
                            Icons.directions_transit,
                            color: Colors.green,
                          ),
                          title: const Text(
                            'Metro Route',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Fastest Metro Routes'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // ......... navigate to car trip planning page .........
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Stats This Month',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GridView.count(
                      childAspectRatio: 2,
                      crossAxisCount: 2,
                      crossAxisSpacing: 15.0,
                      mainAxisSpacing: 15.0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        buildStatCard('Total Trips'),
                        buildStatCard('Fuel Saved'),
                        buildStatCard('Distance Travelled'),
                        buildStatCard('Money Saved'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatCard(String stat) {
    var totalTrips = 0;
    var savedFuel = 0;
    var distance = 0;
    var moneySaved = 0;

    if (stat == 'Total Trips') {
      totalTrips = trips.length;
    } else if (stat == 'Fuel Saved') {
      for (var trip in trips) {
        // logic to get total fuel saved
      }
    } else if (stat == 'Distance Travelled') {
      for (var trip in trips) {
        // logic to get total distance
      }
    } else if (stat == 'Money Saved') {
      for (var trip in trips) {
        // logic to get total money saved
      }
    }
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(stat),
            Text(
              stat == 'Total Trips'
                  ? '$totalTrips'
                  : stat == 'Fuel Saved'
                  ? '$savedFuel L'
                  : stat == 'Distance Travelled'
                  ? '$distance km'
                  : stat == 'Money Saved'
                  ? '\$$moneySaved'
                  : '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
