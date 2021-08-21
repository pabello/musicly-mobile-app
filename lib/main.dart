import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:musicly_app/views/favorites_page.dart';
import 'package:musicly_app/views/home_page.dart';
import 'package:musicly_app/route_generator.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:musicly_app/views/search_page.dart';
import 'package:musicly_app/views/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:musicly_app/providers/auth_provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => Auth(),
    )
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          backgroundColor: const Color(0xFF282B32),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: const Color(0xFF33353D),
            selectedItemColor: Colors.lightBlueAccent.shade100,
            unselectedItemColor: Colors.grey.shade400,
          ),
          appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xff3b3c45),
              iconTheme: IconThemeData(
                color: Color(0xffffd485),
              )),
          accentColor: Colors.lightBlue.shade300,
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(primary: Colors.lightBlue.shade100)),
          // selectedItemColor: const Color(0xFF87DBEA),
          brightness: Brightness.dark,
          snackBarTheme: const SnackBarThemeData(
            contentTextStyle: TextStyle(color: Colors.white),
            backgroundColor: Color(0xFF4D4D50),
            // backgroundColor: Color(0xFF3B3C45),
            behavior: SnackBarBehavior.floating,
          ),
          textTheme: TextTheme(
            headline1:
                GoogleFonts.lobsterTwo(fontSize: 30, color: Colors.white),
            headline2:
                GoogleFonts.lobsterTwo(fontSize: 24, color: Colors.white),
            headline3:
                GoogleFonts.lobsterTwo(fontSize: 22, color: Colors.white),
            headline4:
                GoogleFonts.lobsterTwo(fontSize: 20, color: Colors.white),
            headline5: GoogleFonts.comfortaa(
                fontSize: 17, color: Colors.white, letterSpacing: -.5),
            subtitle1: GoogleFonts.comfortaa(fontSize: 13, color: Colors.white),
            subtitle2: GoogleFonts.comfortaa(
                fontSize: 12, color: const Color(0xffffd485)),
            bodyText1: GoogleFonts.comfortaa(fontSize: 13, color: Colors.white),
            bodyText2: GoogleFonts.comfortaa(
                fontSize: 10, color: const Color(0xffffd485)),
            button: GoogleFonts.comfortaa(
                fontSize: 12,
                color: Colors.lightBlueAccent.shade100,
                letterSpacing: -1),
          )),
      // title: 'Musicly',
      themeMode: ThemeMode.dark,
      home: const ApplicationMainView(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class ApplicationMainView extends StatefulWidget {
  const ApplicationMainView({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<ApplicationMainView> createState() => _ApplicationMainView();
}

class _ApplicationMainView extends State<ApplicationMainView> {
  int _currentPageIndex = 0;
  List<Widget> pageList = <Widget>[
    HomePage(),
    SearchPage(),
    FavoritesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: pageList[_currentPageIndex],
      bottomNavigationBar: buildBottomNavBar(),
      // resizeToAvoidBottomInset: false,
    );
  }

  void onNavBarTapped(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  Widget buildBottomNavBar() {
    // indexHistory = <int>[widget.currentNavBarIndex];
    // BackButtonInterceptor.add(myInterceptor);
    return SizedBox(
      height: 50,
      child: BottomNavigationBar(
        unselectedFontSize: 11,
        selectedFontSize: 11,
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        currentIndex: _currentPageIndex,
        onTap: onNavBarTapped,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key key, this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _currentNavBarIndex = 0;
//
//   void onNavBarTapped(int index) {
//     setState(() {
//       _currentNavBarIndex = index;
//       FloatingSearchBarAction.searchToClear();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF282B32),
//       // resizeToAvoidBottomInset: false,
//       body: Stack(
//         // fit: StackFit.expand,
//         children: <Widget> [
//           AppPageBody(pageIndex: _currentNavBarIndex,),
//           buildFloatingSearchBar(),
//         ]
//       ),
//       bottomNavigationBar: buildBottomNavigationBar(),
//     );
//   }

//   Widget buildBottomNavigationBar() {
//     return SizedBox(
//       height: 50,
//       child: BottomNavigationBar(
//         unselectedFontSize: 11,
//         selectedFontSize: 11,
//         selectedItemColor: const Color(0xFF87DBEA),
//         unselectedItemColor: const Color(0xFFA0A3A3),
//         backgroundColor: const Color(0xFF33353D),
//         currentIndex: _currentNavBarIndex,
//         onTap: onNavBarTapped,
//         type: BottomNavigationBarType.fixed,
//         items: const <BottomNavigationBarItem> [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home'
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.audiotrack_sharp),
//             label: 'Search'
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.favorite),
//             label: 'Favorites'
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings'
//           ),
//         ],
//       ),
//     );
//   }
//
//
// }

// class AppPageBody extends StatelessWidget {
//   const AppPageBody({Key key, @required this.pageIndex}) : super(key: key);
//   final int pageIndex;
//
//   @override
//   Widget build(BuildContext context) {
//     final List<String> headlines = <String> [
//       'Hello world!',
//       'Search',
//       'Favorites',
//       'Settings',
//     ];
//     final List<Widget> applicationPages = <Widget> [
//       const HomePage(),
//       Text(
//         'Search',
//         style: GoogleFonts.lobsterTwo(),
//       ),
//       Text(
//         'Favorites',
//         style: GoogleFonts.lobsterTwo(),
//       ),
//       Text(
//         'Settings',
//         style: GoogleFonts.lobsterTwo(),
//       ),
//     ];
//
//     return ListView(
//       children: <Widget> [
//         Padding( // headline
//           padding: const EdgeInsets.fromLTRB(15, 15, 10, 10),
//           child: RichText(
//             text: TextSpan(
//               text: headlines.elementAt(pageIndex),
//               style: GoogleFonts.lobsterTwo(fontSize: 30),
//             ),
//           )
//         ),
//         Padding(
//           padding: const EdgeInsets.fromLTRB(20, 0, 20,20),
//           child: Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: const Color(0xFF3C3C42),
//                 borderRadius: BorderRadius.circular(999),
//                 border: Border.all(
//                   color: const Color(0xFF24242A),
//                   width: 2,
//                 ),
//               ),
//               height: 40,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: <Widget> [
//                     Expanded(
//                       child: Text(
//                         'Wyszukaj...',
//                         style: GoogleFonts.comfortaa(
//                           color: const Color(0xFFA0A3A3),
//                           fontWeight: FontWeight.bold
//                         ),
//                       ),
//                     ),
//                     const Icon(
//                       Icons.search,
//                       color: Color(0xFFA0A3A3),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ),  // SearchBar
//         IndexedStack(
//           index: pageIndex,
//           children: applicationPages,
//         )
//       ]
//     );
//   }
// }

class SearchBar extends StatefulWidget {
  String _searchPhrase;
  List<String> _searchHistory;
  List<String> filteredSearchHistory;
  String _selectedPhrase;
  int historyLength = 20;

  List<String> filterSearchHistory() {
    if (_searchPhrase != null) {
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
    if (_searchHistory.length > historyLength) {
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
