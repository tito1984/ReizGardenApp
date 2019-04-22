import 'package:flutter/material.dart';
import 'ui/listview_workers.dart';
import 'ui/listview_clients.dart';
import 'ui/listview_workingparts.dart';

void main() => runApp(new MaterialApp(
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
        title: Text('Reiz Garden'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: TabBarView(
        children: <Widget>[
          ListViewWorkingParts(),
          ListViewClients(),
          ListViewWorkers()
        ],
      ),
    ),
  ),
  title: 'Reiz Garden',
));


