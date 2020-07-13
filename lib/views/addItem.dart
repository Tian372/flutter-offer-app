import 'package:flutter/cupertino.dart';
import 'package:offer_app/helper/style.dart';

import '../services/database.dart';
import 'package:flutter/material.dart';

class ItemView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController descEditingController = new TextEditingController();
    TextEditingController nameEditingController = new TextEditingController();
    TextEditingController priceEditingController = new TextEditingController();
    TextEditingController sellerEditingController = new TextEditingController();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text('Add Item to Firebase'),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Text('Item Name:'),
              SizedBox(height: 2),
              CupertinoTextField(
                controller: nameEditingController,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
              ),
              SizedBox(height: 5),
              Text('Description:'),
              SizedBox(height: 2),
              CupertinoTextField(
                controller: descEditingController,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
              ),
              SizedBox(height: 5),
              Text('seller:'),
              SizedBox(height: 2),
              CupertinoTextField(
                controller: sellerEditingController,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
              ),
              SizedBox(height: 5),
              Text('Price:'),
              SizedBox(height: 2),
              CupertinoTextField(
                controller: priceEditingController,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
              ),
              SizedBox(
                height: 5,
              ),
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

  addItemMap(String itemName, condition, seller, price) {
    print(itemName);
    Map<String, dynamic> itemInfo = {
      'itemName': itemName,
      'seller': seller,
      'listPrice': price,
      'condition': condition,
      'offerNum': 0,
      'sold': false,
      'buyers': [],
      'winner': '',
      'listTime': DateTime.now().toUtc().toString(),
    };
    DatabaseMethods().addItemHelper(itemInfo);
  }
}
