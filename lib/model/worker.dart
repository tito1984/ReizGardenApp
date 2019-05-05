import 'package:firebase_database/firebase_database.dart';


class Worker {
  String _id;
  String _email;
  String _name;
  String _role;
  String _uid;
  bool _isCheck;

  Worker(this._id, this._email, this._name, this._role, this._uid, this._isCheck);

  Worker.map(dynamic obj) {
    this._email = obj['email'];
    this._name = obj['name'];
    this._role = obj['role'];
    this._uid = obj['uid'];
    this._isCheck = obj['isCheck'];
  }

  String get id => _id;
  String get email => _email;
  String get name => _name;
  String get role => _role;
  String get uid => _uid;
  bool get isCheck => _isCheck;

  set isChecked(bool value) {
    _isCheck = value;
  }

  Worker.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _email = snapshot.value['email'];
    _name = snapshot.value['name'];
    _role = snapshot.value['role'];
    _uid = snapshot.value['uid'];
    _isCheck = snapshot.value['check'];
  }
}