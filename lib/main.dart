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
  MyHomePage({Key key, this.title}) : super(key: key);  // Co to sa za keye?

  // Fields in a Widget subclass are always marked "final".
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();  // To jest lacznik miedzy widgetem, a stanem, cnie?
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override  // dzieki temu nadpisaniu metody UI sie uaktualnia?
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    //\

    return Scaffold(  // czy tutaj jest opisane zachowanie dla kazdego elementu oddzielnie?
      // appBar: new AppBar(
      //   toolbarHeight: 0,
      // ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF282B32),
        ),
        child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: RichText(
                  text: TextSpan(
                    text: 'Hello world!',
                    style: GoogleFonts.lobsterTwo(fontSize: 30),
                  ),
                )
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20,20),
                child: Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3C42),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Color(0xFF24242A),
                        width: 2,
                      ),
                    ),
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Wyszukaj...",
                              style: GoogleFonts.comfortaa(
                                color: Color(0xFFA0A3A3),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Icon(
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
                  children: [
                    HomescreenPanelOption(
                      imageAsset: AssetImage('assets/images/rekomendacje.jpg'),
                      caption: 'Polecane',
                    ),
                    HomescreenPanelOption(
                      imageAsset: AssetImage('assets/images/playlisty.jpg'),
                      caption: 'Playlisty',
                    ),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    HomescreenPanelOption(
                      imageAsset: AssetImage('assets/images/utwory.jpg'),
                      caption: 'Utwory',
                    ),
                    HomescreenPanelOption(
                      imageAsset: AssetImage('assets/images/zespol.jpg'),
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
                  children: [
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
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class AppBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(1.7, -2.8),
              colors: [
                Color(0xFF1075F5),
                Color(0xFF191E23)
              ],
              radius: 2,
              stops: [
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
  final color;
  final size;

  Square({ this.color = Colors.black, this.size = 100.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.size,
      height: this.size,
      color: this.color,

      child: Align(
          alignment: Alignment.bottomCenter,
        child: Container(color: Colors.green, width: 20, height: 20)
      )
    );
  }
}

class HomescreenPanelOption extends StatelessWidget {
  final AssetImage imageAsset;
  final String caption;

  HomescreenPanelOption({
    this.imageAsset,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double tileRatio = 0.3333;

    return Container(
      color: Color(0xFF1F242A),
      margin: EdgeInsets.all(screenWidth * tileRatio * .05),
      padding: EdgeInsets.all(screenWidth * tileRatio * .08),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10)
            ),
            child: Image(
              image: this.imageAsset,
              width: screenWidth * tileRatio,
              height: screenWidth * tileRatio,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            width: screenWidth * tileRatio,
            child: Text(
              caption,
              style: GoogleFonts.comfortaa(
                color: Color(0xFFDBDFE0),
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