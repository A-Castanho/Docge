
import 'package:docge/Services/firebase/auth.dart';
import 'package:flutter/material.dart';

import '../../../Services/alert_displayer.dart';
import '../../../shared/loading.dart';

//Small Screens
class RegisterUserSmall extends StatefulWidget {

  const RegisterUserSmall({Key? key}) : super(key: key);

  @override
  State<RegisterUserSmall> createState() => _RegisterUserSmallState();
}

class _RegisterUserSmallState extends State<RegisterUserSmall> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();

  // fields state
  String email ="";
  String password ="";
  bool adminRights = false;

  bool loading = false;
  String status="";

  @override
  Widget build(BuildContext context) {
    return loading? Loading(status: status) : Form(
      key: _formKey,

      child: Padding(
        padding: const EdgeInsets.only(top:100.0, left:10.0, right:10.0),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FormField(
                initialValue: false,
                builder: (FormFieldState<bool> field) {
                  return SwitchListTile(
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.redAccent,
                    activeColor: Colors.green,
                    title: Text("Conceder direitos de administrador"),
                    value: adminRights,
                    onChanged: (val) {
                      setState(() => adminRights = val);
                      //field.didChange(val);
                    },
                  );
                }
            ),

            //Email TextFormField===========================================================
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Email',
              ),

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor insira o e-mail da nova conta';
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
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                ),
                icon: const Icon(Icons.app_registration),
                label: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text("Registar novo funcionário"),
                ),
                onPressed: () async{
                  setState(() => loading = true);

                  if(_formKey.currentState!=null){
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      String result = await _auth.registerWithEmailAndPassword(email, password, adminRights: adminRights);
                      //If it works wrapper changes to home
                      displayWarning(context, "Registo de um novo utilizador", result);
                    }
                  }
                  setState(() => loading = false);
                }
            )
          ],
        ),
      ),
    );
  }
}


//Large Screens
class RegisterUserLarge extends StatefulWidget {
  const RegisterUserLarge({Key? key}) : super(key: key);

  @override
  State<RegisterUserLarge> createState() => _RegisterUserLargeState();
}

class _RegisterUserLargeState extends State<RegisterUserLarge> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();

  // fields state
  String email ="";
  String password ="";
  bool adminRights = false;

  bool loading = false;
  String status="";

  @override
  Widget build(BuildContext context) {
    return loading? Loading(status: status) : Form(
      key: _formKey,

      child: Padding(
        padding: const EdgeInsets.only(top:100.0, left:10.0, right:10.0),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FormField(
                initialValue: false,
                builder: (FormFieldState<bool> field) {
                  return SwitchListTile(
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.redAccent,
                    activeColor: Colors.green,
                    title: Text("Conceder direitos de administrador"),
                    value: adminRights,
                    onChanged: (val) {
                      setState(() => adminRights = val);
                      //field.didChange(val);
                    },
                  );
                }
            ),

            //Email TextFormField===========================================================
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Email',
              ),

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor insira o e-mail da nova conta';
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
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                ),
                icon: const Icon(Icons.app_registration),
                label: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text("Registar novo funcionário"),
                ),
                onPressed: () async{
                  setState(() => loading = true);

                  if(_formKey.currentState!=null){
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      String result = await _auth.registerWithEmailAndPassword(email, password, adminRights: adminRights);
                      //If it works wrapper changes to home
                      displayWarning(context, "Registo de um novo utilizador", result);
                    }
                  }
                  setState(() => loading = false);
                }
            )
          ],
        ),
      ),
    );
  }
}