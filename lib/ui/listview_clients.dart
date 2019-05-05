import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:reiz_garden_master/model/client.dart';
import 'package:reiz_garden_master/ui/create_client.dart';


class ListViewClients extends StatefulWidget {
  const ListViewClients({
    Key key,
    this.user,
    this.role
  }) : super(key: key);

  final FirebaseUser user;
  final String role;
  @override
  _ListViewClientsState createState() => _ListViewClientsState();
}

final clientsReference = FirebaseDatabase.instance.reference().child('clients');

class _ListViewClientsState extends State<ListViewClients> {

  List<Client> clients;
  StreamSubscription<Event> _onClientAddedSubscription;
  StreamSubscription<Event> _onClientChangedSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    clients = new List();
    _onClientAddedSubscription = clientsReference.onChildAdded.listen(_onClientAdded);
    _onClientChangedSubscription = clientsReference.onChildChanged.listen(_onClientChanged);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _onClientAddedSubscription.cancel();
    _onClientChangedSubscription.cancel();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clientes',
      home: Scaffold(
        /*appBar: AppBar(
          title: Text('Clientes'),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),*/
        body: Center(
          child: ListView.builder(
            itemCount: clients.length,
            padding: EdgeInsets.all(15.0),
            itemBuilder: (context, position) {
              return Column(
                children: <Widget>[
                  Divider(height: 7.0,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: Text('${clients[position].name}',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 21.0,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red,),
                        onPressed: () => _deleteClient(context, clients[position], position),
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
          backgroundColor: Colors.green,
          onPressed: () => _createNewClient(context),
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

  void _deleteClient(BuildContext context, Client client, int position)async {
    await clientsReference.child(client.id).remove().then((_) {
      setState(() {
        clients.removeAt(position);
      });
    });
  }

  void _createNewClient(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateClient(user: widget.user, role: widget.role, client: Client(null, '')))
    );
  }
}
