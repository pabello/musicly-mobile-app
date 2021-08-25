import 'dart:collection';
import 'dart:convert' show Encoding, jsonDecode, jsonEncode, utf8;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicly_app/dto_classes.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:musicly_app/api_endpoints.dart';
import 'package:musicly_app/providers/auth_provider.dart';
import 'package:musicly_app/errors.dart';

class PlaylistViewPage extends StatelessWidget {
  const PlaylistViewPage({@required this.data});

  final Object data;

  // void _editNameButtonClick(int likeStatus) {
  //   // _setLikeStatus(widget.recordingId, likeStatus)
  //   //     .then((http.Response response) => <void>{
  //   //           if (response.statusCode == 200)
  //   //             <void>{updateLikeStatus(likeStatus)}
  //   //           else { print('error code ${response.statusCode}') }
  //   //         });
  // }

  @override
  Widget build(BuildContext context) {
    final PlaylistSimpleDTO playlist = data as PlaylistSimpleDTO;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          playlist.name,
          style: Theme.of(context).textTheme.headline5,
        ),
        titleSpacing: 5,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Flex(direction: Axis.horizontal, children: <Widget>[
            Text(playlist.name, style: Theme.of(context).textTheme.headline1),
            const SizedBox(width: 16),
            InkWell(
                onTap: () {},
                child:
                    Icon(Feather.edit, size: 21, color: Colors.grey.shade400))
          ]),
          Text(_getPlaylistSubtitles(playlist),
              style: Theme.of(context).textTheme.subtitle2),
          const SizedBox(height: 20),
          Text(
            'Utwory',
            style: Theme.of(context).textTheme.headline3,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child:
                PlaylistRecordings(context: context, playlistId: playlist.id),
          ),
        ],
      ),
    );
  }
}

class PlaylistRecordings extends StatefulWidget {
  const PlaylistRecordings(
      {Key key, @required this.context, @required this.playlistId})
      : super(key: key);

  final BuildContext context;
  final int playlistId;

  @override
  State<PlaylistRecordings> createState() => _PlaylistRecordingsState();
}

class _PlaylistRecordingsState extends State<PlaylistRecordings> {
  @override
  Widget build(BuildContext context) {
    Future<http.Response> _fetchPlaylistRecordings(
        BuildContext context, int playlistId) {
      final Uri url = Uri.parse('${ApiEndpoints.playlistDetails}/$playlistId/');
      final Future<http.Response> future = http.get(url,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: context.watch<Auth>().accessToken
          });
      return future;
    }

    Future<http.Response> _setPlaylistName(int playlistId, String newName) {
      final Map<String, String> data = <String, String>{'name': newName};
      final Uri url = Uri.parse('${ApiEndpoints.playlistDetails}$playlistId/');
      final Future<http.Response> future = http.patch(url,
          headers: <String, String>{
            HttpHeaders.authorizationHeader:
                Provider.of<Auth>(context, listen: false).accessToken,
            HttpHeaders.contentTypeHeader: 'application/json'
          },
          body: jsonEncode(data));
      return future;
    }

    return FutureBuilder<http.Response>(
        future: _fetchPlaylistRecordings(context, widget.playlistId),
        builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.statusCode == 200) {
              if (snapshot.data.body.runtimeType == String) {
                final List<Widget> recordings = <Widget>[];
                final dynamic response =
                    jsonDecode(utf8.decode(snapshot.data.body.runes.toList()));
                for (final dynamic object in response['recordings']) {
                  final RecordingSimpleDTO recording = RecordingSimpleDTO(
                      object['recording_id'] as int,
                      object['title'].toString(),
                      object['length'] as int);
                  recordings.add(Padding(
                    key: GlobalKey(),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Stack(children: <Widget>[
                      ListTile(
                        tileColor: const Color(0xff3b3c45),
                        leading: const Icon(
                          Icons.disc_full,
                          color: Color(0xffffd485),
                        ),
                        title: Text(recording.title),
                        visualDensity: const VisualDensity(vertical: -4),
                        minVerticalPadding: 10,
                        horizontalTitleGap: 10,
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed('/recording',
                                  arguments: recording);
                            },
                          ),
                        ),
                      )
                    ]),
                  ));
                }
                return SizedBox(
                  height: 800,
                  width: 500,
                  child: ReorderableListView(
                    onReorder: (int oldIndex, int newIndex) {  },
                    children: <Widget>[...recordings],
                  ),
                );
              } else {
                return buildAsyncLoadingErrorMessage(
                    'Nie uzyskano danych z serwera...');
              }
            } else {
              return buildAsyncLoadingErrorMessage(
                  'Błąd połączenia z serwerem...');
            }
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

String _getPlaylistSubtitles(PlaylistSimpleDTO playlist) {
  String output = '';
  if (playlist.length != null) {
    if (playlist.length > 0) {
      output += '\n  • ${playlist.getLengthMinutes().toString()} min. '
          '${playlist.getLengthRemainingSeconds().toString()} sek. ';
    }
  }
  if (playlist.musicCount != null) {
    output += '\n  • ${playlist.musicCount.toString()} ';
    final int lwd = playlist.musicCount % 10;
    if (lwd > 4 || lwd == 0) {
      output += 'utworów';
    } else {
      if (lwd == 1) {
        output += 'utwór';
      } else {
        output += 'utwory';
      }
    }
  }
  return output;
}

void _showSnackBar(BuildContext context, String message) {
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
