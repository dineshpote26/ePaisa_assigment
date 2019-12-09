class Result {
  String name;
  String first_name;
  String last_name;
  String email;

  Result(
      {this.name, this.first_name, this.last_name, this.email});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
      name: json["name"],
      first_name: json["first_name"],
      last_name: json["last_name"],
      email: json["email"]);

  Map<String, dynamic> toJson() => {
        "name": name,
        "first_name": first_name,
        "last_name": last_name,
        "email": email
      };
}
