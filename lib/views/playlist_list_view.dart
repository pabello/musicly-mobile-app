import 'dart:convert' show utf8, jsonDecode, jsonEncode;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:musicly_app/views/recording_view.dart';
import 'package:provider/provider.dart';

import 'package:musicly_app/providers/auth_provider.dart';
import 'package:musicly_app/api_endpoints.dart';
import 'package:musicly_app/dto_classes.dart';
import 'package:musicly_app/errors.dart';

class PlaylistListViewPage extends StatefulWidget {
  const PlaylistListViewPage({this.data});

  final Object data;

  @override
  _PlaylistListViewPageState createState() => _PlaylistListViewPageState();
}

class _PlaylistListViewPageState extends State<PlaylistListViewPage> {
  @override
  Widget build(BuildContext context) {
    Future<http.Response> _fetchPlaylists() {
      final Map<String, String> filters = <String, String>{
        'chronological_order': 'desc',
      };
      final Uri url = Uri.parse(ApiEndpoints.playlistList);
      final Future<http.Response> future = http.post(url,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: context.watch<Auth>().accessToken,
            HttpHeaders.contentTypeHeader: 'application/json'
          },
          body: jsonEncode(filters));
      return future;
    }

    final ScrollController _scrollController = ScrollController();
    const String emptyListErrorMessage =
        'Nie posiadasz jeszcze żadnych playlist.';
    const String pageTitle = 'Playlisty';
    const Icon icon = Icon(Icons.list, color: Color(0xFF8B88D1));

    // final double stateBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: Theme.of(context).textTheme.headline5,
        ),
        titleSpacing: 5,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(pageTitle, style: Theme.of(context).textTheme.headline1),
          const SizedBox(height: 20),
          FutureBuilder<http.Response>(
            future: _fetchPlaylists(),
            builder:
                (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data.statusCode == 200) {
                  final dynamic content = jsonDecode(
                      utf8.decode(snapshot.data.body.runes.toList()));
                  if (content.length as int > 0) {
                    final List<Widget> playlists = <Widget>[];
                    for (final dynamic element in content) {
                      final PlaylistSimpleDTO playlistDTO =
                          PlaylistSimpleDTO(
                              element['id'] as int,
                              element['name'].toString(),
                              element['length'] as int,
                              element['music_count'] as int);
                      playlists.add(Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: ListTile(
                          leading: icon,
                          title: Text(playlistDTO.name),
                          trailing: const Icon(Icons.arrow_forward),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -2.5),
                          horizontalTitleGap: 12,
                          onTap: () async {
                            await Navigator.of(context).pushNamed('/playlist',
                                arguments: playlistDTO);
                            setState(() {});
                          },
                        ),
                      ));
                    }
                    return Column(children: <Widget>[...playlists]);
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
          ),
          Center(
            child: TextButton(
              onPressed: () => _scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text('Do góry'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
