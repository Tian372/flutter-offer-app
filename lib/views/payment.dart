import 'package:flutter/services.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import '../helper/constants.dart';
import '../services/database.dart';
import '../widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Payment extends StatefulWidget {
  final String userName;
  final String myName;
  final int price;

  Payment({this.userName, this.myName, this.price});

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sample Payment'),
      ),
      body: paymentMethod(),
      backgroundColor: Colors.blueGrey.shade200,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          child: Text(
              widget.myName + ' Need to Pay ' + widget.userName + ' \$'+ widget.price.toString()
          ),
          alignment: Alignment.bottomCenter,
          height: 50.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
//            setState(() {
//              _count++;
//            }),
        tooltip: '',
        child: Icon(Icons.payment),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  @override
  void initState() {}

  Widget paymentMethod() {
    return RadioButtonGroup(labels: <String>[
      "Payment 1",
      "Payment 2",
    ], onSelected: (String selected) => print(selected));
  }
}
