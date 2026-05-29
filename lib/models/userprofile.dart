class UserProfile {
  final String uid;
  final String name;
  final String bio;
  final String cnum;
  final String email;
  final String gender;
  final String bday;

  UserProfile({
    required this.uid,
    required this.name,
    required this.bio,
    required this.cnum,
    required this.email,
    required this.gender,
    required this.bday,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      cnum: map['cnum'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      bday: map['bday'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'bio': bio,
    'cnum': cnum,
    'email': email,
    'gender': gender,
    'bday': bday,
  };

  UserProfile copyWith({String? name, String? bio, String? cnum, String? gender,
  String? bday}) {
    return UserProfile(
      uid: uid,
      email: email,
      name: name ?? this.name,
      cnum: cnum ?? this.cnum,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      bday: bday ?? this.bday,
    );
  }
}