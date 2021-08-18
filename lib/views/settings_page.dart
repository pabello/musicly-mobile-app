import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(15, 30, 15, 20),
        children: <Widget>[
          ListTile(
            leading: Image.asset('assets/images/default_avatar.png'),
            title: Text('username'),
          )
        ],
      ),
    );
  }
  
}