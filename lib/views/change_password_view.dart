import 'dart:convert' show jsonEncode, jsonDecode, utf8;
import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_field_validator/form_field_validator.dart' as valid;
import 'package:keyboard_visibility/keyboard_visibility.dart';

import 'package:musicly_app/providers/auth_provider.dart';
import 'package:musicly_app/api_endpoints.dart';
import 'package:musicly_app/utils.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({this.isLoggedIn = false});

  final bool isLoggedIn;

  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String emailInput, tokenInput, passwordInput, repeatPasswordInput, errors;
  bool emailVisited,
      tokenVisited,
      passwordVisited,
      repeatPasswordVisited,
      emailHasError,
      tokenHasError,
      passwordHasError,
      repeatPasswordHasError,
      emailIncorrect,
      tokenIncorrect,
      passwordIncorrect,
      repeatedPasswordIncorrect,
      isKeyboardVisible,
      formFocused,
      hasErrors;
  int _keyboardVisibilitySubscriberId;
  final KeyboardVisibilityNotification _keyboardVisibility =
      KeyboardVisibilityNotification();
  Map<String, String> errorMessages = <String, String>{
    'emailError': null,
    'passwordError': null,
    'repeatedPasswordError': null
  };

  @override
  void initState() {
    super.initState();
    errors = '';
    isKeyboardVisible = _keyboardVisibility.isKeyboardVisible;
    emailInput = tokenInput = passwordInput = repeatPasswordInput = null;
    emailVisited = tokenVisited = passwordVisited = repeatPasswordVisited =
        formFocused = hasErrors = emailHasError =
            tokenHasError = passwordHasError = repeatPasswordHasError = false;

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
    super.dispose();
  }

  void unfocusForm() {
    FocusScope.of(context).unfocus();
    checkErrors();
    setState(() {
      formFocused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color inputColor = Color(0xFF1F242E);
    const Flexible spacer8 = Flexible(child: SizedBox(height: 8));

    return GestureDetector(
      onTap: () => unfocusForm(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Zmiana has??a')),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (!isKeyboardVisible)
                  const Text(
                      'Na tw??j adres email, powi??zany z kontem, '
                      'zosta??a wys??ana wiaomo???? z kodem '
                      'potrzebnym do zmiany has??a.',
                      style: TextStyle(fontSize: 13)),
                spacer8,
                if (!widget.isLoggedIn) ...<Widget>[
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text('Adres e-mail *'),
                  ),
                  getFormField(
                    hint: 'Adres email przypisany do konta',
                    hasErrors: emailHasError,
                    visited: emailVisited,
                    onTap: () => setState(() {
                      emailVisited = true;
                      formFocused = true;
                    }),
                    onUpdate: (String value) =>
                        setState(() => emailInput = value),
                  ),
                  spacer8
                ],
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Token zmiany has??a *'),
                ),
                getFormField(
                  hint: 'Klucz otrzymany w wiadomo??ci email',
                  hasErrors: tokenHasError,
                  visited: tokenVisited,
                  onTap: () => setState(() {
                    tokenVisited = true;
                    formFocused = true;
                  }),
                  onUpdate: (String value) =>
                      setState(() => tokenInput = value),
                ),
                spacer8,
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Nowe has??o *'),
                ),
                getFormField(
                    hint: 'Nowe has??o',
                    hasErrors: passwordHasError,
                    visited: passwordVisited,
                    isPassword: true,
                    onTap: () => setState(() {
                          passwordVisited = true;
                          formFocused = true;
                        }),
                    onUpdate: (String value) =>
                        setState(() => passwordInput = value)),
                spacer8,
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Powt??rz has??o *'),
                ),
                getFormField(
                  hint: 'Powt??rz nowe has??o',
                  hasErrors: repeatPasswordHasError,
                  visited: repeatPasswordVisited,
                  isPassword: true,
                  isRepeatedPassword: true,
                  onTap: () => setState(() {
                    repeatPasswordVisited = true;
                    formFocused = true;
                  }),
                  onUpdate: (String value) =>
                      setState(() => repeatPasswordInput = value),
                ),
                if (!formFocused)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: getErrorMessages(),
                  ),
                spacer8,
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                          onPressed: sendButtonDisabled()
                              ? null
                              : () => requestPasswordChange()
                                  .then((http.Response response) =>
                                      handlePasswordChangeResponse(response))
                                  .onError((Exception error,
                                          StackTrace stackTrace) =>
                                      showSnackBar(context,
                                          'B????d po????czenia z serwerem...')),
                          style: ButtonStyle(
                              visualDensity: const VisualDensity(vertical: 1.5),
                              shape:
                                  MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ))),
                          child: const Text('Zmie?? has??o',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool sendButtonDisabled() {
    return !((widget.isLoggedIn || emailVisited) &&
            tokenVisited &&
            passwordVisited &&
            repeatPasswordVisited) ||
        hasErrors ||
        formFocused;
  }

  Future<http.Response> requestPasswordChange() {
    final String accountName = widget.isLoggedIn
        ? Provider.of<Auth>(context, listen: false).username
        : emailInput;
    final Map<String, String> body = <String, String>{
      'username_or_email': accountName.trim(),
      'password_reset_token': tokenInput.trim(),
      'new_password': passwordInput.trim(),
    };
    final Uri url = Uri.parse(ApiEndpoints.changePassword);
    final Future<http.Response> future = http.patch(url,
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode(body));

    return future;
  }

  void handlePasswordChangeResponse(http.Response response) {
    final dynamic content = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      showOneActionDialog(
          headline: 'Sukces',
          content: 'Twoje has??o zosta??o zmienione.',
          headlineColor: Colors.greenAccent.shade400);
    } else if (response.statusCode == 404 &&
        (content['error_source'] == 'account')) {
      showOneActionDialog(
          headline: 'B????d zmiany has??a',
          content: 'Konto u??ytkownika nie istnieje.',
          headlineColor: Colors.red.shade600);
    } else if (response.statusCode == 403) {
      if (content['error_source'] == 'token') {
        showOneActionDialog(
            headline: 'B????d zmiany has??a',
            content: 'Podany kod zmiany has??a jest nieprawid??owy, '
                'przedawni?? si?? lub nie nale??y do twojego konta.',
            headlineColor: Colors.red.shade600);
      } else if (content['error_source'] == 'password') {
        showOneActionDialog(
            headline: 'B????d zmiany has??a',
            content: 'Podane has??o nie spe??nia kryteri??w bezpiecze??stwa.',
            headlineColor: Colors.red.shade600);
      }
    } else {
      showOneActionDialog(
          headline: 'B????d zmiany has??a',
          content: 'Nie mo??na wykona?? operacji. Spr??buj ponownie p????niej.',
          headlineColor: Colors.red.shade600);
    }
  }

  void showOneActionDialog(
      {@required String headline,
      @required String content,
      String actionName = 'Zamknij',
      Color headlineColor = Colors.white}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(headline),
            titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: headlineColor),
            actions: <TextButton>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(actionName))
            ],
            content: Text(content),
          );
        });
  }

  void checkErrors() {
    String errorMessages = '';
    bool emailError, tokenError, passwordError, repeatedPasswordError;
    emailError = tokenError = passwordError = repeatedPasswordError = false;

    if (!widget.isLoggedIn && emailVisited) {
      String errorMessage = '';
      if (emailInput == null || emailInput == '') {
        errorMessage = '??? Adres email nie mo??e by?? pusty.\n';
      } else {
        errorMessage = emailValidator.call(emailInput) ?? '';
      }
      if (errorMessage != '') {
        emailError = true;
        errorMessages += errorMessage;
      }
    }

    if (tokenVisited) {
      String errorMessage = '';
      if (tokenInput == null || tokenInput == '') {
        errorMessage = '??? Kod zmiany has??a nie mo??e by?? pusty.\n';
      }
      if (errorMessage != '') {
        tokenError = true;
        errorMessages += errorMessage;
      }
    }

    if (passwordVisited) {
      String errorMessage = '';
      if (passwordInput == null || passwordInput == '') {
        errorMessage = '??? Has??o nie mo??e by?? puste.\n';
      } else {
        errorMessage = passwordValidator.call(passwordInput) ?? '';
      }
      if (errorMessage != '') {
        passwordError = true;
        errorMessages += errorMessage;
      }
    }

    if (repeatPasswordVisited) {
      String errorMessage = '';
      if (repeatPasswordInput == null || repeatPasswordInput == '') {
        errorMessage = '??? Wpisz ponownie has??o, aby potwierdzi??.\n';
      } else if (repeatPasswordInput != passwordInput) {
        errorMessage = '??? Wprowadzone has??a musz?? by?? identyczne.\n';
      }
      if (errorMessage != '') {
        repeatedPasswordError = true;
        errorMessages += errorMessage;
      }
    }

    setState(() {
      errors = errorMessages.trimRight();
      hasErrors = errorMessages.isNotEmpty;
      emailHasError = emailError;
      tokenHasError = tokenError;
      passwordHasError = passwordError;
      repeatPasswordHasError = repeatedPasswordError;
    });
  }

  Widget getErrorMessages() {
    return Text(errors, style: TextStyle(color: Colors.red.shade600));
  }

  Widget getFormField(
      {@required String hint,
      @required Function(String) onUpdate,
      @required Function onTap,
      @required bool hasErrors,
      @required bool visited,
      bool isPassword = false,
      bool isRepeatedPassword = false}) {
    const Color inputColor = Color(0xFF1F242E);

    return Flexible(
      flex: 10,
      child: TextFormField(
        onTap: () {
          checkErrors();
          onTap();
        },
        style: const TextStyle(color: inputColor),
        onChanged: onUpdate,
        onEditingComplete: isRepeatedPassword
            ? () {
                onTap();
                unfocusForm();
              }
            : () {
                onTap();
                FocusScope.of(context).nextFocus();
              },
        obscureText: isPassword,
        enableSuggestions: !isPassword,
        autocorrect: !isPassword,
        textAlignVertical: TextAlignVertical.bottom,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade700),
          filled: true,
          fillColor: Colors.grey.shade200,
          isDense: true,
          contentPadding: !isKeyboardVisible
              ? const EdgeInsets.fromLTRB(12, 16, 8, 14)
              : const EdgeInsets.fromLTRB(12, 16, 8, 11),
          enabledBorder: OutlineInputBorder(
              gapPadding: 0,
              borderSide: BorderSide(
                  color: visited
                      ? hasErrors
                          ? Colors.red.shade400
                          : Colors.greenAccent.shade400
                      : Colors.lightBlue.shade300,
                  // color: isRepeatedPassword
                  //     ? repeatPasswordInput == null ||
                  //             passwordInput == repeatPasswordInput
                  //         ? Colors.lightBlue.shade300
                  //         : Colors.red.shade400
                  //     : Colors.lightBlue.shade300,
                  width: 1.5),
              borderRadius: const BorderRadius.all(Radius.circular(50))),
          focusedBorder: OutlineInputBorder(
              gapPadding: 0,
              borderSide:
                  BorderSide(color: Colors.lightBlue.shade300, width: 3),
              borderRadius: const BorderRadius.all(Radius.circular(50))),
        ),
      ),
    );
  }
}
