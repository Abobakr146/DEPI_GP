import 'dart:convert';

import 'login_page.dart';
import 'main.dart';

class TripService {
  Future<void> getTripsByID(String userID) async {
    // Implementation to fetch trips by user ID
    print('Loading all trips from database...');
    final response = await cloud.from('Trip').select('*').eq('user_id', user!.id);
    print(response);
    print(json.encode(response));
  }
}