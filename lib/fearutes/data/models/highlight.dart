class Highlight {
  String? id;
  String? date;
  String? title;
  String? image;
  String? status;

  Highlight(this.id, this.date, this.title, this.image, this.status);

  Highlight.fromJson(Map highlight) {
    id = highlight["highlight_id"]??highlight["id"];
    title = highlight["title"];
    date = highlight["date"];
    image = highlight["image"];
    status = highlight["status"] ?? "available";
  }

  Map<String, Object?> toJson() {
    return {
      "highlight_id": id,
      "title": title,
      "date": date,
      "image": image,
      "status": status,
    };
  }
}
