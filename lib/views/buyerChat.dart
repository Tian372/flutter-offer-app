import 'dart:async';

import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

class BuyerChat extends StatefulWidget {
  final String chatRoomId;
  final String sellerName;
  final bool declined;
  final String itemId;

  BuyerChat({this.chatRoomId, this.sellerName, this.declined, this.itemId});

  @override
  _BuyerChatState createState() => _BuyerChatState();
}

class _BuyerChatState extends State<BuyerChat> {
  int _amount;

  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  TextEditingController priceEditingController = new TextEditingController();

  Widget slidingCheckoutView() {
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
            'Offer: \$$_amount',
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
                //TODO: set paid to true after payment
                DatabaseMethods().addWinner(widget.itemId, Constants.myName);
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
            padding: EdgeInsets.only(bottom: 100),
          ),
        ],
      ),
    );
  }

  Widget paymentMethod() {
    return Container(
      child: CustomRadioButton(
        height: 50,
        buttonColor: Theme.of(context).canvasColor,
        buttonLables: [
          'Payment 1',
          'Payment 2',
          'Payment 3',
        ],
        buttonValues: [
          'Payment 1',
          'Payment 2',
          'Payment 3',
        ],
        radioButtonValue: (values) {
          print(values);
        },
        horizontal: true,
        width: 110,
        selectedColor: Theme.of(context).accentColor,
        padding: 5,
        enableShape: false,
      ),
    );
  }

  Widget itemView(String itemName, itemDesc) {
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
        Text('$itemName: $itemDesc')
      ],
    );
  }

  Widget addressMethod() {
    return Container(

      child: CustomRadioButton(
        height: 50,
        buttonColor: Theme.of(context).canvasColor,
        buttonLables: [
          'Address 1',
          'Address 2',
          'Address 3',
        ],
        buttonValues: [
          'Address 1',
          'Address 2',
          'Address 3',
        ],
        radioButtonValue: (values) {
          print(values);
        },
        horizontal: true,
        width: 110,
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
                  int price = snapshot.data.documents[index].data['price'];
                  String message =
                      snapshot.data.documents[index].data['message'];
                  bool sendByMe = Constants.myName ==
                      snapshot.data.documents[index].data['sendBy'];
                  bool approval =
                      snapshot.data.documents[index].data['sellerApproved'];
                  String docID = snapshot.data.documents[index].documentID;
                  return GestureDetector(
                    onTap: () {
                      if (!sendByMe || approval) {
                        setState(() {
                          _amount = price;
                        });
                        _pc.open();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          top: 3,
                          bottom: 3,
                          left: sendByMe ? 0 : 24,
                          right: sendByMe ? 24 : 0),
                      alignment: sendByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
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
                              ? const Color(0xff007EF4)
                              : (approval)
                                  ? Colors.green
                                  : Colors.blueGrey[400],
                        ),
                        child: Text(
                            widget.declined ? message : '\$$price: ' + message,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'OverpassRegular',
                                fontWeight: FontWeight.w300)),
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

  PanelController _pc = new PanelController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SlidingUpPanel(
        backdropEnabled: true,
        slideDirection: SlideDirection.UP,
        minHeight: 0,
        maxHeight: 700,
        isDraggable: false,
        controller: _pc,
        panel: Center(
          child: slidingCheckoutView(),
        ),
        body: CupertinoPageScaffold(
          // resizeToAvoidBottomInset: true,
          //resizeToAvoidBottomPadding: false,
          navigationBar: CupertinoNavigationBar(
            middle: Text(widget.sellerName),
            leading: CupertinoNavigationBarBackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          child: Center(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 100,
                        width: double.infinity,
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 10),
                            child: itemView('temp', 'temp')),
                      ),
                      Container(height: 500, child: chatMessages()),
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
                            (widget.declined)
                                ? SizedBox(
                                    width: 0,
                                  )
                                : Expanded(
                                    flex: 2,
                                    child: Container(
                                      child: CupertinoTextField(
                                        textInputAction: TextInputAction.next,
                                        maxLength: 15,
                                        controller: priceEditingController,
                                        style: simpleTextStyle(),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter
                                              .digitsOnly
                                        ],
//                                        decoration: InputDecoration(
//                                          border: OutlineInputBorder(),
//                                          labelText: 'Price',
//                                        ),
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
                                maxLength: 100,
                                controller: messageEditingController,
                                style: simpleTextStyle(),
//                                decoration: InputDecoration(
//                                  border: OutlineInputBorder(),
//                                  labelText: 'Message',
//                                ),
                              ),
                            ),
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
