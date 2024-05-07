import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upkeephousepartner/HomeScreens/home.dart';
import 'package:upkeephousepartner/size_config.dart';
import 'package:get/get.dart';
import 'loginScreens/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class splashScreen extends StatefulWidget {
  @override
  _splashScreenState createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  String pratnerid;


  checkLogin() async {
    await SharedPreferences.getInstance()
        .then((value) => Future.delayed(Duration(seconds: 2), () {
              value.get('partner_id') != null
                  ? Get.off(Home())
                  : Get.off(loginScreen());
            }));
    //pratnerid= prefs.get('partnerid');
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        SizeConfig().init(constraints);
        return Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: SizeConfig.imageSizeMultiplier * 55,
                    height: SizeConfig.imageSizeMultiplier * 55,
                    child: Image.asset('images/meflisyicon.png'),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Made in',
                  style: GoogleFonts.gotu(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.textMultiplier * 3.5),
                ),
                Container(
                  width: SizeConfig.imageSizeMultiplier * 20,
                  height: SizeConfig.imageSizeMultiplier * 20,
                  child: Image.asset('images/indianflag.png'),
                ),
                Text(
                  'Bharat',
                  style: GoogleFonts.gotu(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.textMultiplier * 3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
