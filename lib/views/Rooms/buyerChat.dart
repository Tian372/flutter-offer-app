import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../helper/constants.dart';
import '../../services/database.dart';
import '../../widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const boxColor = Colors.white;

class BuyerChat extends StatefulWidget {
  final String chatRoomId;
  final String sellerName;
  final bool declined;
  final String itemId;
  final String imageUrl;
  final String listPrice;
  final String condition;
  final int offerNum;

  BuyerChat({
    this.chatRoomId,
    this.sellerName,
    this.declined,
    this.itemId,
    this.imageUrl,
    this.listPrice,
    this.condition,
    this.offerNum,
  });

  @override
  _BuyerChatState createState() => _BuyerChatState();
}

class _BuyerChatState extends State<BuyerChat> {
  double _amount;
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  TextEditingController priceEditingController = new TextEditingController();

  @override
  void dispose() {
    this.messageEditingController.dispose();
    this.priceEditingController.dispose();
    super.dispose();
  }

  Widget slidingCheckoutView() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20.0,
              color: Colors.grey,
            ),
          ]),
      margin: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 0),
          ),
          Expanded(
              flex: 5,
              child: Container(
                child: paymentMethod(),
              )),
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
                DatabaseMethods().paidJob(widget.chatRoomId);
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
    List<String> cards = [
      'https://pics.ebaystatic.com/aw/pics/mastercard/blue_card.png',
      'https://media.tenor.com/images/7402215da4e98d367ebf27b526691271/tenor.png',
      'https://www.apple.com/v/apple-pay/m/images/overview/og__dq5nejr4bg02_image.png?202006150938',
      'https://storage.googleapis.com/gweb-uniblog-publish-prod/images/GooglePay_Lockup.max-1000x1000.png'
    ];
    final List<Widget> imageSliders = cards
        .map((item) => Container(
              child: Container(
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.network(item, fit: BoxFit.cover),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(50, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 0.0),
                            child: Container(),
//                            Text(
//                              'No. ${cards.indexOf(item)} image',
//                              style: TextStyle(
//                                color: Colors.white,
//                                fontSize: 20.0,
//                                fontWeight: FontWeight.bold,
//                              ),
//                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ))
        .toList();
    return Container(
        child: CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 16 / 8,
        enlargeCenterPage: true,
      ),
      items: imageSliders,
    ));
  }

  Widget itemView(String itemName, itemDesc) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          width: 50,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'List Price: ${widget.listPrice}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(height: 5),
              Text(
                '${widget.condition}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(height: 15),
              Text(
                '${widget.offerNum} people are interested.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget addressMethod() {
    return Container(
      child: CustomRadioButton(
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
        customShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(color: Theme.of(context).accentColor)
        ),
        height: 40,
        selectedColor: Theme.of(context).accentColor,
        padding: 5,
        enableShape: true,
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  var roomData = snapshot.data.documents[index].data;
                  String price = roomData['price'].toString();
                  String message = roomData['message'];
                  bool sendByMe = Constants.myName == roomData['sendBy'];
                  bool approval = roomData['sellerApproved'];

//                  String docID = snapshot.data.documents[index].documentID;
                  double chatCornerRadius = 10;
                  return Container(
                    padding: EdgeInsets.only(
                        top: 5,
                        bottom: 5,
                        left: sendByMe ? 80 : 5,
                        right: sendByMe ? 5 : 80),
                    alignment:
                        sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: sendByMe
                            ? BorderRadius.only(
                                topLeft: Radius.circular(chatCornerRadius),
                                topRight: Radius.circular(chatCornerRadius),
                                bottomLeft: Radius.circular(chatCornerRadius))
                            : BorderRadius.only(
                                topLeft: Radius.circular(chatCornerRadius),
                                topRight: Radius.circular(chatCornerRadius),
                                bottomRight: Radius.circular(chatCornerRadius)),
                        color: !sendByMe
                            ? Colors.blue[500]
                            : (approval) ? Colors.green[300] : Colors.grey[500],
                      ),
                      child: (widget.declined)
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              child: Text('$message',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'OverpassRegular',
                                      fontWeight: FontWeight.w300)),
                            )
                          : Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: 200,
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    children: [
                                      Text('\$$price',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontFamily: 'OverpassRegular',
                                              fontWeight: FontWeight.w900)),
                                      Text('$message',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontFamily: 'OverpassRegular',
                                              fontWeight: FontWeight.w300)),
                                    ],
                                  ),
                                ),
                                Expanded(child: Container()),
                                Container(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!sendByMe || approval) {
                                        setState(() {
                                          _amount = double.parse(price);
                                        });
                                        _pc.open();
                                      }
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            chatCornerRadius),
                                        border: Border.all(
                                            width: 1,
                                            color: (approval)
                                                ? Colors.white
                                                : Colors.transparent),
                                      ),
                                      child: Text((approval) ? 'Pay' : '',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontFamily: 'OverpassRegular',
                                              fontWeight: FontWeight.w200)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                )
                              ],
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
        'time': DateTime.now().toUtc().toString(),
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
        renderPanelSheet: false,
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
            middle: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.center,
                //Center Row contents vertically,
                children: [
                  Text(widget.sellerName),
                  SizedBox(
                    width: 6,
                  ),
                  statusIndicator(widget.sellerName)
                ],
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
                      padding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      child: itemView('stuff', 'Description')),
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
//                        child: Row(
//                          children: [
//                            Expanded(
//                                flex: 1,
//                                child: RaisedButton(
//                                  color: Colors.red,
//                                  onPressed: () {
//                                    DatabaseMethods()
//                                        .declineJob(widget.chatRoomId);
//                                    Navigator.pop(context);
//                                  },
//                                  child: const Text('Decline',
//                                      style: TextStyle(
//                                          color: Colors.white,
//                                          fontSize: 20,
//                                          fontWeight: FontWeight.bold)),
//                                )),
//                          ],
//                        ),
                      ),
                Flexible(child: chatMessages()),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      (widget.declined)
                          ? Container()
                          : Expanded(
                              flex: 1,
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
                        width: 5,
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
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
