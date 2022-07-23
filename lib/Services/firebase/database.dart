import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../models/AppUser.dart';

class DatabaseService{
  //Final = Not gonna change in the future
  //underscore means the property is private
  final FirebaseDatabase _database = FirebaseDatabase.instance;


  //Future<Iterable<AppUser>> getUsers async {
  Future<List<AppUser>> getUsers() async{
    var dbRef = await _database.ref("users").get();
    List<AppUser> users = List<AppUser>.empty(growable: true);

    dbRef.children.forEach((dataSnapshot) {
      AppUser user;
      print(dataSnapshot.toString());
      String jsonString = json.encode(dataSnapshot.value);
      Map<String, dynamic> jsonObject = json.decode(jsonString);

      user = AppUser(
        email: jsonObject["email"],
        uid: dataSnapshot.key!,
      );
      users.add(user);
    });
    return users;
  }

  Future<bool> isUserAdmin(String uid) async{
    var dbUserRef = await _database.ref("users").child(uid).get();

    String jsonString = json.encode(dbUserRef.value);
    Map<String, dynamic> jsonObject = json.decode(jsonString);

    return jsonObject["admin"];
  }

  Future<void> createUser(String uid, String email, bool adminRights) async{
    Map<String, dynamic> jsonMap = {'email' : email, "admin" : adminRights};
    print(json.encode(jsonMap));
    await _database.ref("users").child(uid).set(json.decode(json.encode(jsonMap)));
  }
}