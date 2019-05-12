import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:reiz_garden_master/model/client.dart';

class CreateClient extends StatefulWidget {
  const CreateClient({
    Key key,
    this.user,
    this.role,
    this.client
  }) : super(key: key);

  final FirebaseUser user;
  final String role;
  final Client client;

  @override
  _CreateClientState createState() => _CreateClientState();
}

final clientReference = FirebaseDatabase.instance.reference().child('clients');

class _CreateClientState extends State<CreateClient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _name;


  @override
  Widget build(BuildContext context) {
    final name = TextFormField(
      autofocus: false,
      validator: (input) {
        if(input.isEmpty) {
          return 'Introduce un nombre de cliente';
        }
      },
      onSaved: (input) => _name = input,
      decoration: InputDecoration(
          hintText: 'Nombre',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final createClient = Padding(
      padding: EdgeInsets.symmetric( horizontal: 8.0),
      child: ButtonTheme(
        minWidth: 150.0,
        height: 35.0,
        child: RaisedButton(
          shape: new RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
          onPressed: () {
            _createClient();
          },
          color: Color.fromRGBO(195, 195, 195, 1.0),
          child: Text(
            'Crear cliente',
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
        title: Text('Insertar Cliente'),
        backgroundColor: Color.fromRGBO(195, 195, 195, 1.0),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    createClient,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _createClient() {

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      clientReference.push().set({
        'name': _name
      }).then((_) {
        Navigator.pop(context);
      });
    }

  }
}
