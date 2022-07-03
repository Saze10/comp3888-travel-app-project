import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/Calendar.dart';
import 'package:flutter_app/screens/AddInterests.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_app/screens/models/ListofInterests.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_place/google_place.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/firebase_services/database_service.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_app/firebase_services/database_makePlan.dart';
import 'package:flutter_app/objects/personalPlan.dart';
import 'package:flutter_app/objects/savedPlan.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Calendar extends StatefulWidget {
  final FirebaseFirestore? firebase;
  const Calendar({Key? key,this.firebase}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  FirebaseFirestore? firebase;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  User? user = UserServices.getUserInfo();
  LocalUser? localUser;
  DayPlan? dayPlan;

  void initState() {
    super.initState();
    firebase = widget.firebase;
  }
  @override

  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firebase == null ? DatabaseMakePlan().streamDayPlanDataSnapshot : firebase?.collection('day_plan').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

        if (snapshot.hasError) {
        return Text('Something went wrong');
        }
        if (snapshot.data == null) {
        return Text('Loading');
        }
        dayPlan = UserServices.getDayPlanBySnapshot(snapshot);

        return Scaffold(
          appBar: AppBar(
            title: Text('TableCalendar'),
          ),
          body: Column(
              children: <Widget>[
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.utc(2050, 12, 01),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              // Use `selectedDayPredicate` to determine which day is currently selected.
              // If this returns true, then `day` will be marked as selected.

              // Using `isSameDay` is recommended to disregard
              // the time-part of compared DateTime objects.
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                // Call `setState()` when updating the selected day
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;

                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                // Call `setState()` when updating calendar format
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              // No need to call `setState()` here
              _focusedDay = focusedDay;
            },
          ),
        submit()],
        ),
      );
    });
  }
  Widget submit(){
    return ButtonWidget(
      text: 'Submit',
      onPressed: () async {
        if(_selectedDay != null){
          String date = updateDate(_selectedDay);
          await UserServices.updateStartDate(date);
        }

        Fluttertoast.showToast(
          msg: 'date submitted',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      },
    );
  }
  String updateDate(DateTime? day){
    DateTime now = day!;
    String date = DateFormat('yyyy-MM-dd').format(day);
    return date;
  }
}