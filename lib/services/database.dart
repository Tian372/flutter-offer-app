import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DatabaseMethods {
  Future<void> addUserInfo(userData) async {
    Firestore.instance.collection("users").add(userData).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addItemHelper(itemData) async {
    Firestore.instance.collection("mockData").add(itemData).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> declineJob(String jobId) async {
    DocumentReference dr =
        Firestore.instance.collection("chatRoom").document(jobId);

    dr.updateData(<String, dynamic>{
      'declined': true,
    });
//    dr.collection("chats").getDocuments().then((snapshot) {
//      for (DocumentSnapshot ds in snapshot.documents) {
//        ds.reference.delete();
//      }
//    });
//    await Firestore.instance.runTransaction((Transaction myTransaction) async {
//      await myTransaction.delete(dr);
//    });
  }

  Future<void> updateApproval(String chatRoomId, chatId) async {
    DocumentReference dr = Firestore.instance
        .collection('chatRoom')
        .document(chatRoomId)
        .collection('chats')
        .document(chatId);
    bool temp;
    await dr.get().then((value) => {temp = value.data['sellerApproved']});
    dr.updateData(<String, bool>{
      'sellerApproved': !temp,
    });
    print('Price Approved');
  }

  Future<void> updateBuyerList(String itemId, buyerName) async {
    DocumentReference dr =
        Firestore.instance.collection('mockData').document(itemId);

    dr.updateData(<String, dynamic>{
      'offerNum': FieldValue.increment(1),
      'buyers': FieldValue.arrayUnion([buyerName]),
    });
    print('Buyer added');
  }

  Future<void> rejectJob(String jobId) async {
    DocumentReference dr =
        Firestore.instance.collection("chatRoom").document(jobId);

    dr.collection("chats").getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });
    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      await myTransaction.delete(dr);
    });
  }

  getUserInfo(String email) async {
    return Firestore.instance
        .collection("users")
        .where("userEmail", isEqualTo: email)
        .getDocuments()
        .catchError((e) {
      print(e.toString());
    });
  }

  getLatestPriceFrom(String chatRoomId) async {
    return Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy('time', descending: true)
        .limit(1)
        .snapshots();
  }

  getChats(String chatRoomId) async {
    return Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy('time', descending: true)
        .snapshots();
  }

  searchByName(String searchField) {
    return Firestore.instance
        .collection("users")
        .where('userName', isEqualTo: searchField)
        .getDocuments();
  }

  searchByItem(String item, String myName) {
    return Firestore.instance
        .collection("mockData")
        .where('itemName', isEqualTo: item)
        .getDocuments();
  }

  Future<bool> addChatRoom(chatRoom, chatRoomId) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .setData(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> addMessage(String chatRoomId, chatMessageData) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });

  }

  getUserSellerChats(String myName) async {
    return Firestore.instance
        .collection("chatRoom")
        .where('seller', isEqualTo: myName)
        .snapshots();
  }

  getUserBuyerChats(String myName) async {
    return Firestore.instance
        .collection("chatRoom")
        .where('buyer', isEqualTo: myName)
        .snapshots();
  }
  isChatroomExist(String chatRoomId) {
    Firestore.instance
        .collection('chatRoom')
        .where('chatRoomId', isEqualTo: chatRoomId);
  }

  Future<void> addWinner(String itemId, userName) async {
    DocumentReference dr =
        Firestore.instance.collection('mockData').document(itemId);
    dr.updateData(<String, dynamic>{'sold': true, 'winner': userName});
    print('Winner updated');
  }
}
