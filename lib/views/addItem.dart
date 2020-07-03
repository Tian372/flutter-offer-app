import 'package:flutter/cupertino.dart';
import 'package:offer_app/helper/style.dart';

import '../helper/helperfunctions.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../views/chatrooms.dart';
import '../widget/widget.dart';
import 'package:flutter/material.dart';

class ItemView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController descEditingController = new TextEditingController();
    TextEditingController nameEditingController = new TextEditingController();
    TextEditingController priceEditingController = new TextEditingController();
    TextEditingController sellerEditingController = new TextEditingController();
    return SafeArea(
      child: Container(
        child: Form(
          child: Column(
            children: [
              Text('Item Name:'),
              SizedBox(height: 10),
              CupertinoTextField(
                controller: nameEditingController,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
              ),
              SizedBox(height: 50),
              Text('Description:'),
              SizedBox(height: 10),
              CupertinoTextField(
                controller: descEditingController,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
              ),
              SizedBox(height: 50),
              Text('seller:'),
              SizedBox(height: 10),
              CupertinoTextField(
                controller: sellerEditingController,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
              ),
              SizedBox(height: 50),
              Text('Price:'),
              SizedBox(height: 10),
              CupertinoTextField(
                controller: priceEditingController,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
              ),
              SizedBox(height: 50),
              RaisedButton(
                color: Colors.green,
                child: Text('Submit'),
                onPressed: () {
                  addItemMap(
                      nameEditingController.text,
                      descEditingController.text,
                      sellerEditingController.text,
                      priceEditingController.text);
                  nameEditingController.text = '';
                  descEditingController.text = '';
                  sellerEditingController.text = '';
                  priceEditingController.text = '';
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  addItemMap(String itemName, desc, seller, price) {
    print(itemName);
    Map<String, dynamic> itemInfo = {
      'itemName': itemName,
      'seller': seller,
      'listPrice': price,
      'itemDesc': desc,
      'offerNum': 0,
      'sold': false,
      'buyers': [],
      'winner': '',
      'listTime': DateTime.now().millisecondsSinceEpoch,
    };
    DatabaseMethods().addItemHelper(itemInfo);
  }
}
