import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:reiz_garden_master/model/worker.dart';

class CreateWorker extends StatefulWidget {
  final Worker worker;
  CreateWorker(this.worker);

  @override
  _CreateWorkerState createState() => _CreateWorkerState();
}

final workerReference = FirebaseDatabase.instance.reference().child('workers');

class _CreateWorkerState extends State<CreateWorker> {
  TextEditingController _nameEditingController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _nameEditingController = new TextEditingController(text: widget.worker.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: FlatButton(
          child: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Insertar Trabajador'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _nameEditingController,
            decoration: InputDecoration(),
          ),
          Padding(padding: new EdgeInsets.all(5.0),),
          RaisedButton(
            child: Text('Añadir'),
            color: Colors.green,
            onPressed: () {
              workerReference.push().set({
                'name': _nameEditingController.text,
                'check': false
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

