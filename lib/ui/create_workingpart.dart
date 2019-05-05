import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:reiz_garden_master/model/worker.dart';
import 'package:reiz_garden_master/model/client.dart';
import 'package:reiz_garden_master/model/working_part.dart';

class CreateWorkingPart extends StatefulWidget {
  const CreateWorkingPart({
    Key key,
    this.user,
    this.role,
    this.part,
    this.title
  }) : super(key: key);

  final FirebaseUser user;
  final String role;
  final String title;
  final WorkingPart part;

  @override
  _CreateWorkingPartState createState() => _CreateWorkingPartState();
}

final partReference = FirebaseDatabase.instance.reference().child('working_parts');
final workerReference = FirebaseDatabase.instance.reference().child('workers');
final clientReference = FirebaseDatabase.instance.reference().child('clients');

class _CreateWorkingPartState extends State<CreateWorkingPart> {
  List<Client> clients;
  List<DropdownMenuItem<String>> dropList;
  String selected;

  StreamSubscription<Event> _onClientAddedSubscription;
  StreamSubscription<Event> _onClientChangedSubscription;

  List<Worker> workers;

  List<String> alWorkers;

  StreamSubscription<Event> _onWorkerAddedSubscription;
  StreamSubscription<Event> _onWorkerChangedSubscription;


  bool button;

  List<String> material;
  TextEditingController _materialController;

  String date;
  String startHour;
  String finalHour;

  String id;

  int hour, minute;
  double time = 0;

