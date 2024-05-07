import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/native_admob_options.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upkeephousepartner/HomeScreens/blog2.dart';
import 'package:upkeephousepartner/HomeScreens/edit.dart';
import 'package:upkeephousepartner/HomeScreens/wallet.dart';
import 'package:upkeephousepartner/Manager/MyConnectivity.dart';
import 'package:upkeephousepartner/Manager/ad_manager.dart';
import 'package:upkeephousepartner/Models/about.dart';
import 'package:upkeephousepartner/Models/blog_model.dart';
import 'package:upkeephousepartner/Models/noInternet.dart';
import 'package:upkeephousepartner/loginScreens/loginScreen.dart';

import '../size_config.dart';
import 'leads.dart';

class Blog extends StatefulWidget {
  @override
  _BlogState createState() => _BlogState();
}

class _BlogState extends State<Blog> {
  final String domainurl = 'https://www.upkeephouse.com/';
  List<BlogModel> data = [];
  List blogdata;
  ScrollController _scrollController = new ScrollController();
  int pageno = 1;
  bool isLoading = false;

  getBlogData() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      String url = 'https://upkeephouse.com/get_blog.php';

      FormData newData = new FormData.fromMap({'pageno': pageno});

      await Dio().post(url, data: newData).then((response) {
        if (response.statusCode == 200) {
          blogdata = jsonDecode(response.data);
          if (blogdata == null) {
            setState(() {
              isLoading = false;
            });
          } else {
            for (var i in blogdata) {
              data.add(BlogModel(
                  i['sno'],
                  i['heading'],
                  i['content_1'],
                  i['content_2'],
                  i['date'],
                  i['url_1'],
                  i['url_2'],
                  i['keywords'],
                  i['image']));
            }
            setState(() {
              isLoading = false;
            });
            pageno = pageno + 1;
            print("The page no. is " +
                pageno.toString() +
                ' and length is ' +
                data.length.toString());
          }
        }
      });
    }
  }

  @override
  void initState() {
    getBlogData();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isLoading == false)
          getBlogData();
        else {}
        print("Yaa its working");
      }
    });

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

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final nativecontroller = NativeAdmobController();

    Widget _buildProgressIndicator() {
      return new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Center(
          child: new Opacity(
            opacity: isLoading ? 1.0 : 00,
            child: new CircularProgressIndicator(),
          ),
        ),
      );
    }

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
        title: Column(
          children: [
            Text(
              'Blog',
              style: GoogleFonts.gotu(
                  color: Colors.black, fontWeight: FontWeight.bold),
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
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            blogdata != null
                ? Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == data.length) {
                          return _buildProgressIndicator();
                        }

                        if (index != 0 && index % 3 == 0) {
                          return Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(5),
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
                              GestureDetector(
                                onTap: () {
                                  Get.to(Blog2(data[index].sno));
                                },
                                child: Container(
                                  margin: EdgeInsets.all(5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: 10, right: 5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                data[index].heading,
                                                style: GoogleFonts.gotu(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 2.3 *
                                                        SizeConfig
                                                            .textMultiplier),
                                                maxLines: 3,
                                              ),
                                              Text(
                                                data[index].date,
                                                style: GoogleFonts.gotu(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 2 *
                                                        SizeConfig
                                                            .textMultiplier),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            25 * SizeConfig.imageSizeMultiplier,
                                        height:
                                            25 * SizeConfig.imageSizeMultiplier,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              domainurl + data[index].image,
                                          placeholder: (context, url) =>
                                              SpinKitFadingCircle(
                                            color: Colors.black,
                                          ),
                                          imageBuilder:
                                              (context, imageprovider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(1)),
                                              image: DecorationImage(
                                                image: imageprovider,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        }

                        return GestureDetector(
                          onTap: () {
                            Get.to(Blog2(data[index].sno));
                          },
                          child: Container(
                            margin: EdgeInsets.all(5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10, right: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          data[index].heading,
                                          style: GoogleFonts.gotu(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 2.3 *
                                                  SizeConfig.textMultiplier),
                                          maxLines: 3,
                                        ),
                                        Text(
                                          data[index].date,
                                          style: GoogleFonts.gotu(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 2 *
                                                  SizeConfig.textMultiplier),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 25 * SizeConfig.imageSizeMultiplier,
                                  height: 25 * SizeConfig.imageSizeMultiplier,
                                  child: CachedNetworkImage(
                                    imageUrl: domainurl + data[index].image,
                                    placeholder: (context, url) =>
                                        SpinKitFadingCircle(
                                      color: Colors.black,
                                    ),
                                    imageBuilder: (context, imageprovider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(1)),
                                        image: DecorationImage(
                                          image: imageprovider,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: SpinKitFadingCircle(
                      color: Colors.black,
                    ),
                  )
          ],
        ),
      ),
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
              onTap: () {
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
                    Icons.subject,
                    color: SizeConfig.mainpurple,
                  ),
                  Text(
                    'BLOG',
                    style: GoogleFonts.gotu(
                        color: SizeConfig.mainpurple,
                        fontWeight: FontWeight.bold),
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
