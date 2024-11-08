class MyUser {
  String? uid;
  String? name;
  String? phone;
  String? password;

  MyUser({this.uid, this.name, this.phone, this.password});

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'password': password,
    };
  }

  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser(
        uid: json['uid'],
        name: json['name'],
        phone: json['phone'],
        password: json['password'],
    );
  }
}