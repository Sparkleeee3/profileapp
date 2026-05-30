class UserProfile {
  final String uid;
  final String name;
  final String bio;
  final String cnum;
  final String email;
  final String gender;
  final String bday;
  final bool privateCnum;
  final bool privateGender;
  final bool privateBday;
  final bool privateEmail;

  UserProfile({
    required this.uid,
    required this.name,
    required this.bio,
    required this.cnum,
    required this.email,
    required this.gender,
    required this.bday,
    this.privateCnum   = false,
    this.privateGender = false,
    this.privateBday   = false,
    this.privateEmail  = false,
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
      privateCnum:   map['privateCnum']   ?? false,
      privateGender: map['privateGender'] ?? false,
      privateBday:   map['privateBday']   ?? false,
      privateEmail:  map['privateEmail']  ?? false,
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
    'privateCnum':   privateCnum,
    'privateGender': privateGender,
    'privateBday':   privateBday,
    'privateEmail':  privateEmail,
  };

  UserProfile copyWith({String? name, String? bio, String? cnum, String? gender,
  String? bday,bool? privateCnum, bool? privateGender, bool? privateBday, bool? privateEmail, })
{
    return UserProfile(
      uid: uid,
      email: email,
      name: name ?? this.name,
      cnum: cnum ?? this.cnum,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      bday: bday ?? this.bday,
      privateCnum:   privateCnum   ?? this.privateCnum,
      privateGender: privateGender ?? this.privateGender,
      privateBday:   privateBday   ?? this.privateBday,
      privateEmail:  privateEmail  ?? this.privateEmail,

    );
  }
}