import 'package:firebase_database/firebase_database.dart';


class Client {
  String _id;
  String _name;

  Client(this._id, this._name);

  Client.map(dynamic obj) {
    this._id = obj['id'];
    this._name = obj['name'];
  }

  String get id => _id;
  String get name => _name;

  Client.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _name = snapshot.value['name'];
  }
}