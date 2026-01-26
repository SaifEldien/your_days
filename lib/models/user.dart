import 'day.dart';

class UserClass {
  String? email;
  String? name;
  String? image;
  String? registerDate;
   List<Day>? days;
  UserClass(this.email, this.name, this.image, this.registerDate,this.days);

  UserClass.fromJson ( user, List<Day> this.days) {
    email = user["email"];
    name = user["name"];
    image = user["image"];
    registerDate = user["registerDate"];
  }
  Map toJson ()=> {
    'email' : email,
    'name' : name,
    'image' : image,
    'registerDate' : registerDate
  };
}
