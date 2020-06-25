import 'dart:async';

import 'package:custom_radio_grouped_button/CustomButtons/CustomCheckBoxGroup.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:offer_app/main.dart';
import 'package:offer_app/views/payment.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../helper/constants.dart';
import '../services/database.dart';
import '../widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//only one accept or decline between
//inventory closed until the payment is finished
//always have a video backup
//use less blue,
//decline: history

const boxColor = Colors.white;

class Chat extends StatefulWidget {
  final String chatRoomId;
  final String userName;
  final bool declined;

  Chat({this.chatRoomId, this.userName, this.declined});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  int amount;
  Stream<QuerySnapshot> chats;
  Stream<QuerySnapshot> priceStream;
  TextEditingController messageEditingController = new TextEditingController();
  TextEditingController priceEditingController = new TextEditingController();
  // ignore: close_sinks

  Widget priceTag() {
    return StreamBuilder(
        stream: priceStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.data.documents.isEmpty) {
            //amount = snapshot.data.documents[0].data["price"];
            //print(amount);
            return Text(
              "Latest Offer: \$$amount",
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Sriracha'),
            );
          } else {
            return Text("");
          }
        });
  }

  Widget payView() {
    return StreamBuilder(
        stream:priceStream ,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.data.documents.isEmpty) {
            //amount = snapshot.data.documents[0].data["price"];
            //print(amount);
            return Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 0),
                  ),
                  Expanded(
                      flex: 4,
                      child: Container(
                        child: paymentMethod(),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      child: addressMethod(),
                    ),
                  ),
                  Text(
                    "Offer: \$$amount",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sriracha'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: RaisedButton(
                      color: Colors.green,
                      onPressed: () {
                        DatabaseMethods().declineJob(widget.chatRoomId);
                        Navigator.pop(context);
                      },
                      child: const Text('Finish Payment',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 42),
                  ),
                ],
              ),
            );
          } else {
            return Text("");
          }
        });
  }

  Widget paymentMethod() {
    return Container(
      child: CustomRadioButton(
        buttonColor: Theme.of(context).canvasColor,
        buttonLables: [
          "Payment 1",
          "Payment 2",
          "Payment 3",
        ],
        buttonValues: [
          "Payment 1",
          "Payment 2",
          "Payment 3",
        ],
        radioButtonValue: (values) {
          print(values);
        },
        horizontal: true,
        width: 120,
        selectedColor: Theme.of(context).accentColor,
        padding: 5,
        enableShape: false,
      ),
    );
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
        const Text("Item Description")
      ],
    );
  }

  Widget addressMethod() {
    return Container(
      child: CustomRadioButton(
        buttonColor: Theme.of(context).canvasColor,
        buttonLables: [
          "Address 1",
          "Address 2",
          "Address 3",
        ],
        buttonValues: [
          "Address 1",
          "Address 2",
          "Address 3",
        ],
        radioButtonValue: (values) {
          print(values);
        },
        horizontal: true,
        width: 120,
        selectedColor: Theme.of(context).accentColor,
        padding: 5,
        enableShape: false,
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  int price = snapshot.data.documents[index].data["price"];
                  String message =  snapshot.data.documents[index].data["message"];
                  bool sendByMe = Constants.myName ==
                  snapshot.data.documents[index].data["sendBy"];
                  return GestureDetector(
                    onTap: (){
                      if(!sendByMe){
                        setState(() {
                          amount = price;
                        });
                        _pc.open();
                      }
                    },
                    child: Container(
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
                            color: !sendByMe ? const Color(0xff007EF4): Colors.blueGrey[400],
//                            gradient: LinearGradient(
//                              colors: sendByMe
//                                  ? [Colors.blueGrey[400], Colors.blueGrey[500]]
//                                  : [const Color(0xff007EF4), const Color(0xff2A75BC)],
//                            )
                        ),
                        child: Text( widget.declined ? message: "\$$price: " + message,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'OverpassRegular',
                                fontWeight: FontWeight.w300)),
                      ),
                    ),
                  );







