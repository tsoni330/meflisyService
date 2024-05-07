import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upkeephousepartner/HomeScreens/home.dart';
import 'package:upkeephousepartner/Models/newVersion.dart';
import 'package:upkeephousepartner/registerScreen/registerScreen.dart';

import '../size_config.dart';

class loginScreen extends StatefulWidget {
  @override
  _loginScreenState createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  TextEditingController statecontroller = TextEditingController();
  String state, otp;

  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  PackageInfo packageInfo;
  bool loginwaiting = false;
  bool otpwaiting = false;
  bool updateversion = true;
  List versioninfo;
  String new_version, app_version, new_version_details;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final String url = 'https://upkeephouse.com/working_states.php';
  final String url2 = 'https://upkeephouse.com/login_partner.php';
  List statedata;
  String phoneNumber, firetoken;
  String error;
  bool reset = false;

  Future getStateData() async {
    Response response = await Dio().get(url);
    if (response.statusCode == 200) {
      setState(() {
        if (response.data != null) {
          statedata = jsonDecode(response.data);
        } else {
          error =
              'State list is not downloaded. Check your internet connection';
        }
      });
    } else {
      error = 'State list is not downloaded. Check your internet connection';
    }
  }

  upload_firetoken() async {
    print('token is working');
    String url = 'https://upkeephouse.com/upload_token.php';
    await firebaseMessaging.getToken().then((value) async {
      FormData newData = new FormData.fromMap(
          {'partner_id': phoneNumber, 'state': state, 'token': value});
      setState(() {
        otpwaiting = false;
      });
      await Dio().post(url, data: newData).then((response) {
        response.statusCode == 200 ? Get.offAll(Home()) : print('not uploaded');
      });
    });
  }

  loginPartner() async {
    setState(() {
      loginwaiting = true;
    });
    FormData newData =
        new FormData.fromMap({'partner_id': phoneNumber, 'state': state});

    await Dio().post(url2, data: newData).then((value) {
      if (value.data.toString() == '1') {
        setState(() {
          error = null;
          loginwaiting = false;
        });
        phoneVerification(phoneNumber);
      } else {
        setState(() {
          error = 'No Accout Found on this Number';
          loginwaiting = false;
        });
      }
    });
  }

  version_info() async {
    packageInfo = await PackageInfo.fromPlatform();
    app_version = packageInfo.version.toString();
    String url = 'https://upkeephouse.com/version_info.php';
    await Dio().get(url).then((response) {
      if (response.statusCode == 200) {
        if (response.data != null) {
          versioninfo = jsonDecode(response.data);
          for (var i in versioninfo) {
            new_version = i['version'].toString();
            new_version_details = i['info'];
          }
          if (new_version != app_version) {
            setState(() {
              updateversion = false;
            });
          }
        } else {
          print('it show null');
        }
      }
    });
  }

