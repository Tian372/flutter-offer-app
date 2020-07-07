import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:offer_app/helper/style.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../helper/constants.dart';
import '../../services/database.dart';
import '../../widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//only one accept or decline between
//inventory closed until the payment is finished
//always have a video backup
//use less blue,
//decline: history

const boxColor = Colors.white;

class SellerChat extends StatefulWidget {
  final String chatRoomId;
  final String userName;

  //TODO: need to change this to be a Stream from database
  final bool declined;

  SellerChat({this.chatRoomId, this.userName, this.declined});

  @override
  _SellerChatState createState() => _SellerChatState();
}

class _SellerChatState extends State<SellerChat> {
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  TextEditingController priceEditingController = new TextEditingController();

  @override
  void dispose() {
    this.messageEditingController.dispose();
    this.priceEditingController.dispose();
    super.dispose();
  }

  Widget itemView() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          width: 50,
        ),
        const Text('Item Description')
      ],
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                //controller: _controller,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  int price = snapshot.data.documents[index].data['price'];
                  String message =
                      snapshot.data.documents[index].data['message'];
                  bool sendByMe = Constants.myName ==
                      snapshot.data.documents[index].data['sendBy'];
                  bool approval =
                      snapshot.data.documents[index].data['sellerApproved'];
                  String chatId = snapshot.data.documents[index].documentID;
                  return Container(
                    padding: EdgeInsets.only(
                        top: 3,
                        bottom: 3,
                        left: sendByMe ? 0 : 24,
                        right: sendByMe ? 24 : 0),
                    alignment:
                        sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: (widget.declined)
                        ? Container(
                            child: Text('$message',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'OverpassRegular',
                                    fontWeight: FontWeight.w300)),
                            margin: sendByMe
                                ? EdgeInsets.only(left: 30)
                                : EdgeInsets.only(right: 30),
                            padding: EdgeInsets.only(
                                top: 8, bottom: 8, left: 20, right: 20),
                            decoration: BoxDecoration(
                              borderRadius: sendByMe
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(23),
                                      topRight: Radius.circular(23),
                                      bottomLeft: Radius.circular(23))
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(23),
                                      topRight: Radius.circular(23),
                                      bottomRight: Radius.circular(23)),
                              color: !sendByMe
                                  ? (approval)
                                      ? Colors.green
                                      : const Color(0xff007EF4)
                                  : Colors.blueGrey[400],
                            ))
                        : SizedBox(
                            width: (sendByMe) ? 170 : 210,
                            child: Container(
                              margin: sendByMe
                                  ? EdgeInsets.only(left: 30)
                                  : EdgeInsets.only(right: 30),
                              padding: EdgeInsets.only(
                                  top: 8, bottom: 8, left: 20, right: 20),
                              decoration: BoxDecoration(
                                borderRadius: sendByMe
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(23),
                                        topRight: Radius.circular(23),
                                        bottomLeft: Radius.circular(23))
                                    : BorderRadius.only(
                                        topLeft: Radius.circular(23),
                                        topRight: Radius.circular(23),
                                        bottomRight: Radius.circular(23)),
                                color: !sendByMe
                                    ? (approval)
                                        ? Colors.green
                                        : const Color(0xff007EF4)
                                    : Colors.blueGrey[400],
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: (sendByMe) ? 100 : 70,
                                    child: Column(
                                      children: [
                                        (widget.declined)
                                            ? Container()
                                            : Text('\$$price',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontFamily:
                                                        'OverpassRegular',
                                                    fontWeight:
                                                        FontWeight.w900)),
                                        Text('$message',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    (widget.declined) ? 13 : 20,
                                                fontFamily: 'OverpassRegular',
                                                fontWeight: FontWeight.w300)),
                                      ],
                                    ),
                                  ),
                                  !sendByMe
                                      ? GestureDetector(
                                          onTap: () {
                                            if (!widget.declined) {
                                              DatabaseMethods().updateApproval(
                                                  widget.chatRoomId, chatId);
                                            }
                                          },
                                          child: Container(
                                            child: Text(
                                                (approval)
                                                    ? 'Retract'
                                                    : 'Approve',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontFamily:
                                                        'OverpassRegular',
                                                    fontWeight:
                                                        FontWeight.w200)),
                                            color: (approval)
                                                ? Colors.green
                                                : const Color(0xff007EF4),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                  );
                })
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty &&
        (priceEditingController.text.isNotEmpty || widget.declined)) {
      Map<String, dynamic> chatMessageMap = {
        'sendBy': Constants.myName,
        'price':
            (widget.declined) ? -1 : int.parse(priceEditingController.text),
        'message': messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
        'sellerApproved': false,
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = '';
        priceEditingController.text = '';
      });
    }
  }

  @override
  void initState() {
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        this.chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(widget.userName),
              SizedBox(
                width: 6,
              ),
              statusIndicator(widget.userName),
            ],
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      child: itemView()),
                ),
                (widget.declined)
                    ? SizedBox(
                        height: 50,
                      )
                    : Container(
                        height: 50,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: RaisedButton(
                                  color: Colors.red,
                                  onPressed: () {
                                    DatabaseMethods()
                                        .declineJob(widget.chatRoomId);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Decline',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                )),
                          ],
                        ),
                      ),
                Container(height: 500, child: chatMessages()),
                Container(
                  height: 100,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  color: boxColor,
                  child: Row(
                    children: [
                      (widget.declined)
                          ? Container()
                          : Expanded(
                              flex: 2,
                              child: Container(
                                child: CupertinoTextField(
                                  textInputAction: TextInputAction.next,
                                  maxLength: 10,
                                  style: simpleTextStyle(),
                                  controller: priceEditingController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  placeholder: 'price',
                                ),
                              )),
                      SizedBox(
                        width: (widget.declined) ? 0 : 10,
                      ),
                      Expanded(
                        flex: 4,
                        child: CupertinoTextField(
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) {
                            addMessage();
                          },
                          maxLength: 50,
                          controller: messageEditingController,
                          placeholder: 'Message',
                        ),
                      ),
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

  Widget statusIndicator(String userId) {
    return StreamBuilder(
        stream: FirebaseDatabase.instance
            .reference()
            .child('userStatus')
            .child(userId)
            .onValue,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            String onlineStatus = snapshot.data.snapshot.value['status'];
            var lastTime =
                DateTime.parse(snapshot.data.snapshot.value['lastTime']);

            Duration diff = new DateTime.now().difference(lastTime);
            int inDays = diff.inDays;
            int inHours = diff.inHours;
            int inMinutes = diff.inMinutes;

            print(userId);
            print('online status: $onlineStatus');
            bool isOnline = onlineStatus == 'online';

            return Row(
              children: [
                SizedBox(
                  height: 10,
                  width: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: (isOnline) ? Colors.green : Colors.blueGrey,
                      border: Border.all(
                        color: Colors.black,
                        width: 20,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                isOnline
                    ? Text(
                        'online',
                        style: Styles.productRowItemPrice,
                      )
                    : (inMinutes < 1)
                        ? Text(
                            'less than 1 min',
                            style: Styles.productRowItemPrice,
                          )
                        : (inMinutes < 60)
                            ? Text(
                                '$inMinutes m ago',
                                style: Styles.productRowItemPrice,
                              )
                            : (inHours < 24)
                                ? Text(
                                    '$inHours h ago',
                                    style: Styles.productRowItemPrice,
                                  )
                                : Text(
                                    '$inDays d ago',
                                    style: Styles.productRowItemPrice,
                                  )
              ],
            );
          } else
            return Text('no data');
        });
  }
}
