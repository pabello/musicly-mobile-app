import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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