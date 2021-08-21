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
import 'package:musicly_app/api_endpoints.dart';
import 'package:musicly_app/providers/auth_provider.dart';
import 'package:musicly_app/errors.dart';

class RecordingViewPage extends StatelessWidget {
  /*const*/ RecordingViewPage({@required this.data});

  final Object data;

  @override
  Widget build(BuildContext context) {
    RecordingSimpleDTO recording = data as RecordingSimpleDTO;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recording.title,
          style: Theme.of(context).textTheme.headline5,
        ),
        titleSpacing: 5,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          RichText(
              text: TextSpan(children: <TextSpan>[
            TextSpan(
                text: recording.title,
                style: Theme.of(context).textTheme.headline1),
            TextSpan(
                text: _getRecordingLength(recording),
                style: Theme.of(context).textTheme.subtitle2),
          ])),
          const SizedBox(height: 10),
          _getLikeStatusButtons(context, recording.id),
          const SizedBox(height: 20),
          Text(
            'Wykonawcy',
            style: Theme.of(context).textTheme.headline3,
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: _getRecordingArtists(context, recording.id)),
        ],
      ),
    );
  }
}

class LikeStatusButtons extends StatefulWidget {
  const LikeStatusButtons(
      {Key key, @required this.context, @required this.recordingId})
      : super(key: key);

  final BuildContext context;
  final int recordingId;

  @override
  State<LikeStatusButtons> createState() => _LikeStatusButtonsState();
}

class _LikeStatusButtonsState extends State<LikeStatusButtons> {
  int _likeStatus = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

Widget _getLikeStatusButtons(BuildContext context, int recordingId) {
  Future<http.Response> _setLikeStatus(int recordingId, int likeStatus) {
    final Map<String, int> data = <String, int>{'like_status': likeStatus};
    final Uri url = Uri.parse('${ApiEndpoints.musicReaction}$recordingId/');
    final Future<http.Response> future = http.post(url,
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              Provider.of<Auth>(context, listen: false).accessToken,
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode(data));

    return future;
  }

  Future<http.Response> _fetchRecordingLikeStatus(
      BuildContext context, int recordingId) {
    final Uri url = Uri.parse('${ApiEndpoints.musicReaction}/$recordingId/');
    final Future<http.Response> future = http.get(url,
        headers: <String, String>{
          HttpHeaders.authorizationHeader: context.watch<Auth>().accessToken
        });
    return future;
  }

  final Map<int, Color> _likeColors = <int, Color>{
    -1: Colors.red.shade300,
    0: Colors.grey.shade500,
    1: const Color(0xff93ec7d),
  };

  // TODO zmiana koloru przycisków in real time jak się klinkie!
  // może wymagać przerobienia na statefull widget albo użycie providera
  return FutureBuilder<http.Response>(
      future: _fetchRecordingLikeStatus(context, recordingId),
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        LikeStatusDTO likeStatus;
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data.statusCode == 200) {
            final dynamic response =
                jsonDecode(utf8.decode(snapshot.data.body.runes.toList()));
            likeStatus = LikeStatusDTO(response['recording_id'] as int,
                response['like_status'] as int);
          } else {
            likeStatus = LikeStatusDTO(recordingId, 0);
            if (snapshot.data.statusCode != 404) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor:
                      Theme.of(context).snackBarTheme.backgroundColor,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(10),
                  content: const Text('Błąd połączenia z serwerem'),
                  duration: const Duration(milliseconds: 3000),
                ));
              });
            }
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlinedButton(
                onPressed: () => _setLikeStatus(
                    recordingId, likeStatus.likeStatus == 1 ? 0 : 1),
                style: OutlinedButton.styleFrom(
                    primary: _likeColors[likeStatus.likeStatus > 0 ? 1 : 0],
                    side: BorderSide(
                        color: _likeColors[likeStatus.likeStatus > 0 ? 1 : 0])),
                child: const Text('Lubię to'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => _setLikeStatus(
                    recordingId, likeStatus.likeStatus == -1 ? 0 : -1),
                style: OutlinedButton.styleFrom(
                    primary: _likeColors[likeStatus.likeStatus < 0 ? -1 : 0],
                    side: BorderSide(
                        color:
                            _likeColors[likeStatus.likeStatus < 0 ? -1 : 0])),
                child: const Text('Nie lubię'),
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                    primary: _likeColors[0],
                    side: BorderSide(color: _likeColors[0])),
                child: const Text('Lubię to'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                    primary: _likeColors[0],
                    side: BorderSide(color: _likeColors[0])),
                child: const Text('Nie lubię'),
              ),
            ],
          );
        }
      });
}

String _getRecordingLength(RecordingSimpleDTO recording) {
  if (recording.length == null) {
    return '\n  • unknown';
  } else {
    return '\n  • ${recording.getLengthMinutes().toString()} min. '
        '${recording.getLengthRemainingSeconds().toString()} sek.';
  }
}

Widget _getRecordingArtists(BuildContext context, int recordingId) {
  Future<http.Response> _fetchArtists() async {
    final Uri url = Uri.parse('${ApiEndpoints.recordingDetails}$recordingId/');
    final Future<http.Response> response =
        http.get(url, headers: <String, String>{
      HttpHeaders.authorizationHeader: context.watch<Auth>().accessToken,
    });
    return response;
  }

  return FutureBuilder<http.Response>(
      future: _fetchArtists(),
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data.statusCode == 200) {
            if (snapshot.data.body.runtimeType == String) {
              final List<Widget> artists = <Widget>[];
              final dynamic content =
                  jsonDecode(utf8.decode(snapshot.data.body.runes.toList()));
              for (final dynamic a in content['artists_list']) {
                final ArtistSimpleDTO artist =
                    ArtistSimpleDTO(a['id'] as int, a['stage_name'] as String);

                artists.add(Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    // tileColor: const Color(0xff3b3c45),
                    leading: const Icon(
                      Icons.person,
                      // color: Color(0xffbbebff),
                      color: Color(0xffffd485),
                    ),
                    title: Text(
                      artist.stageName,
                    ),
                    visualDensity: const VisualDensity(vertical: -4),
                    minVerticalPadding: 10,
                    horizontalTitleGap: 10,
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed('/artist', arguments: artist);
                    },
                  ),
                ));
              }

              return Column(
                children: artists,
              );
            } else {
              return buildAsyncLoadingErrorMessage(
                  'Nie uzyskano danych z serwera...');
            }
          } else {
            return buildAsyncLoadingErrorMessage(
                'Nie udało się połączyć z serwerem...');
          }
        } else {
          return const CircularProgressIndicator();
        }
      });
}
