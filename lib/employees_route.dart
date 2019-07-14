import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_flutter/bloc_base.dart';
import 'package:staff_flutter/blocs.dart';
import 'package:staff_flutter/employee.dart';
import 'package:staff_flutter/employees_children_route.dart';

class EmployeesRoute extends StatefulWidget {
  _EmployeesRouteState createState() => _EmployeesRouteState();
}

class _EmployeesRouteState extends State<EmployeesRoute> {
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'ru');

  EmployeeBloc employeeBloc;
  StreamSubscription<bool> subscription;

  @override
  void initState() {
    super.initState();
    employeeBloc = BlocProvider.of<EmployeeBloc>(context);
    subscription = employeeBloc.outExistenceCheck.listen(null);
  }

  @override
  void dispose() {
    subscription.cancel();
  }

  _navigateToEmployeesChildren(BuildContext context, Employee employee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
              bloc: EmployeeChildBloc(employee.id),
              child: EmployeesChildrenRoute(parent: employee),
            ),
      ),
    );
  }

  makeEmployeeCard(Employee employee) {
    return Card(
        elevation: 3.0,
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Container(
          child: makeListTile(employee),
        ));
  }

  makeListTile(Employee employee) {
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

  _showEmployeeEntryCreatorDialog(
      StreamSubscription subscription, EmployeeBloc employeeBloc) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EmployeeEntryCreatorDialog(
          subscription: subscription, employeeBloc: employeeBloc),
    ));
  }

  _showRemovalConfirmationDialog(
      Employee employee, EmployeeBloc employeeListBloc) {
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
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            FlatButton(
              child: Text("Да"),
              onPressed: () {
                employeeListBloc.removeEmployeeExternal.add(employee.id);
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
        child: StreamBuilder<List<Employee>>(
            stream: employeeBloc.outEmployeeList,
            initialData: [],
            builder:
                (BuildContext context, AsyncSnapshot<List<Employee>> snapshot) {
              return Center(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(10.0),
                        children: snapshot.data.reversed.map((employee) {
                          return Dismissible(
                            key: Key("key_employee_" + employee.id.toString()),
                            child: makeEmployeeCard(employee),
                            confirmDismiss: (direction) async {
                              return _showRemovalConfirmationDialog(
                                  employee, employeeBloc);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showEmployeeEntryCreatorDialog(subscription, employeeBloc),
        child: Icon(Icons.add),
      ),
    );
  }
}

class EmployeeEntryCreatorDialog extends StatefulWidget {
  final EmployeeBloc employeeBloc;
  final StreamSubscription<bool> subscription;

  const EmployeeEntryCreatorDialog({this.subscription, this.employeeBloc});

  @override
  State<StatefulWidget> createState() => _EmployeeEntryCreatorState();
}

class _EmployeeEntryCreatorState extends State<EmployeeEntryCreatorDialog> {
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _patronymicController = TextEditingController();
  TextEditingController _positionController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'ru');

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

  _showSnackbar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: Text(text),
      duration: Duration(seconds: 2),
    ));
  }

  _checkIfRequiredDataExists() {
    return _surnameController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _patronymicController.text.isEmpty ||
        _positionController.text.isEmpty;
  }

  _handleIfExistsValue(BuildContext context, bool exists) async {
    if (exists) {
      _showSnackbar(context, "Такой сотрудник уже указан!");
    } else {
      Navigator.of(context).pop();
    }
  }

  _createNewEmployeeAndAddItToTheDB(BuildContext context) async {
    widget.subscription.onData((exists) {
      _handleIfExistsValue(context, exists);
    });

    var newEmployee = Employee(
        surname: _surnameController.text[0].toUpperCase() +
            _surnameController.text.substring(1).toLowerCase(),
        name: _nameController.text[0].toUpperCase() +
            _nameController.text.substring(1).toLowerCase(),
        patronymicName: _patronymicController.text[0].toUpperCase() +
            _patronymicController.text.substring(1).toLowerCase(),
        birthdate: selectedBirthdate,
        position: _positionController.text[0].toUpperCase() +
            _positionController.text.substring(1).toLowerCase());

    widget.employeeBloc.addEmployeeExternal.add(newEmployee);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый сотрудник'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              child: TextField(
                controller: _surnameController,
                style: Theme.of(context).textTheme.display1,
                decoration: InputDecoration(
                  labelStyle: Theme.of(context).textTheme.display1,
                  labelText: 'Фамилия',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              child: TextField(
                controller: _nameController,
                style: Theme.of(context).textTheme.display1,
                decoration: InputDecoration(
                  labelStyle: Theme.of(context).textTheme.display1,
                  labelText: 'Имя',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              child: TextField(
                controller: _patronymicController,
                style: Theme.of(context).textTheme.display1,
                decoration: InputDecoration(
                  labelStyle: Theme.of(context).textTheme.display1,
                  labelText: 'Отчество',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              child: TextField(
                controller: _positionController,
                style: Theme.of(context).textTheme.display1,
                decoration: InputDecoration(
                  labelStyle: Theme.of(context).textTheme.display1,
                  labelText: 'Должность',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 43.0),
              child: RaisedButton(
                onPressed: () => _selectDate(context),
                color: Colors.blue,
                textColor: Colors.white,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                child: selectedBirthdate == null
                    ? Text('Укажите дату рождения',
                        style: TextStyle(fontSize: 20))
                    : Text(_dateFormat.format(selectedBirthdate),
                        style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
              onPressed: () async {
                if (_checkIfRequiredDataExists()) {
                  _showSnackbar(context, "Заполните все поля");
                } else if (selectedBirthdate == null) {
                  _showSnackbar(context, "Укажите дату рождения");
                } else {
                  _createNewEmployeeAndAddItToTheDB(context);
                }
              },
              child: Icon(Icons.done),
            ),
      ),
    );
  }
}
