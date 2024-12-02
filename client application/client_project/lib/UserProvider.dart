import 'package:flutter/material.dart';
import 'User.dart';

class Userprovider extends ChangeNotifier{
  final User _user = User();

  User get user => _user;

   Future<String> login(String username, String password) async {
    String result = await _user.login(username, password);
    notifyListeners();
    return result;
  }

  Future<String> createUser(String username, String password) async {
    String result = await _user.createUser(username, password);
    notifyListeners(); 
    return result;
  }
}