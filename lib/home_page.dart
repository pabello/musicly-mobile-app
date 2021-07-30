import 'package:flutter/material.dart';
// import 'package:musicly_app/main.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView( // content
      children: <Widget> [
        Padding( // headline
          padding: const EdgeInsets.fromLTRB(25, 20, 10, 20),
          child: RichText(
            text: TextSpan(
              text: 'Dzień dobry',
              style: GoogleFonts.lobsterTwo(fontSize: 30),
            ),
          )
        ),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const <HomeScreenPanelOption> [
              HomeScreenPanelOption(
                imageAsset: AssetImage('assets/images/rekomendacje.jpg'),
                caption: 'Polecane',
              ),
              HomeScreenPanelOption(
                imageAsset: AssetImage('assets/images/playlisty.jpg'),
                caption: 'Playlisty',
              ),
            ],
          ),
        ),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const <HomeScreenPanelOption> [
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
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const <HomeScreenPanelOption> [
              HomeScreenPanelOption(
                imageAsset: AssetImage('assets/images/rekomendacje.jpg'),
                caption: 'Polecane',
              ),
              HomeScreenPanelOption(
                imageAsset: AssetImage('assets/images/playlisty.jpg'),
                caption: 'Playlisty',
              ),
            ],
          ),
        ),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const <HomeScreenPanelOption> [
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
      ]
    );
  }
}

class HomeScreenPanelOption extends StatelessWidget {
  const HomeScreenPanelOption({
    @required this.imageAsset,
    @required this.caption,
  });

  final AssetImage imageAsset;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double tileRatio = 0.3333;

    return Container(
      color: const Color(0xFF1F242A),
      margin: EdgeInsets.all(screenWidth * tileRatio * .05),
      padding: EdgeInsets.all(screenWidth * tileRatio * .08),
      child: Column(
        children: <Widget> [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10)
            ),
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
    );
  }
}