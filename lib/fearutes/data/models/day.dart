import '../../../core/const/vars.dart';
import 'highlight.dart';
import 'mood.dart';

class Day {
  Mood? mood;
  String? name;
  String? date;
  String? details;
  String? lastUpdateDate;
  String? status;
  List<Highlight>? highlights;
  List<Highlight>? deletedHighlights;
  String? userEmail;

  Day(
    this.mood,
    this.name,
    this.date,
    this.details,
    this.userEmail,
    this.highlights,
    this.lastUpdateDate,
    this.status, {
    this.deletedHighlights = const [],
  });
  Day.fromJson(Map day, List<Highlight> allHighlights, {String ? email}) {
    mood = moods[day["moodId"] ?? day["mood"]];
    date = day["date"];
    details = day["details"];
    userEmail = day["userEmail"]??email;
    name = day["name"];
    status = day["status"];
    lastUpdateDate = day["lastUpdateDate"];
    highlights = allHighlights.where((h) => h.status != "deleted").toList();
    deletedHighlights = allHighlights
        .where((h) => h.status == "deleted")
        .toList();
  }

  Map<String, Object?> toJson() {
    return {
      "moodId": moods.indexOf(mood!),
      "date": date,
      "details": details,
      "userEmail": userEmail,
      "name": name,
      "status": status ?? "available",
      "lastUpdateDate": lastUpdateDate,
    };
  }
}
