import 'dart:convert';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/native_admob_options.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:upkeephousepartner/HomeScreens/leads.dart';
import 'package:upkeephousepartner/Manager/MyConnectivity.dart';
import 'package:upkeephousepartner/Manager/ad_manager.dart';
import 'package:upkeephousepartner/Models/about.dart';

import 'package:upkeephousepartner/Models/noInternet.dart';
import 'package:upkeephousepartner/loginScreens/loginScreen.dart';

import '../size_config.dart';
import 'blog.dart';
import 'edit.dart';

class Third extends StatefulWidget {
  @override
  _ThirdState createState() => _ThirdState();
}

class _ThirdState extends State<Third> {
  int points;
  List walletinfo;
  String state, partner_id, dialog_error;

  String admessage;

  Map _source = {ConnectivityResult.none: false};


  AdmobReward rewardAd;
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  final nativecontroller = NativeAdmobController();

  getWalletInfo(String state, String partnerid) async {
    final prefs = await SharedPreferences.getInstance();
    String url = 'https://upkeephouse.com/show_points.php';
    FormData newData =
        new FormData.fromMap({'partner_id': partnerid, 'state': state});
    await Dio().post(url, data: newData).then((value) {
      if (value.statusCode == 200) {
        print('200');
        if (value.data.toString() != '0') {
          setState(() {
            walletinfo = jsonDecode(value.data);
            for (var i in walletinfo) {
              points = int.parse(i['points']);
            }
            prefs.setString('points', points.toString());
          });
          print(walletinfo.toString());
        }
      } else {
        print('error');
      }
    });
  }

