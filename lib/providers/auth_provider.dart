import 'package:flutter/material.dart';

class Auth extends ChangeNotifier {
  String _username;
  String _accessToken = 'Token fc0b909da04d1c61c619d65405e0a62b659a1e35';
  // TODO remove static definition, implement login / optionally save between sessions

  String get username => _username;
  String get accessToken => _accessToken;

  void setIdentity(String username, String accessToken) {
    _username = username;
    _accessToken = accessToken;
    notifyListeners();
  }
}