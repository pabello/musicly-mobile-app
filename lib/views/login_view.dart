import 'dart:convert' show jsonEncode, jsonDecode, utf8;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:musicly_app/api_endpoints.dart';
import 'package:provider/provider.dart';
import 'package:form_field_validator/form_field_validator.dart'
    show MatchValidator;
import 'package:http/http.dart' as http;

import 'package:musicly_app/providers/auth_provider.dart';
import 'package:musicly_app/utils.dart';

class LoginViewPage extends StatefulWidget {
  @override
  State<LoginViewPage> createState() => _LoginViewPageState();
}

class _LoginViewPageState extends State<LoginViewPage> {
  String errorMessage = '';
  bool isKeyboardVisible = false;
  bool formFocused = false;
  bool isRegisterForm = false;
  String responseError;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _repasswdFormKey = GlobalKey<FormState>();
  TextEditingController loginInputController = TextEditingController();
  TextEditingController emailInputController = TextEditingController();
  TextEditingController passwordInputController = TextEditingController();
  TextEditingController repasswdInputController = TextEditingController();

  int _keyboardVisibilitySubscriberId;
  final KeyboardVisibilityNotification _keyboardVisibility =
      KeyboardVisibilityNotification();

  @override
  void initState() {
    super.initState();
    _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        setState(() {
          isKeyboardVisible = visible;
        });
      },
    );
  }

  @override
  void dispose() {
    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
    loginInputController.dispose();
    emailInputController.dispose();
    passwordInputController.dispose();
    repasswdInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          formFocused = false;
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (!(isRegisterForm && formFocused))
                  Text(
                    isRegisterForm ? 'Rejestracja' : 'Logowanie',
                    style: Theme.of(context).textTheme.headline1.merge(
                        const TextStyle(
                            fontSize: 40, color: Color(0xffffd485))),
                  ),
                const Flexible(child: SizedBox(height: 8)),
                getFormInputField(
                  formKey: _loginFormKey,
                  controller: loginInputController,
                  label: 'Nazwa użytkownika *',
                  hint: 'Nazwa użytkownika lub adres e-mail',
                  validator: loginValidator,
                ),
                if (isRegisterForm)
                  getFormInputField(
                    formKey: _emailFormKey,
                    controller: emailInputController,
                    label: 'Adres e-mail *',
                    hint: 'Potrzebny gdy zapomnisz hasła',
                    validator: emailValidator,
                  ),
                getFormInputField(
                  formKey: _passwordFormKey,
                  controller: passwordInputController,
                  label: 'Hasło *',
                  hint: 'Hasło logowania do konta',
                  isPassword: true,
                  validator: passwordValidator,
                ),
                if (isRegisterForm)
                  getFormInputField(
                    formKey: _repasswdFormKey,
                    controller: repasswdInputController,
                    label: 'Powtórz hasło *',
                    hint: 'Powtórz hasło',
                    isPassword: true,
                    isLastFormField: true,
                    validator: (String value) =>
                        MatchValidator(errorText: 'Hasła muszą być zgodne')
                            .validateMatch(
                                value, passwordInputController.value.text),
                  ),
                Row(
                  mainAxisAlignment: isRegisterForm
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (!isRegisterForm)
                      TextButton(
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              visualDensity: const VisualDensity(vertical: -4)),
                          onPressed: null,
                          child: Text(
                            'Zapomniałe/am hasła',
                            style: TextStyle(
                                fontSize: 11, color: Colors.lightBlue.shade300),
                          )),
                    TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(vertical: -4)),
                        onPressed: () {
                          setState(() {
                            isRegisterForm = !isRegisterForm;
                            responseError = null;
                          });
                          if (!isRegisterForm) {
                            _loginFormKey.currentState.reset();
                            _passwordFormKey.currentState.reset();
                          }
                        },
                        child: Text(
                          isRegisterForm ? 'Zaloguj się' : 'Zarejestruj konto',
                          style: TextStyle(
                              fontSize: 11, color: Colors.lightBlue.shade300),
                        ))
                  ],
                ),
                if (responseError != null)
                  Text('• $responseError',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Colors.red.shade700)),
                const Flexible(child: SizedBox(height: 8)),
                getSubmitButton()
              ],
            ),
          ),
        ));
  }

  Widget getFormInputField({
    @required String label,
    @required String hint,
    @required TextEditingController controller,
    @required Function(String) validator,
    @required GlobalKey<FormState> formKey,
    bool isPassword = false,
    bool isLastFormField = false,
  }) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        onTap: () => setState(() => formFocused = true),
        onEditingComplete: () {
          if (isLastFormField || (!isRegisterForm && isPassword)) {
            FocusScope.of(context).unfocus();
            setState(() {
              formFocused = false;
            });
          } else {
            FocusScope.of(context).nextFocus();
          }
        },
        onChanged: (_) => setState(() => responseError = null),
        controller: controller,
        obscureText: isPassword,
        validator: isRegisterForm
            ? (String value) {
                return validator(value) as String;
              }
            : (String value) => null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }

  Widget getSubmitButton() {
    return Tooltip(
      message: 'Wypełnij wszystkie pola',
      child: ElevatedButton(
          onPressed: submitButtonDisabled()
              ? null
              : () {
                  if (!submitButtonDisabled()) {
                    if (isRegisterForm) {
                      if (_loginFormKey.currentState.validate() &&
                          _emailFormKey.currentState.validate() &&
                          _passwordFormKey.currentState.validate() &&
                          _repasswdFormKey.currentState.validate()) {
                        _sendRegisterRequest();
                      }
                    } else {
                      _sendLoginRequest();
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(isRegisterForm ? 'Zarejestruj' : 'Zaloguj')),
    );
  }

  void _sendRegisterRequest() {
    print('sending register request');
    final Map<String, String> data = <String, String>{
      'username': loginInputController.text,
      'email': emailInputController.text,
      'password': passwordInputController.text,
    };
    final Uri url = Uri.parse(ApiEndpoints.register);
    final Future<http.Response> future = http.post(url,
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode(data));

    future.then((http.Response response) {
      final dynamic content = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201) {
        Provider.of<Auth>(context, listen: false).setIdentity(
            content['username'].toString(), content['token'].toString());
        if (content['errors'] != null) {
          showSnackBar(context,
              'Nie udało się wysłać maila potwierdzającego adres e-mail');
        }
      } else if (response.statusCode == 403) {
        if (content['characters'] != null) {
          final String chars = content['restricted_chars'].toString();
          setState(() {
            responseError =
                'Nazwa użytkownika nie może zawierać znaków: $chars';
          });
        } else if (content['password'] != null) {
          setState(() {
            responseError = 'Hasło nie spełnia kryterów bezpieczeństwa';
          });
        } else {
          String error = '';
          if (content['username'] != null) {
            error += 'Użytkownik o takiej nazwie już istnieje\n';
          }
          if (content['email'] != null) {
            if (error != '') {
              error += '• ';
            }
            error += 'Ten adres email jest już w użyciu\n';
          }
          if (error == '') {
            error = "Nieznany błąd, spróbuj ponownie";
          }
          setState(() {
            responseError = error;
          });
        }
      } else if (response.statusCode == 500) {
        setState(() {
          responseError = 'Błąd serwera, spróbuj ponownie za chwilę';
        });
      } else {
        setState(() {
          responseError = 'Nieznany błąd, spróbuj ponownie';
        });
      }
    }).onError((Exception error, StackTrace stackTrace) {
      setState(() {
        responseError =
            'Nie można połączyć z serwerem, spróbuj ponownie później';
      });
    });
  }

  void _sendLoginRequest() {
    final Map<String, String> data = <String, String>{
      'username': loginInputController.text,
      'password': passwordInputController.text
    };
    final Uri url = Uri.parse(ApiEndpoints.login);
    final Future<http.Response> future = http.post(url,
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode(data));

    future.then((http.Response response) {
      if (response.statusCode == 200) {
        final dynamic content = jsonDecode(utf8.decode(response.bodyBytes));
        Provider.of<Auth>(context, listen: false).setIdentity(
            content['username'].toString(), content['token'].toString());
      } else if (response.statusCode == 400) {
        setState(
            () => responseError = 'Nazwa użytkownika lub hasło są niepoprawne');
      }
    }).onError((Exception error, StackTrace stackTrace) {
      showSnackBar(
          context, 'Nie można połączyć z serwerem\nSpróbuj ponownie późńiej');
    });
  }

  bool submitButtonDisabled() {
    if (isRegisterForm) {
      return loginInputController.value.text == '' ||
          emailInputController.value.text == '' ||
          passwordInputController.value.text == '' ||
          repasswdInputController.value.text == '';
    } else {
      return loginInputController.value.text == '' ||
          passwordInputController.value.text == '';
    }
  }
}
