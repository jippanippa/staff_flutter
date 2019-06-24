class EmployeeChild {
  int id;
  String surname;
  String name;
  String patronymicName;
  String birthdate;
  int parentId;

  EmployeeChild(
      {this.id,
      this.surname,
      this.name,
      this.patronymicName,
      this.birthdate,
      this.parentId});

  factory EmployeeChild.fromMap(Map<String, dynamic> json) => new EmployeeChild(
      id: json["id"],
      surname: json["surname"],
      name: json["name"],
      patronymicName: json["patronymicName"],
      birthdate: json["birthdate"],
      parentId: json["parentId"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "surname": surname,
        "name": name,
        "patronymicName": patronymicName,
        "birthdate": birthdate,
        "parentId": parentId
      };
}
