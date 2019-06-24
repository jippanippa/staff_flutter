class Employee {
  int id;
  String surname;
  String name;
  String patronymicName;
  String birthdate;
  String position;

  Employee(
      {this.id,
      this.surname,
      this.name,
      this.patronymicName,
      this.birthdate,
      this.position});

  factory Employee.fromMap(Map<String, dynamic> json) => new Employee(
      id: json["id"],
      surname: json["surname"],
      name: json["name"],
      patronymicName: json["patronymicName"],
      birthdate: json["birthdate"],
      position: json["position"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "surname": surname,
        "name": name,
        "patronymicName": patronymicName,
        "birthdate": birthdate,
        "position": position
      };
}
