import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

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
        primarySwatch: Colors.lightBlue
      ),
      title: 'Musicly',
      home: const MyHomePage(title: 'Well, this is some kind of a title...'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentNavBarIndex = 0;

  void onNavBarTapped(int index) {
    setState(() {
      _currentNavBarIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282B32),
      // resizeToAvoidBottomInset: false,
      body: Stack(
        // fit: StackFit.expand,
        children: <Widget> [
          AppPageBody(pageIndex: _currentNavBarIndex,),
          buildFloatingSearchBar(),
        ]
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildBottomNavigationBar() {
    return SizedBox(
      height: 50,
      child: BottomNavigationBar(
        unselectedFontSize: 11,
        selectedFontSize: 11,
        selectedItemColor: const Color(0xFF87DBEA),
        unselectedItemColor: const Color(0xFFA0A3A3),
        backgroundColor: const Color(0xFF33353D),
        currentIndex: _currentNavBarIndex,
        onTap: onNavBarTapped,
        type: BottomNavigationBarType.fixed,
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
            icon: Icon(Icons.favorite),
            label: 'Favorites'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings'
          ),
        ],
      ),
    );
  }
  Widget buildFloatingSearchBar() {
    final bool isPortrait =
      MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      // hint: 'Search...',
      height: 40,
      borderRadius: const BorderRadius.all(Radius.circular(100)),
      margins: EdgeInsets
          .fromLTRB(20, MediaQuery.of(context).viewPadding.top, 20, 0),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 400),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      // debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      actions: <FloatingSearchBarAction> [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        )
      ],
      transition: CircularFloatingSearchBarTransition(),
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Material(
            color: const Color(0xFF3C3C42),
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: Colors.accents.map((Color color) {
                return Container(height: 48, color: color);
              }).toList(),
            ),
          )
        );
      }
    );
  }
}

class AppPageBody extends StatelessWidget {
  const AppPageBody({Key key, @required this.pageIndex}) : super(key: key);
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final List<String> headlines = <String> [
      'Hello world!',
      'Music for you',
      'Favorites',
      'Settings',
    ];
    final List<Widget> applicationPages = <Widget> [
      const HomePage(),
      Text(
        'Music',
        style: GoogleFonts.lobsterTwo(),
      ),
      Text(
        'Favorites',
        style: GoogleFonts.lobsterTwo(),
      ),
      Text(
        'Settings',
        style: GoogleFonts.lobsterTwo(),
      ),
    ];
    
    return ListView(
      children: <Widget> [
        Padding( // headline
          padding: const EdgeInsets.fromLTRB(15, 15, 10, 10),
          child: RichText(
            text: TextSpan(
              text: headlines.elementAt(pageIndex),
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
        applicationPages.elementAt(pageIndex),
      ]
    );
  }
}

class SearchBar extends StatefulWidget {
  String _searchPhrase;
  List<String> _searchHistory;
  List<String> filteredSearchHistory;
  String _selectedPhrase;
  int historyLength = 20;

  List<String> filterSearchHistory() {
    if(_searchPhrase != null) {
      return _searchHistory.reversed
          .where((String element) => element.contains(_searchPhrase))
          .toList();
    } else {
      return _searchHistory.reversed.toList();
    }
  }
  
  void addSearchPhrase(String searchTerm) {
    if (searchTerm == null || searchTerm == '') return;
    if (_searchHistory.contains(searchTerm)) {
      _searchHistory.remove(searchTerm);
    }
    _searchHistory.add(searchTerm);
    if(_searchHistory.length > historyLength) {
      _searchHistory.removeRange(0, _searchHistory.length - historyLength);
    }

    filteredSearchHistory = filterSearchHistory();
  }

  void deleteSearchPhrase(String phrase) {
    _searchHistory.removeWhere((String element) => element == phrase);
    filteredSearchHistory = filterSearchHistory();
  }

  void putSearchPhraseFirst(String phrase) {
    deleteSearchPhrase(phrase);
    addSearchPhrase(phrase);
  }

  void initState() {
    filteredSearchHistory = filterSearchHistory();
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }


}

class HomePage extends StatelessWidget {
  const HomePage();

  @override
  Widget build(BuildContext context) {
    return Column( // content
      children: <Widget> [
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