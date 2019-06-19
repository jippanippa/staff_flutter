import 'package:staff_flutter/employee_child.dart';

class Employee {
  String _surname;
  String _name;
  String _patronymicName;
  String _birthdate;
  String _position;
  List<EmployeeChild> _children;

  Employee(this._surname, this._name, this._patronymicName, this._birthdate,
      this._position, this._children);


//  Employee.fromJson(Map<String, dynamic> jsonMap) {
//    var childrenList = jsonMap['children'] as List;
//    List<EmployeeChild> children = childrenList.map((c) => EmployeeChild.fromJson(c)).toList();
//  }

  String get patronymicName => _patronymicName;

  String get name => _name;

  String get surname => _surname;

  String get position => _position;

  String get birthdate => _birthdate;

  List<EmployeeChild> get children => _children;

  set children(List<EmployeeChild> value) {
    _children = value;
  }
}
