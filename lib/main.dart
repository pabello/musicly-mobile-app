import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        primarySwatch: Colors.blue,

      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green
      ),
      title: 'Musicly',
      home: MyHomePage(title: 'Hi! How are you?'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // Fields in a Widget subclass are always marked "final".
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override  // dzieki temu nadpisaniu metody UI sie uaktualnia?
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF282B32),
        ),
        child: ListView(
            children: <Widget> [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 10, 10),
                child: RichText(
                  text: TextSpan(
                    text: 'Hello world!',
                    style: GoogleFonts.lobsterTwo(fontSize: 30),
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20,20),
                child: Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF3C3C42),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF24242A),
                        width: 2,
                      ),
                    ),
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: <Widget> [
                          Expanded(
                            child: Text(
                              'Wyszukaj...',
                              style: GoogleFonts.comfortaa(
                                color: const Color(0xFFA0A3A3),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.search,
                            color: Color(0xFFA0A3A3),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <HomescreenPanelOption> [
                    HomescreenPanelOption(
                      imageAsset: const AssetImage('assets/images/rekomendacje.jpg'),
                      caption: 'Polecane',
                    ),
                    HomescreenPanelOption(
                      imageAsset: const AssetImage('assets/images/playlisty.jpg'),
                      caption: 'Playlisty',
                    ),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <HomescreenPanelOption> [
                    HomescreenPanelOption(
                      imageAsset: const AssetImage('assets/images/utwory.jpg'),
                      caption: 'Utwory',
                    ),
                    HomescreenPanelOption(
                      imageAsset: const AssetImage('assets/images/zespol.jpg'),
                      caption: 'Zespoły',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  shrinkWrap: true,
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: <Widget> [
                    Container(
                      color: Colors.green,
                      child: Text('whatever'),
                    ),
                    Container(
                      color: Colors.green,
                      child: Text('whatever'),
                    ),
                    Container(
                      color: Colors.green,
                      child: Text('whatever'),
                    ),
                    Container(
                      color: Colors.green,
                      child: Text('whatever'),
                    ),
                    Container(
                      color: Colors.green,
                      child: Text('whatever'),
                    ),
                    Container(
                      color: Colors.green,
                      child: Text('whatever'),
                    ),
                  ]
                ),
              )
            ],
          ),
      ),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: BottomNavigationBar(
          unselectedFontSize: 11,
          selectedFontSize: 11,
          fixedColor: const Color(0xFF87DBEA),
          unselectedItemColor: const Color(0xFFA0A3A3),
          backgroundColor: const Color(0xFF33353D),
          items: const <BottomNavigationBarItem> [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.audiotrack_sharp),
              label: 'Music for you'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings'
            )
          ],
        ),
      ),
    );
  }
}

class AppBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(1.7, -2.8),
              colors: <Color> [
                Color(0xFF1075F5),
                Color(0xFF191E23)
              ],
              radius: 2,
              stops: <double> [
                .7,
                1
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Square extends StatelessWidget {
  const Square({ this.color = Colors.black, this.size = 100.0});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: color,

      child: Align(
          alignment: Alignment.bottomCenter,
        child: Container(color: Colors.green, width: 20, height: 20)
      )
    );
  }
}

class HomescreenPanelOption extends StatelessWidget {
  const HomescreenPanelOption({
    this.imageAsset,
    this.caption,
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