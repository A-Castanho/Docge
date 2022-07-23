import 'package:docge/Services/firebase/auth.dart';
import 'package:docge/Services/firebase/database.dart';
import 'package:docge/screens/authentication/login.dart';
import 'package:docge/screens/home/home_admin.dart';
import 'package:docge/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/session_timer.dart';
import '../models/AppUser.dart';
import 'home/home_user.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    DatabaseService _database = DatabaseService();

    //Return either Home or Authentication widget
    //Note: Changes dynamically
    if(user==null)
    {
      return LogIn();
    }
    else{
      return FutureBuilder(
        future: _database.isUserAdmin(user.uid),
        builder: (BuildContext context,
            AsyncSnapshot<bool> snapshot){
          if(snapshot.hasData){
              return (snapshot.data!)?HomeAdim() : HomeUser(user: user,);
          }
          else{
            print(user.uid);
            print(snapshot.data);
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Loading(status: "A iniciar"),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: (){
                        AuthService().signOut();
                      },
                      child: const Text("Cancelar",
                      style: TextStyle(
                          decoration: TextDecoration.underline
                      ))
                    ),
                  )
                ],
              ),
            );
          }
        },
      );
    }
  }
}