//                  return MessageTile(
//                    price: snapshot.data.documents[index].data["price"],
//                    message: snapshot.data.documents[index].data["message"],
//                    sendByMe: Constants.myName ==
//                        snapshot.data.documents[index].data["sendBy"],
//                    de: widget.declined,
//                  );
                })
            : Container();
      },
    );
  }

  addMessage() {
    if (
        messageEditingController.text.isNotEmpty &&(
            priceEditingController.text.isNotEmpty || widget.declined)) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "price": (widget.declined) ? -1:int.parse(priceEditingController.text),
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

  PanelController _pc = new PanelController();

  //TODO: add sliding panel for payment
  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      bottomLeft: Radius.circular(24.0),
      bottomRight: Radius.circular(24.0),
    );

    return Material(
      child: SlidingUpPanel(
        backdropEnabled: true,
        slideDirection: SlideDirection.UP,
        minHeight: 0,
        maxHeight: 600,
        isDraggable: false,
        controller: _pc,
        panel: Center(
          child: payView(),
        ),
        body: Scaffold(
          // resizeToAvoidBottomInset: true,
          //resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text(widget.userName),
            elevation: 0.0,
            centerTitle: false,
          ),

          body: Center(
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
                      Container(height: 500, child: chatMessages()),
//                    (widget.declined)?
//                    SizedBox(
//                      height: 0,
//                    ):Container(
//                      height: 20,
//                      width: double.infinity,
//                      //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//                      color: Colors.white,
//                      child: Center(child: priceTag()),
//                    ),
                      (widget.declined)
                          ? SizedBox(
                              height: 50,
                            )
                          : Container(
                              height: 50,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 0),
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
//                                Expanded(
//                                    flex: 1,
//                                    child: RaisedButton(
//                                      color: Colors.green,
//                                      onPressed: () {
//                                        _pc.open();
////                                  Navigator.push(
////                                      context,
////                                      MaterialPageRoute(
////                                          builder: (context) => Payment(
////                                            userName: widget.userName,
////                                            myName: Constants.myName,
////                                            price: _latestAmount,
////                                            chatId: widget.chatRoomId,
////                                          )));
//                                      },
//                                      child: const Text('Accept',
//                                          style: TextStyle(
//                                              color: Colors.white,
//                                              fontSize: 20,
//                                              fontWeight: FontWeight.bold)),
//                                    ))
                                ],
                              ),
                            ),
                      Container(
                        height: 100,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        color: boxColor,
                        child: Row(
                          children: [
                            (widget.declined)?
                            SizedBox(
                              width: 0,
                            ):Expanded(
                                flex: 2,
                                child: Container(
                                  child: TextField(
                                    textInputAction: TextInputAction.next,
                                    maxLength: 15,
                                    controller: priceEditingController,
                                    style: simpleTextStyle(),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly
                                    ],
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Price',
                                    ),
                                  ),
                                )),
                            SizedBox(
                              width: (widget.declined) ? 0:10,
                            ),
                            Expanded(
                              flex: 4,
                              child: TextField(
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) {
                                  addMessage();
                                },
                                maxLength: 100,
                                controller: messageEditingController,
                                style: simpleTextStyle(),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Message',
                                ),
                              ),
                            ),
//                          SizedBox(
//                            width: 10,
//                          ),
//                          Expanded(
//                            flex: 1,
//                            child: GestureDetector(
//                              onTap: () {
//                                addMessage();
//                              },
//                              child: Container(
//                              height: double.infinity,
//                                decoration: BoxDecoration(
//                                    color: Colors.black38,
//                                    borderRadius: BorderRadius.circular(40)),
//                                padding: EdgeInsets.all(8),
//                                child: Icon(Icons.arrow_upward),
//                              ),
//                            ),
//                          ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}

//class MessageTile extends StatelessWidget {
//  final int price;
//  final String message;
//  final bool sendByMe;
//  MessageTile(
//      {@required this.price, @required this.message, @required this.sendByMe});
//
//  @override
//  Widget build(BuildContext context) {
//    return GestureDetector(
//
//      child: Container(
//        padding: EdgeInsets.only(
//            top: 3, bottom: 3, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
//        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
//        child: Container(
//          margin:
//              sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
//          padding: EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
//          decoration: BoxDecoration(
//              borderRadius: sendByMe
//                  ? BorderRadius.only(
//                      topLeft: Radius.circular(23),
//                      topRight: Radius.circular(23),
//                      bottomLeft: Radius.circular(23))
//                  : BorderRadius.only(
//                      topLeft: Radius.circular(23),
//                      topRight: Radius.circular(23),
//                      bottomRight: Radius.circular(23)),
//              gradient: LinearGradient(
//                colors: sendByMe
//                    ? [Colors.blueGrey[400], Colors.blueGrey[500]]
//                    : [const Color(0xff007EF4), const Color(0xff2A75BC)],
//              )),
//          child: Text( true ? message: "\$$price: " + message,
//              textAlign: TextAlign.start,
//              style: TextStyle(
//                  color: Colors.white,
//                  fontSize: 16,
//                  fontFamily: 'OverpassRegular',
//                  fontWeight: FontWeight.w300)),
//        ),
//      ),
//    );
//  }
//}
