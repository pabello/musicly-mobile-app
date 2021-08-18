import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicly_app/dto_classes.dart';
import 'package:http/http.dart' as http;
import 'package:musicly_app/api_endpoints.dart';

class RecordingViewPage extends StatelessWidget {
  /*const*/ RecordingViewPage({@required this.data});

  final Object data;

  @override
  Widget build(BuildContext context) {
    RecordingSimpleDTO recording = data as RecordingSimpleDTO;
    // print(data);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recording.title,
          style: GoogleFonts.comfortaa(fontSize: 17, letterSpacing: -.5),
        ),
        titleSpacing: 5,
      ),
      backgroundColor: Theme
          .of(context)
          .backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
                text: TextSpan(children: <TextSpan>[
                  TextSpan(text: recording.title),
                  TextSpan(
                      text: '\n • ${recording.getLengthMinutes()
                          .toString()} min. '
                          '${recording.getLengthRemainingSeconds()
                          .toString()} sek.'),
                ])),
            const SizedBox(width: 30),
            Text(
              'Wykonawcy',
              style: GoogleFonts.comfortaa(),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: _getRecordingArtists(recording.id)
            ),
          ],
        ),
      ),
    );
  }

  Widget _getRecordingArtists(int recordingId) {
    Future<http.Response> _fetchArtists() async {
      final Uri url = Uri.parse('${ApiEndpoints.recordingDetails}/$recordingId/');
      final Future<http.Response> response =
      http.get(url, headers: <String, String>{
        HttpHeaders.authorizationHeader:
        'Token fc0b909da04d1c61c619d65405e0a62b659a1e35',
      });
      print(response);
      return response;
    }

    _fetchArtists();
    // TODO return widget
  }
}
