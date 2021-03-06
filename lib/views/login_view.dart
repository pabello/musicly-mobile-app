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
                  label: 'Nazwa u??ytkownika *',
                  hint: 'Nazwa u??ytkownika lub adres e-mail',
                  validator: loginValidator,
                ),
                if (isRegisterForm)
                  getFormInputField(
                    formKey: _emailFormKey,
                    controller: emailInputController,
                    label: 'Adres e-mail *',
                    hint: 'Potrzebny gdy zapomnisz has??a',
                    validator: emailValidator,
                  ),
                getFormInputField(
                  formKey: _passwordFormKey,
                  controller: passwordInputController,
                  label: 'Has??o *',
                  hint: 'Has??o logowania do konta',
                  isPassword: true,
                  validator: passwordValidator,
                ),
                if (isRegisterForm)
                  getFormInputField(
                    formKey: _repasswdFormKey,
                    controller: repasswdInputController,
                    label: 'Powt??rz has??o *',
                    hint: 'Powt??rz has??o',
                    isPassword: true,
                    isLastFormField: true,
                    validator: (String value) =>
                        MatchValidator(errorText: 'Has??a musz?? by?? zgodne')
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
                            'Zapomnia??e/am has??a',
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
                          isRegisterForm ? 'Zaloguj si??' : 'Zarejestruj konto',
                          style: TextStyle(
                              fontSize: 11, color: Colors.lightBlue.shade300),
                        ))
                  ],
                ),
                if (responseError != null)
                  Text('??? $responseError',
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
        enableSuggestions: !isPassword,
        autocorrect: !isPassword,
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
      message: 'Wype??nij wszystkie pola',
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
              'Nie uda??o si?? wys??a?? maila potwierdzaj??cego adres e-mail');
        }
      } else if (response.statusCode == 403) {
        if (content['characters'] != null) {
          final String chars = content['restricted_chars'].toString();
          setState(() {
            responseError =
                'Nazwa u??ytkownika nie mo??e zawiera?? znak??w: $chars';
          });
        } else if (content['password'] != null) {
          setState(() {
            responseError = 'Has??o nie spe??nia kryter??w bezpiecze??stwa';
          });
        } else {
          String error = '';
          if (content['username'] != null) {
            error += 'U??ytkownik o takiej nazwie ju?? istnieje\n';
          }
          if (content['email'] != null) {
            if (error != '') {
              error += '??? ';
            }
            error += 'Ten adres email jest ju?? w u??yciu\n';
          }
          if (error == '') {
            error = "Nieznany b????d, spr??buj ponownie";
          }
          setState(() {
            responseError = error;
          });
        }
      } else if (response.statusCode == 500) {
        setState(() {
          responseError = 'B????d serwera, spr??buj ponownie za chwil??';
        });
      } else {
        setState(() {
          responseError = 'Nieznany b????d, spr??buj ponownie';
        });
      }
    }).onError((Exception error, StackTrace stackTrace) {
      setState(() {
        responseError =
            'Nie mo??na po????czy?? z serwerem, spr??buj ponownie p????niej';
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
            () => responseError = 'Nazwa u??ytkownika lub has??o s?? niepoprawne');
      }
    }).onError((Exception error, StackTrace stackTrace) {
      showSnackBar(
          context, 'Nie mo??na po????czy?? z serwerem.\nSpr??buj ponownie p??????iej.');
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
