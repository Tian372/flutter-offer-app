import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:offer_app/helper/constants.dart';
import 'package:offer_app/models/item.dart';
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
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 26),
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
            Flexible(
              child: Container(
                child: someItem(),
                  ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 1.0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CupertinoButton(
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 17),
                ),
                onPressed: () {
                  AuthService().signOut();
                  userIsLoggedIn.logout();
                },
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget someItem() {
    List<String> entries = <String>['Watching', 'Saved', 'Buy again', 'Purchases', 'Bids & Offers', 'Selling', 'Payment options','Help','Recently Viewed'];

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          alignment: Alignment.centerLeft,
          height: 30,
          child: Text('${entries[index]}', style: TextStyle(fontWeight: FontWeight.bold),),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
