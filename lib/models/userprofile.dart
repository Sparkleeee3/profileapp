class UserProfile {
  final String uid;
  final String name;
  final String bio;
  final String photoUrl;
  final String email;

  UserProfile({
    required this.uid,
    required this.name,
    required this.bio,
    required this.photoUrl,
    required this.email,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'bio': bio,
    'photoUrl': photoUrl,
    'email': email,
  };

  UserProfile copyWith({String? name, String? bio, String? photoUrl}) {
    return UserProfile(
      uid: uid,
      email: email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}