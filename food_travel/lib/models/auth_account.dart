class AuthAccount {
  AuthAccount({
    required this.phoneNumber,
    required this.displayName,
    required this.passwordHash,
    this.isAdmin = false,
  });

  final String phoneNumber;
  final String displayName;
  final String passwordHash;
  final bool isAdmin;

  factory AuthAccount.fromJson(Map<String, dynamic> json) {
    return AuthAccount(
      phoneNumber: json['phoneNumber'] as String,
      displayName: json['displayName'] as String,
      passwordHash: json['passwordHash'] as String,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'passwordHash': passwordHash,
      'isAdmin': isAdmin,
    };
  }
}
