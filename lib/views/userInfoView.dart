import 'package:flutter/cupertino.dart';
import 'package:offer_app/helper/authenticate.dart';
import 'package:offer_app/helper/constants.dart';
import 'package:offer_app/helper/style.dart';

import '../helper/helperfunctions.dart';
import '../helper/theme.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../views/chatrooms.dart';
import '../widget/widget.dart';
import 'package:flutter/material.dart';

class UserInfoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 600,
              width: 600,
              child: Center(
                child: Row(
                  children: [
                    Icon(CupertinoIcons.person_solid, color: Colors.black),
                    Text(
                      '${Constants.myName}',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 200,
              height: 120,
              child: CupertinoButton(
                color: Colors.lightBlue,
                child: Text('Sign Out'),
                onPressed: () {
                  AuthService().signOut();
                  Navigator.pushReplacement(context,
                      CupertinoPageRoute(builder: (context) => Authenticate()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
