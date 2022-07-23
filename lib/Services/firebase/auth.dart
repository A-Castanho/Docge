import 'package:docge/Services/firebase/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../models/AppUser.dart';

class AuthService{
  //Final = Not gonna change in the future
  //underscore means the property is private
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _database = DatabaseService();

  AppUser? _userFromFirebaseUser(User? user){
    return user!=null ? AppUser(uid: user.uid, email: user.email??"") : null;
  }

  Stream<AppUser?> get user{
    //return _auth.authStateChanges().map((User? user)=> _userFromFirebaseUser(user));
    //^Same as:
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  //sign in with email & password
  Future logInWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }
  //sign out
  Future signOut() async{
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future<String> registerWithEmailAndPassword(String email, String password,  {bool adminRights = false}) async {
    try{
      //Create a secondary app so the current app doesn't stay logged in as the new user
      FirebaseApp app = await Firebase.initializeApp(
          name: 'Secondary', options: Firebase.app().options);

      UserCredential result = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = result.user;
      await _database.createUser(user!.uid, email, adminRights);

      await app.delete();

      return "Utilizador criado com sucesso!";

    }catch(e){
      return e.toString();
    }
  }

  Future<String >sendPasswordResetEmail(String email) async {
    try{
      await _auth.sendPasswordResetEmail(email: email);
      return "Foi enviada uma mensagem para a redefinição da password para o seu email.";
    }
    on FirebaseAuthException{
      return "O email inserido não corresponde a uma conta existente.";
    }
    catch(e){
      return "Ocorreu um erro no envio do e-mail: ${e.toString()}";
    }
  }
}