import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:offer_app/helper/style.dart';
import 'package:offer_app/views/Rooms/auctionRoom.dart';
import 'package:offer_app/views/Rooms/sellerChat.dart';
import 'package:offer_app/widget/widget.dart';

import '../helper/constants.dart';
import '../helper/helperfunctions.dart';
import '../services/database.dart';
import 'Rooms/buyerChat.dart';
import 'package:flutter/material.dart';

import 'AuctionView.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream chatSellerRooms;
  Stream chatBuyerRooms;
  Stream bids;
  int _currentIndex;

  @override
  dispose() {
    super.dispose();
    chatSellerRooms.drain();
    chatBuyerRooms.drain();
    bids.drain();
  }

  Widget chatRoomsSellerList() {
    return StreamBuilder(
      stream: chatSellerRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.separated(
                separatorBuilder: (context, index) => Divider(
                      color: Styles.productRowDivider,
                      thickness: 1,
                    ),
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var roomData = snapshot.data.documents[index];
                  return Container(
                    child: ChatRoomsTile(
                      sellerName: roomData.data['seller'],
                      buyerName: roomData.data['buyer'],
                      chatRoomId: roomData.data['chatRoomId'],
                      declined: roomData.data['declined'],
                      payment: roomData.data['paid'],
                      itemName: roomData.data['itemName'],
                      itemId: roomData.data['itemId'],
                      imageUrl: roomData.data['imageUrl'],
                      listPrice: roomData.data['listedPrice'],
                      condition: roomData.data['condition'],
                      offerNum: roomData.data['offerNum'],
                    ),
                  );
                })
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Widget chatRoomsBuyerList() {
    return StreamBuilder(
      stream: chatBuyerRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.separated(
                separatorBuilder: (context, index) => Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var roomData = snapshot.data.documents[index];
                  return ChatRoomsTile(
                    sellerName: roomData.data['seller'],
                    buyerName: roomData.data['buyer'],
                    chatRoomId: roomData.data['chatRoomId'],
                    declined: roomData.data['declined'],
                    payment: roomData.data['paid'],
                    itemName: roomData.data['itemName'],
                    itemId: roomData.data['itemId'],
                    imageUrl: roomData.data['imageUrl'],
                    listPrice: roomData.data['listedPrice'],
                    condition: roomData.data['condition'],
                    offerNum: roomData.data['offerNum'],
                  );
                })
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Widget bidsList() {
    return StreamBuilder(
      stream: bids,
      builder: (context, snapshot) {
        return snapshot.hasData && snapshot.data.documents != null
            ? ListView.separated(
                separatorBuilder: (context, index) => Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var roomData = snapshot.data.documents[index];
                  return BidRoomTile(
                    sellerName: roomData.data['seller'],
                    declined: roomData.data['declined'],
                    payment: roomData.data['paid'],
                    itemName: roomData.data['itemName'],
                    imageUrl: roomData.data['imageUrl'],
                    bidderNum: roomData.data['buyers'] == null
                        ? 0
                        : roomData.data['buyers'].length,
                    condition: roomData.data['condition'],
                    itemId: roomData.data['itemId'],
                  );
                })
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  @override
  void initState() {
    _currentIndex = 0;
    getUserInfoGetChats();
    super.initState();
  }

  getUserInfoGetChats() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    DatabaseMethods().getUserBuyerChats(Constants.myName).then((snapshots) {
      setState(() {
        chatBuyerRooms = snapshots;
      });
    });
    DatabaseMethods().getUserSellerChats(Constants.myName).then((snapshots) {
      setState(() {
        chatSellerRooms = snapshots;
      });
    });
    DatabaseMethods().getUserBids(Constants.myName).then((snapshots) {
      setState(() {
        bids = snapshots;
      });
    });
  }

  Widget segmentedTabs() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: CupertinoSlidingSegmentedControl(
        children: {
          0: Text('As Buyer'),
          1: Text('As Seller'),
          2: Text('Auction'),
          3: Text('General'),
        },
        groupValue: _currentIndex,
        onValueChanged: (value) {
          this.setState(() {
            this._currentIndex = value;
          });
        },
      ),
    );
  }

  Widget listViews() {
    if (this._currentIndex == 0) {
      return chatRoomsBuyerList();
    }
    if (this._currentIndex == 1) {
      return chatRoomsSellerList();
    }
    if (this._currentIndex == 2) {
      return bidsList();
    }
    if (this._currentIndex == 3) {
      return Center(child: Text('System Notifications'));
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: appBarMain(context, 'Notification'),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  child: segmentedTabs(),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            listViews(),
          ]),
        ),
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String chatRoomId;
  final String itemName;
  final bool declined;
  final String itemId;
  final String sellerName;
  final String buyerName;
  final bool payment;
  final String imageUrl;
  final String listPrice;
  final String condition;
  final int offerNum;

  ChatRoomsTile({
    @required this.chatRoomId,
    this.declined,
    this.payment,
    this.itemName,
    @required this.itemId,
    this.buyerName,
    this.sellerName,
    this.imageUrl,
    this.listPrice,
    this.condition,
    this.offerNum,
  });

  @override
  Widget build(BuildContext context) {
    bool isSeller = Constants.myName == sellerName;

    return Container(
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(
                    builder: (context) => isSeller
                        ? SellerChat(
                            chatRoomId: this.chatRoomId,
                            userName: this.buyerName,
                            declined: this.declined,
                            imageUrl: imageUrl,
                            listPrice: listPrice,
                            condition: condition,
                            offerNum: offerNum,
                            itemId: itemId,
                          )
                        : BuyerChat(
                            chatRoomId: this.chatRoomId,
                            sellerName: this.sellerName,
                            declined: this.declined,
                            itemId: this.itemId,
                            imageUrl: imageUrl,
                            listPrice: listPrice,
                            condition: condition,
                            offerNum: offerNum,
                          )));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: 120,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Column(
                    children: [
                      Container(
                          width: 85,
                          height: 30,
                          decoration: new BoxDecoration(
                            border: Border.all(color: this.declined
                                ? (this.payment
                                ? Colors.green[200]
                                : Colors.red[200])
                                : Colors.blue, width: 5),
                            color: Colors.transparent,
                            borderRadius: new BorderRadius.circular(8),
//                            boxShadow: [
//                              BoxShadow(
//                                color: Colors.grey.withOpacity(0.5),
//                                spreadRadius: 3,
//                                blurRadius: 10,
//                                offset:
//                                    Offset(0, 2), // changes position of shadow
//                              ),
//                            ],
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
                        height: 10,
                      ),
                      Text(
                        '$itemName',
                        style: Styles.chatRoomTitle,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                          isSeller
                              ? '${this.buyerName}'
                              : '${this.sellerName}',
                          style: Styles.productRowItemPrice),
//                      SizedBox(
//                        height: 3,
//                      ),
//                      Text('$offerNum people are interested',
//                          style: Styles.productRowItemPrice),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BidRoomTile extends StatelessWidget {
  final String itemName;
  final bool declined;
  final String sellerName;
  final bool payment;
  final String imageUrl;
  final int bidderNum;
  final String condition;
  final String itemId;

  BidRoomTile({
    this.declined,
    this.payment,
    this.itemName,
    this.sellerName,
    this.imageUrl,
    this.bidderNum,
    this.condition,
    @required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(
                    // AuctionRoom({this.itemName, this.userName, this.declined, this.imageUrl});
                    builder: (context) => AuctionRoom(
                          itemName: itemName,
                          userName: sellerName,
                          declined: false,
                          imageUrl: imageUrl,
                          bidderNum: bidderNum,
                          condition: condition,
                      itemId: itemId,
                        )));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: 120,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                          width: 85,
                          height: 30,
                          decoration: new BoxDecoration
                            (border: Border.all(color: this.declined
                              ? (this.payment
                              ? Colors.green[200]
                              : Colors.red[200])
                              : Colors.blue, width: 5),

                            borderRadius: new BorderRadius.circular(8),
//                            boxShadow: [
//                              BoxShadow(
//                                color: Colors.grey.withOpacity(0.5),
//                                spreadRadius: 3,
//                                blurRadius: 10,
//                                offset: Offset(
//                                    0, 2), // changes position of shadow
//                              ),
//                            ],
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
                        height: 10,
                      ),
                      Text(
                        '$itemName',
                        style: Styles.chatRoomTitle,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text('${this.sellerName}',
                          style: Styles.productRowItemPrice),

//                      Text('$bidderNum people bidding on this',
//                          style: Styles.productRowItemPrice),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
