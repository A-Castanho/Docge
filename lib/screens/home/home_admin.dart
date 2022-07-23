import 'package:adaptive_layout/adaptive_layout.dart';
import 'package:docge/Services/alert_displayer.dart';
import 'package:docge/Services/firebase/auth.dart';
import 'package:docge/Services/firebase/database.dart';
import 'package:docge/models/AppUser.dart';
import 'package:docge/screens/home/home_user.dart';
import 'package:flutter/material.dart';

import '../../shared/loading.dart';

class HomeAdim extends StatefulWidget {
  const HomeAdim({Key? key}) : super(key: key);
  @override
  State<HomeAdim> createState() => _HomeAdimState();
}

class _HomeAdimState extends State<HomeAdim> {
  final AuthService _auth = AuthService();
  DatabaseService _database = DatabaseService();

  Widget _usersListing = Loading(status: "A carregar funcionários");
  final Widget _registerUser = AdaptiveLayout(
    largeLayout: RegisterUser(padding: EdgeInsets.symmetric(horizontal: 300.0)),
    smallLayout: RegisterUser(padding: EdgeInsets.zero),
  );
  
  int _viewIndex = 0;
  List<Widget> _views = List<Widget>.of({ Loading(status: "A carregar funcionários"), Loading(status: "A carregar ecrã")});


  getUsers() async{
    return await _database.getUsers();
  }

  @override
  void initState() {
    getUsers().then((value){
      setState(() {
        _usersListing = UsersListing(users: value);
        _views = List<Widget>.of({ _usersListing, _registerUser});
      });
    });
    //_views = List<Widget>.of({ _usersListing, _registerUser});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _viewIndex,
        onTap: (index){
          setState(() => _viewIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            label: "Funcionários",
            icon: Icon(Icons.home)
          ),
          BottomNavigationBarItem(
            label: "Registar",
            icon: Icon(Icons.person_add)
          ),
        ],
      ),
      appBar: AppBar(
        actions: [
          TextButton.icon(
            onPressed: (){
              _auth.signOut();
              Navigator.maybePop(context);
            },
            icon: Icon(Icons.logout),
            label: Text(""),
          )
        ],
        title: Icon(Icons.home),
      ),
        body: _views[_viewIndex],
    );
  }
}

class UsersListing extends StatelessWidget {
  const UsersListing({
    Key? key,
    required List<AppUser> users,
  }) : _users = users, super(key: key);

  final List<AppUser> _users;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Funcionários registados: "),
                IconButton(onPressed: (){setState(){}}, icon: Icon(Icons.refresh))
              ],
            ),
            ListView.builder(
            shrinkWrap: true,
            itemCount: _users.length,
            itemBuilder: (context, index){
              return ListTile(
                onTap: ()=>{
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeUser(user: _users[index],))
                  ),
                },
                title: Text(_users[index].email),
              );
            },
            ),
          ],
        ),
      ),
      );
  }
}

class RegisterUser extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  const RegisterUser({Key? key, required this.padding}) : super(key: key);

  @override
  State<RegisterUser> createState() => _RegisterUserState();

}

class _RegisterUserState extends State<RegisterUser>{
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
    return loading? Loading(status: status) : Padding(
      padding: widget.padding,
      child: Form(
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
      ),
    );
  }
}

