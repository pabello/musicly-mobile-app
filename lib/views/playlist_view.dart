import 'dart:convert' show Encoding, jsonDecode, jsonEncode, utf8;
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:musicly_app/dto_classes.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:musicly_app/api_endpoints.dart';
import 'package:musicly_app/providers/auth_provider.dart';
import 'package:musicly_app/errors.dart';
import 'package:musicly_app/utils.dart';

class PlaylistViewPage extends StatefulWidget {
  const PlaylistViewPage({@required this.data});

  final Object data;

  @override
  _PlaylistViewPageState createState() => _PlaylistViewPageState();
}

class _PlaylistViewPageState extends State<PlaylistViewPage> {
  List<RecordingSimpleDTO> playlistRecordings;
  TextEditingController _editingController;
  ScrollController scrollController;
  PlaylistSimpleDTO playlist;
  bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = false;
    scrollController = ScrollController();
    playlistRecordings = <RecordingSimpleDTO>[];
    playlist = widget.data as PlaylistSimpleDTO;
    _editingController = TextEditingController(text: playlist.name);
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isEditing) {
          setState(() {
            isEditing = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            playlist.name,
            style: Theme.of(context).textTheme.headline5,
          ),
          titleSpacing: 5,
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          children: <Widget>[
            Expanded(
              child: getPlaylistRecordings(),
            ),
          ],
        ),
        //   ],
        // )
      ),
    );
  }

  Widget getPlaylistRecordings() {
    return FutureBuilder<List<dynamic>>(
        future: _fetchPlaylistRecordings(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasError) {
              for (final dynamic object in snapshot.data) {
                playlistRecordings.add(RecordingSimpleDTO(
                    object['recording_id'] as int,
                    object['title'] as String,
                    object['length'] as int));
              }
              return ReorderableListView.builder(
                  // physics: const BouncingScrollPhysics(),
                  itemCount: snapshot.data.length as int,
                  scrollController: scrollController,
                  onReorder: (int oldIndex, int newIndex) {
                    _changePlaylistPosition(
                            snapshot.data[oldIndex]['association_id'] as int,
                            newIndex)
                        .then((http.Response response) {
                      if (response.statusCode == 200) {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        setState(() {
                          scrollController = ScrollController(
                              initialScrollOffset: scrollController.offset);
                          final RecordingSimpleDTO recording =
                              playlistRecordings[oldIndex];
                          playlistRecordings.removeAt(oldIndex);
                          playlistRecordings.insert(newIndex, recording);
                        });
                      } else {
                        showSnackBar(context,
                            'Nie udało się zmienić kolejności utworów.');
                      }
                    });
                  },
                  header: getPlaylistPageHeader(),
                  itemBuilder: (BuildContext context, int index) {
                    final int associationId =
                        snapshot.data[index]['association_id'] as int;
                    final RecordingSimpleDTO recording =
                        playlistRecordings[index];
                    return Padding(
                      key: ValueKey<int>(associationId),
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 20),
                      child: Stack(children: <Widget>[
                        ListTile(
                          contentPadding: const EdgeInsets.only(left: 16),
                          tileColor: const Color(0xff3b3c45),
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              Icon(
                                Icons.disc_full,
                                color: Color(0xffffd485),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                              icon: Icon(
                                FontAwesome.trash_o,
                                color: Colors.grey.shade400,
                              ),
                              onPressed: () => deleteRecordingDialog(
                                  recording, associationId, index)),
                          title: Text(recording.title),
                          visualDensity: const VisualDensity(vertical: -4),
                          minVerticalPadding: 10,
                          horizontalTitleGap: 0,
                        ),
                        Positioned.fill(
                          right: 48,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pushNamed('/recording',
                                    arguments: recording);
                              },
                            ),
                          ),
                        ),
                      ]),
                    );
                  });
            } else {
              return buildAsyncLoadingErrorMessage(snapshot.error.toString());
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Future<List<dynamic>> _fetchPlaylistRecordings() {
    final Uri url = Uri.parse('${ApiEndpoints.playlistDetails}${playlist.id}/');
    final Future<http.Response> future = http.get(url,
        headers: <String, String>{
          HttpHeaders.authorizationHeader: context.watch<Auth>().accessToken
        });
    final Future<List<dynamic>> futures = future.then((http.Response response) {
      if (response.statusCode == 200) {
        final List<dynamic> recordings = <dynamic>[];
        final dynamic content = jsonDecode(utf8.decode(response.bodyBytes));
        for (final dynamic object in content['recordings']) {
          recordings.add(object);
        }
        return recordings;
      } else if (response.statusCode == 404) {
        throw 'Ta playlista nie zawiera żadnych utworów...';
      } else {
        throw 'Błąd połączenia z serwerem...';
      }
    }).onError((dynamic error, StackTrace stackTrace) {
      throw 'Błąd połączenia z serwerem...';
    });
    return futures;
  }

  Widget getPlaylistPageHeader() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              getPlaylistEditableHeadline(),
              Text(_getPlaylistSubtitles(playlist),
                  style: Theme.of(context).textTheme.subtitle2),
              const SizedBox(height: 12),
              Text(
                'Utwory',
                style: Theme.of(context).textTheme.headline3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getPlaylistEditableHeadline() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
        Widget>[
      if (isEditing)
        SizedBox(
          width: 200,
          child: TextField(
            controller: _editingController,
            autofocus: true,
            onSubmitted: (String newName) async {
              await _setPlaylistName(newName).then((http.Response response) {
                if (response.statusCode == 200) {
                  setState(() {
                    playlist.name = newName;
                    isEditing = false;
                  });
                } else {
                  setState(() {
                    isEditing = false;
                  });
                  showSnackBar(
                      context, 'Nie udało się zmienić nazwy playlisty...');
                }
              });
            },
          ),
        )
      else
        Flexible(
          child:
              Text(playlist.name, style: Theme.of(context).textTheme.headline1),
        ),
      // const SizedBox(width: 4),
      SizedBox(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
                onPressed: () {
                  setState(() {
                    scrollController = ScrollController();
                    isEditing = true;
                  });
                },
                icon:
                    Icon(Feather.edit, size: 21, color: Colors.grey.shade400)),
            // const Spacer(),
            IconButton(
                splashColor: Colors.red.shade900,
                color: Colors.red.shade600,
                icon: const Icon(Feather.trash_2),
                onPressed: () => deletePlaylistDialog()),
          ],
        ),
      )
    ]);
  }

  Future<http.Response> _setPlaylistName(String newName) {
    final Map<String, String> data = <String, String>{'name': newName};
    final Uri url = Uri.parse('${ApiEndpoints.playlistDetails}${playlist.id}/');
    final Future<http.Response> future = http.patch(url,
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              Provider.of<Auth>(context, listen: false).accessToken,
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode(data));
    return future;
  }

  Future<http.Response> _changePlaylistPosition(
      int associationId, int newPosition) {
    final Map<String, int> data = <String, int>{'new_position': newPosition};
    final Uri url =
        Uri.parse('${ApiEndpoints.changePlaylistPosition}$associationId/');
    final Future<http.Response> future = http.patch(url,
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              Provider.of<Auth>(context, listen: false).accessToken,
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode(data));
    return future;
  }

  void deletePlaylistDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Uwaga!',
                  style: TextStyle(
                    color: Colors.red.shade400,
                  )),
              content: Text('Ta operacja jest nieodwracalna. '
                  'Czy napewno chcesz usunąć playlistę '
                  '${playlist.name}?'),
              actions: <TextButton>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Anuluj',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade400),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deletePlaylist().then((http.Response response) {
                      if (response.statusCode == 200) {
                        Navigator.of(context).pop();
                      } else {
                        showSnackBar(
                            context, 'Nie udało się usunąć playlisty.');
                      }
                    });
                  },
                  child: const Text('Usuń',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ],
            ));
  }

  Future<http.Response> _deletePlaylist() {
    final Uri url = Uri.parse('${ApiEndpoints.deletePlaylist}${playlist.id}/');
    final Future<http.Response> future =
        http.delete(url, headers: <String, String>{
      HttpHeaders.authorizationHeader:
          Provider.of<Auth>(context, listen: false).accessToken
    });
    return future;
  }

  void deleteRecordingDialog(
      RecordingSimpleDTO recording, int associationId, int playlistPosition) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Uwaga!',
                  style: TextStyle(
                    color: Colors.red.shade400,
                  )),
              content: Text('Czy napewno chcesz usunąć utwór '
                  '"${recording.title}" z tej playlisty?'),
              actions: <TextButton>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Anuluj',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade400),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _removeRecordingFromPlaylist(associationId)
                        .then((http.Response response) {
                      if (response.statusCode == 200) {
                        setState(() {
                          playlistRecordings.removeAt(playlistPosition);
                          playlist.length -= recording.length;
                          playlist.musicCount -= 1;
                          scrollController = ScrollController(
                              initialScrollOffset: scrollController.offset);
                        });
                      } else {
                        showSnackBar(context,
                            'Nie udało się usunąć utworu z playlisty.');
                      }
                    });
                  },
                  child: const Text('Usuń',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ],
            ));
  }

  Future<http.Response> _removeRecordingFromPlaylist(int associationId) {
    final Uri url =
        Uri.parse('${ApiEndpoints.deleteFromPlaylist}$associationId/');
    final Future<http.Response> future =
        http.delete(url, headers: <String, String>{
      HttpHeaders.authorizationHeader:
          Provider.of<Auth>(context, listen: false).accessToken
    });

    return future;
  }
}

String _getPlaylistSubtitles(PlaylistSimpleDTO playlist) {
  String output = '';
  if (playlist.length != null) {
    if (playlist.length > 0) {
      output += '\n  • ${playlist.lengthStringParse()}';
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
