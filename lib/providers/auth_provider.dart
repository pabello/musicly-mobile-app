import 'package:flutter/material.dart';

class Auth extends ChangeNotifier {
  String username = '';
  String _accessToken = '';

  String get accessToken => _accessToken;

  void setIdentity(String username, String accessToken) {
    this.username = username;
    _accessToken = 'Token $accessToken';
    notifyListeners();
  }

  void logOut() {
    username = '';
    _accessToken = '';
    notifyListeners();
  }
}