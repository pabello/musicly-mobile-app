import 'package:flutter/material.dart';

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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
          gradient: RadialGradient(
            center: Alignment(.85, -1.4),
            colors: [
              Color(0xFF1075F5),
              Color(0xFF191E23),
            ],
            radius: 1.2,
            stops: [
              .35,
              .5
            ],
            // colors: [
            //   Color(0xFF1075F5),
            //   Color(0xFF191E23),
            // ],
            // radius: 2,
            // stops: [
            //   .7,
            //   1
            // ],
          ),
        ),
        child: Center(
          child: ListView(
            shrinkWrap: true,
              children: [
                // Container(
                //   child: RichText(
                //     text: TextSpan(
                //       text: 'Hello world!'
                //     ),
                //   )
                // ),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).padding.top,
                ),
                Placeholder(
                  fallbackHeight: 160,
                ),
                // IntrinsicHeight(
                //   child: Row(
                //     children: [
                //       HomescreenPanelOption(
                //         imageAsset: AssetImage('assets/images/rekomendacje.jpg'),
                //         caption: 'Polecane',
                //       ),
                //       HomescreenPanelOption(
                //         imageAsset: AssetImage('assets/images/playlisty.jpg'),
                //         caption: 'Playlisty',
                //       ),
                //     ],
                //   ),
                // ),
                // IntrinsicHeight(
                //   child: Row(
                //     children: [
                //       HomescreenPanelOption(
                //         imageAsset: AssetImage('assets/images/utwory.jpg'),
                //         caption: 'Utwory',
                //       ),
                //       HomescreenPanelOption(
                //         imageAsset: AssetImage('assets/images/zespol.jpg'),
                //         caption: 'Zespoły',
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  width: MediaQuery.of(context).size.width * .9,
                  height: 160,
                  color: Colors.blue,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * .9,
                  height: 160,
                  color: Colors.yellow,
                ),
                GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: <Widget>[
                    Container(
                      color: Colors.green,
                    ),
                    Container(
                      color: Colors.green,
                    )
                  ],

                  // children: [
                  //   Container(
                  //     width: 100,
                  //     height: 100,
                  //     color: Colors.green,
                  //     child: Text('whatever'),
                  //   ),
                  //   Container(
                  //     color: Colors.green,
                  //     child: Text('whatever'),
                  //   ),
                  //   Container(
                  //     color: Colors.green,
                  //     child: Text('whatever'),
                  //   ),
                  //   Container(
                  //     color: Colors.green,
                  //     child: Text('whatever'),
                  //   ),
                    // Card(
                    //   clipBehavior: Clip.antiAlias,
                    //   child: Column(
                    //     // crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       SizedBox(
                    //         child: Image(
                    //           image: AssetImage('assets/images/playlisty.jpg'),
                    //           fit: BoxFit.cover,
                    //         ),
                    //       ),
                    //       Container(
                    //         child: Padding(
                    //           padding: EdgeInsets.all(10),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Text(
                    //                 'Playlisty',
                    //                 style: Theme.of(context).textTheme.headline6
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                  // ]
                )
              ],
            ),
            // child: Container(
            //     height: 100,
            //     width: 100,
            //     color: Colors.green
            // ),
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

    TextStyle tileTextStyle = new TextStyle(
        fontSize: 14,
        color: Color(0xFFDBDFE0),
    );

    return Container(
      color: Color(0xFF1F242A),
      margin: EdgeInsets.all(screenWidth * tileRatio * .05),
      padding: EdgeInsets.all(screenWidth * tileRatio * .08),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
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
              style: tileTextStyle,
              maxLines: 1,
            ),
          )
        ],
      ),
    );
  }
}