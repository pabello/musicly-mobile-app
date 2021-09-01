import 'dart:convert' show jsonEncode, jsonDecode, utf8;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicly_app/utils.dart';
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
              editingController.text =
                  Provider.of<Auth>(context, listen: false).username;
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
                onTap: () => showAboutDialog(
                    context: context,
                    applicationLegalese:
                        'Używaj, tylko nie zniszcz. Miłej zabawy :)',
                    applicationIcon: const Icon(Icons.audiotrack),
                    applicationName: 'Musicly',
                    applicationVersion: 'version 1.0.0'),
                title: const Text('Informacje o aplikacji'),
              ),
              const Divider(color: dividerColor, height: 0, thickness: 0),
              ListTile(
                onTap: showDeleteAccountDialog,
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
              _requestSetUsername(value).then((http.Response response) {
                switch (response.statusCode) {
                  case 200:
                    Provider.of<Auth>(context, listen: false).username = value;
                    showSnackBar(
                        context, 'Nazwa użytkownika została zmieniona');
                    break;
                  case 403:
                    setState(() => editingController.text =
                        Provider.of<Auth>(context, listen: false).username);
                    final dynamic content =
                        jsonDecode(utf8.decode(response.bodyBytes));
                    if (content['error'] != null &&
                        content['error']['source'] == 'username') {
                      switch (content['error']['cause'].toString()) {
                        case 'empty':
                          showSnackBar(
                              context, 'Nazwa użytkownika nie może być pusta.');
                          break;
                        case 'in use':
                          showSnackBar(
                              context, 'Ta nazwa użytkownika jest już zajęta');
                          break;
                        default:
                          showSnackBar(
                              context,
                              'Nie udało się zmienić nazwy użytkownika. '
                              'Spróbuj ponownie później.');
                          break;
                      }
                    }
                    break;
                  case 500:
                    setState(() => editingController.text =
                        Provider.of<Auth>(context, listen: false).username);
                    showSnackBar(
                        context,
                        'Błąd serwera. '
                        'Nie udało się zmienić nazwy użytkownika.');
                    break;
                }
              }).onError((Exception error, StackTrace stackTrace) {
                setState(() => editingController.text =
                    Provider.of<Auth>(context, listen: false).username);
                showSnackBar(
                    context,
                    'Nie udało się połączyć z serwerem. '
                    'Spróbuj ponownie później.');
              });
            }
          });
    } else {
      return Text(editingController.value.text);
    }
  }

  Future<http.Response> _requestSetUsername(String newName) {
    final Map<String, String> data = <String, String>{'new_name': newName};
    final Uri url = Uri.parse(ApiEndpoints.changeUsername);
    final Future<http.Response> future = http.patch(url,
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              Provider.of<Auth>(context, listen: false).accessToken,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(data));

    return future;
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

  void showDeleteAccountDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AccountDeleteDialog();
        });
  }
}

class AccountDeleteDialog extends StatefulWidget {
  @override
  _AccountDeleteDialogState createState() => _AccountDeleteDialogState();
}

class _AccountDeleteDialogState extends State<AccountDeleteDialog> {
  final TextEditingController _inputController = TextEditingController();
  String _responseError;
  bool _formFocused = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unfocusForm,
      child: AlertDialog(
        title: Text('Usuń konto', style: TextStyle(color: Colors.red.shade400)),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                  style: Theme.of(context).textTheme.subtitle1,
                  children: <TextSpan>[
                    const TextSpan(text: 'Usunięcie konta jest '),
                    TextSpan(
                        text: 'nieodwracalne',
                        style: TextStyle(color: Colors.red.shade400)),
                    const TextSpan(text: '.\nAby usunąć konto wpisz swoje '),
                    TextSpan(
                        text: 'hasło',
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.subtitle2.color)),
                    const TextSpan(text: ' w polu poniżej i kliknij '),
                    TextSpan(
                        text: 'Usuń konto',
                        style: TextStyle(color: Colors.red.shade400)),
                    const TextSpan(text: '.'),
                  ]),
            ),
            const SizedBox(height: 8),
            TextField(
              style: const TextStyle(color: Color(0xFF1F242E)),
              controller: _inputController,
              onTap: focusForm,
              onChanged: (_) => setState(() => _responseError = null),
              onEditingComplete: FocusScope.of(context).unfocus,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                hintText: 'Hasło *',
                hintStyle: TextStyle(color: Colors.grey.shade700),
                filled: true,
                fillColor: Colors.grey.shade200,
                isDense: true,
                contentPadding: _formFocused
                    ? const EdgeInsets.fromLTRB(12, 12, 12, 10)
                    : const EdgeInsets.fromLTRB(12, 16, 8, 14),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.lightBlue.shade300, width: 1.5),
                    borderRadius: const BorderRadius.all(Radius.circular(50))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.lightBlue.shade300, width: 1.5),
                    borderRadius: const BorderRadius.all(Radius.circular(50))),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlue.shade300, width: 3),
                    borderRadius: const BorderRadius.all(Radius.circular(50))),
              ),
            ),
            if (_responseError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 3, 16, 0),
                child: Text(
                  '• $_responseError',
                  style: TextStyle(fontSize: 11, color: Colors.red.shade400),
                ),
              )
          ],
        ),
        actions: <TextButton>[
          TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text(
                'Anuluj',
                style: TextStyle(color: Colors.white),
              )),
          TextButton(
              onPressed: _inputController.text.isEmpty
                  ? null
                  : sendAccountDeleteRequest,
              child: Text(
                'Usuń konto',
                style: TextStyle(color: Colors.red.shade400),
              ))
        ],
      ),
    );
  }

  void sendAccountDeleteRequest() {
    final Map<String, String> data = <String, String>{
      'password': _inputController.text
    };
    final Uri url = Uri.parse(ApiEndpoints.deleteAccount);
    final Future<http.Response> future = http.delete(url,
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              Provider.of<Auth>(context, listen: false).accessToken,
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode(data));

    future.then((http.Response response) {
      switch (response.statusCode) {
        case 200:
          Navigator.of(context).pop();
          Provider.of<Auth>(context, listen: false).logOut();
          Provider.of<NavBarState>(context, listen: false).currentPageIndex = 0;
          showSnackBar(context, 'Konto zostało usunięte.');
          break;
        case 403:
          setState(() => _responseError = 'Niepoprawne hasło.');
          break;
        case 404:
          setState(() => _responseError = 'Konto nie istnieje.');
          break;
        case 500:
          setState(
              () => _responseError = 'Błąd serwera, spróbuj ponownie później.');
          break;
      }
    }).onError((Exception error, StackTrace stackTrace) {
      setState(() => _responseError =
          'Nie można połączyć z serwerem. Spróbuj ponownie później.');
    });
  }

  void focusForm() {
    setState(() {
      _formFocused = true;
    });
  }

  void unfocusForm() {
    FocusScope.of(context).unfocus();
    _formFocused = false;
  }
}
