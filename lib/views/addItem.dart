import 'package:flutter/cupertino.dart';

import '../helper/helperfunctions.dart';
import '../helper/theme.dart';
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
    return Scaffold(
        appBar: appBarMain(context),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: nameEditingController,
                  style: simpleTextStyle(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: descEditingController,
                  style: simpleTextStyle(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Desc',
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: sellerEditingController,
                  style: simpleTextStyle(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Seller',
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: priceEditingController,
                  style: simpleTextStyle(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Price',
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: RaisedButton(
                  color: Colors.green,
                  onPressed: (){addItemMap(
                      nameEditingController.text,
                      descEditingController.text,
                      sellerEditingController.text,
                      priceEditingController.text);
                  },
              )
              )
            ],
          ),
        ));
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
