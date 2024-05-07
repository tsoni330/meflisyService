import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter_native_admob/native_admob_options.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upkeephousepartner/HomeScreens/blog.dart';
import 'package:upkeephousepartner/HomeScreens/blog2.dart';
import 'package:upkeephousepartner/HomeScreens/edit.dart';
import 'package:upkeephousepartner/HomeScreens/leads.dart';
import 'package:upkeephousepartner/HomeScreens/wallet.dart';
import 'package:upkeephousepartner/Manager/MyConnectivity.dart';
import 'package:upkeephousepartner/Manager/ad_manager.dart';
import 'package:upkeephousepartner/Models/about.dart';
import 'package:upkeephousepartner/Models/newVersion.dart';
import 'package:upkeephousepartner/Models/noInternet.dart';

import 'package:upkeephousepartner/size_config.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String state,
      city,
      partner_id,
      name,
      business_name,
      image,
      aadhar,
      address,
      locality,
      profession,
      sub_profession,
      date,
      description,
      points,
      filepath;
  FirebaseMessaging firebaseMessaging;

  Map _source = {ConnectivityResult.none: false};

  MyConnectivity _connectivity = MyConnectivity.instance;

  List userinfo, walletinfo;

  final String url = 'https://upkeephouse.com/working_states.php';

  final String domainurl = 'https://www.upkeephouse.com/';

  List versioninfo;
  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;
  AdmobReward rewardAd;
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  final nativecontroller = NativeAdmobController();
  bool intersitialads = false;
  String new_version, app_version, new_version_details;
  PackageInfo packageInfo;

  bool updateversion = true;

  version_info() async {
    packageInfo = await PackageInfo.fromPlatform();
    app_version = packageInfo.version.toString();
    print('the app version is is '+app_version);
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

  getPartnerInfo(String state, String partnerid) async {
    print('its work');
    String url = 'https://upkeephouse.com/show_profile.php';
    FormData newData =
        new FormData.fromMap({'partner_id': partnerid, 'state': state});
    Response response = await Dio().post(url, data: newData);

    if (response.statusCode == 200) {
      if (response.data.toString() != '0') {
        setState(() {
          userinfo = jsonDecode(response.data);
          for (var i in userinfo) {
            name = i['name'];
            business_name = i['business_name'];
            image = i['image'];
            aadhar = i['aadhar'];
            address = i['address'];
            city = i['city'];
            locality = i['locality'];
            profession = i['profession'];
            sub_profession = i['sub_profession'];
            date = i['date'];
            description = i['description'];
            partner_id = i['partner_id'];
          }
        });
      }
    } else {
      print('error');
    }
  }

  getWalletInfo(String state, String partnerid) async {
    final prefs = await SharedPreferences.getInstance();
    String url = 'https://upkeephouse.com/show_points.php';
    FormData newData =
        new FormData.fromMap({'partner_id': partnerid, 'state': state});
    Response response = await Dio().post(url, data: newData);

    if (response.statusCode == 200) {
      print('200');
      if (response.data.toString() != '0') {
        setState(() {
          walletinfo = jsonDecode(response.data);
          for (var i in walletinfo) {
            points = i['points'];
          }
          prefs.setString('points', points);
        });
        print(walletinfo.toString());
      }
    } else {
      print('error');
    }
  }

  Future<void> getInfo() async {
    await SharedPreferences.getInstance().then((value) {
      filepath = value.get('profile_image');
      getPartnerInfo(value.get('state'), value.get('partner_id'));
      getWalletInfo(value.get('state'), value.get('partner_id'));
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
    version_info();
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
    });
    firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.requestNotificationPermissions();
    firebaseMessaging
        .getToken()
        .then((value) => print('The token is ' + value));
    getInfo();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ), //this right here
                child: Container(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['notification']['title'],
                          style: GoogleFonts.gotu(
                              fontSize: 2.3 * SizeConfig.textMultiplier,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          message['notification']['body'],
                          style: GoogleFonts.gotu(
                              fontSize: 2.1 * SizeConfig.textMultiplier),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: RaisedButton(
                            onPressed: () async {
                              Get.back();
                              if (message['data']['screen'] == 'blog') {
                                Get.to(Blog2(message['data']['id'].toString()));
                              } else {
                                Get.back();
                              }
                            },
                            child: Text(
                              "Checkout Now",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: const Color(0xFF1BC0C5),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        Get.to(Blog2(message['data']['id'].toString()));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        Get.to(Blog2(message['data']['id'].toString()));
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectivity.disposeStream();
    imageCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String string;
    switch (_source.keys.toList()[0]) {
      case ConnectivityResult.none:
        string = "Offline";
        break;
      case ConnectivityResult.mobile:
        string = "Mobile: Online";
        break;
      case ConnectivityResult.wifi:
        string = "WiFi: Online";
    }
    return Scaffold(
      key: scaffoldState,
      appBar: updateversion == true
          ? AppBar(
              title: Column(
                children: [
                  Text(
                    'Profile',
                    style: GoogleFonts.gotu(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                GestureDetector(
                  onTap: () {
                    Get.to(About());
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.black,
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
                      color: Colors.black,
                      size: SizeConfig.imageSizeMultiplier * 7,
                    ),
                  ),
                ),
              ],
            )
          : AppBar(
              backgroundColor: SizeConfig.mainpurple,
              elevation: 0,
            ),
      body: updateversion == true
          ? string != 'Offline' || string != null
              ? userinfo != null
                  ? RefreshIndicator(
                      onRefresh: getInfo,
                      color: Colors.red,
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 5),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Refrence Id:  ' + partner_id,
                                style: GoogleFonts.gotu(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2.2 * SizeConfig.textMultiplier),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  filepath != null
                                      ? Container(
                                          width: 35 *
                                              SizeConfig.imageSizeMultiplier,
                                          height: 35 *
                                              SizeConfig.imageSizeMultiplier,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: FileImage(File(filepath)),
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.4),
                                                spreadRadius: 1,
                                                blurRadius: 10,
                                                offset: Offset(10,6),
                                              )
                                            ],
                                          ),
                                        )
                                      : Container(
                                          width: 35 *
                                              SizeConfig.imageSizeMultiplier,
                                          height: 35 *
                                              SizeConfig.imageSizeMultiplier,
                                          child: CachedNetworkImage(
                                            imageUrl: domainurl + image,
                                            placeholder: (context, url) =>
                                                SpinKitFadingCircle(
                                              color: Colors.black,
                                            ),
                                            imageBuilder:
                                                (context, imageprovider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(20),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.4),
                                                    spreadRadius: 1,
                                                    blurRadius: 10,
                                                    offset: Offset(10, 6),
                                                  )
                                                ],
                                                image: DecorationImage(
                                                  image: imageprovider,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  Expanded(
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(left: 10, right: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AutoSizeText(
                                            business_name.toUpperCase(),
                                            style: GoogleFonts.gotu(
                                                color: SizeConfig.mainpurple,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 2.8 *
                                                    SizeConfig.textMultiplier),
                                            maxLines: 3,
                                          ),
                                          AutoSizeText(
                                            profession.toUpperCase(),
                                            style: GoogleFonts.gotu(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 2.3 *
                                                    SizeConfig.textMultiplier),
                                            maxLines: 2,
                                          ),
                                          AutoSizeText(
                                            city.toUpperCase(),
                                            style: GoogleFonts.gotu(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 2.3 *
                                                    SizeConfig.textMultiplier),
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 42 * SizeConfig.imageSizeMultiplier,
                              child: NativeAdmob(
                                adUnitID: AdManager.nativeAdUnitId,
                                loading:
                                    Center(child: CircularProgressIndicator()),
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
                                          fontSize:
                                              2.3 * SizeConfig.textMultiplier),
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
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Information',
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.bold,
                                        color: SizeConfig.mainpurple,
                                        fontSize:
                                            3 * SizeConfig.textMultiplier),
                                  ),
                                  AutoSizeText(
                                    name.toUpperCase(),
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.w300,
                                        fontSize:
                                            2 * SizeConfig.textMultiplier),
                                    maxLines: 2,
                                  ),
                                  AutoSizeText(
                                    partner_id.toUpperCase(),
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.w300,
                                        fontSize:
                                            2 * SizeConfig.textMultiplier),
                                  ),
                                  AutoSizeText(
                                    address.toUpperCase(),
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.w300,
                                        fontSize:
                                            2 * SizeConfig.textMultiplier),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'Your Service Areas',
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.bold,
                                        color: SizeConfig.mainpurple,
                                        fontSize:
                                            3 * SizeConfig.textMultiplier),
                                  ),
                                  AutoSizeText(
                                    locality.toUpperCase(),
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.w300,
                                        fontSize:
                                            2 * SizeConfig.textMultiplier),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'Your Services',
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.bold,
                                        color: SizeConfig.mainpurple,
                                        fontSize:
                                            3 * SizeConfig.textMultiplier),
                                  ),
                                  AutoSizeText(
                                    sub_profession
                                        .toUpperCase()
                                        .replaceAll(',', '\n'),
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.w300,
                                        fontSize:
                                            2 * SizeConfig.textMultiplier),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'Your Contact Information',
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.bold,
                                        color: SizeConfig.mainpurple,
                                        fontSize:
                                            3 * SizeConfig.textMultiplier),
                                  ),
                                  AutoSizeText(
                                    partner_id,
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.w300,
                                        fontSize:
                                            2 * SizeConfig.textMultiplier),
                                  ),
                                  AutoSizeText(
                                    address.toUpperCase(),
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.w300,
                                        fontSize:
                                            2 * SizeConfig.textMultiplier),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'Your AadharCard Number',
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.bold,
                                        color: SizeConfig.mainpurple,
                                        fontSize:
                                            3 * SizeConfig.textMultiplier),
                                  ),
                                  AutoSizeText(
                                    aadhar,
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.w300,
                                        fontSize:
                                            2 * SizeConfig.textMultiplier),
                                  ),
                                  AutoSizeText(
                                    'Note: We will not share your aadhar card number to anyone and not event to our user. We take it as a security region.',
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.w300,
                                        fontSize:
                                            2 * SizeConfig.textMultiplier),
                                  ),
                                  AutoSizeText(
                                    'नोट: हम आपका आधार  कार्ड नंबर किसी को भी साझा नहीं करते यहां तक की हमारे एप्लीकेशन उपभोक्ता को भी नह। हम इसको सिक्योरिटी के उदेशय से  अपने पास रख्ते है। ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize:
                                            2 * SizeConfig.textMultiplier),
                                  ),
                                  SizedBox(
                                    height: 15,
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
                                  Text(
                                    'About Your Services',
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.bold,
                                        color: SizeConfig.mainpurple,
                                        fontSize:
                                            3 * SizeConfig.textMultiplier),
                                  ),
                                  AutoSizeText(
                                    description,
                                    style: GoogleFonts.gotu(
                                        fontWeight: FontWeight.w300,
                                        fontSize:
                                            2 * SizeConfig.textMultiplier),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: SpinKitFadingCircle(
                        color: Colors.black,
                      ),
                    )
              : noInternet()
          : newVersion(new_version_details),
      bottomNavigationBar: updateversion == true
          ? Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home,
                          color: SizeConfig.mainpurple,
                        ),
                        Text(
                          'HOME',
                          style: GoogleFonts.gotu(
                              color: SizeConfig.mainpurple,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(Second());
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
                    onTap: () {
                      Get.to(Third());
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Colors.black,
                        ),
                        Text(
                          'WALLET',
                          style: GoogleFonts.gotu(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(Blog());
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
                      Get.to(Fourth());
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
            )
          : Container(
              color: SizeConfig.mainpurple,
              height: 14 * SizeConfig.imageSizeMultiplier,
            ),
    );
  }
}
