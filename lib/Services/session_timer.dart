import 'dart:async';

import 'package:docge/screens/authentication/login.dart';
import 'package:flutter/material.dart';

class SessionTimer {
  late Timer timer;
  void startTimer() {
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      timedOut();
    });
  }

  void userActivityDetected([_]) {
    if (!timer.isActive) {
      timer.cancel();
      startTimer();
    }
    return;
  }

  Future<void> timedOut() async {
    timer.cancel();
    // await showDialog(
    //   context: navigatorKey.currentState.overlay.context,
    //   barrierDismissible: false,
    //   builder: (context) => new AlertDialog(
    //     title: new Text('Alert'),
    //     content:
    //     Text('Sorry but you have been logged out due to inactivity...'),
    //     actions: <Widget>[
    //       new FlatButton(
    //         onPressed: () {
    //           Navigator.pushAndRemoveUntil<dynamic>(
    //             context,
    //             MaterialPageRoute<dynamic>(
    //               builder: (BuildContext context) => LogIn(),
    //             ),
    //                 (route) =>
    //             false,
    //           );
    //         },
    //         child: new Text('OK'),
    //       ),
    //     ],
    //   ),
    // );
  }
}