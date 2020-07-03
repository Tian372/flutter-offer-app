import 'package:flutter/cupertino.dart';
import 'package:offer_app/helper/authenticate.dart';
import 'package:offer_app/helper/constants.dart';
import 'package:provider/provider.dart';
import '../services/auth.dart';

import 'package:flutter/material.dart';

import 'ebayMock.dart';

class UserInfoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userIsLoggedIn = Provider.of<UserIsLoggedIn>(context);
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.person_solid,
                    color: Colors.black,
                    size: 60,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    '${Constants.myName}',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 500,
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: CupertinoButton(
                color: Colors.lightBlue,
                child: Text('Sign Out'),
                onPressed: () {
                  AuthService().signOut();
                  userIsLoggedIn.logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
