class Highlight {
  String? id;
  String? date;
  String? title;
  String? image;
  Highlight(this.id,this.date,this.title,this.image);
  Highlight.fromJson(Map<String, dynamic> highlight) {
    id = highlight["highlight_id"];
    title = highlight["title"];
    date = highlight ["date"];
    image = highlight ["image"];
  }
  Map<String, dynamic> toJson() {
    return {
      "highlight_id": id,
      "title": title,
      "date": date,
      "image": image,
    };
  }

}