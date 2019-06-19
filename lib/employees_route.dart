import 'package:flutter/material.dart';
import 'package:staff_flutter/employee.dart';
import 'package:staff_flutter/employee_child.dart';
import 'package:staff_flutter/employees_children_route.dart';


class EmployeesRoute extends StatefulWidget {
  _EmployeesRouteState createState() => _EmployeesRouteState();
}

class _EmployeesRouteState extends State<EmployeesRoute> {
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _patronymicController = TextEditingController();
  TextEditingController _birthdateController = TextEditingController();
  TextEditingController _positionController = TextEditingController();


  static List<EmployeeChild> _testChildrenFirst = [
    new EmployeeChild("Петров", "Иван", "Петрович", "19.07.1999"),
  ];

  static List<EmployeeChild> _testChildrenSecond = [
    new EmployeeChild("Иванов", "Виктор", "Иванович", "31.12.1989"),
    new EmployeeChild("Иванов", "Петр", "Иванович", "01.01.2001"),
  ];

  List<Employee> _listOfEmployees = [
    new Employee("Петров", "Петр", "Петрович", "21.02.1968", "Директор",
        _testChildrenFirst),
    new Employee("Иванов", "Иван", "Иванович", "22.05.1958",
        "Генеральный директор", _testChildrenSecond),
  ];


  void _navigateToEmployeesChildren(BuildContext context, Employee employee) {
    Navigator.of(context)
        .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
      return Scaffold(
        body: EmployeesChildrenRoute(parent: employee),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сотрудники'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Center(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  new Padding(padding: EdgeInsets.all(10.0)),
                  new Flexible(
                      child: TextField(
                        controller: _surnameController,
                        decoration: InputDecoration(hintText: 'Фамилия'),
                      )),
                  new Padding(padding: EdgeInsets.all(10.0)),
                  new Flexible(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(hintText: 'Имя'),
                      )),
                  new Padding(padding: EdgeInsets.all(10.0)),
                  new Flexible(
                      child: TextField(
                        controller: _patronymicController,
                        decoration: InputDecoration(hintText: 'Отчество'),
                      )),
                  new Padding(padding: EdgeInsets.all(10.0)),
                ],
              ),
              Row(
                children: <Widget>[
                  new Padding(padding: EdgeInsets.all(20.0)),
                  new Flexible(
                      child: TextField(
                        controller: _birthdateController,
                        decoration: InputDecoration(hintText: 'Дата рождения'),
                      )),
                  new Padding(padding: EdgeInsets.all(20.0)),
                  new Flexible(
                      child: TextField(
                        controller: _positionController,
                        decoration: InputDecoration(hintText: 'Должность'),
                      )),
                  new Padding(padding: EdgeInsets.all(20.0)),
                ],
              ),
              SizedBox(height: 10.0),
              Builder(
                builder: (context) =>
                    RaisedButton(
                        child: Text('Добавить в список'),
                        color: Colors.red,
                        textColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            if (_surnameController.text.isEmpty ||
                                _nameController.text.isEmpty ||
                                _patronymicController.text.isEmpty ||
                                _birthdateController.text.isEmpty ||
                                _positionController.text.isEmpty) {
                              Scaffold.of(context).showSnackBar(new SnackBar(
                                content: new Text("Заполните все поля"),
                                duration: Duration(seconds: 2),
                              ));
                            } else {
                              _listOfEmployees.add(new Employee(
                                  _surnameController.text,
                                  _nameController.text,
                                  _patronymicController.text,
                                  _birthdateController.text,
                                  _positionController.text,
                                  new List<EmployeeChild>()));
                            }
                          });
                        }),
              ),

              SizedBox(height: 20.0),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(10.0),
                  children: _listOfEmployees.reversed.map((employee) {
                    return SizedBox(
                      key: Key("key_employees"),
                      child: ListTile(
                        onTap: () {
                          _navigateToEmployeesChildren(context, employee);
                        },
                        title: Text(employee.surname +
                            ' ' +
                            employee.name +
                            ' ' +
                            employee.patronymicName),
                        subtitle: Text(
                            employee.position + ' | ' + employee.birthdate),
                        dense: true,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
