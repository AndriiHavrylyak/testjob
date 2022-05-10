class TodoInfo {
  String todoText;
  bool todoCheck;

  TodoInfo({required this.todoText, required this.todoCheck});

  factory TodoInfo.fromJson(Map<String, dynamic> json) {
    return TodoInfo(todoText: json["todoText"], todoCheck: json["todoCheck"]);
  }

  Map<String, dynamic> toJson() {
    return {"todoText": todoText, "todoCheck": todoCheck};
  }
}