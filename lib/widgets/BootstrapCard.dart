import 'package:flutter/material.dart';

class BootstrapCard extends StatefulWidget {
  const BootstrapCard({Key? key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  BootstrapCardState createState() => BootstrapCardState();
}

class BootstrapCardState extends State<BootstrapCard>{
  @override
  Widget build(BuildContext context){
    return Card(
      margin: EdgeInsets.all(20),
      child: Column(
        children: <Widget> [
          Container(
            width: double.infinity,
            child: Card(
              color: Colors.black12,
              child: Padding( 
                padding: EdgeInsets.all(20.0),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  )
                )
              )
            )
          ),
          Container (
            child: Padding(
              padding: EdgeInsets.all(20),
              child: widget.child
            )
          )
        ]
      )
    );
  }
}