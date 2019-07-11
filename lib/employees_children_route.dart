import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_flutter/bloc_base.dart';
import 'package:staff_flutter/blocs.dart';
import 'package:staff_flutter/employee.dart';
import 'package:staff_flutter/employee_child.dart';

class EmployeesChildrenRoute extends StatefulWidget {
  final Employee parent;

  const EmployeesChildrenRoute({@required this.parent})
      : assert(parent != null);

  _EmployeesChildrenRouteState createState() => _EmployeesChildrenRouteState();
}

class _EmployeesChildrenRouteState extends State<EmployeesChildrenRoute> {
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'ru');

  EmployeeChildBloc employeeChildBloc;
  StreamSubscription<bool> subscription;

  @override
  void initState() {
    super.initState();
    employeeChildBloc = BlocProvider.of<EmployeeChildBloc>(context);
    subscription = employeeChildBloc.outChildExistenceCheck.listen(null);
  }

  Widget makeEmployeeChildCard(EmployeeChild employeeChild) {
    return Card(
        elevation: 3.0,
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Container(
          child: makeListTile(employeeChild),
        ));
  }

  Widget makeListTile(EmployeeChild employeeChild) {
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        title: Text(
          employeeChild.getFullName(),
          style:
              TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
        ),
        trailing: Text(_dateFormat.format(employeeChild.birthdate)));
  }

  _showEmployeeChildEntryCreatorDialog({EmployeeChildBloc employeeChildBloc}) {
    Navigator.of(context)
        .push(new MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return EmployeeChildEntryCreatorDialog(parent: widget.parent, subscription: subscription, employeeChildBloc: employeeChildBloc);
            },
            fullscreenDialog: true));
  }

  _showRemovalConfirmationDialog(
      EmployeeChild employeeChild, EmployeeChildBloc employeeChildBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Удалить запись о ${employeeChild.surname} ${employeeChild.name}?",
          ),
          content: Text("Ребенок сотрудника ${widget.parent.surname}"),
          actions: <Widget>[
            FlatButton(
                child: Text("Отмена"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            FlatButton(
              child: Text("Да"),
              onPressed: () {
                employeeChildBloc.removeEmployeeChildExternal.add(employeeChild);
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
        title: Text(widget.parent.surname + ': дети'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: StreamBuilder<List<EmployeeChild>>(
          stream: employeeChildBloc.outEmployeeChildrenList,
          initialData: [],
          builder: (BuildContext context, AsyncSnapshot<List<EmployeeChild>> snapshot) {
            return Center(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(10.0),
                      children: snapshot.data.reversed.map((employeeChild) {
                        return Dismissible(
                          key: Key("key_employee_child_" + employeeChild.id.toString()),
                          child: makeEmployeeChildCard(employeeChild),
                          confirmDismiss: (direction) async {
                            _showRemovalConfirmationDialog(
                                employeeChild, employeeChildBloc);
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
          onPressed: () => _showEmployeeChildEntryCreatorDialog(employeeChildBloc: employeeChildBloc),
          child: Icon(Icons.add)),
    );
  }
}

class EmployeeChildEntryCreatorDialog extends StatefulWidget {
  final Employee parent;
  final EmployeeChildBloc employeeChildBloc;
  final StreamSubscription<bool> subscription;

  const EmployeeChildEntryCreatorDialog({@required this.parent, this.subscription, this.employeeChildBloc})
      : assert(parent != null);

  @override
  State<StatefulWidget> createState() => _EmployeeChildEntryCreatorState();
}

class _EmployeeChildEntryCreatorState extends State<EmployeeChildEntryCreatorDialog> {
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _patronymicController = TextEditingController();
  DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'ru');

  DateTime selectedBirthdate;
  DateTime initialDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        locale: const Locale('ru', 'RU'),
        firstDate: DateTime(DateTime.now().year - (DateTime.now().year - widget.parent.birthdate.year - 12)),
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
        _patronymicController.text.isEmpty;
  }

  _handleIfExistsValue(BuildContext context, bool exists) async {
    if (exists) {
      _showSnackbar(context, "Такой ребёнок у сотрудника уже указан!");
    } else {
      Navigator.of(context).pop();
    }
  }

  _createNewEmployeeChildAndAddItToTheDB(BuildContext context) async {
    widget.subscription.onData((exists) {
      _handleIfExistsValue(context, exists);
    });

    var newEmployeeChild = EmployeeChild(
        surname: _surnameController.text[0].toUpperCase() +
            _surnameController.text.substring(1).toLowerCase(),
        name: _nameController.text[0].toUpperCase() +
            _nameController.text.substring(1).toLowerCase(),
        patronymicName: _patronymicController.text[0].toUpperCase() +
            _patronymicController.text.substring(1).toLowerCase(),
        birthdate: selectedBirthdate,
        parentId: widget.parent.id);

      widget.employeeChildBloc.addEmployeeChildExternal.add(newEmployeeChild);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.parent.surname}: новый ребенок'),
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
                  _createNewEmployeeChildAndAddItToTheDB(context);
                }
              },
              child: Icon(Icons.done),
            ),
      ),
    );
  }
}
