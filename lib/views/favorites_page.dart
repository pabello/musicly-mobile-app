import 'dart:convert' show utf8, jsonDecode, jsonEncode;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:musicly_app/api_endpoints.dart';
import 'package:musicly_app/dto_classes.dart';
import 'package:musicly_app/errors.dart';
import 'package:musicly_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final double stateBarHeight = MediaQuery.of(context).padding.top;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, stateBarHeight + 10, 20, 10),
      children: <Widget>[
        getFavoritesModule(context, FavoriteCategory.playlist),
        const SizedBox(height: 20),
        getFavoritesModule(context, FavoriteCategory.liked),
        const SizedBox(height: 20),
        getFavoritesModule(context, FavoriteCategory.disliked),
      ],
    );
  }

  Widget getFavoritesModule(BuildContext context, FavoriteCategory type) {
    String header, emptyListErrorMessage, likeStatus, fullListPathName;
    Icon leadingIcon;
    List<String> fetchingMethod;

    switch (type) {
      case FavoriteCategory.liked:
        header = 'Polubione utwory';
        leadingIcon =
            const Icon(Icons.thumb_up_outlined, color: Color(0xff93ec7d));
        emptyListErrorMessage = 'Nie masz jeszcze żadnych polubionych utworów.';
        likeStatus = 'like';
        fullListPathName = '/userMusic';
        break;

      case FavoriteCategory.playlist:
        header = 'Twoje playlisty';
        leadingIcon = const Icon(Icons.list, color: Color(0xFF8B88D1));
        emptyListErrorMessage = 'Nie posiadasz jeszcze żadnych playlist.';
        fullListPathName = '/playlistsList';
        break;

      case FavoriteCategory.disliked:
        header = 'Nielubiane utwory';
        leadingIcon =
            Icon(Icons.thumb_down_outlined, color: Colors.red.shade300);
        emptyListErrorMessage =
            'Nie masz jeszcze żadnych nielubianych utworów.';
        likeStatus = 'dislike';
        fullListPathName = '/userMusic';
        break;
    }

    return SizedBox(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 0, 15),
              child: Text(header, style: Theme.of(context).textTheme.headline1),
            ),
            if (likeStatus == null)
              getFavoritesListTiles(context, fetchingMethod,
                  icon: leadingIcon,
                  emptyListErrorMessage: emptyListErrorMessage,
                  playlists: true)
            else
              getFavoritesListTiles(context, fetchingMethod,
                  icon: leadingIcon,
                  likeStatus: likeStatus,
                  emptyListErrorMessage: emptyListErrorMessage),
            Center(
              child: TextButton(
                onPressed: () async {
                  await Navigator.of(context)
                      .pushNamed(fullListPathName, arguments: likeStatus);
                  setState(() {});
                },
                style: Theme.of(context).textButtonTheme.style,
                child: const Text('Zobacz wszystkie'),
              ),
            ),
          ]),
    );
  }

  Widget getFavoritesListTiles(BuildContext context, List<String> items,
      {@required String emptyListErrorMessage,
      String likeStatus,
      @required Icon icon,
      bool playlists = false}) {
    final List<Padding> favorites = <Padding>[];
    String headlineTag = 'recording_title';
    String apiEndpoint = ApiEndpoints.userMusicList;

    final Map<String, dynamic> filters = <String, dynamic>{
      'chronological_order': 'desc',
      'top': 3,
    };
    if (!playlists && likeStatus != null) {
      filters['like_status'] = likeStatus;
    }
    if (playlists) {
      headlineTag = 'name';
      apiEndpoint = ApiEndpoints.playlistList;
    }

    Future<http.Response> _fetchFavorites() {
      final Uri url = Uri.parse(apiEndpoint);
      final Future<http.Response> future = http.post(url,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: context.watch<Auth>().accessToken,
            HttpHeaders.contentTypeHeader: 'application/json'
          },
          body: jsonEncode(filters));
      return future;
    }

    return FutureBuilder<http.Response>(
      future: _fetchFavorites(),
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data.statusCode == 200) {
            final dynamic content =
                jsonDecode(utf8.decode(snapshot.data.body.runes.toList()));
            if (content.length as int > 0) {
              for (final dynamic element in content) {
                dynamic elementDTO;
                if (playlists) {
                  elementDTO = PlaylistSimpleDTO(
                      element['id'] as int,
                      element['name'].toString(),
                      element['length'] as int,
                      element['music_count'] as int);
                } else {
                  elementDTO = RecordingSimpleDTO(
                      element['recording_id'] as int,
                      element['recording_title'].toString(),
                      element['recording_length'] as int);
                }
                favorites.add(Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: ListTile(
                    leading: icon,
                    title: Text(element[headlineTag].toString()),
                    trailing: const Icon(Icons.arrow_forward),
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -2.5),
                    horizontalTitleGap: 12,
                    onTap: () async {
                      await Navigator.of(context).pushNamed(
                          playlists ? '/playlist' : '/recording',
                          arguments: elementDTO);
                      setState(() {});
                    },
                  ),
                ));
              }
              return Column(children: <Padding>[...favorites]);
            } else {
              return buildAsyncLoadingErrorMessage(emptyListErrorMessage);
            }
          } else {
            return buildAsyncLoadingErrorMessage(
                'Nie udało się połączyć z serwerem...');
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

enum FavoriteCategory {
  liked,
  disliked,
  playlist,
}
