class Employee {
  int id;
  String surname;
  String name;
  String patronymicName;
  DateTime birthdate;
  String position;

  Employee(
      {this.id,
      this.surname,
      this.name,
      this.patronymicName,
      this.birthdate,
      this.position});

  bool operator ==(otherEmployee) {
    return (otherEmployee is Employee &&
        surname == otherEmployee.surname &&
        name == otherEmployee.name &&
        patronymicName == otherEmployee.patronymicName &&
        birthdate == otherEmployee.birthdate);
  }

  factory Employee.fromMap(Map<String, dynamic> json) => new Employee(
      id: json["id"],
      surname: json["surname"],
      name: json["name"],
      patronymicName: json["patronymicName"],
      birthdate: DateTime.parse(json["birthdate"]),
      position: json["position"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "surname": surname,
        "name": name,
        "patronymicName": patronymicName,
        "birthdate": birthdate,
        "position": position
      };

  String getFullName() {
    return surname + " " + name + " " + patronymicName;
  }
}
