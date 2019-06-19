import 'package:flutter/material.dart';
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
  TextEditingController _birthdateController = TextEditingController();

  List<EmployeeChild> _listOfEmployeesChildren = [];

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (_listOfEmployeesChildren.isEmpty) {
      await _retrieveEmployees();
    }
  }

  Future<void> _retrieveEmployees() async {
    _listOfEmployeesChildren.addAll(widget.parent.children);
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
                  new Padding(padding: EdgeInsets.all(40.0)),
                  new Flexible(
                      child: TextField(
                    controller: _birthdateController,
                    decoration: InputDecoration(hintText: 'Дата рождения'),
                  )),
                  new Padding(padding: EdgeInsets.all(40.0)),
                ],
              ),
              SizedBox(height: 10.0),
              Builder(
                builder: (context) => RaisedButton(
                    child: Text('Добавить ребёнка'),
                    color: Colors.red,
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        if (_surnameController.text.isEmpty ||
                            _nameController.text.isEmpty ||
                            _patronymicController.text.isEmpty ||
                            _birthdateController.text.isEmpty) {
                          Scaffold.of(context).showSnackBar(new SnackBar(
                            content: new Text("Заполните все поля"),
                            duration: Duration(seconds: 2),
                          ));
                        } else {
                          var employeeChild = new EmployeeChild(
                              _surnameController.text,
                              _nameController.text,
                              _patronymicController.text,
                              _birthdateController.text);

                          _listOfEmployeesChildren.add(employeeChild);
                        }
                      });
                    }),
              ),
              SizedBox(height: 20.0),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(10.0),
                  children:
                      _listOfEmployeesChildren.reversed.map((employeeChild) {
                    return SizedBox(
                      key: Key("key_employees_children"),
                      child: ListTile(
                        title: Text(employeeChild.surname +
                            ' ' +
                            employeeChild.name +
                            ' ' +
                            employeeChild.patronymicName),
                        subtitle: Text(employeeChild.birthdate),
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