  uploadWalletInfo() async {
    setState(() {
      points++;
      dialog_error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    String url = 'https://upkeephouse.com/upload_points.php';

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Wait..',
              style:
                  GoogleFonts.gotu(fontSize: 2.5 * SizeConfig.textMultiplier),
            ),
            content: dialog_error != null
                ? Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Error ' + dialog_error,
                          style: GoogleFonts.gotu(
                              fontSize: 2 * SizeConfig.textMultiplier),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            uploadWalletInfo();
                          },
                          color: Colors.amber,
                          child: Text('Retry'),
                        )
                      ],
                    ),
                  )
                : Text(
                    'Points is uploading.',
                    style: GoogleFonts.gotu(
                        fontSize: 2 * SizeConfig.textMultiplier),
                  ),
          );
        });
    if (state != null && partner_id != null) {
      FormData newData = new FormData.fromMap({
        'partner_id': partner_id,
        'state': state,
        'points': points.toString()
      });
      await Dio().post(url, data: newData).then((value) {
        if (value.statusCode == 200) {
          if (value.data.toString() == 'true') {
            setState(() {
              prefs.setString('points', points.toString());
              Future.delayed(Duration(seconds: 1), () {
                Navigator.of(context).pop();
              });
            });
          } else {
            setState(() {
              dialog_error = 'Points is not uploaded';
              points--;
            });
          }
        } else {
          print('error');
          setState(() {
            points--;
            dialog_error = 'Error: ' + value.statusCode.toString();
          });
        }
      });
    } else {
      await SharedPreferences.getInstance().then((value) async {
        FormData newData = new FormData.fromMap({
          'partner_id': partner_id,
          'state': state,
          'points': points.toString()
        });
        await Dio().post(url, data: newData).then((value) {
          if (value.statusCode == 200) {
            if (value.data.toString() == 'true') {
              setState(() {
                print(value.data);
                prefs.setString('points', points.toString());
                Future.delayed(Duration(milliseconds: 50), () {
                  Navigator.of(context).pop();
                });
              });
            } else {
              setState(() {
                points--;
                dialog_error = 'Error: ' + value.statusCode.toString();
              });
            }
          } else {
            setState(() {
              points--;
              dialog_error = 'Error: ' + value.statusCode.toString();
            });
            print('error');
          }
        });
      });
    }
  }

  Future<void> getInfo() async {
    await SharedPreferences.getInstance().then((value) {
      getWalletInfo(value.get('state'), value.get('partner_id'));
    });
  }

  getWalletPoints() async {
    await SharedPreferences.getInstance().then((value) {
      setState(() {
        points = int.parse(value.get('points').toString());
        state = value.get('state');
        partner_id = value.get('partner_id');
      });
    });
  }

  void showSnackBar(String content) {
    scaffoldState.currentState.showSnackBar(
      SnackBar(
        content: Text(content),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState

    rewardAd = AdmobReward(
      adUnitId: AdManager.rewardedAdUnitId,
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) {
          setState(() {
            admessage = 'Ad कुछ सेकेंड में लोड हो जाएगी। ';
          });
          rewardAd.load();
        }
        if (event == AdmobAdEvent.rewarded) {
          setState(() {
            admessage = ' hey you got reward man ';
          });
          uploadWalletInfo();
          rewardAd.load();
        }
        if (event == AdmobAdEvent.loaded) {
          setState(() {
            admessage = ' Ads लोड हो गई है आप इसको देख सकते है। ';
          });
        }
        if (event == AdmobAdEvent.opened) {
          rewardAd.load();
        }
        if (event == AdmobAdEvent.failedToLoad) {
          setState(() {
            admessage =
                ' Ads लोड नहीं हो पा रही  है या तो इंटरनेट चेक करे अपना या फिर कुछ सेकेंड इंतज़ार करे। ';
          });
          rewardAd.load();
        }
      },
    );
    rewardAd.load();
    getWalletPoints();

    FirebaseMessaging().configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        //_showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // _navigateToItemDetail(message);
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    rewardAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                  SizeConfig.mainyellow,
                  SizeConfig.mainpurple
                ])),
          ),
          leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: SizeConfig.imageSizeMultiplier * 7,
              ),
            ),
          ),
          title: Column(
            children: [
              Text(
                'Wallet',
                style: GoogleFonts.gotu(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Get.to(About());
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: SizeConfig.imageSizeMultiplier * 7,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                SizeConfig.shareApp(context);
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.share,
                  color: Colors.white,
                  size: SizeConfig.imageSizeMultiplier * 7,
                ),
              ),
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 0),
      body:  points != null
              ? RefreshIndicator(
                  onRefresh: getInfo,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: ListView(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                SizeConfig.mainyellow,
                                SizeConfig.mainpurple
                              ])),
                          child: Center(
                              child: Column(
                            children: [
                              Text(
                                'Points',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 2.3 * SizeConfig.textMultiplier,
                                    color: Colors.white),
                              ),
                              Text(
                                points.toString(),
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 6.3 * SizeConfig.textMultiplier,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'ये आपके points  है जिनकी मदद से आप leads ( हमारे user की details जो आप से काम करवाना चाहता है जैसे फ़ोन नंबर ) की डिटेल देख सकते है जो आपको नोटिफिकेशन से मिलेगी । आपको अपने points  बढ़ाने के लिए वीडियो ads को पूरा देखना होगा तभी आपके points बढ़ेंगे नहीं तो नहीं बढ़ेंगे,  धन्यवाद !',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 2.3 * SizeConfig.textMultiplier,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Watch A Video',
                                style: GoogleFonts.gotu(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 2.5 * SizeConfig.textMultiplier,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (await rewardAd.isLoaded) {
                                    rewardAd.show();
                                  } else {
                                    showSnackBar(
                                        'Ad कुछ सेकेंड में लोड हो जाएगी। ...');
                                    rewardAd.load();
                                  }
                                },
                                child: new Container(
                                    height: 40 * SizeConfig.imageSizeMultiplier,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 2.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              5.0) //         <--- border radius here
                                          ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            admessage != null
                                                ? Text(
                                                    admessage,
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 2.2 *
                                                            SizeConfig
                                                                .textMultiplier,
                                                        color: Colors.black),
                                                    textAlign: TextAlign.center,
                                                  )
                                                : SizedBox(),
                                            Icon(
                                              Icons.play_circle_filled,
                                              color: Colors.black,
                                              size: SizeConfig
                                                      .imageSizeMultiplier *
                                                  20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 42 * SizeConfig.imageSizeMultiplier,
                                child: NativeAdmob(
                                  adUnitID: AdManager.nativeAdUnitId,
                                  loading: Center(
                                      child: CircularProgressIndicator()),
                                  error: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              5.0) //         <--- border radius here
                                          ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Ad will show here',
                                        style: GoogleFonts.gotu(
                                            fontSize: 2.3 *
                                                SizeConfig.textMultiplier),
                                      ),
                                    ),
                                  ),
                                  controller: nativecontroller,
                                  type: NativeAdmobType.full,
                                  options: NativeAdmobOptions(
                                    ratingColor: Colors.green,
                                    // Others ...
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Center(
                  child: SpinKitFadingCircle(
                    color: Colors.black,
                  ),
                ) ,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home,
                    color: Colors.black,
                  ),
                  Text(
                    'HOME',
                    style: GoogleFonts.gotu(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.off(Second());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contact_phone,
                    color: Colors.black,
                  ),
                  Text(
                    'LEADS',
                    style: GoogleFonts.gotu(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            GestureDetector(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: SizeConfig.mainpurple,
                  ),
                  Text(
                    'WALLET',
                    style: GoogleFonts.gotu(
                        color: SizeConfig.mainpurple,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.off(Blog());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.subject,
                    color: Colors.black,
                  ),
                  Text(
                    'BLOG',
                    style: GoogleFonts.gotu(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.off(Fourth());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mode_edit,
                    color: Colors.black,
                  ),
                  Text(
                    'EDIT',
                    style: GoogleFonts.gotu(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
