import 'dart:async';

import 'package:staff_flutter/bloc_base.dart';
import 'package:staff_flutter/database_provider.dart';
import 'package:staff_flutter/employee.dart';
import 'package:staff_flutter/employee_child.dart';

class EmployeeBloc implements BlocBase {
  StreamController<List<Employee>> _employeeListController = StreamController<List<Employee>>.broadcast();
  StreamSink<List<Employee>> get _inAddEmployeeSink => _employeeListController.sink;
  Stream<List<Employee>> get outEmployeeList => _employeeListController.stream;

  StreamController<Employee> _addEmployeeController = StreamController<Employee>();
  StreamSink<Employee> get addEmployeeExternal => _addEmployeeController.sink;

  StreamController<int> _removeEmployeeController = StreamController<int>();
  StreamSink<int> get removeEmployeeExternal => _removeEmployeeController.sink;

  StreamController<bool> _checkIfEmployeeExistsController = StreamController<bool>();
  StreamSink<bool> get _inEmployeeForExistenceCheck => _checkIfEmployeeExistsController.sink;
  Stream<bool> get outExistenceCheck => _checkIfEmployeeExistsController.stream;

  get closeExistenceCheckController =>_checkIfEmployeeExistsController.close();

  EmployeeBloc() {
    _getEmployeeList();

    _addEmployeeController.stream.listen(_handleAddEmployee);
    _removeEmployeeController.stream.listen((id) => _handleRemoveEmployee(id));
  }

  _getEmployeeList() async {
    List<Employee>  _listOfEmployees = await DBProvider.db.getAllEmployees();
    _inAddEmployeeSink.add(_listOfEmployees);
  }

  _handleAddEmployee(Employee employee) async {
    List<Employee>  _listOfEmployees = await DBProvider.db.getAllEmployees();

    if(!_listOfEmployees.contains(employee)) {
      await DBProvider.db.newEmployee(employee);
      _getEmployeeList();
      _inEmployeeForExistenceCheck.add(false);
    } else {
      _inEmployeeForExistenceCheck.add(true);
    }
  }

  _handleRemoveEmployee(int id) async {
    await DBProvider.db.deleteEmployee(id);
    _getEmployeeList();
  }


  @override
  void dispose(){
    _employeeListController.close();
    _addEmployeeController.close();
    _removeEmployeeController.close();

    _checkIfEmployeeExistsController.close();
  }
}


class EmployeeChildBloc implements BlocBase {
  StreamController<List<EmployeeChild>> _employeeChildListController = StreamController<List<EmployeeChild>>();
  StreamSink<List<EmployeeChild>> get _inAddEmployeeChildSink => _employeeChildListController.sink;
  Stream<List<EmployeeChild>> get outEmployeeChildrenList => _employeeChildListController.stream;


  StreamController<EmployeeChild> _addEmployeeChildController = StreamController<EmployeeChild>();
  StreamSink<EmployeeChild> get addEmployeeChildExternal => _addEmployeeChildController.sink;

  StreamController<EmployeeChild> _removeEmployeeChildController = StreamController<EmployeeChild>();
  StreamSink<EmployeeChild> get removeEmployeeChildExternal => _removeEmployeeChildController.sink;

  EmployeeChildBloc(int employeeId) {
    _getEmployeeChildrenList(employeeId);

    _addEmployeeChildController.stream.listen(_handleAddEmployeeChild);
    _removeEmployeeChildController.stream.listen((employeeChild) => _handleRemoveEmployeeChild(employeeChild));
  }

  _getEmployeeChildrenList(employeeId) async {
    List<EmployeeChild>  _listOfEmployeeChildren = await DBProvider.db.getEmployeeChildren(employeeId);
    _inAddEmployeeChildSink.add(_listOfEmployeeChildren);
  }

  _handleAddEmployeeChild(EmployeeChild employeeChild) async {
    await DBProvider.db.newEmployeeChild(employeeChild);
    _getEmployeeChildrenList(employeeChild.parentId);
  }

  _handleRemoveEmployeeChild(EmployeeChild employeeChild) async {
    await DBProvider.db.deleteEmployeeChild(employeeChild.id);
    _getEmployeeChildrenList(employeeChild.parentId);
  }

  @override
  void dispose() {
    _employeeChildListController.close();
    _addEmployeeChildController.close();
    _removeEmployeeChildController.close();
  }
}
