import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:form_field_validator/form_field_validator.dart' as valid;

void showSnackBar(BuildContext context, String message) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      content: Text(message),
      duration: const Duration(milliseconds: 3000),
    ));
  });
}

class MultiValidator extends valid.FieldValidator<String> {
  final List<valid.FieldValidator> validators;
  static String _errorText = '';

  MultiValidator(this.validators) : super(_errorText);

  @override
  bool isValid(dynamic value) {
    _errorText = '';
    for (final valid.FieldValidator validator in validators) {
      if (validator.call(value) != null) {
        _errorText += '${validator.errorText}\n';
      }
    }
    if (_errorText != '') {
      _errorText.trim();
      return false;
    }
    return true;
  }

  @override
  String call(dynamic value) {
    return isValid(value) ? null : _errorText;
  }
}

final MultiValidator loginValidator =
    MultiValidator(<valid.FieldValidator<String>>[
  valid.RequiredValidator(errorText: '• Nazwa użytkownika nie może być pusta')
]);
final MultiValidator emailValidator =
    MultiValidator(<valid.FieldValidator<String>>[
  valid.EmailValidator(errorText: '• Błędny format adresu email')
]);
final MultiValidator passwordValidator =
    MultiValidator(<valid.FieldValidator<String>>[
  valid.MinLengthValidator(8,
      errorText: '• Hasło zawierać przynajmniej 8 znaków'),
  valid.PatternValidator('(?=.*?[A-Z])',
      errorText: '• Musi zawierać przynajmniej jedną wielką literę'),
  valid.PatternValidator(r'(?=.*?[#?!@$%^&*-_\d])',
      errorText: '• Musi zawierać znak specjalny lub cyfrę'),
]);
