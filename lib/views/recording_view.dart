import 'dart:collection';
import 'dart:convert' show Encoding, jsonDecode, jsonEncode, utf8;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:musicly_app/dto_classes.dart';
import 'package:http/http.dart' as http;
import 'package:musicly_app/utils.dart';
import 'package:provider/provider.dart';
import 'package:musicly_app/api_endpoints.dart';
import 'package:musicly_app/providers/auth_provider.dart';
import 'package:musicly_app/errors.dart';
import 'package:musicly_app/views/playlist_list_view.dart' show fetchPlaylists;

class RecordingViewPage extends StatelessWidget {
  const RecordingViewPage({@required this.data});

  final Object data;

  @override
  Widget build(BuildContext context) {
    final RecordingSimpleDTO recording = data as RecordingSimpleDTO;
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
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: RichText(
                      text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: recording.title,
                        style: Theme.of(context).textTheme.headline1),
                    TextSpan(
                        text: _getRecordingLength(recording),
                        style: Theme.of(context).textTheme.subtitle2),
                  ])),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  transform: Matrix4.translationValues(0, -5, 0),
                  child: PopupMenuButton<Function>(
                    icon: const Icon(Entypo.dots_three_horizontal),
                    offset: const Offset(-12, 12),
                    onSelected: (Function function) => function(),
                    itemBuilder: (BuildContext context) {
                      final List<PopupMenuEntry<Function>> actions =
                          <PopupMenuEntry<Function>>[];
                      actions.add(PopupMenuItem<Function>(
                        value: () => choosePlaylistDialog(context, recording),
                        child: const Text('Dodaj do playlisty'),
                      ));
                      return actions;
                    },
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          LikeStatusButtons(context: context, recordingId: recording.id),
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

  void choosePlaylistDialog(
      BuildContext context, RecordingSimpleDTO recording) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return getPlaylistsDialogOptions(context, recording);
        });
  }
}

Widget getPlaylistsDialogOptions(
    BuildContext context, RecordingSimpleDTO recording) {
  return FutureBuilder<http.Response>(
      future: fetchPlaylists(context),
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        final List<SimpleDialogOption> dialogOptions = <SimpleDialogOption>[];
        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasError) {
            if (snapshot.data.statusCode == 200) {
              final dynamic content =
                  jsonDecode(utf8.decode(snapshot.data.bodyBytes));
              if (content.length > 0 != null) {
                for (final dynamic object in content) {
                  dialogOptions.add(SimpleDialogOption(
                    onPressed: () => addRecordingToPlaylist(
                        context, recording.id, object['id'] as int),
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          object['name'].toString(),
                          style: Theme.of(context).textTheme.subtitle2,
                        )),
                  ));
                }
                return SimpleDialog(
                  title: const Text('Wybierz playlistę'),
                  children: dialogOptions,
                );
              }
            } else if (snapshot.data.statusCode == 404) {
              showSnackBar(context, 'Nie posiadasz żadnych playlist...');
            } else {
              showSnackBar(context, 'Nie udało się połączyć z serwerem...');
            }
          } else {
            showSnackBar(context, 'Nie udało się połączyć z serwerem...');
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
        return const SizedBox();
      });
}

void addRecordingToPlaylist(
    BuildContext context, int recordingId, int playlistId) {
  final Map<String, int> data = <String, int>{
    'playlist_id': playlistId,
    'recording_id': recordingId
  };
  final Uri url = Uri.parse(ApiEndpoints.addToPlaylist);
  final Future<http.Response> future = http.post(url,
      headers: <String, String>{
        HttpHeaders.authorizationHeader:
            Provider.of<Auth>(context, listen: false).accessToken,
        HttpHeaders.contentTypeHeader: 'application/json'
      },
      body: jsonEncode(data));

  future.then((http.Response response) {
    Navigator.of(context).pop();
    if (response.statusCode == 201) {
      showSnackBar(context, 'Dodano utwór do playlisty');
    } else {
      showSnackBar(context, 'Nie udało się dodać utworu do playlisty');
    }
  }).onError((error, StackTrace stackTrace) {
    showSnackBar(context, 'Błąd połączenia z serwerem...');
  });
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
  final Map<int, Color> _likeColors = <int, Color>{
    -1: Colors.red.shade300,
    0: Colors.grey.shade500,
    1: const Color(0xff93ec7d),
  };

  void updateLikeStatus(int likeStatus) {
    setState(() {
      _likeStatus = likeStatus;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _fetchRecordingLikeStatus(context, widget.recordingId)
        .then((http.Response response) {
      if (response.statusCode == 200) {
        updateLikeStatus(
            int.parse(jsonDecode(response.body)['like_status'].toString()));
      } else if (response.statusCode != 404) {
        {
          _showSnackBar('Błąd połączenia z serwerem.');
        }
      }
    }).onError((Exception error, StackTrace stackTrace) {
      _showSnackBar('Nie można połączyć z serwerem. Spróbój ponownie później.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        OutlinedButton.icon(
          icon: const Icon(Icons.thumb_up_outlined),
          label: const Text('Lubię to'),
          onPressed: () => _likeButtonClick(_likeStatus == 1 ? 0 : 1),
          style: OutlinedButton.styleFrom(
              primary: _likeColors[_likeStatus > 0 ? 1 : 0],
              side: BorderSide(color: _likeColors[_likeStatus > 0 ? 1 : 0])),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () => _likeButtonClick(_likeStatus == -1 ? 0 : -1),
          style: OutlinedButton.styleFrom(
              primary: _likeColors[_likeStatus < 0 ? -1 : 0],
              side: BorderSide(color: _likeColors[_likeStatus < 0 ? -1 : 0])),
          child: Row(
            children: const <Widget>[
              Text('Nie lubię'),
              SizedBox(width: 8),
              Icon(Icons.thumb_down_outlined)
            ],
          ),
        ),
      ],
    );
  }

  Future<http.Response> _fetchRecordingLikeStatus(
      BuildContext context, int recordingId) {
    final Uri url = Uri.parse('${ApiEndpoints.musicReaction}$recordingId/');
    final Future<http.Response> future = http.get(url,
        headers: <String, String>{
          HttpHeaders.authorizationHeader: context.watch<Auth>().accessToken
        });
    return future;
  }

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

  void _showSnackBar(String message) {
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

  void _likeButtonClick(int likeStatus) {
    _setLikeStatus(widget.recordingId, likeStatus)
        .then((http.Response response) {
      if (response.statusCode == 200) {
        updateLikeStatus(likeStatus);
      } else if (response.statusCode == 500) {
        _showSnackBar(
            'Nie udało się zmienić oceny utworu. Spróbój ponownie później.');
      } else {
        _showSnackBar('Błąd połączenia z serwerem. Spróbój ponownie później.');
      }
    }).onError((Exception error, StackTrace stackTrace) {
      _showSnackBar('Nie można połączyć z serwerem. Spróbój ponownie później.');
    });
  }
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
          if (!snapshot.hasError && snapshot.data.statusCode == 200) {
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
