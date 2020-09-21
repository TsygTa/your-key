class User {
  int userId;
  String name;
  String surname;

  User({this.userId, this.name, this.surname});

  factory User.fromJson(Map<String, dynamic> json) => User(
      userId: json["userid"] as int,
      name: json["name"] as String,
      surname: json["surname"] as String
  );
}