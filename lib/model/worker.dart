import 'package:firebase_database/firebase_database.dart';


class Worker {
  String _id;
  String _name;
  bool _isCheck;

  Worker(this._id, this._name, this._isCheck);

  Worker.map(dynamic obj) {
    this._name = obj['name'];
    this._isCheck = obj['isCheck'];
  }

  String get id => _id;
  String get name => _name;
  bool get isCheck => _isCheck;

  set isChecked(bool value) {
    _isCheck = value;
  }

  Worker.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _name = snapshot.value['name'];
    _isCheck = snapshot.value['check'];
  }
}