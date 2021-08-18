import 'dart:convert' as convert;

// import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:musicly_app/api_endpoints.dart';

// import 'package:http/http.dart' as http;
import 'package:musicly_app/dto_classes.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  final GlobalKey recommendationsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ListView(// content
        children: <Widget>[
      Padding(
          // headline
          padding: const EdgeInsets.fromLTRB(25, 20, 10, 20),
          child: RichText(
            text: TextSpan(
              text: 'Dzień dobry',
              style: GoogleFonts.lobsterTwo(fontSize: 30),
            ),
          )),
      IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <HomeScreenPanelOption>[
            HomeScreenPanelOption(
              imageAsset: const AssetImage('assets/images/rekomendacje.jpg'),
              caption: 'Polecane',
              scrollPositionKey: recommendationsKey,
            ),
            const HomeScreenPanelOption(
              imageAsset: AssetImage('assets/images/playlisty.jpg'),
              caption: 'Playlisty',
            ),
          ],
        ),
      ),
      IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const <HomeScreenPanelOption>[
            HomeScreenPanelOption(
              imageAsset: AssetImage('assets/images/utwory.jpg'),
              caption: 'Utwory',
            ),
            HomeScreenPanelOption(
              imageAsset: AssetImage('assets/images/zespol.jpg'),
              caption: 'Zespoły',
            ),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              key: recommendationsKey,
              padding: const EdgeInsets.fromLTRB(25, 35, 10, 20),
              child: RichText(
                text: TextSpan(
                  text: 'Wybrane dla Ciebie',
                  style: GoogleFonts.lobsterTwo(fontSize: 30),
                ),
              )),
          getRecommendations(context),
        ],
      ),
    ]);
  }

  Widget getRecommendations(BuildContext context) {
    print('username: ${context.watch<Auth>().username}');
    print('token: ${context.watch<Auth>().accessToken}');
    Future<http.Response> _fetchRecommendations() async {
      final Uri url = Uri.parse(ApiEndpoints.recommendationList);
      final Future<http.Response> response =
          http.get(url, headers: <String, String>{
        HttpHeaders.authorizationHeader:
            context.watch<Auth>().accessToken,
      });
      return response;
    }

    return FutureBuilder<http.Response>(
        future: _fetchRecommendations(),
        builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.statusCode == 200) {
              if (snapshot.data.body.runtimeType == String) {
                final List<Widget> recommendations = <Widget>[];
                final dynamic content =
                    convert.jsonDecode(snapshot.data.body.toString());
                // final int listLength = content.;
                for (final dynamic r in content.sublist(0,)) {
                  final RecordingSimpleDTO recording = RecordingSimpleDTO(
                      r['id'] as int, r['title'] as String, r['length'] as int);

                  recommendations.add(Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                    child: ListTile(
                      // tileColor: Theme.of(context)
                      //     .bottomNavigationBarTheme
                      //     .backgroundColor,
                      tileColor: const Color(0xff3b3c45),
                      leading: const Icon(
                        Icons.disc_full,
                        // color: Color(0xffbbebff),
                        color: Color(0xffffd485),
                      ),
                      title: Text(
                        r['title'].toString(),
                        style: GoogleFonts.comfortaa(
                            color: Colors.white, fontSize: 13),
                      ),
                      subtitle: Text(
                        recording.lengthStringParse(),
                        style: GoogleFonts.comfortaa(
                            color: const Color(0xffffd485), fontSize: 10),
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
                  children: recommendations,
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

  Widget buildAsyncLoadingErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 30),
      child: Center(
          child: Text(
        message,
        style: GoogleFonts.comfortaa(fontSize: 12, color: Colors.white),
      )),
    );
  }
}

class HomeScreenPanelOption extends StatelessWidget {
  const HomeScreenPanelOption({
    @required this.imageAsset,
    @required this.caption,
    this.scrollPositionKey,
  });

  final AssetImage imageAsset;
  final String caption;
  final GlobalKey scrollPositionKey;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double tileRatio = 0.3333;

    return InkWell(
      onTap: () {
        if (scrollPositionKey != null) {
          Scrollable.ensureVisible(scrollPositionKey.currentContext,
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 300));
        }
      },
      child: Container(
        color: const Color(0xFF20252F),
        // color: const Color(0xFF1F242A),
        // color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        margin: EdgeInsets.all(screenWidth * tileRatio * .05),
        padding: EdgeInsets.all(screenWidth * tileRatio * .08),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              child: Image(
                image: imageAsset,
                width: screenWidth * tileRatio,
                height: screenWidth * tileRatio,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              width: screenWidth * tileRatio,
              child: Text(
                caption,
                style: GoogleFonts.comfortaa(
                  color: const Color(0xFFDBDFE0),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            )
          ],
        ),
      ),
    );
  }
}
