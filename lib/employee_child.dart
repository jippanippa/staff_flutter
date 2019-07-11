class EmployeeChild {
  int id;
  String surname;
  String name;
  String patronymicName;
  DateTime birthdate;
  int parentId;

  EmployeeChild(
      {this.id,
      this.surname,
      this.name,
      this.patronymicName,
      this.birthdate,
      this.parentId});

  bool operator ==(otherChild) {
    return (otherChild is EmployeeChild &&
        surname == otherChild.surname &&
        name == otherChild.name &&
        patronymicName == otherChild.patronymicName &&
        birthdate == otherChild.birthdate);
  }

  factory EmployeeChild.fromMap(Map<String, dynamic> json) => new EmployeeChild(
      id: json["id"],
      surname: json["surname"],
      name: json["name"],
      patronymicName: json["patronymicName"],
      birthdate: DateTime.parse(json["birthdate"]),
      parentId: json["parentId"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "surname": surname,
        "name": name,
        "patronymicName": patronymicName,
        "birthdate": birthdate,
        "parentId": parentId
      };

  String getFullName() {
    return surname + " " + name + " " + patronymicName;
  }
}
