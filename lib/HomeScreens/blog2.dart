import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/native_admob_options.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upkeephousepartner/Manager/MyConnectivity.dart';
import 'package:upkeephousepartner/Manager/ad_manager.dart';
import 'package:upkeephousepartner/Models/blog_model.dart';
import 'package:upkeephousepartner/Models/noInternet.dart';
import 'package:url_launcher/url_launcher.dart';

import '../size_config.dart';

class Blog2 extends StatefulWidget {
  String id;

  Blog2(this.id);

  @override
  _Blog2State createState() => _Blog2State();
}

class _Blog2State extends State<Blog2> {
  List data;
  String heading, image, content1, content2, url1, url2, date, keyword;

  final String domainurl = 'https://www.upkeephouse.com/';

  final nativecontroller = NativeAdmobController();

  getBlogDetails() async {
    String url = 'https://upkeephouse.com/get_blog_details.php';
    FormData newData = new FormData.fromMap({'sno': widget.id});

    String error;
    await Dio().post(url, data: newData).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.data);
        });
        for (var i in data) {
          heading = i['heading'];
          content1 = i['content_1'];
          content2 = i['content_2'];
          url1 = i['url_1'];
          url2 = i['url_2'];
          keyword = i['keyword'];
          date = i['date'];
          image = i['image'];
        }
      } else {
        setState(() {
          error = 'Error:- ' + response.statusCode.toString();
        });
      }
    });
  }

  @override
  void initState() {

    // TODO: implement initState
    getBlogDetails();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:
      data != null
          ? SafeArea(
              child: CustomScrollView(
                slivers: <Widget>[
                  // Add the app bar to the CustomScrollView.
                  SliverAppBar(
                    snap: false,
                    pinned: true,
                    floating: false,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: SizeConfig.mainpurple,
                    expandedHeight: 220.0,
                    bottom: PreferredSize(
                      child: AppBar(
                        title: Text(
                          'Blog Details',
                          style: GoogleFonts.gotu(
                              fontSize: 2.5 * SizeConfig.textMultiplier,
                              fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        automaticallyImplyLeading: true,
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                        background: Image.network(
                      domainurl + image,
                      fit: BoxFit.cover,
                    )),
                  ),

                  SliverPadding(
                    padding: EdgeInsets.all(5),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Text(
                            heading,
                            style: GoogleFonts.teko(
                              wordSpacing: 1.5,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                              fontSize: 3.2 * SizeConfig.textMultiplier,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.all(5),
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
                          Text(
                            content1,
                            style: GoogleFonts.gotu(
                              fontWeight: FontWeight.w500,
                              fontSize: 2.5 * SizeConfig.textMultiplier,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.all(5),
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
                          Text(
                            content2,
                            style: GoogleFonts.gotu(
                              fontWeight: FontWeight.w500,
                              fontSize: 2.5 * SizeConfig.textMultiplier,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (await canLaunch('https://' + url1)) {
                                await launch('https://' + url1);
                              } else {
                                throw 'Could not launch $url1';
                              }
                            },
                            child: Text(
                              url1,
                              style: GoogleFonts.gotu(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 2.5 * SizeConfig.textMultiplier,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              url2,
                              style: GoogleFonts.gotu(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 2.5 * SizeConfig.textMultiplier,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5),
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
                        ],
                      ),
                    ),
                  ),
                  // Next, create a SliverList
                ],
              ),
            )
          : SpinKitFadingCircle(
              color: Colors.black,
            )
    );
  }
}
