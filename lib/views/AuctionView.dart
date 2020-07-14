import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:offer_app/helper/style.dart';
import 'package:offer_app/main.dart';
import 'package:offer_app/views/Rooms/sellerChat.dart';
import 'package:offer_app/widget/widget.dart';

import '../helper/authenticate.dart';
import '../helper/constants.dart';
import '../helper/helperfunctions.dart';
import '../services/database.dart';
import 'Rooms/buyerChat.dart';
import 'package:flutter/material.dart';

class AuctionView extends StatefulWidget {
  @override
  _AuctionViewState createState() => _AuctionViewState();
}

class _AuctionViewState extends State<AuctionView> {
  int _currentIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Auction Rooms'),
    );
  }
}

class AuctionRoomTile extends StatelessWidget {
  final String chatRoomId;
  final String itemName;
  final bool declined;
  final String itemId;
  final String sellerName;
  final String buyerName;
  final bool payment;

  AuctionRoomTile(
      {@required this.chatRoomId,
      @required this.declined,
      this.payment,
      this.itemName,
      @required this.itemId,
      this.buyerName,
      this.sellerName});

  @override
  Widget build(BuildContext context) {
    bool isSeller = Constants.myName == sellerName;
    return Container(
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => isSeller
                        ? SellerChat(
                            chatRoomId: this.chatRoomId,
                            userName: this.buyerName,
                            declined: this.declined,
                          )
                        : BuyerChat(
                            chatRoomId: this.chatRoomId,
                            sellerName: this.sellerName,
                            declined: this.declined,
                            itemId: this.itemId,
                          )));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                              width: 85,
                              height: 30,
                              decoration: new BoxDecoration(
                                color: this.declined
                                    ? (this.payment
                                        ? Colors.green[200]
                                        : Colors.red[200])
                                    : Colors.grey,
                                borderRadius: new BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                    offset: Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  this.declined
                                      ? (this.payment ? 'Accepted' : 'Declined')
                                      : 'Ongoing',
                                  style: Styles.indication,
                                ),
                              )),
                          SizedBox(
                            width: 20,
                          ),
                          Text('$itemName', style: Styles.productRowItemName),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 105,
                          ),
                          Text(
                              isSeller
                                  ? '${this.buyerName}'
                                  : '${this.sellerName}',
                              style: Styles.productRowItemPrice),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 80,
                  width: 80,
                  decoration: new BoxDecoration(
                      color: Colors.black38,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10),
                        topRight: const Radius.circular(10),
                        bottomRight: const Radius.circular(10),
                        bottomLeft: const Radius.circular(10),
                      )),
                  child: Text(
                    ' item pic goes here',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
