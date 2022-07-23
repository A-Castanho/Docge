import 'package:flutter/material.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {

  Loading({this.status, Key? key}) : super(key: key);
  String? status="";

  @override
  State<Loading> createState() => _LoadingState(status);
}

class _LoadingState extends State<Loading> {
  String? status;

  _LoadingState(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,

      //using spinKit
      /*child: Center(
        //Using the spink kit
        child: SpinKitCircle(
          color: Colors.blue,
          size: 50.0,
        ),*/

      //using flutter things
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              backgroundColor: Colors.grey,
              color: Colors.black,
              strokeWidth: 5,
            ),
            SizedBox(height: 10),
            DefaultTextStyle(
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18
                ),
                child: Text(status??"",
                    overflow: TextOverflow.clip,
                )
            ),
          ],
        ),
      ),
    );
  }
}
