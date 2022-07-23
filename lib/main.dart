import 'dart:async';
import 'dart:io';

import 'package:docge/Services/firebase/database.dart';
import 'package:docge/screens/authentication/login.dart';
import 'package:docge/screens/home/home_user.dart';
import 'package:docge/screens/wrapper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Services/firebase/auth.dart';
import 'models/AppUser.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  //FlutterDownloader.registerCallback(callbackDownloader);
  String apiKey= "";
  String appId = "";
   if(kIsWeb){
    apiKey = "AIzaSyDfyKXfsPZV9KEXnwjWwrTAi1HkYrm6d-4";
    appId = "1:821643388605:web:720ac047e271acf2e9b9d4";
  }
  if(!apiKey.isEmpty && !appId.isEmpty){
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: apiKey,
            appId: appId,
            messagingSenderId: "821643388605",
            projectId: "docge-2051c",
            storageBucket: "docge-2051c.appspot.com",
            databaseURL: "https://docge-2051c-default-rtdb.europe-west1.firebasedatabase.app/"
        )
    );
  }
  else{
    await Firebase.initializeApp();
  }
  await DatabaseService().getUsers();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    const int _blackPrimaryValue = 0xFF000000;
    const MaterialColor primaryBlack = MaterialColor(
      _blackPrimaryValue,
      <int, Color>{
        50: Color(0xFF000000),
        100: Color(0xFF000000),
        200: Color(0xFF000000),
        300: Color(0xFF000000),
        400: Color(0xFF000000),
        500: Color(_blackPrimaryValue),
        600: Color(0xFF000000),
        700: Color(0xFF000000),
        800: Color(0xFF000000),
        900: Color(0xFF000000),
      },
    );

    return StreamProvider<AppUser?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'DocGe',

        theme: ThemeData(

          primarySwatch: primaryBlack,
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
          ),
        ),
        home: Wrapper()
      ),
    );
  }
}
