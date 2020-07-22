import 'package:flutter/cupertino.dart';

class Item {
  final String title;
  final String price;
  final String currency;
  final String condition;
  final String imageUrl;
  final String sellerName;
  final String feedbackPercentage;
  final int feedbackScore;
  final List<dynamic> buyingOptions;
  final int offerNum;
  final bool sold;

  Item(
      {@required this.title,
      @required this.price,
      @required this.currency,
      @required this.condition,
      @required this.imageUrl,
      @required this.sellerName,
      @required this.feedbackPercentage,
      @required this.feedbackScore,
      @required this.buyingOptions,
      this.offerNum = 0,
      this.sold = false});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        title: json['title'] as String,
        price: json['price']['value'] as String,
        currency: json['price']['currency'] as String,
        condition: json['condition'] as String,
        imageUrl: json.containsKey('image') ? json['image']['imageUrl'] : null,
        sellerName: json['seller']['username'] as String,
        feedbackPercentage: json['seller']['feedbackPercentage'] as String,
        feedbackScore: json['seller']['feedbackScore'] as int,
        buyingOptions: json['buyingOptions'] as List<dynamic>,
      );

  factory Item.fromJson2(Map<String, dynamic> json) => Item(
        title: json['itemName'] as String,
        price: json['listPrice'] as String,
        currency: 'USD',
        condition: json['condition'] as String,
        imageUrl: json['imageUrl'] as String,
        sellerName: json['seller'] as String,
        feedbackPercentage: json['feedbackPercentage'] as String,
        feedbackScore: json['feedbackScore'] as int,
        buyingOptions: json['buyingOptions'] as List<dynamic>,
        offerNum: json['offerNum'] as int,
        sold: json['sold'] as bool,
      );
}
