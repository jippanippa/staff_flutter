import 'package:flutter/material.dart';
import 'package:staff_flutter/database_provider.dart';
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

  List<Employee> _listOfEmployees = [];

  void _navigateToEmployeesChildren(BuildContext context, Employee employee) {
    Navigator.of(context)
        .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
      return Scaffold(
        body: EmployeesChildrenRoute(parent: employee),
      );
    }));
  }

  @override
  void didChangeDependencies() async {
    if (_listOfEmployees.isEmpty) {
      _listOfEmployees = await DBProvider.db.getAllEmployees();
    }

    setState(() {});
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
                builder: (context) => RaisedButton(
                    child: Text('Добавить в список'),
                    color: Colors.red,
                    textColor: Colors.white,
                    onPressed: () async {
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
                        var novyEmployee = new Employee(
                            surname: _surnameController.text,
                            name: _nameController.text,
                            patronymicName: _patronymicController.text,
                            birthdate: _birthdateController.text,
                            position: _positionController.text);

                        await DBProvider.db.newEmployee(novyEmployee);
                        _listOfEmployees =
                            await DBProvider.db.getAllEmployees();
                      }

                      setState(() {});
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
                        title: Text(employee.id.toString() +
                            ": " +
                            employee.surname +
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
