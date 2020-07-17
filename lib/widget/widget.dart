import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:offer_app/helper/style.dart';

Widget appBarMain(BuildContext context, String title) {
  return CupertinoNavigationBar(
    leading: Image.network(
      "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/EBay_logo.svg/800px-EBay_logo.svg.png",
      height: 30,
    ),
    middle: Text(title),
  );
}

Widget loginAppBar(BuildContext context) {
  return CupertinoNavigationBar(
    middle: Image.network(
      "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/EBay_logo.svg/800px-EBay_logo.svg.png",
      height: 40,
    ),
  );
}
InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.black),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)));
}

TextStyle simpleTextStyle() {
  return TextStyle(color: Colors.black, fontSize: 16);
}

TextStyle biggerTextStyle() {
  return TextStyle(color: Colors.black, fontSize: 17);
}



Widget statusIndicator(String userId) {
  return StreamBuilder(
      stream: FirebaseDatabase.instance
          .reference()
          .child('userStatus')
          .child(userId)
          .onValue,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData && snapshot.data.snapshot.value != null) {
          String onlineStatus = snapshot.data.snapshot.value['status'];
          var lastTime =
          DateTime.parse(snapshot.data.snapshot.value['lastTime']);

          Duration diff = new DateTime.now().difference(lastTime);
          int inDays = diff.inDays;
          int inHours = diff.inHours;
          int inMinutes = diff.inMinutes;

          print(userId);
          print('online status: $onlineStatus');
          bool isOnline = onlineStatus == 'online';

          return Row(
            children: [
              SizedBox(
                height: 10,
                width: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: (isOnline) ? Colors.green : Colors.grey,
                    border: Border.all(
                      color: Colors.black,
                      width: 20,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(
                width: 6,
              ),
              isOnline
                  ? Text(
                'online',
                style: Styles.productRowItemPrice,
              )
                  : (inMinutes < 1)
                  ? Text(
                '< 1 min',
                style: Styles.productRowItemPrice,
              )
                  : (inMinutes < 30)
                  ? Text(
                '$inMinutes m ago',
                style: Styles.productRowItemPrice,
              )
                  : (inHours < 24)
                  ? Text(
                '$inHours h ago',
                style: Styles.productRowItemPrice,
              )
                  : Text(
                '$inDays d ago',
                style: Styles.productRowItemPrice,
              )
            ],
          );
        } else
          return Text('no data' ,style: Styles.productRowItemPrice,);
      });
}