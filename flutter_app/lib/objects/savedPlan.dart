class SavedPlan {
  String uid;
  String email;
  String tripDuration;
  String startDate;
  Map tripInterests;
  String title;
  List friendsID;
  String id;
  //List tripInterests;
  //Map dayInterests;
  //save as {day1:{interest1:detatiled place, interest2:detailed place}, day2:}
  SavedPlan({
    required this.uid,
    required this.email,
    required this.tripDuration,
    required this.startDate,
    required this.tripInterests,
    required this.title,
    required this.friendsID,
    required this.id,
  });
}