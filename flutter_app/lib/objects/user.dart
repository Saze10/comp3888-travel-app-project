class LocalUser {
  String uid;
  String name;
  String email;
  String gender;
  Map preference;
  List trips;
  List saved;
  String? photoURL;
  LocalUser({required this.uid,
    required this.name,
    required this.email,
    required this.gender,
    required this.preference,
    required this.trips,
    required this.saved,
    this.photoURL});
}