import 'dart:convert' show jsonEncode;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:musicly_app/providers/navbar_state_provider.dart';
import 'package:musicly_app/providers/auth_provider.dart';
import 'package:musicly_app/api_endpoints.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isEditing;
  String currentUsername;
  TextEditingController editingController;

  @override
  void initState() {
    super.initState();
    isEditing = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    editingController =
        TextEditingController(text: Provider.of<Auth>(context).username);
  }

  @override
  Widget build(BuildContext context) {
    const Color dividerColor = Color(0xFF1F242E);

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          if (isEditing) {
            setState(() {
              isEditing = false;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 30, 15, 10),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Image.asset('assets/images/default_avatar.png'),
                title: getUsernameWidget(),
              ),
              const SizedBox(height: 24),
              const Divider(color: dividerColor, height: 0, thickness: 1),
              ListTile(
                onTap: () => setState(() => isEditing = !isEditing),
                title: const Text('Zmień nazwę użytkownika'),
              ),
              const Divider(color: dividerColor, height: 0, thickness: 0),
              ListTile(
                onTap: () => showPasswordChangeDialog(),
                title: const Text('Zmień hasło'),
              ),
              const Divider(color: dividerColor, height: 0, thickness: 0),
              ListTile(
                onTap: () {},
                title: const Text('Informacje prawne'),
              ),
              const Divider(color: dividerColor, height: 0, thickness: 0),
              ListTile(
                onTap: () {},
                title: Text(
                  'Usuń konto',
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ),
              const Divider(color: dividerColor, height: 0, thickness: 0),
              const Spacer(),
              ListTile(
                onTap: () {
                  Provider.of<NavBarState>(context, listen: false)
                      .currentPageIndex = 0;
                  Provider.of<Auth>(context, listen: false).logOut();
                },
                title: const Text('Wyloguj się'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getUsernameWidget() {
    if (isEditing) {
      return TextField(
          controller: editingController,
          autofocus: true,
          onSubmitted: (String value) {
            setState(() {
              isEditing = false;
            });
            if (value != Provider.of<Auth>(context, listen: false).username) {
              // TODO request to server changing the username
              Provider.of<Auth>(context, listen: false).username = value;
            }
          });
    } else {
      return Text(editingController.value.text);
    }
  }

  void showPasswordChangeDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Zmiana hasła'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                Text('Jeśli chcesz zmienić hasło, kliknij przycisk '
                    '"Zmień hasło" na dole strony.'),
                SizedBox(height: 20),
                Text('Zostanie do ciebie wysłany email '
                    'z linkiem do zmiany hasła.'),
              ],
            ),
            actions: <TextButton>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Anuluj')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    requestPasswordResetToken();
                  },
                  child: const Text('Zmień hasło')),
            ],
          );
        });
  }

  void showPasswordResetErrorDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Błąd połączenia',
                style: TextStyle(color: Colors.red.shade600)),
            content: const Text('Nie udało się wysłać wiadomości email. '
                'Spróbuj ponownie za chwilę.'),
            actions: <TextButton>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Ok')),
            ],
          );
        });
  }

  void requestPasswordResetToken() {
    final Map<String, String> data = <String, String>{
      'username_or_email': Provider.of<Auth>(context, listen: false).username
    };
    final Uri url = Uri.parse(ApiEndpoints.resetPassword);
    final Future<http.Response> future = http.post(url,
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode(data));

    future.then((http.Response response) {
      if (response.statusCode == 201) {
        Navigator.of(context).pushNamed('/changePassword', arguments: true);
      } else {
        showPasswordResetErrorDialog();
      }
    }).onError((Exception error, StackTrace stackTrace) {
      showPasswordResetErrorDialog();
    });
  }
}
