import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:offer_app/models/item.dart';
import 'package:provider/provider.dart';

import 'ebayMock.dart';

class SearchAPI extends StatefulWidget {
  @override
  _SearchAPIState createState() => new _SearchAPIState();
}

class _SearchAPIState extends State<SearchAPI> {
  TextEditingController searchText = new TextEditingController();
  final HttpService httpService = HttpService();
  String _terms = '';
  bool haveUserSearched = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userIsLoggedIn = Provider.of<UserIsLoggedIn>(context);
    return SafeArea(
        bottom: false,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              CupertinoTextField(
                controller: searchText,
                onSubmitted: (text) {
                  _terms = searchText.text;
                  if (_terms != '') {
                    setState(() {
                      haveUserSearched = true;
                    });
                  }
                },
                autofocus: true,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: (!haveUserSearched)
                    ? Container()
                    : Flexible(child: httpResult(_terms, userIsLoggedIn.token)),
              )
            ],
          ),
        ),
      );

  }

  Widget httpResult(String itemName, token) {
    return FutureBuilder(
      future: httpService.getItems(itemName, token),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          List<Item> items = snapshot.data;
          haveUserSearched = false;
          return GridView.builder(
              shrinkWrap: true,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                Item currentItem = items[index];
                return Card(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Image.network(
                        currentItem.imageUrl == null
                            ? 'https://us.123rf.com/450wm/pavelstasevich/pavelstasevich1811/pavelstasevich181101027/112815900-stock-vector-no-image-available-icon-flat-vector.jpg?ver=6'
                            : items[index].imageUrl,
                        height: 100,
                        width: 100,
                      ),
                      Flexible(
                        child: Container(),
                      ),
                      Text(
                        currentItem.title.substring(0, 20),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        currentItem.condition,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: items.length);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class HttpService {
  Future<List<Item>> getItems(String itemName, token) async {
    String searchURL =
        'https://api.ebay.com/buy/browse/v1/item_summary/search?q=$itemName&limit=42';
    http.Response res = await http.get(searchURL, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'X-EBAY-C-ENDUSERCTX':
          'contextualLocation=country=<2_character_country_code>,zip=<zip_code>,affiliateCampaignId=<ePNCampaignId>,affiliateReferenceId=<referenceId>'
    });
    print(res.statusCode);
    if (res.statusCode == 200) {
      print('begin parsing response');

      Map<String, dynamic> body = jsonDecode(res.body);
      List<dynamic> temp = body['itemSummaries'];
      print('size of the list = ${temp.length}');
      List<Item> items = temp
          .map(
            (dynamic it) => Item.fromJson(it),
          )
          .toList();

      print(items.length);
      print('Done Parsing');
      return items;
    } else {
      throw "Can't get items.";
    }
  }
}
