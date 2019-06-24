import 'dart:io';

import 'package:staff_flutter/employee.dart';
import 'package:staff_flutter/employee_child.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initEmployeesDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TestDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Client ("
          "id INTEGER PRIMARY KEY,"
          "first_name TEXT,"
          "last_name TEXT,"
          "blocked BIT"
          ")");
    });
  }

  initEmployeesDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TestEmployeeDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Employee ("
          "id INTEGER PRIMARY KEY,"
          "surname TEXT,"
          "name TEXT,"
          "patronymicName TEXT,"
          "birthdate TEXT,"
          "position TEXT"
          ")");

      await db.execute("CREATE TABLE Employee_Child ("
          "id INTEGER PRIMARY KEY,"
          "surname TEXT,"
          "name TEXT,"
          "patronymicName TEXT,"
          "birthdate TEXT,"
          "parentId INTEGER,"
          "FOREIGN KEY(parentId) REFERENCES Employee(id)"
          ")");
    });
  }

  newEmployee(Employee newEmployee) async {
    final db = await database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Employee");
    int id = table.first["id"];
    var raw = await db.rawInsert(
        "INSERT Into Employee (id, surname, name, patronymicName, birthdate, position)"
        " VALUES (?,?,?,?,?,?)",
        [
          id,
          newEmployee.surname,
          newEmployee.name,
          newEmployee.patronymicName,
          newEmployee.birthdate,
          newEmployee.position
        ]);
    return raw;
  }

  newEmployeeChild(EmployeeChild newEmployeeChild) async {
    final db = await database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Employee_Child");
    int id = table.first["id"];
    var raw = await db.rawInsert(
        "INSERT Into Employee_Child (id, surname, name, patronymicName, birthdate, parentId)"
        " VALUES (?,?,?,?,?,?)",
        [
          id,
          newEmployeeChild.surname,
          newEmployeeChild.name,
          newEmployeeChild.patronymicName,
          newEmployeeChild.birthdate,
          newEmployeeChild.parentId
        ]);
    return raw;
  }

  getEmployee(int id) async {
    final db = await database;
    var res = await db.query("Employee", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Employee.fromMap(res.first) : null;
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await database;
    var res = await db.query("Employee");
    List<Employee> list =
        res.isNotEmpty ? res.map((c) => Employee.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<EmployeeChild>> getEmployeeChild(int employeeId) async {
    final db = await database;
    var res = await db.query("Employee_Child",
        where: "parentId = ?", whereArgs: [employeeId]);
    List<EmployeeChild> list =
        res.isNotEmpty ? res.map((c) => EmployeeChild.fromMap(c)).toList() : [];
    return list;
  }
}
