import 'package:staff_flutter/employee.dart';

class EmployeeChild {
  String _surname;
  String _name;
  String _patronymicName;
  String _birthdate;
  Employee _parent;

  EmployeeChild(this._surname, this._name, this._patronymicName, this._birthdate);


  EmployeeChild.fromJson(Map jsonMap)
      : assert(jsonMap['surname'] != null),
        assert(jsonMap['name'] != null),
        assert(jsonMap['patronymicName'] != null),
        assert(jsonMap['birthdate'] != null),
        _surname = jsonMap['surname'],
        _name = jsonMap['name'],
        _patronymicName = jsonMap['patronymicName'],
        _birthdate = jsonMap['birthdate'];

  Employee get parent => _parent;

  set parent(Employee value) {
    _parent = value;
  }

  String get birthdate => _birthdate;

  String get patronymicName => _patronymicName;

  String get name => _name;

  String get surname => _surname;
}
