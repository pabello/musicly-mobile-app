import 'dart:convert' show utf8, jsonDecode, jsonEncode;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:musicly_app/utils.dart';
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
  final ScrollController _scrollController = ScrollController();
  final String emptyListErrorMessage =
      'Nie posiadasz jeszcze żadnych playlist.';
  final String pageTitle = 'Playlisty';
  final Icon playlistIcon = const Icon(Icons.list, color: Color(0xFF8B88D1));
  bool isAddingPlaylist = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isAddingPlaylist) {
          setState(() {
            isAddingPlaylist = false;
          });
        }
      },
      child: Scaffold(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(pageTitle, style: Theme.of(context).textTheme.headline1),
                IconButton(
                  color: const Color(0xff93ec7d),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Nowa playlista',
                  onPressed: () {
                    if (!isAddingPlaylist) {
                      setState(() {
                        isAddingPlaylist = true;
                      });
                    }
                  },
                ),
              ],
            ),
            if (isAddingPlaylist)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: TextField(
                  autofocus: true,
                  decoration:
                      const InputDecoration(hintText: 'Nazwa playlisty'),
                  onSubmitted: (String value) {
                    if (value != '') {
                      _requestCreatePlaylist(value);
                    }
                  },
                ),
              ),
            if (isAddingPlaylist)
              const SizedBox(height: 10)
            else
              const SizedBox(height: 10),
            FutureBuilder<http.Response>(
              future: fetchPlaylists(context),
              builder: (BuildContext context,
                  AsyncSnapshot<http.Response> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (!snapshot.hasError && snapshot.data.statusCode == 200) {
                    final dynamic content = jsonDecode(
                        utf8.decode(snapshot.data.body.runes.toList()));
                    if (content.length as int > 0) {
                      final List<Widget> playlists = <Widget>[];
                      for (final dynamic element in content) {
                        final PlaylistSimpleDTO playlistDTO = PlaylistSimpleDTO(
                            element['id'] as int,
                            element['name'].toString(),
                            element['length'] as int,
                            element['music_count'] as int);
                        playlists.add(Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: ListTile(
                            leading: playlistIcon,
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
                      return buildAsyncLoadingErrorMessage(
                          emptyListErrorMessage);
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
      ),
    );
  }

  void _requestCreatePlaylist(String playlistName) {
    final Map<String, String> data = <String, String>{'name': playlistName};
    final Uri url = Uri.parse(ApiEndpoints.createPlaylist);
    final Future<http.Response> future = http.post(url,
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              Provider.of<Auth>(context, listen: false).accessToken,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(data));

    future.then((http.Response response) {
      switch (response.statusCode) {
        case 201:
          showSnackBar(context, 'Utworzono playlistę.');
          break;
        case 403:
          showSnackBar(context,
              'Posiadasz już playlistę o tej nazwie. Wybierz inną nazwę.');
          break;
        default:
          showSnackBar(context,
              'Nie udało się utworzyć playlisty. Spróbuj ponownie później.');
          break;
      }
    }).onError((Exception error, StackTrace stackTrace) {
      showSnackBar(
          context, 'Nie można połączyć z serwerem. Spróbuj ponownie później.');
    }).whenComplete(() => setState(() {
          isAddingPlaylist = false;
        }));
  }
}

Future<http.Response> fetchPlaylists(
  BuildContext context,
) {
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
