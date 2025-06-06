import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onUndo,
    bool showUndo = true,
  }) {
    late Flushbar<dynamic> flush;
    flush = Flushbar<dynamic>(
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      flushbarPosition: FlushbarPosition.BOTTOM,
      backgroundColor: Colors.black87,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      duration: duration,
      mainButton: showUndo
          ? TextButton(
              onPressed: () {
                flush.dismiss();
                onUndo?.call();
              },
              child: const Text(
                'Undo',
                style: TextStyle(color: Colors.yellow),
              ),
            )
          : null,
      onTap: (bar) {
        bar.dismiss();
      },
    );

    flush.show(context);
  }
}
