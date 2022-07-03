import 'package:flutter/material.dart';
import 'package:flutter_app/screens/plan_related/SearchPlace.dart';
import 'package:flutter_app/screens/models/InterestsCell.dart' as allInterests;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_app/screens/MakeTrip.dart';

class ListofInterests extends StatefulWidget {
  final GooglePlace? googlePlace;
  List InterestList;
  //List? DetailedList;

  ListofInterests({Key? key, this.googlePlace, required this.InterestList}) : super(key: key);

  @override
  _ListofInterestsState createState() =>
      _ListofInterestsState(this.googlePlace, this.InterestList);
}

class _ListofInterestsState extends State<ListofInterests> {
  final GooglePlace? googlePlace;
  final List? InterestList;

  _ListofInterestsState(this.googlePlace, this.InterestList);

  List<Widget> _getInterestList(InterestList) {

    if (InterestList == null){
      return allInterests.allinterests.map((item) {
        return ListItem(
          title: '${item['title']}',
          googlePlace: googlePlace,
        );
      }).toList();
    }
    else{
      //print('here!');
      return InterestList.map<Widget>((item){
        //print('xixixixi');
        if(item['title'][1] == ''){
          item['title'][1] = '...';
        }
        return ListItem(
          title:'${item['title'][0]}',
          googlePlace: googlePlace,
          detail: '${item['title'][1]}',
        );
      }).toList();
    }

     //*/

  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      SizedBox(
        height: 270,
        child: ListView(
          children: this._getInterestList(this.InterestList),
        ),
      ),
    ]);
  }
}

class ListItem extends StatelessWidget {
  ListItem({this.title: '', this.googlePlace, this.detail:'...'});

  final String title;
  final GooglePlace? googlePlace;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(this.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )),
      subtitle: Container(
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(height: 65),
            Expanded(
              child: Container(
                //margin: const EdgeInsets.only(right: 20),
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                alignment: Alignment.centerLeft,
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: new Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        offset: Offset(1.0, 1.0),
                        blurRadius: 0.5,
                        spreadRadius: 0.1)
                  ],
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 5),
                    _getTextbutton(detail, context),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40.0,
              width: 40.0,
              child: IconButton(
                onPressed: () {

                },
                padding: new EdgeInsets.all(0.0),
                color: Colors.black,
                icon: new Icon(Icons.close, size: 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTextbutton(String word, BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPlace(
              googlePlace: googlePlace,
            ),
          ),
        );
      },
      style: ButtonStyle(
        //backgroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor:
            MaterialStateProperty.all(Color.fromRGBO(217, 230, 242, 80)),
        //side: MaterialStateProperty.all(BorderSide(width: 1,color: Colors.grey)),
        //shadowColor: MaterialStateProperty.all(Colors.grey),
        //elevation: MaterialStateProperty.all(3),
        shape: MaterialStateProperty.all(StadiumBorder(
          side: BorderSide.none,
        )),
      ),
      child: Text(
        word,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
