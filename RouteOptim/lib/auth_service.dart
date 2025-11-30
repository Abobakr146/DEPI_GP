import 'package:get/get.dart';
import 'package:route_optim/user.dart';

import 'main.dart';

class AuthService{
  Future<User?> login(String mail, String password) async {
    try{
      await cloud.auth.signInWithPassword(password: password, email: mail.trim());
      final user = cloud.auth.currentUser;
      final type = await cloud.from('User').select('role').eq('id', user!.id).single();
      final name = await cloud.from('User').select('full_name').eq('id', user.id).single();
      print('Logged in as ${name['full_name']} with role ${type['role']}');
      return User(name: name['full_name'], role: type['role'] == 'admin', email: user.email.toString(), id: user.id.toString());
    } catch(e){
      print(e);
      return null;
    }
  }

  Future<bool> register(String mail, String password, String name) async {
    try{
      final response = await cloud.auth.signUp(password: password, email: mail.trim());
      await cloud.from('User').insert({'role':false, 'id':response.user?.id, 'full_name':name});
      return true;
    } catch(e){
      print(e);
      return false;
    }
  }

  Future<bool> logout() async {
    try{
      await cloud.auth.signOut();
      return true;
    } catch(e){
      print(e);
      return false;
    }
  }

  bool isLoggedIn() => cloud.auth.currentSession != null;
}