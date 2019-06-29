import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_flutter/database_provider.dart';
import 'package:staff_flutter/employee.dart';
import 'package:staff_flutter/employee_child.dart';

class EmployeesChildrenRoute extends StatefulWidget {
  final Employee parent;

  const EmployeesChildrenRoute({@required this.parent})
      : assert(parent != null);

  _EmployeesChildrenRouteState createState() => _EmployeesChildrenRouteState();
}

class _EmployeesChildrenRouteState extends State<EmployeesChildrenRoute> {
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _patronymicController = TextEditingController();
  DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'ru');

  List<EmployeeChild> _listOfEmployeesChildren = [];

  DateTime selectedBirthdate;
  DateTime initialDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        locale: const Locale('ru', 'RU'),
        firstDate: DateTime(DateTime.now().year -
            (DateTime.now().year - widget.parent.birthdate.year - 12)),
        lastDate: initialDate);
    if (picked != null && picked != selectedBirthdate)
      setState(() {
        selectedBirthdate = picked;
      });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_listOfEmployeesChildren.isEmpty) {
      _listOfEmployeesChildren =
          await DBProvider.db.getEmployeeChilden(widget.parent.id);
    }
    setState(() {});
  }

  void updateEmployeesList() async {
    _listOfEmployeesChildren =
        await DBProvider.db.getEmployeeChilden(widget.parent.id);
    setState(() {});
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

  _showRemovalConfirmationDialog(EmployeeChild employeeChild) {
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
                onPressed: () async {
                  updateEmployeesList();
                  Navigator.of(context).pop();
                }),
            FlatButton(
              child: Text("Да"),
              onPressed: () {
                DBProvider.db.deleteEmployeeChild(employeeChild.id);
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
        title: Text(widget.parent.surname + ': дети'),
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
                    style: TextStyle(fontSize: 14),
                    controller: _surnameController,
                    decoration: InputDecoration(labelText: 'Фамилия'),
                  )),
                  new Padding(padding: EdgeInsets.all(10.0)),
                  new Flexible(
                      child: TextField(
                    style: TextStyle(fontSize: 14),
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Имя'),
                  )),
                  new Padding(padding: EdgeInsets.all(10.0)),
                  new Flexible(
                      child: TextField(
                    style: TextStyle(fontSize: 14),
                    controller: _patronymicController,
                    decoration: InputDecoration(labelText: 'Отчество'),
                  )),
                  new Padding(padding: EdgeInsets.all(10.0)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.symmetric(vertical: 30.0)),
                  new RaisedButton(
                    onPressed: () => _selectDate(context),
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: selectedBirthdate == null
                        ? Text('Дата рождения')
                        : Text(_dateFormat.format(selectedBirthdate)),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Builder(
                builder: (context) => RaisedButton(
                    child: Text('Добавить ребёнка'),
                    color: Colors.red,
                    textColor: Colors.white,
                    onPressed: () async {
                      if (_surnameController.text.isEmpty ||
                          _nameController.text.isEmpty ||
                          _patronymicController.text.isEmpty) {
                        Scaffold.of(context).showSnackBar(new SnackBar(
                          content: new Text("Заполните все поля"),
                          duration: Duration(seconds: 2),
                        ));
                      } else if (selectedBirthdate == null) {
                        Scaffold.of(context).showSnackBar(new SnackBar(
                          content: new Text("Укажите дату рождения"),
                          duration: Duration(seconds: 2),
                        ));
                      } else {
                        var employeeChild = new EmployeeChild(
                          surname: _surnameController.text[0].toUpperCase() +
                              _surnameController.text
                                  .substring(1)
                                  .toLowerCase(),
                          name: _nameController.text[0].toUpperCase() +
                              _nameController.text.substring(1).toLowerCase(),
                          patronymicName: _patronymicController.text[0]
                                  .toUpperCase() +
                              _nameController.text.substring(1).toLowerCase(),
                          birthdate: selectedBirthdate,
                          parentId: widget.parent.id,
                        );

                        if (_listOfEmployeesChildren.contains(employeeChild)) {
                          Scaffold.of(context).showSnackBar(new SnackBar(
                              content: new Text(
                                  "Такой ребёнок у сотрудника уже указан!"),
                              duration: Duration(seconds: 2)));
                        } else {
                          await DBProvider.db.newEmployeeChild(employeeChild);
                          _listOfEmployeesChildren = await DBProvider.db
                              .getEmployeeChilden(widget.parent.id);
                        }
                      }
                      setState(() {});
                    }),
              ),
              SizedBox(height: 20.0),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(10.0),
                  children:
                      _listOfEmployeesChildren.reversed.map((employeeChild) {
                    return Dismissible(
                      key: Key(
                          "key_employee_child" + employeeChild.id.toString()),
                      child: makeEmployeeChildCard(employeeChild),
                      confirmDismiss: (direction) {
                        _showRemovalConfirmationDialog(employeeChild);
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
