import 'package:flutter/material.dart';
import 'package:flutter_app/screens/plan_related/SearchPlace.dart';

class AddPlan extends StatefulWidget {
  const AddPlan({Key? key}) : super(key: key);

  @override
  _AddPlanState createState() => _AddPlanState();
}

class _AddPlanState extends State<AddPlan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plan Your Trip',
          style: const TextStyle(
            color: Color.fromRGBO(20, 41, 82, 1),
            fontSize: 24.0,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: _shareTrip, color: Colors.black,),
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              _titleImage(),
              SizedBox(height:10),
              _dayPlanlist(),

            ],

          ),

        ),
      ),
    );
  }

  Widget _titleImage(){
    return Container(
      height: 153,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.grey,
    ),
      child: Column(
        children: <Widget>[
          Container(
            //margin: EdgeInsets.fromLTRB(0,2,0,120),
            height: 20,
            //width:10,
            //color:Colors.blue,
            alignment: Alignment.center,
            child: Text(
              'Title',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(8,100,8,0),
                height: 30,
                //width:120,
                //color:Colors.blue,
                alignment: Alignment.centerLeft,
                child: Text(
                  'PLACES  PEOPLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(8,100,8,0),
                alignment: Alignment.centerRight,
                height: 30,
                //width: 220,
                //color:Colors.blue,
                child: IconButton(icon: Icon(Icons.date_range), color:Colors.white, alignment: Alignment.center,onPressed: (){},),
              ),
            ],
          )
        ],
      ),
    );
  }


  Widget _dayPlanlist(){
    return Container(
      height: 170,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromRGBO(241,241,241,1),
        boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1.0, 1.0),blurRadius: 0.5, spreadRadius: 0.1)],
      ),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            alignment: Alignment.centerLeft,
            child: Text('Plan your day',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: new Border.all(color:Colors.grey, width:1,),
              boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1.0, 1.0),blurRadius: 0.5, spreadRadius: 0.1)],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(width:5),
                _getTextbutton('My Location'),
                Icon(
                  Icons.flight,
                  color: Colors.blueGrey,

                ),
                _getTextbutton('Destination'),
                SizedBox(width:5),
              ],
            ),
          ),
          SizedBox(height: 11,),
          ElevatedButton(
            onPressed: (){},
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: MaterialStateProperty.all(Colors.blueGrey),
              side: MaterialStateProperty.all(BorderSide(width: 1,color: Colors.grey)),
              shadowColor: MaterialStateProperty.all(Colors.grey),
              elevation: MaterialStateProperty.all(3),
                shape: MaterialStateProperty.all(
                    StadiumBorder(
                        side: BorderSide(
                          style: BorderStyle.solid,
                        )
                    )
                ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 30),
              child:Text(
                'Done',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTextbutton(String word){
    return TextButton(
      onPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPlace()),
        );
      },
      style: ButtonStyle(
        //backgroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.all(Color.fromRGBO(217, 230, 242, 80 )),
        //side: MaterialStateProperty.all(BorderSide(width: 1,color: Colors.grey)),
        //shadowColor: MaterialStateProperty.all(Colors.grey),
        //elevation: MaterialStateProperty.all(3),
        shape: MaterialStateProperty.all(
            StadiumBorder(
              side: BorderSide.none,
            )
        ),
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
  void _shareTrip(){

  }

}