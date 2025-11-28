import 'package:get/get.dart';

import 'main.dart';

class AuthService{
  Future<bool> login(String mail, String password) async {
    try{
      await cloud.auth.signInWithPassword(password: password, email: mail);
      return true;
    } catch(e){
      print(e);
      return false;
    }
  }

  Future<bool> register(String mail, String password) async {
    try{
      final response = await cloud.auth.signUp(password: password, email: mail);
      await cloud.from('profiles').insert({'type':'user', 'UID':response.user?.id});
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