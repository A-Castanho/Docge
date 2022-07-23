import 'package:adaptive_layout/adaptive_layout.dart';
import 'package:docge/Services/alert_displayer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Services/firebase/auth.dart';

enum PAGEMODE{
  login,
  passwordRecovery
}

final AuthService _auth = AuthService();
PAGEMODE pageMode=PAGEMODE.login;

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);
  @override
  State<LogIn> createState() => _LogInState();
}


class _LogInState extends State<LogIn> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Autenticação"),
      ),
      body: AdaptiveLayout(
        largeLayout: const LogInBody(padding: const EdgeInsets.symmetric(horizontal: 300.0),),
        smallLayout: const LogInBody(padding: EdgeInsets.zero,),
      )
    );
  }
}

class LogInBody extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  const LogInBody({Key? key, required this.padding}) : super(key: key);

  @override
  State<LogInBody> createState() => _LogInBodyState();
}

class _LogInBodyState extends State<LogInBody> {
  final _formKey = GlobalKey<FormState>();

  //Text fields state
  String email ="";
  String password ="";

  @override
  Widget build(BuildContext context) {
    return Padding(padding: widget.padding,
    child: (pageMode==PAGEMODE.login)? Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),

        child: Form(
          key: _formKey,

          child: Padding(
            padding: const EdgeInsets.all(8.0),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                //Email TextFormField===========================================================
                TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Email',
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor insira o seu e-mail';
                    }
                    return null;
                  },
                  onChanged: (val){
                    setState(()=> email = val);
                  },
                ),
                //Password TextFormField======================================================
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Palavra-passe',
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty || value.length<8) {
                      return 'Por favor insira a palavra-passe';
                    }
                    return null;
                  },

                  onChanged: (val){
                    setState(()=> password = val);
                  },
                ),

                //Submit ==========================================================================
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                          ),
                          icon: const Icon(Icons.login),
                          label: const Text("Iniciar Sessão"),
                          onPressed: () async{

                            if(_formKey.currentState!=null){
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                dynamic result = await _auth.logInWithEmailAndPassword(email, password);
                                //If it works wrapper changes to home
                                if(result == null){
                                  ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: new Text('Os valores inseridos não correspondem a nenhuma conta existente')));
                                }
                                else{

                                }
                              }
                            }
                          }
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () async{
                          setState(() {
                            pageMode = PAGEMODE.passwordRecovery;
                          });
                          //String resultado = _auth.sendResetPasswordEmail(email);
                          //displayWarning(context, "Alteraç", resultado);
                        },
                        child: const Text("Redefinir palavra passe",
                            style: const TextStyle(decoration: TextDecoration.underline)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
    ) :

    //Password Setting Screen
    Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),

        child: Form(
          key: _formKey,

          child: Padding(
            padding: const EdgeInsets.all(8.0),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                const Text("Insira o seu endereço para lhe enviarmos um email de redefinição de palavra passe"),
                //Email TextFormField===========================================================
                TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Email',
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor insira o seu e-mail';
                    }
                    return null;
                  },
                  onChanged: (val){
                    setState(()=> email = val);
                  },
                ),

                //Submit ==========================================================================
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                          ),
                          icon: const Icon(Icons.login),
                          label: const Text("Enviar e-mail"),
                          onPressed: () async{

                            if(_formKey.currentState!=null){
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                String result = await _auth.sendPasswordResetEmail(email);
                                displayWarning(context, "Redefinição da password", result);
                              }
                            }
                          }
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () async{
                          setState(() {
                            pageMode = PAGEMODE.login;
                          });
                          //String resultado = _auth.sendResetPasswordEmail(email);
                          //displayWarning(context, "Alteraç", resultado);
                        },
                        child: const Text("Iniciar sessão",
                            style: const TextStyle(decoration: TextDecoration.underline)),
                      ),
                    ),

                  ],
                )
              ],
            ),
          ),
        )
    ),
    );
  }
}


