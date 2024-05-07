import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upkeephousepartner/loginScreens/loginScreen.dart';
import 'package:upkeephousepartner/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool down = true;

  removeLoginData() async {
    await SharedPreferences.getInstance().then((value) {
      value.remove('state');
      value.remove('partner_id');
      value.remove('points');
      Get.offAll(loginScreen());
    });
  }

  _launchCaller() async {
    const url = "tel:+919671775251";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchMessage() async {
    const url = "https://wa.me/9671515251";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchMail() async {
    const url = "mailto:help@upkeephouse.com";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        SizeConfig().init(constraint);
        return Scaffold(
          backgroundColor: Colors.grey,
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
                  'About Us',
                  style: GoogleFonts.gotu(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Container(
            padding: EdgeInsets.all(2),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  child: Card(
                    child: Column(
                      children: [
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                'Who we are',
                                style: GoogleFonts.gotu(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2.8 * SizeConfig.textMultiplier),
                              ),
                            ),
                          ],
                        ),
                        down
                            ? Container(
                                padding: EdgeInsets.only(left: 10, right: 5),
                                child: Text(
                                  'हमारी कंपनी एक ऐसी संस्था है जो लोग सर्विस इंडस्ट्री से जुड़े हुए '
                                      'है जैसे की  एलेक्ट्रीशन , प्लम्बर , मैकेनिक , ड्राइवर , खाती,'
                                      ' दर्जी  और भी अलग अलग तरह की सर्विस में है तो उनको बिना क'
                                      'िसी पैसे खर्चे के उनको ऑनलाइन दुकान खुलवाना , '
                                      'काम देना और उनकी कमाई बढ़ाना वो भी बिना कमीशन और बिना कोई'
                                      ' पैसे के । हमारी सर्विस फ्री है न कोई पैसे देने न कोई कमीशन। 100 से'
                                      ' अधिक तरह की सर्विस में हम काम करते है। तो आपका हमसे जुड़ने का धन्यवाद।  आप ज्यादा से ज्यादा सर्विस देने वाले भाइयो '
                                      'और बहनो जोड़े और एप्लीकेशन को ज्यादा से ज्यादा शेयर करे। ',
                                  style: TextStyle(
                                      fontSize:
                                          2.5 * SizeConfig.textMultiplier,
                                  color: Colors.grey[700]),
                                ),
                              )
                            : SizedBox(
                                height: 1,
                              ),
                        SizedBox(height: 5,),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Card(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                'Contact us ',
                                style: GoogleFonts.gotu(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2.8 * SizeConfig.textMultiplier),
                              ),
                            ),
                            Container(
                              child: GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.black,
                                    size: SizeConfig.imageSizeMultiplier * 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              child: GestureDetector(
                                onTap: () {
                                  _launchCaller();
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.call,
                                    color: Colors.grey,
                                    size: SizeConfig.imageSizeMultiplier * 9,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: GestureDetector(
                                onTap: () {
                                  _launchMessage();
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.message,
                                    color: Colors.grey,
                                    size: SizeConfig.imageSizeMultiplier * 9,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: GestureDetector(
                                onTap: () {
                                  _launchMail();
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.mail,
                                    color: Colors.grey,
                                    size: SizeConfig.imageSizeMultiplier * 9,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: GestureDetector(
                    onTap: () {
                      removeLoginData();
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  'Log out',
                                  style: GoogleFonts.gotu(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      fontSize:
                                          2.8 * SizeConfig.textMultiplier),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: Icon(
                                      Icons.exit_to_app,
                                      color: Colors.grey,
                                      size: SizeConfig.imageSizeMultiplier * 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