  phoneVerification(String phonenumber) async {
    final prefs = await SharedPreferences.getInstance();
    await auth.verifyPhoneNumber(
        phoneNumber: '+91' + phonenumber,
        verificationCompleted: (PhoneAuthCredential authCredential) async {
          await auth.signInWithCredential(authCredential).then((value) {
            if (value.user != null) {
              prefs.setString('state', state);
              prefs.setString('partner_id', phoneNumber);
              upload_firetoken();
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            print('This is working ');
            error = e.toString();
          });
        },
        codeSent: (String verificationId, int resendToken) async {
          setState(() {
            error = null;
          });
          smsCodeDialog(context, verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.otp = verificationId;
        });
  }

  smsCodeDialog(BuildContext context, String verificationId) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Enter OTP",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: SizeConfig.mainpurple,
                        fontSize: 2.2 * SizeConfig.textMultiplier,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.all(20.0),
                    child: PinPut(
                      autofocus: true,
                      fieldsCount: 6,
                      onSubmit: (String pin) => this.otp = pin,
                      focusNode: _pinPutFocusNode,
                      controller: _pinPutController,
                      submittedFieldDecoration: _pinPutDecoration.copyWith(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      selectedFieldDecoration: _pinPutDecoration,
                      followingFieldDecoration: _pinPutDecoration.copyWith(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Colors.deepPurpleAccent.withOpacity(.5),
                        ),
                      ),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      setState(() {
                        otpwaiting = true;
                      });
                      signinMannually(verificationId, otp);
                    },
                    child: Text(
                      "Verify",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: const Color(0xFF1BC0C5),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  otpwaiting
                      ? Container(
                          child: SpinKitFadingCircle(
                            color: Colors.black,
                          ),
                        )
                      : SizedBox()
                ],
              ));
        });
  }

  signinMannually(String verificationID, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: otp);

    await auth.signInWithCredential(phoneAuthCredential).then((value) {
      if (value.user != null) {
        prefs.setString('state', state);
        prefs.setString('partner_id', phoneNumber);
        upload_firetoken();
      }
    });
  }

  @override
  void initState() {
    version_info();
    getStateData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        SizeConfig().init(constraints);
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: updateversion == true
              ? AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                )
              : AppBar(
                  backgroundColor: SizeConfig.mainpurple,
                  elevation: 0,
                ),
          body: updateversion == true
              ? Stack(
                  children: [
                    loginwaiting
                        ? Center(
                            child: SpinKitFadingCircle(
                              color: Colors.black,
                            ),
                          )
                        : Opacity(
                            opacity: 0.0,
                          ),
                    ListView(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.gotu(
                                        fontSize:
                                            5.5 * SizeConfig.textMultiplier,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 5, top: 45, right: 5),
                                    child: Text(
                                      "1",
                                      style: GoogleFonts.gotu(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            SizeConfig.textMultiplier * 2.5,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 5, top: 45, right: 5),
                                        child: Text(
                                          "Select State First",
                                          style: GoogleFonts.gotu(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.textMultiplier * 2.2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 5, top: 1, right: 5),
                                        child: Text(
                                          "अपना राज्य चुने",
                                          style: GoogleFonts.gotu(
                                            color: Colors.black,
                                            fontSize:
                                                SizeConfig.textMultiplier * 2.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              statedata != null
                                  ? Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 2.0),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                5.0) //         <--- border radius here
                                            ),
                                      ),
                                      margin: EdgeInsets.only(
                                          left: 5, top: 15, right: 5),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          iconSize: 50,
                                          iconEnabledColor:
                                              Colors.black,
                                          iconDisabledColor:
                                              Colors.black,
                                          items: statedata.map((item) {
                                            return new DropdownMenuItem(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Text(
                                                  item['state'].toString(),
                                                  style: GoogleFonts.gotu(
                                                    color:
                                                        SizeConfig.mainpurple,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: SizeConfig
                                                            .textMultiplier *
                                                        2.5,
                                                  ),
                                                ),
                                              ),
                                              value: item['state'].toString(),
                                            );
                                          }).toList(),
                                          hint: Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Text(
                                              "Select State",
                                              style: GoogleFonts.gotu(
                                                color: Colors.black,
                                                fontSize:
                                                    SizeConfig.textMultiplier *
                                                        2.5,
                                              ),
                                            ),
                                          ),
                                          onChanged: (newVal) {
                                            setState(() {
                                              state = newVal;
                                              print('the selected state is ' +
                                                  newVal);
                                            });
                                          },
                                          value: state,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: SpinKitFadingCircle(
                                        color: Colors.black,
                                      ),
                                    ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 5, top: 45, right: 5),
                                    child: Text(
                                      "2",
                                      style: GoogleFonts.gotu(
                                          fontSize:
                                              SizeConfig.textMultiplier * 2.5,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 5, top: 35, right: 5),
                                        child: Text(
                                          "Enter Mobile Number",
                                          style: GoogleFonts.gotu(
                                              color: Colors.black,
                                              fontSize:
                                                  SizeConfig.textMultiplier *
                                                      2.2),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 5, top: 1, right: 5),
                                        child: Text(
                                          "अपना मोबाइल नंबर डाले",
                                          style: GoogleFonts.gotu(
                                            fontSize:
                                                SizeConfig.textMultiplier * 2.2,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 2.0),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          5.0) //         <--- border radius here
                                      ),
                                ),
                                margin:
                                    EdgeInsets.only(left: 5, top: 15, right: 5),
                                child: TextField(
                                  style: TextStyle(
                                      fontSize: 2.5 * SizeConfig.textMultiplier,
                                      color: SizeConfig.mainpurple),
                                  decoration: InputDecoration(
                                    hintText: "Ex: 9671775251",
                                    hintStyle: GoogleFonts.gotu(
                                        color: Colors.black,
                                        fontSize:
                                            2.3 * SizeConfig.textMultiplier),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, bottom: 11, top: 11),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  onChanged: (value) => phoneNumber = value,
                                ),
                              ),
                              error != null
                                  ? Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(top: 10),
                                      child: Text(
                                        error,
                                        style: GoogleFonts.gotu(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 2.3 *
                                                SizeConfig.textMultiplier),
                                      ),
                                    )
                                  : SizedBox(),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    error = null;
                                  });
                                  loginPartner();
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      SizeConfig.mainyellow,
                                      SizeConfig.mainpurple
                                    ]),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            5.0) //         <--- border radius here
                                        ),
                                  ),
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                      left: 25, top: 15, right: 25),
                                  child: Center(
                                    child: Text(
                                      "Login",
                                      style: GoogleFonts.gotu(
                                          color: Colors.white,
                                          fontSize:
                                              SizeConfig.textMultiplier * 3.2,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(registerScreen());
                                },
                                child: Container(
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 5, top: 35, right: 5),
                                        child: NeumorphicText(
                                          "नये है तो अभी जुड़े ",
                                          style: NeumorphicStyle(
                                            depth: 8, //customize depth here
                                            color: SizeConfig.mainpurple,
                                          ),
                                          textStyle: NeumorphicTextStyle(
                                            fontSize:
                                                SizeConfig.textMultiplier * 3,
                                            //customize size here
                                            // AND others usual text style properties (fontFamily, fontWeight, ...)
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(left: 5, right: 5),
                                        child: NeumorphicText(
                                          "Register Now",
                                          style: NeumorphicStyle(
                                            depth: 8, //customize depth here
                                            color: SizeConfig.mainpurple,
                                            border: NeumorphicBorder(
                                                isEnabled: true,
                                                color: Colors.black,
                                                width: 1),
                                          ),
                                          textStyle: NeumorphicTextStyle(
                                            fontSize:
                                                SizeConfig.textMultiplier * 3,
                                            //fontWeight: FontWeight.bold, //customize size here
                                            // AND others usual text style properties (fontFamily, fontWeight, ...)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : newVersion(new_version_details),
        );
      },
    );
  }
}
