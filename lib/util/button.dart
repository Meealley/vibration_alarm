import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WatchButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const WatchButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Text(
          text,
          style: GoogleFonts.manrope(fontSize: 10),
        ),
      ),
    );
  }
}
