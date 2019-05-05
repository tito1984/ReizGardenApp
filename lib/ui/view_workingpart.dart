import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:reiz_garden_master/model/working_part.dart';
import 'package:reiz_garden_master/model/worker.dart';
import 'package:reiz_garden_master/model/client.dart';

class ViewWorkingPart extends StatefulWidget {
  const ViewWorkingPart({
    Key key,
    this.user,
    this.role,
    this.part
  }) : super(key: key);

  final FirebaseUser user;
  final String role;
  final WorkingPart part;

  @override
  _ViewWorkingPartState createState() => _ViewWorkingPartState();
}

final workingPartReference = FirebaseDatabase.instance.reference().child('working_parts');
final clientReference = FirebaseDatabase.instance.reference().child('clients');
final workerReference = FirebaseDatabase.instance.reference().child('workers');

class _ViewWorkingPartState extends State<ViewWorkingPart> {

  List<Client> clients;
  StreamSubscription<Event> _onClientAddedSubscription;
  StreamSubscription<Event> _onClientChangedSubscription;

  List<Worker> workers;
  StreamSubscription<Event> _onWorkerAddedSubscription;
  StreamSubscription<Event> _onWorkerChangedSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    clients = new List();
    _onClientChangedSubscription = clientReference.onChildChanged.listen(_onClientChanged);
    _onClientAddedSubscription = clientReference.onChildAdded.listen(_onClientAdded);

    workers = new List();
    _onWorkerAddedSubscription = workerReference.onChildAdded.listen(_onWorkerAdded);
    _onWorkerChangedSubscription = workerReference.onChildChanged.listen(_onWorkerChanged);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _onClientAddedSubscription.cancel();
    _onClientChangedSubscription.cancel();
    _onWorkerChangedSubscription.cancel();
    _onWorkerAddedSubscription.cancel();
  }


  @override
  Widget build(BuildContext context) {
    var workerList = widget.part.workers.toList();
    return MaterialApp(
      title: 'Ver partes de Trabajo',
      home: Scaffold(
        appBar: AppBar(
          leading: FlatButton(
            child: Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Ver Parte'),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              Center(
                child: ListTile(
                  title: Text('Cliente',
                    style: TextStyle(
                      fontSize: 21.0,
                      color: Colors.blueGrey
                    ),
                  ),
                  subtitle: Text(widget.part.client),
                  trailing: IconButton(
                              icon: Icon(Icons.border_color, color: Colors.blue,),
                              onPressed: () => _editClient(),
                            ),
                ),
              ),
              Center(
                child: ListTile(
                  title: Text('Trabajadores',
                    style: TextStyle(
                        fontSize: 21.0,
                        color: Colors.blueGrey
                    ),
                  ),
                ),
              ),
              Center(
                child: ListView.builder(
                  itemCount: workerList.length,
                  padding: EdgeInsets.all(15.0),
                  shrinkWrap: true,
                  physics: ScrollPhysics(parent: NeverScrollableScrollPhysics()),
                  itemBuilder: (context, position) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(workerList[position]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red,),
                            onPressed: () {
                              _deleteWorker(context, widget.part, position);
                            },
                          ),
                        ),
                      ],
                    );
                  },

                ),

              ),
              Center(
                child: FlatButton(
                    child: Text(
                      'Agregar Trabajador',
                      style: TextStyle(
                        fontSize: 21.0,
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.green,

                    onPressed: () {}
                ),
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: Text('Fecha y horas',
                            style: TextStyle(
                                fontSize: 21.0,
                                color: Colors.blueGrey
                            ),
                          ),
                          subtitle: Text('Fecha: ' + widget.part.date,
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text('Desde: '+ widget.part.startHour,
                            style: TextStyle(
                              color: Colors.black
                            ),
                          ),
                          subtitle: Text('Hasta: ' + _isFinished(widget.part),
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              Center(
                child: ListTile(
                  title: Text('Materiales',
                    style: TextStyle(
                      fontSize: 21.0,
                      color: Colors.blueGrey
                    ),
                  ),
                ),
              ),
              _materialTitle(),
              Center(
                child: FlatButton(
                    child: Text(
                      'Agregar Material',
                      style: TextStyle(
                        fontSize: 21.0,
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.green,

                    onPressed: () {}
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onClientAdded(Event event) {
    setState(() {
      clients.add(new Client.fromSnapshot(event.snapshot));
    });
  }

  void _onClientChanged(Event event) {
    var oldClientValue = clients.singleWhere((item) => item.id == event.snapshot.key);
    setState(() {
      clients[clients.indexOf(oldClientValue)] = new Client.fromSnapshot(event.snapshot);
    });
  }

  void _onWorkerAdded(Event event) {
    setState(() {
      workers.add(new Worker.fromSnapshot(event.snapshot));
    });
  }

  void _onWorkerChanged(Event event) {
    var oldWorkerValue = workers.singleWhere((item) => item.id == event.snapshot.key);
    setState(() {
      workers[workers.indexOf(oldWorkerValue)] = new Worker.fromSnapshot(event.snapshot);
    });
  }

  void _editClient() {

  }

  void _deleteMaterial(BuildContext context, WorkingPart part, int position) async {
    await workingPartReference.child(part.id).child('material').child(position.toString()).remove().then((_) {
      if (position < part.material.length-1) {
        for (int i = position; i < part.material.length-1; i++) {
          workingPartReference.child(part.id).child('material').child(i.toString()).set(part.material[i+1]);
        }
        workingPartReference.child(part.id).child('material').child((part.material.length-1).toString()).remove();
      }
    });
  }

  void _deleteWorker(BuildContext context, WorkingPart part, int position) async {
    var workerList = widget.part.workers.toList();
    await workingPartReference.child(part.id).child('workers').child(position.toString()).remove().then((_) {
      if (position < part.workers.length-1) {
          for (int i = position; i < part.workers.length-1; i++ ) {
            workingPartReference.child(part.id).child('workers').child(i.toString()).set(part.workers[i+1]);
          }
          workingPartReference.child(part.id).child('workers').child((part.workers.length-1).toString()).remove();
      }
      setState(() {
        workerList.removeAt(position);
        print(workerList);
      });
    });
  }

  String _isFinished(WorkingPart part) {
    String finish;
    if (part.finished == true){
      finish = part.finalHour;
    }else{
      finish = 'Finaliza antes';
    }
    return finish;
  }

  Widget _materialTitle() {
    var materialLength = widget.part.material;
    if (materialLength == null) {
      return Center(
        child: Text('No hay materiales'),
      );
    } else {
      return Center(
        child: ListView.builder(
          itemCount: widget.part.material.length,
          padding: EdgeInsets.all(15.0),
          shrinkWrap: true,
          physics: ScrollPhysics(parent: NeverScrollableScrollPhysics()),
          itemBuilder: (context, position) {
            return Column(
              children: <Widget>[
                ListTile(
                  title: Text(widget.part.material[position]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red,),
                    onPressed: () => _deleteMaterial(context, widget.part, position),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

  }
  //Future<Worker>
}
