import 'package:flutter/cupertino.dart';
import 'package:offer_app/main.dart';

import '../helper/helperfunctions.dart';
import '../helper/theme.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../views/chatrooms.dart';
import '../views/forgot_password.dart';
import '../widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'addItem.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn(this.toggleView);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();

  AuthService authService = new AuthService();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

//
  signIn() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      await authService
          .signInWithEmailAndPassword(
          emailEditingController.text, passwordEditingController.text)
          .then((result) async {
        if (result != null) {
          QuerySnapshot userInfoSnapshot =
          await DatabaseMethods().getUserInfo(emailEditingController.text);

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
              userInfoSnapshot.documents[0].data["userName"]);
          HelperFunctions.saveUserEmailSharedPreference(
              userInfoSnapshot.documents[0].data["userEmail"]);

          Navigator.pushReplacement(
              context, CupertinoPageRoute(
              settings: RouteSettings(name: "chatRoom"),
              builder: (context) => ChatRoom()));
        } else {
          setState(() {
            isLoading = false;
            //show snackbar
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: appBarMain(context),
      child: isLoading
          ? Container(
        child: Center(child: CircularProgressIndicator()),
      )
          : Container(
        padding: EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => ItemView()),
                );
              },
              child: Text(
                "add item info",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    decoration: TextDecoration.underline),
              ),
            ),
            Spacer(
              flex: 2,
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  CupertinoTextField(
//                          validator: (val) {
//                            return RegExp(
//                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//                                    .hasMatch(val)
//                                ? null
//                                : "Please Enter Correct Email";
//                          },
                    controller: emailEditingController,
                    style: simpleTextStyle(),
//                          decoration: textFieldInputDecoration("email"),
                  ),
                  CupertinoTextField(
                    obscureText: true,
//                          validator: (val) {
//                            return val.length >= 6
//                                ? null
//                                : "Enter Password 6+ characters";
//                          },
                    style: simpleTextStyle(),
                    controller: passwordEditingController,
//                          decoration: textFieldInputDecoration("password"),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => ForgotPassword()));
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        "Forgot Password?",
                        style: simpleTextStyle(),
                      )),
                )
              ],
            ),
            Spacer(
              flex: 2,
            ),
            GestureDetector(
              onTap: () {
                signIn();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: HexColor.fromHex('#0064D2')
                ),
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: CupertinoButton(child: Text(
                  "Sign In",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                  textAlign: TextAlign.center,
                ),),
              ),
            ),
            SizedBox(
              height: 16,
            ),
//                  Container(
//                    padding: EdgeInsets.symmetric(vertical: 16),
//                    decoration: BoxDecoration(
//                        borderRadius: BorderRadius.circular(30),
//                        color: Colors.white),
//                    width: MediaQuery.of(context).size.width,
//                    child: Text(
//                      "Sign In with Google",
//                      style:
//                          TextStyle(fontSize: 17, color: CustomTheme.textColor),
//                      textAlign: TextAlign.center,
//                    ),
//                  ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have account? ",
                  style: simpleTextStyle(),
                ),
                GestureDetector(
                  onTap: () {
                    widget.toggleView();
                  },
                  child: Text(
                    "Register now",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),

            Spacer(
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}