  void loadData() {
    dropList = clients.map((val) => new DropdownMenuItem<String>(
      child: Text(val.name), value: val.name,
    )).toList();
    if (widget.part.client != null) {
      selected = widget.part.client;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDateFormatting("es_ES", null);

    material = new List();
    _materialController = new TextEditingController();

    workers = new List();
    _onWorkerAddedSubscription = workerReference.onChildAdded.listen(_onWorkerAdded);
    _onWorkerChangedSubscription = workerReference.onChildChanged.listen(_onWorkerChanged);
    alWorkers = new List();

    clients = new List();
    _onClientAddedSubscription = clientReference.onChildAdded.listen(_onClientAdded);
    _onClientChangedSubscription = clientReference.onChildChanged.listen(_onClientChanged);

    button = widget.part.finished;
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
    loadData();

    return  MaterialApp(
      title: 'Nuevo Parte',
      home: Scaffold(
        appBar: AppBar(
          leading: FlatButton(
            child: Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.title),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(10.0),),
              Center(
                child: Text('Selecciona el cliente', style: TextStyle(fontSize: 21.0, color: Colors.blueGrey),),
              ),
              Center(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    items: dropList,
                    value: selected,
                    hint: Text('Elije el cliente'),
                    iconSize: 21.0,
                    elevation: 1,
                    onChanged: (value) {
                      setState(() {
                        selected = value;
                      });
                    },
                  ),
                ),
              ),
              Center(
                child: Text('Agrega los trabajadores', style: TextStyle(fontSize: 21.0, color: Colors.blueGrey),),
              ),
              Center(
                child: ListView.builder(
                  itemCount: workers.length,
                  shrinkWrap: true,
                  itemBuilder: (context, position) {
                    return Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Checkbox(
                              value: workers[position].isCheck,
                              onChanged: (bool value) {
                                setState(() {
                                  workers[position].isChecked = value;
                                  workerReference.child(workers[position].id).set({
                                    'check': value,
                                    'name': workers[position].name
                                  });
                                });
                              },
                            ),
                            Text('${workers[position].name}')
                          ],
                        )
                      ]
                    );
                  },
                )
              ),
              Padding(padding: EdgeInsets.all(10.0),),
              Center(
                child: Text('Inicia el contador', style: TextStyle(fontSize: 21.0, color: Colors.blueGrey),),
              ),
              Padding(padding: EdgeInsets.all(5.0),),
              Center(
                child: FloatingActionButton(
                  child: button ? Icon(Icons.play_arrow, color: Colors.white,) : Icon(Icons.stop, color: Colors.white,),
                  backgroundColor: button ? Colors.greenAccent : Colors.red,
                  onPressed: () {
                    setState(() {
                      _createPart();
                    });
                  },
                )
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
              ),
              Center(
                child: Text('Agrega Materiales usados', style: TextStyle(fontSize: 21.0, color: Colors.blueGrey)),
              ),
              Container(
                width: 50.0,
                child: Center(
                  child: TextField(
                    controller: _materialController,
                    decoration: InputDecoration(
                      hintText: 'Introduce los materiales',
                      contentPadding: EdgeInsets.only(left: 60.0,top: 20.0),
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(8.0),),
              Center(
                child: FlatButton(
                  child: Text(
                    'Agregar',
                    style: TextStyle(
                      fontSize: 21.0,
                      color: Colors.white,
                    ),
                  ),
                  color: Colors.green,
                  onPressed: () {
                    setState(() {
                      material.add(_materialController.text);
                    });
                    _materialController.clear();
                  },
                ),
              ),
              SizedBox(height: 20.0,),
              _materialTitle()
            ]
          ),
        )
      ),
    );

  }

  Widget _materialTitle() {
    var materialLength = material;
    if (materialLength == null) {
      return Center(
        child: Text('No hay materiales'),
      );
    } else {
      return Center(
        child: ListView.builder(
          itemCount: material.length,
          shrinkWrap: true,
          physics: ScrollPhysics(parent: NeverScrollableScrollPhysics()),
          itemBuilder: (context, position) {
            return Column(
              children: <Widget>[
                 Text(material[position]),
              ],
            );
          },
        ),
      );
    }

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

  void _addWorkers() {
    if(widget.part.id == null) {
      for (int i = 0; i< workers.length; i++) {
        if (workers[i].isCheck == true) {
          alWorkers.add(workers[i].name);
        }
      }
    }else {
      for (int i = 0; i < widget.part.workers.length; i++) {
        alWorkers.add(widget.part.workers[i]);
      }
    }
  }

  void _refreshMaterial() {
    if (widget.part.material != null) {
      for (int i = 0; i< widget.part.material.length; i++) {
        material.add(widget.part.material[i]);
      }
    }
  }

  void _createPart() {
    if(widget.part.id == null) {
      if (selected == null) {
         _clientAlert(context);
      } else {
        if (button == true) {
          _addWorkers();
          startHour = DateFormat.Hm("es_ES").format(DateTime.now());
          date = DateFormat.yMd("es_ES").format(DateTime.now());
          var dateTime = DateTime.now();
          minute = dateTime.minute;
          hour = dateTime.hour;
          if (minute > 44) {
            hour = hour+1;
            minute = 0;
          } else if (minute > 15 && minute <= 44) {
            minute = 30;
          } else {
            minute = 0;
          }
          button = false;
          partReference.push().set({
            'uid': widget.user.uid,
            'client': selected,
            'workers': alWorkers,
            'material': material,
            'date': date,
            'start_hour': startHour,
            'hour': hour,
            'minute': minute,
            'finished': false,
            'passed': false
          }).then((doc) {
            Navigator.pop(context);
          });
        }
      }

    }else{
      _addWorkers();
      _refreshMaterial();
      finalHour = DateFormat.Hm("es_ES").format(DateTime.now());
      date = DateFormat.yMd("es_ES").format(DateTime.now());
      var dateTime = DateTime.now();
      minute = dateTime.minute;
      hour = dateTime.hour;
      if (minute > 44) {
        hour = hour+1;
        minute = 0;
      } else if (minute > 15 && minute <= 44) {
        minute = 30;
      } else {
        minute = 0;
      }

      if (minute == 30 && widget.part.minute == 30) {
        hour = hour + 1;
      } else if ((minute == 0 && widget.part.minute == 30) || (minute == 30 && widget.part.minute == 0)) {
        time = 0.5;
      }

      hour = hour - widget.part.hour;
      print(minute);
      print(time);
      time = time + hour;

      partReference.child(widget.part.id).set({
        'uid': widget.user.uid,
        'client': widget.part.client,
        'workers': alWorkers,
        'material': material,
        'date': date,
        'start_hour': widget.part.startHour,
        'final_hour': finalHour,
        'time': time,
        'finished': true,
        'passed': false
      }).then((_) {
        Navigator.pop(context);
      });
    }

  }

  Future<void> _clientAlert(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Introduce un cliente'),
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
}
