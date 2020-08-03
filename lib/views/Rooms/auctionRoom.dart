import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:offer_app/widget/widget.dart';
import '../../helper/constants.dart';
import '../../services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const boxColor = Colors.white;

class AuctionRoom extends StatefulWidget {
  final String itemName;
  final String userName;
  final String imageUrl;
  final int bidderNum;
  final String condition;
  final String itemId;

  //bidderNum : bidderNum,
  //                          condition: condition,
  //TODO: need to change this to be a Stream from database
  final bool declined;

  AuctionRoom(
      {this.itemName, this.userName, this.declined, this.imageUrl, this.condition, this.bidderNum,this.itemId});

  @override
  _AuctionRoomState createState() => _AuctionRoomState();
}

class _AuctionRoomState extends State<AuctionRoom> {
  Stream<QuerySnapshot> bids;
  Stream<QuerySnapshot> latestPrice;
  TextEditingController messageEditingController = new TextEditingController();
  TextEditingController priceEditingController = new TextEditingController();

  @override
  void dispose() {
    this.messageEditingController.dispose();
    this.priceEditingController.dispose();
    super.dispose();
  }


  Widget priceAdder() {
    return StreamBuilder(
        stream: latestPrice,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            double latestPrice = double.parse(
                (snapshot.data.documents[0].data['price']).toString());
            List<double> bidBtnTitle = new List<double>();
            double percentage = 1.0;
            int btnNum = 10;
            for (int i = 0; i < btnNum; i++) {
              percentage *= 1.02;
              bidBtnTitle.add(latestPrice * percentage);
            }
            return Column(
              children: [
                Container(
                  child: Text('Your Bid:'),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: btnNum,
                    itemBuilder: (_, int index) =>
                        Container(
                          height: 40,
                          child: RaisedButton(
                            onPressed: () {
                              print(bidBtnTitle[index].toStringAsFixed(2));
                              addMessage(bidBtnTitle[index].toStringAsFixed(2));
                            },
                            child: Text(bidBtnTitle[index].toStringAsFixed(2)),
                          ),
                        ),
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        });
  }

  Widget bidRecord() {
    return StreamBuilder(
      stream: bids,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
            reverse: false,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              String price = snapshot.data.documents[index].data['price'];
              bool sendByMe = Constants.myName ==
                  snapshot.data.documents[index].data['sendBy'];
              double chatCornerRadius = 10;
              int docLen = snapshot.data.documents.length;
              return Container(
                padding: EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                    left: sendByMe ? 80 : 10,
                    right: sendByMe ? 10 : 80),
                alignment:
                sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                    padding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: sendByMe
                          ? BorderRadius.only(
                          topLeft: Radius.circular(chatCornerRadius),
                          topRight: Radius.circular(chatCornerRadius),
                          bottomLeft: Radius.circular(chatCornerRadius))
                          : BorderRadius.only(
                          topLeft: Radius.circular(chatCornerRadius),
                          topRight: Radius.circular(chatCornerRadius),
                          bottomRight:
                          Radius.circular(chatCornerRadius)),
                      color: (index == 0) ? Colors
                          .green[500] : sendByMe ? Colors.grey[500] : Colors
                          .blue[500],
                    ),
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Text(
                          (index == docLen - 1)
                              ? 'Original Price: \$ $price'
                              : (index == 0)
                              ? 'Highest Bid: \$ $price'
                              : '\$ $price',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'OverpassRegular',
                              fontWeight: FontWeight.w300)),
                    )),
              );
            })
            : Container();
      },
    );
  }

  addMessage(String num) {
    Map<String, dynamic> bidMap = {
      'sendBy': Constants.myName,
      'price': num,
      'time': DateTime.now().toUtc().toString(),
    };

    DatabaseMethods().addBid(widget.itemName, bidMap);
  }

  @override
  void initState() {
    DatabaseMethods().getBids(widget.itemName).then((val) {
      setState(() {
        this.bids = val;
      });
    });
    DatabaseMethods().getLatestPriceFrom(widget.itemName).then((val) {
      setState(() {
        this.latestPrice = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Center(
          child: Text(
            widget.itemName,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  child: itemView(widget.itemId)),
            ),
            Flexible(child: bidRecord()),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: SizedBox(height: 100, child: priceAdder()),
            ),
          ],
        ),
      ),
    );
  }
}
