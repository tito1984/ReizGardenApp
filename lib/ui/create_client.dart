import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:reiz_garden_master/model/client.dart';

class CreateClient extends StatefulWidget {
  final Client client;
  CreateClient(this.client);

  @override
  _CreateClientState createState() => _CreateClientState();
}

final clientReference = FirebaseDatabase.instance.reference().child('clients');

class _CreateClientState extends State<CreateClient> {
  TextEditingController _nameEditingController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _nameEditingController = new TextEditingController(text: widget.client.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: FlatButton(
          child: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Insertar Cliente'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _nameEditingController,
            decoration: InputDecoration(),
          ),
          Padding(padding: new EdgeInsets.all(5.0)),
          RaisedButton(
            child: Text('Añadir'),
            onPressed: () {
              clientReference.push().set({
                'name': _nameEditingController.text
              }).then((_) {
                Navigator.pop(context);
              });
            },
          )
        ],
      ),
    );
  }
}
