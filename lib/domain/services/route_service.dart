import 'dart:developer';

import 'package:flutter/material.dart';

class RouterService {
  static void router(BuildContext context, Widget widget) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  static void routeFade(
    BuildContext context,
    Widget widget, {
    Duration? duration,
  }) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: duration ?? Duration(milliseconds: 200),
        pageBuilder: (_, _, _) => widget,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    log("void routeFade", name: "RouterService");
  }

  static void routeCloseAll(BuildContext context, Widget widget) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => widget,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    log("void routeCloseAll", name: "RouterService");
  }

  static void back(BuildContext context) {
    Navigator.pop(context);
    log("void back", name: "RouterService");
  }
}
