import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:offer_app/helper/style.dart';
import 'package:offer_app/main.dart';
import 'package:offer_app/views/sellerChat.dart';
import 'package:offer_app/widget/widget.dart';

import '../helper/authenticate.dart';
import '../helper/constants.dart';
import '../helper/helperfunctions.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../views/buyerChat.dart';
import '../views/search.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream chatSellerRooms;
  Stream chatBuyerRooms;
  int _currentIndex;

  Widget chatRoomsSellerList() {
    return StreamBuilder(
      stream: chatSellerRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
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
            ? ListView.builder(
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
    this._currentIndex = 0;
    getUserInfoGetChats();
    super.initState();
  }

  getUserInfoGetChats() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    DatabaseMethods().getUserBuyerChats(Constants.myName).then((snapshots) {
      setState(() {
        chatBuyerRooms = snapshots;
        print(
            'we got the data + ${chatBuyerRooms.toString()} this is name ${Constants.myName} ');
      });
    });
    DatabaseMethods().getUserSellerChats(Constants.myName).then((snapshots) {
      setState(() {
        chatSellerRooms = snapshots;
        print(
            'we got the data + ${chatSellerRooms.toString()} this is name ${Constants.myName} ');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: appBarMain(context, 'Notification'),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(children: [
            Container(
              height: 100,
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: new BoxDecoration(
                  color: Styles.scaffoldBackground,
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(10),
                    topRight: const Radius.circular(10),
                    bottomRight: const Radius.circular(10),
                    bottomLeft: const Radius.circular(10),
                  )),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.collections_solid, size: 60,),
                        Text('System')
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.news_solid, size: 60,),
                        Text('Other')
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(height: 50, child: Center(child: Text('Buy:'))),
            chatRoomsBuyerList(),
            Container(height: 50, child: Center(child: Text('Sell:'))),
            chatRoomsSellerList(),
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

  ChatRoomsTile(
      {@required this.chatRoomId,
      this.declined,
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
            decoration: new BoxDecoration(
                color: this.declined
                    ? (this.payment ? Colors.green[200] : Colors.red[200])
                    : Colors.grey,
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                  bottomRight: const Radius.circular(10),
                  bottomLeft: const Radius.circular(10),
                )),
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Item: $itemName',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontFamily: 'RobotoMono',
                              fontWeight: FontWeight.w400)),
                      Text(
                          'Seller: ${this.sellerName}; Buyer: ${this.buyerName}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black38,
                              fontSize: 20,
                              fontFamily: 'RobotoMono',
                              fontWeight: FontWeight.w400)),
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
                    'pic goes here',
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
