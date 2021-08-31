import 'package:flutter/material.dart';

class NavBarState extends ChangeNotifier {
  int _currentPageIndex = 0;

  int get currentPageIndex => _currentPageIndex;
  set currentPageIndex(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }
}