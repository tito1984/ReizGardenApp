import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {

  @override
  _SignInState createState() => new _SignInState();
}

final workerReference = FirebaseDatabase.instance.reference().child('workers');

class _SignInState extends State<SignIn> {
  String roleUser;
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var emailCont = new TextEditingController();
  var passCont = new TextEditingController();

  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 100.0,
        child: Image.asset('assets/images/logo.png'),
      ),
    );

    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      initialValue: _email,
      controller: emailCont,
      validator: (input) {
        if(input.isEmpty) {
          return 'Introduce un Email';
        }
      },
      onSaved: (input) => _email = input,
      decoration: InputDecoration(
          hintText: 'Email',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      initialValue: _password,
      controller: passCont,
      validator: (input) {
        if(input.isEmpty) {
          return 'Introduce la contraseña';
        }
      },
      onSaved: (input) => _password = input,
      decoration: InputDecoration(
          hintText: 'Contraseña',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric( horizontal: 8.0),
      child: ButtonTheme(
        minWidth: 150.0,
        height: 35.0,
        child: RaisedButton(
          shape: new RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
          onPressed: signIn,
          color: Color.fromRGBO(195, 195, 195, 1.0),
          child: Text(
            'Iniciar Sesion',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
                SizedBox(height: 60.0),
                logo,
                SizedBox(height: 60.0),
                email,
                SizedBox(height: 8.0),
                password,
                SizedBox(height: 28.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    loginButton,
                  ],
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

  void signIn() async {

    final _formState = _formKey.currentState;

    if (_formState.validate()) {
      _formState.save();
      saveData();
      try {
        FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
        await workerReference.once().then((DataSnapshot snapshot) {
          Map<dynamic, dynamic> values = snapshot.value;
          values.forEach((key, values) {
            if ((values['uid']).toString() == (user.uid).toString()) {
              roleUser = (values['role']).toString();
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(user: user, role: roleUser)));
            }
          });
        });

        //TODO: Navigate to home
      } catch(e) {
        if (e.code == 'ERROR_WRONG_PASSWORD') {
          _signInAlert(context, 'Password incorrecto');
        } else if (e.code == 'ERROR_INVALID_EMAIL') {
          _signInAlert(context, 'Email no valido');
        } else if (e.code == 'ERROR_USER_NOT_FOUND') {
          _signInAlert(context, 'Usuario no encontrado');
        } else {
          _signInAlert(context, 'error desconocido');
        }
      }

    }
  }

  Future<void> _signInAlert(BuildContext context, String error) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(error),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
    );
  }

  void readData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      emailCont.text =  (prefs.getString('email')?? '');
      passCont.text = (prefs.getString('password')?? '');
    });
  }

  saveData() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('email', _email);
    prefs.setString('password', _password);
  }
}
