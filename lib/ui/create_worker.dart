import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:reiz_garden_master/model/worker.dart';

class CreateWorker extends StatefulWidget {
  const CreateWorker({
    Key key,
    this.user,
    this.role,
    this.worker,
  }) : super(key: key);

  final FirebaseUser user;
  final String role;
  final Worker worker;

  @override
  _CreateWorkerState createState() => _CreateWorkerState();
}

final workerReference = FirebaseDatabase.instance.reference().child('workers');

class _CreateWorkerState extends State<CreateWorker> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email, _name, _password;

  @override
  Widget build(BuildContext context) {

    final name = TextFormField(
      autofocus: false,
      validator: (input) {
        if(input.isEmpty) {
          return 'Introduce un nombre';
        }
      },
      onSaved: (input) => _name = input,
      decoration: InputDecoration(
          hintText: 'Nombre',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
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

    final createWorker = Padding(
      padding: EdgeInsets.symmetric( horizontal: 8.0),
      child: ButtonTheme(
        minWidth: 150.0,
        height: 35.0,
        child: RaisedButton(
          shape: new RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
          onPressed: () {
            signUp();

          },
          color: Color.fromRGBO(206, 206, 206, 1.0),
          child: Text(
            'Crear trabajador',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: FlatButton(
          child: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Crear Trabajador'),
        backgroundColor: Color.fromRGBO(206, 206, 206, 1.0),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
                SizedBox(height: 60.0),
                name,
                SizedBox(height: 8.0),
                email,
                SizedBox(height: 8.0),
                password,
                SizedBox(height: 28.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    createWorker,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void signUp() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
        workerReference.push().set({
          'email': _email,
          'name': _name,
          'role': 'worker',
          'uid': user.uid,
          'check': false
        }).then((_) {
          Navigator.pop(context);
        });
      } catch(e) {
        print(e.message);
      }
    }
  }
}

