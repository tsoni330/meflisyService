import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upkeephousepartner/HomeScreens/wallet.dart';
import 'package:upkeephousepartner/Manager/MyConnectivity.dart';

import '../size_config.dart';
import 'blog.dart';
import 'edit.dart';

class Second extends StatefulWidget {
  @override
  _SecondState createState() => _SecondState();
}

class _SecondState extends State<Second> {

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }
  @override
  void initState() {

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
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            margin: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: SizeConfig.imageSizeMultiplier * 7,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Text(
              'Leads',
              style: GoogleFonts.gotu(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Text(
            'अभी हमारी partner registration अवधि चल रही है इसी के चलते leads system कुछ समय के लिए बंद कर दिया गया है।  आपको अगले update तक leads system शुरू कर दिया जायेगा। App  को update  करना न भूले। ',
            style:TextStyle(
              fontSize: 3*SizeConfig.textMultiplier
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 15,right: 15,top: 5,bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: (){
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
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
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
                    Icons.contact_phone,
                    color: SizeConfig.mainpurple,
                  ),
                  Text(
                    'LEADS',
                    style: GoogleFonts.gotu(
                        color: SizeConfig.mainpurple,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: (){
                Get.off(Third());
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
                        color: Colors.black,
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
              onTap: (){
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
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
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
