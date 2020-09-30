class User {
  final int userId;
  String login;
  String password;
  String name;
  String surname;

  User(this.userId, {this.login, this.password, this.name, this.surname});

  factory User.fromJson(Map<String, dynamic> json) => User(
      json["userid"] as int,
      login: json["login"] as String,
      password: json["password"] as String,
      name: json["name"] as String,
      surname: json["surname"] as String
  );
}