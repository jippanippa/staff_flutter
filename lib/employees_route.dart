import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_flutter/database_provider.dart';
import 'package:staff_flutter/employee.dart';
import 'package:staff_flutter/employees_children_route.dart';

class EmployeesRoute extends StatefulWidget {
  _EmployeesRouteState createState() => _EmployeesRouteState();
}

class _EmployeesRouteState extends State<EmployeesRoute> {
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _patronymicController = TextEditingController();

  DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'ru');

  TextEditingController _positionController = TextEditingController();

  List<Employee> _listOfEmployees = [];

  DateTime selectedBirthdate;
  DateTime initialDate = DateTime(
      DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        locale: const Locale('ru', 'RU'),
        firstDate: DateTime(DateTime.now().year - 100),
        lastDate: initialDate);
    if (picked != null && picked != selectedBirthdate)
      setState(() {
        selectedBirthdate = picked;
      });
  }

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

  void updateEmployeesList() async {
    _listOfEmployees = await DBProvider.db.getAllEmployees();
    setState(() {});
  }

  Widget makeEmployeeCard(Employee employee) {
    return Card(
        elevation: 3.0,
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Container(
          child: makeListTile(employee),
        ));
  }

  Widget makeListTile(Employee employee) {
    return ListTile(
        onTap: () {
          _navigateToEmployeesChildren(context, employee);
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        title: Text(
          employee.getFullName(),
          style:
              TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: <Widget>[
            Text(employee.position, style: TextStyle(color: Colors.grey[600]))
          ],
        ),
        trailing: Text(_dateFormat.format(employee.birthdate)));
  }

  _showRemovalConfirmationDialog(Employee employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Удалить запись о сотруднике ${employee.surname}?",
          ),
          content: Text("Данные детей сотрудника тоже будут удалены"),
          actions: <Widget>[
            FlatButton(
                child: Text("Отмена"),
                onPressed: () async {
                  updateEmployeesList();
                  Navigator.of(context).pop();
                }),
            FlatButton(
              child: Text("Да"),
              onPressed: () {
                DBProvider.db.deleteEmployee(employee.id);
                updateEmployeesList();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                  Padding(padding: EdgeInsets.all(10.0)),
                  Flexible(
                      child: TextField(
                    controller: _surnameController,
                    decoration: InputDecoration(
                      labelText: 'Фамилия',
                    ),
                  )),
                  Padding(padding: EdgeInsets.all(10.0)),
                  Flexible(
                      child: TextField(
                    style: TextStyle(fontSize: 14),
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Имя',
                    ),
                  )),
                  Padding(padding: EdgeInsets.all(10.0)),
                  Flexible(
                      child: TextField(
                    style: TextStyle(fontSize: 14),
                    controller: _patronymicController,
                    decoration: InputDecoration(
                      labelText: 'Отчество',
                    ),
                  )),
                  Padding(padding: EdgeInsets.all(10.0)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(20.0)),
                  RaisedButton(
                    onPressed: () => _selectDate(context),
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: selectedBirthdate == null
                        ? Text('Дата рождения', style: TextStyle(fontSize: 14))
                        : Text(_dateFormat.format(selectedBirthdate)),
                  ),
                  Padding(padding: EdgeInsets.all(20.0)),
                  Flexible(
                      child: TextField(
                    style: TextStyle(fontSize: 14),
                    controller: _positionController,
                    decoration: InputDecoration(
                      labelText: 'Должность',
                    ),
                  )),
                  Padding(padding: EdgeInsets.all(20.0)),
                ],
              ),
              Builder(
                builder: (context) => RaisedButton(
                    child: Text('Добавить в список'),
                    color: Colors.red,
                    textColor: Colors.white,
                    onPressed: () async {
                      if (_surnameController.text.isEmpty ||
                          _nameController.text.isEmpty ||
                          _patronymicController.text.isEmpty ||
                          _positionController.text.isEmpty) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("Заполните все поля"),
                          duration: Duration(seconds: 2),
                        ));
                      } else if (selectedBirthdate == null) {
                        Scaffold.of(context).showSnackBar(new SnackBar(
                          content: Text("Укажите дату рождения"),
                          duration: Duration(seconds: 2),
                        ));
                      } else {
                        var newEmployee = Employee(
                            surname: _surnameController.text[0].toUpperCase() +
                                _surnameController.text
                                    .substring(1)
                                    .toLowerCase(),
                            name: _nameController.text[0].toUpperCase() +
                                _nameController.text.substring(1).toLowerCase(),
                            patronymicName:
                                _patronymicController.text[0].toUpperCase() +
                                    _patronymicController.text
                                        .substring(1)
                                        .toLowerCase(),
                            birthdate: selectedBirthdate,
                            position:
                                _positionController.text[0].toUpperCase() +
                                    _positionController.text
                                        .substring(1)
                                        .toLowerCase());
                        if (_listOfEmployees.contains(newEmployee)) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text("Такой сотрудник уже указан!"),
                              duration: Duration(seconds: 2)));
                        } else {
                          await DBProvider.db.newEmployee(newEmployee);
                          _listOfEmployees =
                              await DBProvider.db.getAllEmployees();
                        }
                      }
                      setState(() {});
                    }),
              ),
              Expanded(
                child: ListView(
                  children: _listOfEmployees.reversed.map((employee) {
                    return Dismissible(
                      key: Key("key_employee_" + employee.id.toString()),
                      child: makeEmployeeCard(employee),
                      confirmDismiss: (direction) {
                        _showRemovalConfirmationDialog(employee);
                      },
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
