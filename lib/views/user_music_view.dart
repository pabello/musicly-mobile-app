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

class UserMusicViewPage extends StatefulWidget {
  const UserMusicViewPage({this.data});

  final Object data;

  @override
  _UserMusicViewPageState createState() => _UserMusicViewPageState();
}

class _UserMusicViewPageState extends State<UserMusicViewPage> {
  @override
  Widget build(BuildContext context) {
    Future<http.Response> _fetchUserMusic(String likeStatus) {
      final Map<String, String> filters = <String, String>{
        'chronological_order': 'desc',
        'like_status': likeStatus,
      };
      final Uri url = Uri.parse(ApiEndpoints.userMusicList);
      final Future<http.Response> future = http.post(url,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: context.watch<Auth>().accessToken,
            HttpHeaders.contentTypeHeader: 'application/json'
          },
          body: jsonEncode(filters));
      return future;
    }

    final ScrollController _scrollController = ScrollController();
    final String likeStatus = widget.data as String;
    String emptyListErrorMessage, pageTitle;
    Icon icon;
    if (likeStatus == 'like') {
      icon = const Icon(Icons.thumb_up_outlined, color: Color(0xff93ec7d));
      emptyListErrorMessage = 'Nie masz jeszcze żadnych polubionych utworów.';
      pageTitle = 'Lubiane utwory';
    } else {
      if (likeStatus == 'dislike') {
        icon = Icon(Icons.thumb_down_outlined, color: Colors.red.shade300);
        emptyListErrorMessage =
            'Nie masz jeszcze żadnych nielubionych utworów.';
        pageTitle = 'Nielubiane utwory';
      }
    }
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
            future: _fetchUserMusic(likeStatus),
            builder:
                (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data.statusCode == 200) {
                  final dynamic content = jsonDecode(
                      utf8.decode(snapshot.data.body.runes.toList()));
                  if (content.length as int > 0) {
                    final List<Widget> recordingList = <Widget>[];
                    for (final dynamic element in content) {
                      final RecordingSimpleDTO recordingDTO =
                          RecordingSimpleDTO(
                              element['recording_id'] as int,
                              element['recording_title'].toString(),
                              element['recording_length'] as int);
                      recordingList.add(Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: ListTile(
                          leading: icon,
                          title: Text(recordingDTO.title),
                          trailing: const Icon(Icons.arrow_forward),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -2.5),
                          horizontalTitleGap: 12,
                          onTap: () async {
                            await Navigator.of(context).pushNamed('/recording',
                                arguments: recordingDTO);
                            setState(() {});
                          },
                        ),
                      ));
                    }
                    return Column(children: <Widget>[...recordingList]);
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

    // return ListView(
    //   padding: EdgeInsets.fromLTRB(20, stateBarHeight + 10, 20, 10),
    //   controller: _scrollController,
    //   children: <Widget>[
    //     Padding(
    //       padding: const EdgeInsets.fromLTRB(5, 10, 0, 15),
    //       child: Text("Lubiane utwory",
    //           style: Theme.of(context).textTheme.headline1),
    //     ),
    // FutureBuilder<http.Response>(
    //   future: _fetchUserMusic(),
    //   builder:
    //       (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       if (snapshot.data.statusCode == 200) {
    //         final dynamic content =
    //             jsonDecode(utf8.decode(snapshot.data.body.runes.toList()));
    //         if (content.length as int > 0) {
    //           List<Widget> recordingList;
    //           for (final dynamic element in content) {
    //             final RecordingSimpleDTO recordingDTO = RecordingSimpleDTO(
    //                 element['recording_id'] as int,
    //                 element['recording_title'].toString(),
    //                 element['recording_length'] as int);
    //             recordingList.add(Padding(
    //               padding: const EdgeInsets.symmetric(vertical: 1),
    //               child: ListTile(
    //                 leading: icon,
    //                 title: Text(recordingDTO.title),
    //                 trailing: const Icon(Icons.arrow_forward),
    //                 dense: true,
    //                 visualDensity: const VisualDensity(vertical: -2.5),
    //                 horizontalTitleGap: 12,
    //                 onTap: () {
    //                   Navigator.of(context)
    //                       .pushNamed('/recording', arguments: recordingDTO);
    //                 },
    //               ),
    //             ));
    //           }
    //           return Column(children: <Widget>[...recordingList]);
    //         } else {
    //           return buildAsyncLoadingErrorMessage(emptyListErrorMessage);
    //         }
    //       } else {
    //         return buildAsyncLoadingErrorMessage(
    //             'Nie udało się połączyć z serwerem...');
    //       }
    //     } else {
    //       return const CircularProgressIndicator();
    //     }
    //   },
    // ),
    //     Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    //       Center(
    //         child: TextButton(
    //           onPressed: () => _scrollController.animateTo(0,
    //               duration: const Duration(milliseconds: 800),
    //               curve: Curves.easeInOut),
    //           // style: Theme.of(context).textButtonTheme.style,
    //           child: const Padding(
    //             padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
    //             child: Text('Do góry'),
    //           ),
    //         ),
    //       ),
    //     ]),
    //   ],
    // );
  }
}
