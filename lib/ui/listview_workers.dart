import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:reiz_garden_master/model/worker.dart';
import 'package:reiz_garden_master/ui/create_worker.dart';

class ListViewWorkers extends StatefulWidget {
  @override
  _ListViewWorkersState createState() => _ListViewWorkersState();
}

final workersReference = FirebaseDatabase.instance.reference().child('workers');

class _ListViewWorkersState extends State<ListViewWorkers> {

  List<Worker> workers;
  StreamSubscription<Event> _onWorkerAddedSubscription;
  StreamSubscription<Event> _onWorkerChangedSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    workers = new List();
    _onWorkerAddedSubscription = workersReference.onChildAdded.listen(_onWorkerAdded);
    _onWorkerChangedSubscription = workersReference.onChildChanged.listen(_onWorkerChanged);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _onWorkerChangedSubscription.cancel();
    _onWorkerAddedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trabajadores',
      home: Scaffold(
        /*appBar: AppBar(
          title: Text('Trabajadores'),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),*/
        body: Center(
          child: ListView.builder(
            itemCount: workers.length,
            padding: EdgeInsets.all(15.0),
            itemBuilder: (context, position) {
              return Column(
                children: <Widget>[
                  Divider(height: 7.0,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: Text('${workers[position].name}',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 21.0,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red,),
                        onPressed: () => _deleteWorker(context,workers[position], position),
                      )
                    ],
                  )
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white,),
          heroTag: 'createWorker',
          backgroundColor: Colors.green,
          onPressed: () => _createNewWorker(context),
        ),
      ),
    );
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

  void _deleteWorker(BuildContext context, Worker worker, int position) async {
    await workersReference.child(worker.id).remove().then((_) {
      setState(() {
        workers.removeAt(position);
      });
    });
  }

  void _createNewWorker(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateWorker(Worker(null, '', false)))
    );
  }

}
