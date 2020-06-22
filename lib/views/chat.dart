import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:offer_app/main.dart';
import 'package:offer_app/views/payment.dart';
import '../helper/constants.dart';
import '../services/database.dart';
import '../widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const boxColor = Colors.white;

class Chat extends StatefulWidget {
  final String chatRoomId;
  final String userName;

  Chat({this.chatRoomId, this.userName});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  int _latestAmount;
  Stream<QuerySnapshot> chats;
  Stream<QuerySnapshot> priceStream;
  TextEditingController messageEditingController = new TextEditingController();
  TextEditingController priceEditingController = new TextEditingController();

  Widget priceTag() {
    return StreamBuilder(
        stream: priceStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.data.documents.isEmpty) {
            _latestAmount = snapshot.data.documents[0].data["price"];
            print(_latestAmount);
            return Text(
              "Latest Offer: \$$_latestAmount",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
            );
          } else {
            return Text("");
          }
        });
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    price: snapshot.data.documents[index].data["price"],
                    message: snapshot.data.documents[index].data["message"],
                    sendByMe: Constants.myName ==
                        snapshot.data.documents[index].data["sendBy"],
                  );
                })
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty &&
        priceEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "price": int.parse(priceEditingController.text),
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
        priceEditingController.text = "";
      });
    }
  }

  @override
  void initState() {
    DatabaseMethods().getLatestPriceFrom(widget.chatRoomId).then((val) {
      setState(() {
        this.priceStream = val;
      });
    });
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        this.chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
        elevation: 0.0,
        centerTitle: false,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: boxColor,
                ),
                child: Text('Item Info Goes here.'),
              ),
            ),
            Expanded(flex: 8, child: chatMessages()),
            Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        color: HexColor.fromHex('#00B9F1'),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: RaisedButton(
                                  color: Colors.red,
                                  onPressed: () {
                                    DatabaseMethods()
                                        .rejectJob(widget.chatRoomId);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Decline',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                )),
                            Expanded(
                                flex: 1,
                                child: RaisedButton(
                                  color: Colors.green,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Payment(
                                                  userName: widget.userName,
                                                  myName: Constants.myName,
                                                  price: _latestAmount,
                                                )));
                                  },
                                  child: const Text('Accept',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ))
                          ],
                        )),
                    Container(child: priceTag()),
                  ],
                )),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                color: boxColor,
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          height: 65,
                    
                          child: TextField(
                            controller: priceEditingController,
                            style: simpleTextStyle(),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              hintText: "\$",
                              hintStyle: simpleTextStyle(),
                    
                            ),
                          ),
                        )
                        ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: messageEditingController,
                        style: simpleTextStyle(),
                        decoration: InputDecoration(
                          hintText: "Message ...",
                          hintStyle: simpleTextStyle(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                      },
                      child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(40)),
                          padding: EdgeInsets.all(8),
                          child: Image.asset(
                            "assets/images/send.png",
                            height: 40,
                            width: 40,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final int price;
  final String message;
  final bool sendByMe;

  MessageTile(
      {@required this.price, @required this.message, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 3, bottom: 3, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
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
            gradient: LinearGradient(
              colors: sendByMe
                  ? [Colors.blueGrey[400], Colors.blueGrey[500]]
                  : [const Color(0xff007EF4), const Color(0xff2A75BC)],
            )),
        child: Text("\$$price: " + message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w300)),
      ),
    );
  }
}
