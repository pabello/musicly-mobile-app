import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        children: <Widget>[
          getFavoritesModule(context, FavoriteCategory.recording),
          getFavoritesModule(context, FavoriteCategory.artist),
          getFavoritesModule(context, FavoriteCategory.playlist),
        ],
      ),
    );
  }

  Widget getFavoritesModule(BuildContext context, FavoriteCategory type) {
    String header;
    Icon leadingIcon;
    List<String> listItems;

    switch(type) {
      case FavoriteCategory.artist:
        header = 'Lubiani artyści';
        leadingIcon = const Icon(Icons.person);
        listItems = getRecentFavorites();
        break;

      case FavoriteCategory.playlist:
        header = 'Twoje playlisty';
        leadingIcon = const Icon(Icons.list);
        listItems = getRecentFavorites();
        break;

      case FavoriteCategory.recording:
        header = 'Ulubione utwory';
        leadingIcon = const Icon(Icons.disc_full);
        listItems = getRecentFavorites();
        break;
    }

    return SizedBox(
      child: Column(children: <Widget>[
        RichText(
            text: TextSpan(
          text: header,
        )),
        ...getFavoritesListTiles(getRecentFavorites(), icon: leadingIcon),
        TextButton(
          onPressed: () => {print('Go to full list view on tap here')},
          style: Theme.of(context).textButtonTheme.style,
          child: const Text('Zobacz wszystkie'),
        ),
      ]),
    );
  }

  List<Widget> getFavoritesListTiles(List<String> items,
      {Icon icon = const Icon(Icons.adjust)}) {
    // Todo: check if final below causes issues with adding to list
    final List<ListTile> favorites = <ListTile>[];
    for (final String element in items) {
      favorites.add(ListTile(
        leading: icon,
        title: Text(element),
        trailing: const Icon(Icons.arrow_forward),
        dense: true,
      ));
    }
    return favorites;
  }

  List<String> getRecentFavorites() {
    // Todo: get list, reverse it, take x first elements / or take last x elements and then reverse
    return <String>['Taką wodą być', 'Let it go', 'Ale jazz'];
  }
}

enum FavoriteCategory {
  recording,
  artist,
  playlist,
}