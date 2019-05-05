import 'package:firebase_database/firebase_database.dart';



class WorkingPart {
  String _id;
  String _uid;
  String _client;
  List<dynamic> _workers;
  List<dynamic> _material;
  String _date;
  String _startHour;
  String _finalHour;
  double _time;
  int _hour;
  int _minute;
  bool _finished;
  bool _passed;
  double preTime;

  WorkingPart(this._id, this._uid, this._client, this._workers, this._material,
      this._date, this._startHour, this._finalHour, this._time, this._hour, this._minute, this._finished,
      this._passed);

  WorkingPart.map(dynamic obj) {
    this._uid = obj['uid'];
    this._client = obj['client'];
    this._workers = obj['workers'];
    this._material = obj['material'];
    this._date = obj['date'];
    this._startHour = obj['start_hour'];
    this._finalHour = obj['final_hour'];
    this._time = obj['time'];
    this._hour = obj['hour'];
    this._minute = obj['minute'];
    this._finished = obj['finished'];
    this._passed = obj['passed'];
  }

  String get id => _id;
  String get uid => _uid;
  String get client => _client;
  List<dynamic> get workers => _workers;
  List<dynamic> get material => _material;
  String get date => _date;
  String get startHour => _startHour;
  String get finalHour => _finalHour;
  double get time => _time;
  int get hour => _hour;
  int get minute => _minute;
  bool get finished => _finished;
  bool get passed => _passed;

  WorkingPart.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _uid = snapshot.value['uid'];
    _client = snapshot.value['client'];
    _workers = snapshot.value['workers'];
    _material = snapshot.value['material'];
    _date = snapshot.value['date'];
    _startHour = snapshot.value['start_hour'];
    _finalHour = snapshot.value['final_hour'];
    _time = double.tryParse((snapshot.value['time']).toString());
    _hour = snapshot.value['hour'];
    _minute = snapshot.value['minute'];
    _finished = snapshot.value['finished'];
    _passed = snapshot.value['passed'];
  }


}