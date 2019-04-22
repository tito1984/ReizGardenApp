import 'package:firebase_database/firebase_database.dart';

import 'client.dart';


class WorkingPart {
  String _id;
  String _client;
  List<dynamic> _workers;
  List<dynamic> _material;
  String _date;
  String _startHour;
  String _finalHour;
  bool _finished;

  WorkingPart(this._id, this._client, this._workers, this._material,
      this._date, this._startHour, this._finalHour, this._finished);

  WorkingPart.map(dynamic obj) {
    this._client = obj['client'];
    this._workers = obj['workers'];
    this._material = obj['material'];
    this._date = obj['date'];
    this._startHour = obj['start_hour'];
    this._finalHour = obj['final_hour'];
    this._finished = obj['finished'];
  }

  String get id => _id;
  String get client => _client;
  List<dynamic> get workers => _workers;
  List<dynamic> get material => _material;
  String get date => _date;
  String get startHour => _startHour;
  String get finalHour => _finalHour;
  bool get finished => _finished;

  WorkingPart.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _client = snapshot.value['client'];
    _workers = snapshot.value['workers'];
    _material = snapshot.value['material'];
    _date = snapshot.value['date'];
    _startHour = snapshot.value['start_hour'];
    _finalHour = snapshot.value['final_hour'];
    _finished = snapshot.value['finished'];
  }


}