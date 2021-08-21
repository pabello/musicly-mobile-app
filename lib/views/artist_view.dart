import 'dart:collection';
import 'dart:convert' show utf8, jsonDecode;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicly_app/dto_classes.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:musicly_app/api_endpoints.dart';
import 'package:musicly_app/providers/auth_provider.dart';
import 'package:musicly_app/errors.dart';

class ArtistViewPage extends StatelessWidget {
  /*const*/ ArtistViewPage({@required this.data});

  final Object data;

  @override
  Widget build(BuildContext context) {
    ArtistSimpleDTO artist = data as ArtistSimpleDTO;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          artist.stageName,
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
                text: artist.stageName,
                style: Theme.of(context).textTheme.headline1),
            // ?TODO? łączna liczba nagrań artysty?
          ])),
          const SizedBox(height: 20),
          Text(
            'Utwory',
            style: Theme.of(context).textTheme.headline3,
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: _getArtistRecordings(context, artist.id)),
        ],
      ),
    );
  }

  Widget _getArtistRecordings(BuildContext context, int artistId) {
    Future<http.Response> _fetchRecordings() async {
      final Uri url = Uri.parse('${ApiEndpoints.artistDetails}$artistId/');
      final Future<http.Response> response =
          http.get(url, headers: <String, String>{
        HttpHeaders.authorizationHeader: context.watch<Auth>().accessToken,
      });
      return response;
    }

    return FutureBuilder<http.Response>(
        future: _fetchRecordings(),
        builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.statusCode == 200) {
              if (snapshot.data.body.runtimeType == String) {
                final List<Widget> recordings = <Widget>[];
                final dynamic content =
                    jsonDecode(utf8.decode(snapshot.data.body.runes.toList()));
                for (final dynamic r in content['recordings']) {

                  final RecordingSimpleDTO recording = RecordingSimpleDTO(
                      r['id'] as int, r['title'] as String, r['length'] as int);

                  recordings.add(Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      leading: const Icon(
                        Icons.disc_full,
                        color: Color(0xffffd485),
                      ),
                      title: Text(
                        recording.title,
                      ),
                      subtitle: Text(
                        recording.lengthStringParse(),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      visualDensity: const VisualDensity(vertical: -4),
                      minVerticalPadding: 10,
                      horizontalTitleGap: 10,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed('/recording', arguments: recording);
                      },
                    ),
                  ));
                }

                return Column(
                  children: recordings,
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
}
