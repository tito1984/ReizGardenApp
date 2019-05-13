import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:reiz_garden_master/model/working_part.dart';
import 'package:reiz_garden_master/ui/create_workingpart.dart';
import 'package:reiz_garden_master/ui/view_workingpart.dart';

class ListViewWorkingParts extends StatefulWidget {
  const ListViewWorkingParts({
    Key key,
    this.user,
    this.role
  }) : super(key: key);

  final FirebaseUser user;
  final String role;
  @override
  _ListViewWorkingPartsState createState() => _ListViewWorkingPartsState();
}

final partsReference = FirebaseDatabase.instance.reference().child('working_parts');

class _ListViewWorkingPartsState extends State<ListViewWorkingParts> {

  List<WorkingPart> parts;
  StreamSubscription<Event> _onPartAddedSubscription;
  StreamSubscription<Event> _onPartChangedSubscription;



  var workers;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    parts = new List();


    _onPartAddedSubscription = partsReference.onChildAdded.listen(_onPartAdded);
    _onPartChangedSubscription = partsReference.onChildChanged.listen(_onPartChanged);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _onPartChangedSubscription.cancel();
    _onPartAddedSubscription.cancel();
    super.dispose();
  }

  Widget deleteButton(int position) {
    if (widget.role == 'admin') {
      return Expanded(
          child: IconButton(
          icon: Icon(Icons.delete, color: Colors.red,),
          onPressed: () => _deletePartAlert(context, parts[position], position),
          )
      );
    } else if (widget.role == 'super_admin') {
      return Expanded(
          child: IconButton(
            icon: Icon(Icons.delete, color: Colors.red,),
            onPressed: () => _deletePartAlert(context, parts[position], position),
          )
      );
    } else {
      return Container();
    }
  }

  Widget calculateButton(int position) {
    if (widget.role == 'admin') {
      return Expanded(
          child: IconButton(
            icon: Icon(Icons.access_time, color: Colors.black),
            onPressed: () => _hourCalculationClient(parts[position].client),
          )
      );
    } else if (widget.role == 'super_admin') {
      return Expanded(
          child: IconButton(
            icon: Icon(Icons.access_time, color: Colors.black,),
            onPressed: () => _hourCalculationClient(parts[position].client),
          )
      );
    } else {
      return Container();
    }
  }


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white,),
          backgroundColor: Colors.red,
          onPressed: () => _createNewPart(context, 'Crear parte nuevo'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 7.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 12.0,),
                  RaisedButton.icon(
                    icon: Icon(Icons.access_time),
                    label: Text('Calcula horas totales'),
                    onPressed: () {_hourCalculation();},
                    color: Colors.white,
                    elevation: 0.0,
                  ),
                  SizedBox(width: 22.0,),
                ]
              ),
              ListView.builder(
                itemCount: parts.length,
                padding: EdgeInsets.all(5.0),
                shrinkWrap: true,
                itemBuilder: (context, position) {
                  workers = new List<String>.from(parts[position].workers);
                  return Column(
                    children: <Widget>[
                      Divider(height: 2.0,),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              title: Text('${parts[position].client}',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 21.0,
                                ),
                              ),
                              subtitle: Text('${parts[position].workers.length} trabajadores',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 18.0,
                                ),
                              ),
                              onTap: () {
                                if (parts[position].finished == false) {
                                  _editNewPart(parts[position], 'Editar parte');
                                } else {
                                  _viewPart(parts[position]);
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text('Horas: ${_isFinished(parts[position])}',
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 18.0
                                ),
                              ),
                              subtitle: Text('${parts[position].date}',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 18.0,
                                ),
                              ),
                              onTap: () {
                                if (parts[position].finished == false) {
                                  _editNewPart(parts[position], 'Editar parte');
                                } else {
                                  _viewPart(parts[position]);
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text('${_numberMaterial(parts[position])} materiales usados',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 18.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          calculateButton(position),
                          deleteButton(position),
                        ],
                      )
                    ],
                  );
                },
              )
            ],
          ),
        )
      ),
    );
  }
  
  int _numberMaterial(WorkingPart part) {
    if(part.material == null) {
      return 0;
    } else {
      return part.material.length;
    }
  }

  void _onPartAdded(Event event) {
    setState(() {
      parts.add(new WorkingPart.fromSnapshot(event.snapshot));
    });
  }

  void _onPartChanged(Event event) {
    var oldPartsValue = parts.singleWhere((item) => item.id == event.snapshot.key);
    setState(() {
      parts[parts.indexOf(oldPartsValue)] = new WorkingPart.fromSnapshot(event.snapshot);
    });
  }

  void _editNewPart(WorkingPart part, String title) async {
    await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateWorkingPart(user: widget.user, role: widget.role, part: part,title: title))
    );
  }

  void _createNewPart(BuildContext context, String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateWorkingPart(user: widget.user, role: widget.role, part: WorkingPart(null, null, null, null, null, '', '', '',0, 0, 0, true, false),title: title))
    );
  }

  void _viewPart(WorkingPart part) async {
    await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewWorkingPart(user: widget.user, role: widget.role, part: part))
    );
  }

  String _isFinished(WorkingPart part) {
    String finish;
    if (part.finished == true){
      finish = part.time.toString();
    }else{
      finish = 'Finaliza';
    }
    return finish;
  }

  void _deletePart(BuildContext context, WorkingPart part, int position)async {
    await workingPartReference.child(part.id).remove().then((_) {
      setState(() {
        parts.removeAt(position);
      });
    });
  }

  Future<void> _deletePartAlert(BuildContext context, WorkingPart part, int position) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Estas seguro que quieres borrar el parte?'),
            actions: <Widget>[
              FlatButton(
                child: Text('SI'),
                onPressed: () {
                  _deletePart(context, part, position);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('NO'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        }
    );
  }

  
  Future<void> _dialogClientList(BuildContext context, double horas, String part ) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Has trabajado '+ horas.toString() + ' horas en ' + part),
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

  void _hourCalculationClient(String client) {
    double hours = 0;

    for (var i=0; i<parts.length; i++) {
      if (parts[i].client == client) {
        hours = hours + parts[i].time;
      }
    }
    _dialogClientList(context, hours, client);

  }

  void _hourCalculation() {
    double hours = 0;
    for (var i=0; i<parts.length; i++) {
      hours = hours + parts[i].time;

    }

    _dialogClientList(context, hours, 'total');
  }


}

