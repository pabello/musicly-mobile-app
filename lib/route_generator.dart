import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:musicly_app/views/home_page.dart';
import 'package:musicly_app/views/error_page.dart';
import 'package:musicly_app/views/search_page.dart';
import 'package:musicly_app/views/settings_page.dart';
import 'package:musicly_app/views/favorites_page.dart';
import 'package:musicly_app/views/recording_view.dart';
import 'package:musicly_app/views/artist_view.dart';
import 'package:musicly_app/views/user_music_view.dart';
import 'package:musicly_app/views/playlist_list_view.dart';
import 'package:musicly_app/views/playlist_view.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Object args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute<dynamic>(builder: (_) => HomePage());
      case '/recording':
        return MaterialPageRoute<dynamic>(
            builder: (_) => RecordingViewPage(data: args));
      case '/artist':
        return MaterialPageRoute<dynamic>(
          builder: (_) => ArtistViewPage(data: args));
      case '/userMusic':
        return MaterialPageRoute<dynamic>(
          builder: (_) => UserMusicViewPage(data: args));
      case '/playlistsList':
        return MaterialPageRoute<dynamic>(
          builder: (_) => PlaylistListViewPage(data: args));
      case '/playlist':
        return MaterialPageRoute<dynamic>(
          builder: (_) => PlaylistViewPage(data: args));
      default:
        return MaterialPageRoute<dynamic>(builder: (_) => ErrorPage());
    }
  }
}
