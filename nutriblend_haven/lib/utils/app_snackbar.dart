import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shows a top-anchored snack bar.
/// [success] = true → green, false → red.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool success = true,
}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            success ? const Color(0xFF00A651) : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        // Top margin pushes it to the top of the screen
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).size.height - 120,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
}
