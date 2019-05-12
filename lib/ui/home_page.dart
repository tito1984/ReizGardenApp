import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'listview_workers.dart';
import 'listview_clients.dart';
import 'listview_workingparts.dart';

class HomePage extends StatefulWidget {

  const HomePage({
    Key key,
    this.user,
    this.role
  }) : super(key: key);

  final FirebaseUser user;
  final String role;

  @override
  _HomePageState createState() => _HomePageState();
}

final workerReference = FirebaseDatabase.instance.reference().child('workers');


class _HomePageState extends State<HomePage> {

  String roleUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: <Widget>[
                Tab(text: 'Partes',),
                Tab( text: 'Clientes',),
                Tab(text: 'Trabajadores',)
              ],
            ),
            title: Image.asset('assets/images/logo2.png'),
            centerTitle: true,
            backgroundColor: Color.fromRGBO(206, 206, 206, 1.0),
          ),
          body: TabBarView(
            children: <Widget>[
              ListViewWorkingParts(user: widget.user, role: widget.role),
              ListViewClients(user: widget.user, role: widget.role),
              ListViewWorkers(user: widget.user, role: widget.role)
            ],
          ),
        ),
      ),
      title: 'Reiz Garden',
    );
  }


}
