import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:offer_app/helper/style.dart';
import 'package:offer_app/models/item.dart';
import 'package:offer_app/views/Rooms/auctionRoom.dart';

import '../helper/constants.dart';
import '../services/database.dart';
import 'Rooms/buyerChat.dart';
import '../widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController _controller;
  FocusNode _focusNode;
  QuerySnapshot searchResultSnapshot;

  String _terms = '';

  bool isLoading = false;
  bool haveUserSearched = false;

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  initiateSearch() async {
    if (_terms != '') {
      setState(() {
        isLoading = true;
      });
      await databaseMethods
          .searchByItem(_terms, Constants.myName)
          .then((snapshot) {
        searchResultSnapshot = snapshot;
        setState(() {
          isLoading = false;
          haveUserSearched = true;
        });
      });
    }
  }

  Widget itemList() {
    return haveUserSearched
        ? Flexible(
            child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                      color: Styles.productRowDivider,
                      thickness: 1,
                    ),
                shrinkWrap: true,
                itemCount: searchResultSnapshot.documents.length,
                itemBuilder: (context, index) {
                  Item currentItem = Item.fromJson2(
                      searchResultSnapshot.documents[index].data);
                  return itemTile(
                    currentItem,
                    searchResultSnapshot.documents[index].documentID,
                  );
                }),
          )
        : Container();
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchBar(
        controller: _controller,
        focusNode: _focusNode,
      ),
    );
  }

  sendAuction(Item currentItem, String itemId) async {
    final snapShot = await Firestore.instance
        .collection('auctionRoom')
        .document(currentItem.title)
        .get();

    if (snapShot.exists) {
      DatabaseMethods()
          .updateAuctionBuyerList(currentItem.title, Constants.myName);
    } else {
      Map<String, dynamic> auctionRoom = {
        'itemName': currentItem.title,
        'seller': currentItem.sellerName,
        'buyers': [Constants.myName],
        'declined': false,
        'paid': false,
        'imageUrl': currentItem.imageUrl,
        'condition': currentItem.condition,
      };

      databaseMethods.addAuctionRoom(auctionRoom, currentItem.title);

      Map<String, dynamic> bidMap = {
        'sendBy': currentItem.sellerName,
        'price': currentItem.price,
        'time': DateTime.now().toUtc().toString(),
      };

      DatabaseMethods().addBid(currentItem.title, bidMap);
    }
    Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
            builder: (context) => AuctionRoom(
                  itemName: currentItem.title,
                  userName: currentItem.sellerName,
                  declined: false,
                  imageUrl: currentItem.imageUrl,
                  bidderNum: 1,
                  condition: currentItem.condition,
                )));
  }

  /// 1.create a chatroom, send user to the chatroom, other userdetails
  sendMessage(Item currentItem, String itemId) async {
    String chatRoomId = getChatRoomId(
        Constants.myName, currentItem.sellerName, currentItem.title);
    print(chatRoomId);
    final snapShot = await Firestore.instance
        .collection('chatRoom')
        .document(chatRoomId)
        .get();
    bool declinedStatus = false;
    bool paymentStatus = false;

    if (snapShot.exists) {
      declinedStatus = snapShot.data['declined'];
      paymentStatus = snapShot.data['paid'];
    } else {
      print('add now chatroom');
      DatabaseMethods().updateBuyerList(itemId, Constants.myName);
      Map<String, dynamic> chatRoom = {
        'itemName': currentItem.title,
        'itemId': itemId,
        'seller': currentItem.sellerName,
        'buyer': Constants.myName,
        'chatRoomId': chatRoomId,
        'declined': declinedStatus,
        'paid': paymentStatus,
        'imageUrl': currentItem.imageUrl,
        'condition': currentItem.condition,
        'listedPrice': currentItem.price,
        'offerNum': currentItem.offerNum,
      };
      databaseMethods.addChatRoom(chatRoom, chatRoomId);
      print('chat room added');
      Map<String, dynamic> priceMap = {
        'sendBy': currentItem.sellerName,
        'price': currentItem.price,
        'message': 'Buy it now price.',
        'sellerApproved': true,
        'time': DateTime.now().toUtc().toString(),
      };

      DatabaseMethods().addMessage(chatRoomId, priceMap);

      print('message added');
    }
    Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
            builder: (context) => BuyerChat(
                  chatRoomId: chatRoomId,
                  sellerName: currentItem.sellerName,
                  declined: declinedStatus,
                  itemId: itemId,
                  imageUrl: currentItem.imageUrl,
                  listPrice: currentItem.price,
                  condition: currentItem.condition,
                  offerNum: currentItem.offerNum,
                )));
  }

  Widget itemTile(Item currentItem, String itemId) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('mockData')
            .document(itemId)
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> map = snapshot.data.data;
            Item myItem = Item.fromJson2(map);
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FutureBuilder(
                      future: getImage(context, 'images/$itemId.jpg'),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.connectionState == ConnectionState.done)
                            return Container(
                              child: snapshot.data,
                            );
                          else {
                            return CircularProgressIndicator();
                          }
                        } else {
                          return Image.network(
                            myItem.imageUrl,
                            height: 100,
                            width: 100,
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 250,
                          child: Text(
                            '${myItem.title}',
                            style: Styles.searchText,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${myItem.condition}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        SizedBox(height: 15),
                        Text(
                          '\$ ${myItem.price}',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${myItem.offerNum} people are interested.',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      CupertinoButton(
                        child: Text('Offer'),
                        onPressed: () {
                          print('send message');
                          sendMessage(currentItem, itemId);
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      CupertinoButton(
                        child: Text('Auction'),
                        onPressed: () {
                          sendAuction(currentItem, itemId);
                        },
                      ),
                    ],
                  )
                ],
              ),
            );
          }else{
            return CircularProgressIndicator();
          }
        });
  }

  getChatRoomId(String a, b, itemName) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return '$b\_$a\_$itemName';
    } else {
      return '$a\_$b\_$itemName';
    }
  }

  @override
  void initState() {
    _controller = TextEditingController()..addListener(_onTextChanged);
    _focusNode = FocusNode();
    super.initState();
  }

  void _onTextChanged() {
    setState(() {
      _terms = _controller.text;
      initiateSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Styles.scaffoldBackground,
      ),
      child: SafeArea(
        child: Container(
          child: Column(
            children: [
              _buildSearchBox(),
              isLoading ? CupertinoActivityIndicator() : itemList()
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({
    @required this.controller,
    @required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Styles.searchBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.search,
              color: Styles.searchIconColor,
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: CupertinoTextField(
                autofocus: true,
                controller: controller,
                focusNode: focusNode,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
                decoration: BoxDecoration(
                  color: Styles.searchBackground,
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: controller.clear,
              child: const Icon(
                CupertinoIcons.clear_thick_circled,
                color: Styles.searchIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
