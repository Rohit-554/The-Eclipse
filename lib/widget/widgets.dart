import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomWidgets {
  void showSnackBar({
    required BuildContext context,
    required String message,
    int duration = 1,
    Color color = Colors.green,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.spaceGrotesk(
        textStyle:  TextStyle(
        color: Colors.grey[100],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
        ),
        backgroundColor: Color(0xff222222),
        duration: Duration(seconds: duration),
        showCloseIcon: true,
      ),
    );
  }
}




class ConfirmationDialog extends StatelessWidget {
  final BuildContext context;
  final String title;
  final VoidCallback onClick;

  const ConfirmationDialog({
    required this.context,
    required this.title,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: Text(
        title,
        style: GoogleFonts.spaceGrotesk(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Text(
        title,
        style: GoogleFonts.spaceGrotesk(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            "Cancel",
            style: GoogleFonts.spaceGrotesk(
              textStyle: const TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onPressed: () {
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pop();
            });
          },
        ),
        TextButton(
          child: Text(
            "Continue",
            style: GoogleFonts.spaceGrotesk(
              textStyle: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onPressed: () {
            Future.delayed(Duration.zero, () {
              onClick();
              Navigator.of(context).pop();
            });

          },
        ),
      ],
    );

  }

}



