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

  Item(
      {this.title,
      this.price,
      this.currency,
      this.condition,
      this.imageUrl,
      this.sellerName,
      this.feedbackPercentage,
      this.feedbackScore,
      this.buyingOptions});

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
}
