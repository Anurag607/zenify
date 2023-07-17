class UserModel {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final dynamic address;
  final dynamic city;
  final dynamic state;
  final dynamic zipCode;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.address,
    this.city,
    this.state,
    this.zipCode,
  });
}

class UserDetails {
  UserDetails({required this.name, required this.email});

  String? name;
  String? email;

  String? get getName {
    return name;
  }

  String? get getEmail {
    return email;
  }

  set setName(String name) {
    this.name = name;
  }

  set setEmail(String email) {
    this.email = email;
  }
}
