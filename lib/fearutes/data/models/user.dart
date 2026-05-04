import '../../../core/const/functions.dart';
import 'day.dart';

class UserClass {
  String? email;
  String? name;
  String? image;
  String? registerDate;
  List<Day> days = [];
  List<Day>? deletedDays = [];
  UserClass(
    this.email,
    this.name,
    this.image,
    this.registerDate,
    this.days, {
    this.deletedDays,
  });

  UserClass.fromJson(Map user, this.days) {
    email = user["email"];
    name = user["name"];
    image = user["image"];
    registerDate = user["registerDate"];
  }
  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'image': image,
    'registerDate': registerDate,
  };

  static UserClass defaultUser(String email) => UserClass(
    email,
    getNameFromEmail(email),
    'default',
    DateTime.now().toString(),
    [],
  );
}
