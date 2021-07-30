import 'package:flutter/material.dart';
import 'package:musicly_app/home_page.dart';
import 'package:musicly_app/error_page.dart';
import 'package:musicly_app/search_page.dart';
import 'package:musicly_app/settings_page.dart';
import 'package:musicly_app/favorites_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute<dynamic>(builder: (_) => HomePage());
      case '/search':
        return MaterialPageRoute<dynamic>(builder: (_) => SearchPage());
      case '/favorites':
        return MaterialPageRoute<dynamic>(
            builder: (_) => FavoritesPage());
      case '/settings':
        return MaterialPageRoute<dynamic>(builder: (_) => SettingsPage());
      default:
        return MaterialPageRoute<dynamic>(builder: (_) => ErrorPage());
    }
  }
}
