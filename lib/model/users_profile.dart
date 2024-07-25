class UserProfile {
  String? uid;
  String? name;
  String? pfpURL;
  String? email;
  String? dateOfBirth; // Add date of birth field

  UserProfile({
    required this.uid,
    required this.name,
    required this.pfpURL,
    required this.email,
    required this.dateOfBirth,
  });

  // Named constructor for JSON deserialization
  UserProfile.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        name = json['name'],
        pfpURL = json['pfpURL'],
        email = json['email'],
        dateOfBirth = json['dateOfBirth'];

  // Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'pfpURL': pfpURL,
      'email': email,
      'dateOfBirth': dateOfBirth,
    };
  }
}
