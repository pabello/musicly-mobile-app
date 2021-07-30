import 'package:flutter/material.dart';
import 'package:musicly_app/main.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            children: <Widget>[
              RichText(text: const TextSpan(
                text: 'Wyszukaj artystów/utwory',
              )),
              ...previousSearches()
            ],
          ),
          buildFloatingSearchBar(context),
        ],
      ),
    );
  }

  List<ListTile> previousSearches() {
    List<ListTile> listTiles = <ListTile>[];
    previousSearchesStatic.forEach((element) {
      listTiles.add(ListTile(
        leading: Icon(Icons.account_circle_outlined),
        title: Text(element),
        subtitle: Text('Artist'),
        // Todo: defferentiate artists from recordings
        trailing: Icon(Icons.highlight_remove),
      ));
    });
    return listTiles;
  }

  List<String> previousSearchesStatic = <String>[
    'U2',
    'ACDC',
    'Kwiat jabłoni',
    'Łydka grubasa',
    'Rammstein',
    'Iron Maiden',
    'Led Zeppelin'
  ];

  Widget buildFloatingSearchBar(BuildContext context) {
      final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

      return FloatingSearchBar(
        // hint: 'Search...',
        height: 40,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        margins: EdgeInsets
            .fromLTRB(20, MediaQuery.of(context).viewPadding.top + 10, 20, 0),
        scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
        transitionDuration: const Duration(milliseconds: 400),
        transitionCurve: Curves.easeInOut,
        transition: CircularFloatingSearchBarTransition(),
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