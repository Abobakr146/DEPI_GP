import 'dart:convert';

import 'package:get/get.dart';
import 'package:route_optim/login_page.dart';
import 'package:route_optim/vehicle.dart';
import 'main.dart';

class VehicleService extends GetxService {
  Future<List<Vehicle>> loadAllVehicles() async {
    print('Loading all vehicles from database...');
    final response = await cloud.from('Vehicle').select('manufacture, fuel_type, consumption').eq('user_id', user!.id);
    print(response);
    print(json.encode(response));
    final vehicles = vehicleFromJson(json.encode(response));
    return vehicles;
  }

  Future<bool> addVehicle(Vehicle vehicle) async {
    print('Adding vehicle to database...');
    try{
      vehicle.userId = user!.id;
      await cloud.from('Vehicle').insert(vehicle.toJson());
      print('Vehicle added successfully.');
      return true;
    } on Exception catch(e){
      print('Error adding vehicle: $e');
      return false;
    }
  }
}
