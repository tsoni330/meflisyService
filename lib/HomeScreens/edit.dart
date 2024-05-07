import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upkeephousepartner/HomeScreens/edit2.dart';

import 'package:upkeephousepartner/HomeScreens/leads.dart';

import 'package:upkeephousepartner/HomeScreens/wallet.dart';
import 'package:upkeephousepartner/Manager/ad_manager.dart';
import 'package:upkeephousepartner/Models/about.dart';

import '../size_config.dart';
import 'blog.dart';

class Fourth extends StatefulWidget {
  @override
  _FourthState createState() => _FourthState();
}

class _FourthState extends State<Fourth> {



  TextEditingController namecontorller,
      addresscontroller,
      businessnamecontroller,
      descriptioncontroller;

  FocusNode namefocus, addressfocus, businessfocus, descriptionfocus;

  String filepath;
  AdmobInterstitial interstitialAd;

  @override
  void initState() {

    interstitialAd = AdmobInterstitial(
      adUnitId: AdManager.interstitialAdUnitId,
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) {
          interstitialAd.load();
        }
        if(event == AdmobAdEvent.failedToLoad){
          interstitialAd.load();
        }
      },
    );

    interstitialAd.load();
    namefocus = FocusNode();
    addressfocus = FocusNode();
    businessfocus = FocusNode();
    descriptionfocus = FocusNode();

    namecontorller = TextEditingController();
    addresscontroller = TextEditingController();
    businessnamecontroller = TextEditingController();
    descriptioncontroller = TextEditingController();

    getInfo();
    super.initState();
  }

  @override
  void dispose() {

    namefocus.dispose();

    addressfocus.dispose();

    businessfocus.dispose();
    descriptionfocus.dispose();
    namecontorller.dispose();
    addresscontroller.dispose();
    businessnamecontroller.dispose();
    descriptioncontroller.dispose();

    interstitialAd.dispose();
    super.dispose();
  }

  String states,
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
      businessname,
      error;

  List userinfo, walletinfo;

  final String domainurl = 'https://www.upkeephouse.com/';

  File getcameraFile, setcameraFile;

  imageSelectorCamera() async {
    final prefs = await SharedPreferences.getInstance();
    getcameraFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: getcameraFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      maxHeight: 512,
      maxWidth: 512,
    );

    File result = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path, getcameraFile.path,
        quality: 80);
    setState(() {
      setcameraFile = result;
    });
  }

  uploadWithImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    Get.bottomSheet(
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              error != null
                  ? Text(
                      error,
                      style: GoogleFonts.gotu(fontWeight: FontWeight.bold),
                    )
                  : Text(
                      'Your information is uploading. Wait...',
                      style: GoogleFonts.gotu(fontWeight: FontWeight.bold),
                    ),
              SizedBox(
                height: 10,
              ),
              SpinKitFadingCircle(
                color: Colors.black,
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        isDismissible: false,
        clipBehavior: Clip.antiAliasWithSaveLayer);

    String url = "https://upkeephouse.com/upload_partner.php";

    FormData newData = new FormData.fromMap({
      'name': namecontorller.text,
      'business_name': businessnamecontroller.text,
      'image':
          await MultipartFile.fromFile(path, filename: path.split("/").last),
      'address': addresscontroller.text,
      'description': descriptioncontroller.text,
      'partner_id': partner_id,
      'state': states
    });
    await Dio().post(url, data: newData).then((response) => {
          if (response.statusCode == 200)
            {
              if (response.data.toString() != '1')
                {
                  setState(() {
                    error = 'Data not Save to Server';
                  })
                }
              else
                {
                  prefs.setString('profile_image', path),
                  Future.delayed(Duration(seconds: 1), () {
                    Get.back();
                  })
                }
            }
          else
            {
              setState(() {
                error = 'May be internet not working';
              })
            }
        });
  }

  uploadWithoutImage() async {
    Get.bottomSheet(
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              error != null
                  ? Text(
                      error,
                      style: GoogleFonts.gotu(fontWeight: FontWeight.bold),
                    )
                  : Text(
                      'Your information is uploading. Wait...',
                      style: GoogleFonts.gotu(fontWeight: FontWeight.bold),
                    ),
              SizedBox(
                height: 10,
              ),
              SpinKitFadingCircle(
                color: Colors.black,
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        isDismissible: false,
        clipBehavior: Clip.antiAliasWithSaveLayer);

    String url = "https://upkeephouse.com/upload_partner_without_image.php";

    FormData newData = new FormData.fromMap({
      'name': namecontorller.text,
      'business_name': businessnamecontroller.text,
      'address': addresscontroller.text,
      'description': descriptioncontroller.text,
      'partner_id': partner_id,
      'state': states
    });
    await Dio().post(url, data: newData).then((response) => {
          if (response.statusCode == 200)
            {
              if (response.data.toString() != '1')
                {
                  setState(() {
                    error = 'Data not Save to Server';
                  })
                }
              else
                {
                  Future.delayed(Duration(seconds: 1), () {
                    Get.back();
                  })
                }
            }
          else
            {
              setState(() {
                error = 'May be internet not working';
              })
            }
        });
  }



  getPartnerInfo(String state, String partnerid) async {
    String url = 'https://upkeephouse.com/show_profile.php';
    FormData newData =
        new FormData.fromMap({'partner_id': partnerid, 'state': state});
    await Dio().post(url, data: newData).then((value) {
      if (value.statusCode == 200) {
        if (value.data.toString() != '0') {
          setState(() {
            userinfo = jsonDecode(value.data);
            for (var i in userinfo) {
              namecontorller.text = i['name'];
              businessnamecontroller.text = i['business_name'];
              image = i['image'];
              aadhar = i['aadhar'];
              addresscontroller.text = i['address'];
              city = i['city'];
              states = i['state'];
              locality = i['locality'];
              profession = i['profession'];
              sub_profession = i['sub_profession'];
              descriptioncontroller.text = i['description'];
              partner_id = i['partner_id'];
            }
          });
        }
      } else {
        print('error');
      }
    });
  }

  Future<void> getInfo() async {
    await SharedPreferences.getInstance().then((value) {
      filepath = value.get('profile_image');
      getPartnerInfo(value.get('state'), value.get('partner_id'));
    });
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
        title: Column(
          children: [
            Text(
              'Edit',
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
      body: userinfo != null
          ? Container(
              margin: EdgeInsets.only(left: 10, right: 5),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'ध्यान रखे की, आप जो भी बदलाव कर रहे है वो english में ही करे, हिंदी या कोई और भाषा का प्रयोग ना करे। ',
                          style: TextStyle(
                              fontSize: 2.3 * SizeConfig.textMultiplier,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            imageSelectorCamera();
                          },
                          child: Container(
                            width: 40 * SizeConfig.imageSizeMultiplier,
                            height: 40 * SizeConfig.imageSizeMultiplier,
                            child: setcameraFile != null
                                ? Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: FileImage(setcameraFile),
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
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
                                : filepath != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: FileImage(File(filepath)),
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
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
                                    : CachedNetworkImage(
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
                                                Radius.circular(20)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.4),
                                                spreadRadius: 1,
                                                blurRadius: 10,
                                                offset: Offset(10,6),
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
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5, top: 15, right: 5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(
                                    5.0) //         <--- border radius here
                                ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                child: NeumorphicText(
                                  "Your Name",
                                  style: NeumorphicStyle(
                                    depth: 8, //customize depth here
                                    color: SizeConfig.mainpurple,
                                    border: NeumorphicBorder(
                                        isEnabled: true,
                                        color: Colors.black,
                                        width: 1),
                                  ),
                                  textStyle: NeumorphicTextStyle(
                                    fontSize: SizeConfig.textMultiplier * 2.5,
                                    //fontWeight: FontWeight.bold, //customize size here
                                    // AND others usual text style properties (fontFamily, fontWeight, ...)
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
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
                                // margin: EdgeInsets.only(left: 5, top: 15, right: 5),
                                child: TextField(
                                  controller: namecontorller,
                                  style: TextStyle(
                                      fontSize: 2.5 * SizeConfig.textMultiplier,
                                      color: SizeConfig.mainpurple),
                                  decoration: InputDecoration(
                                    hintText: "Ex: John Gates",
                                    hintStyle: TextStyle(
                                        color: SizeConfig.mainpurple,
                                        fontSize:
                                            2.3 * SizeConfig.textMultiplier),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, bottom: 11, top: 11),
                                  ),
                                  onEditingComplete: () {
                                    FocusScope.of(context)
                                        .requestFocus(businessfocus);
                                  },
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) => name = value,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5, top: 15, right: 5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(
                                    5.0) //         <--- border radius here
                                ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                child: NeumorphicText(
                                  "Business / Shop Name",
                                  style: NeumorphicStyle(
                                    depth: 8, //customize depth here
                                    color: SizeConfig.mainpurple,
                                    border: NeumorphicBorder(
                                        isEnabled: true,
                                        color: Colors.black,
                                        width: 1),
                                  ),
                                  textStyle: NeumorphicTextStyle(
                                    fontSize: SizeConfig.textMultiplier * 2.5,
                                    //fontWeight: FontWeight.bold, //customize size here
                                    // AND others usual text style properties (fontFamily, fontWeight, ...)
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
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
                                // margin: EdgeInsets.only(left: 5, top: 15, right: 5),
                                child: TextField(
                                  controller: businessnamecontroller,
                                  focusNode: businessfocus,
                                  style: TextStyle(
                                      fontSize: 2.5 * SizeConfig.textMultiplier,
                                      color: SizeConfig.mainpurple),
                                  decoration: InputDecoration(
                                    hintText: "Ex: Balaji Electronics",
                                    hintStyle: TextStyle(
                                        color: SizeConfig.mainpurple,
                                        fontSize:
                                            2.3 * SizeConfig.textMultiplier),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, bottom: 11, top: 11),
                                  ),
                                  keyboardType: TextInputType.text,
                                  onEditingComplete: () {
                                    FocusScope.of(context)
                                        .requestFocus(addressfocus);
                                  },
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) => businessname = value,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5, top: 15, right: 5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(
                                    5.0) //         <--- border radius here
                                ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                child: NeumorphicText(
                                  "Complete Address",
                                  style: NeumorphicStyle(
                                    depth: 8, //customize depth here
                                    color: SizeConfig.mainpurple,
                                    border: NeumorphicBorder(
                                        isEnabled: true,
                                        color: Colors.black,
                                        width: 1),
                                  ),
                                  textStyle: NeumorphicTextStyle(
                                    fontSize: SizeConfig.textMultiplier * 2.5,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
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
                                // margin: EdgeInsets.only(left: 5, top: 15, right: 5),
                                child: TextField(
                                  controller: addresscontroller,
                                  focusNode: addressfocus,
                                  style: TextStyle(
                                      fontSize: 2.5 * SizeConfig.textMultiplier,
                                      color: SizeConfig.mainpurple),
                                  decoration: InputDecoration(
                                    hintText:
                                        "Ex: house no., nearest landmark, city name",
                                    hintStyle: TextStyle(
                                        color: SizeConfig.mainpurple,
                                        fontSize:
                                            2.3 * SizeConfig.textMultiplier),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, bottom: 11, top: 11),
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 2,
                                  onEditingComplete: () {
                                    FocusScope.of(context)
                                        .requestFocus(descriptionfocus);
                                  },
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) => address = value,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5, top: 15, right: 5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(
                                    5.0) //         <--- border radius here
                                ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                child: NeumorphicText(
                                  "Description",
                                  style: NeumorphicStyle(
                                    depth: 8, //customize depth here
                                    color: SizeConfig.mainpurple,
                                    border: NeumorphicBorder(
                                        isEnabled: true,
                                        color: Colors.black,
                                        width: 1),
                                  ),
                                  textStyle: NeumorphicTextStyle(
                                    fontSize: SizeConfig.textMultiplier * 2.5,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
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
                                // margin: EdgeInsets.only(left: 5, top: 15, right: 5),
                                child: TextField(
                                  controller: descriptioncontroller,
                                  focusNode: descriptionfocus,
                                  style: TextStyle(
                                      fontSize: 2.5 * SizeConfig.textMultiplier,
                                      color: SizeConfig.mainpurple),
                                  decoration: InputDecoration(
                                    hintText:
                                        "Description about you and your work",
                                    hintStyle: TextStyle(
                                        color: SizeConfig.mainpurple,
                                        fontSize:
                                            2.3 * SizeConfig.textMultiplier),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, bottom: 11, top: 11),
                                  ),
                                  keyboardType: TextInputType.text,
                                  maxLines: 3,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (value) => description = value,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: SizeConfig.mainpurple)),
                            onPressed: () {
                              setcameraFile != null
                                  ? uploadWithImage(setcameraFile.path)
                                  : uploadWithoutImage();
                            },
                            color: SizeConfig.mainpurple,
                            textColor: Colors.white,
                            child: Text("Update".toUpperCase(),
                                style: GoogleFonts.gotu(
                                    fontSize: 3 * SizeConfig.textMultiplier,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'आप को अगर इनके अलावा और कुछ बदलाव करने है जैसे profession में , location तो आप More Updates बटन को दबाये',
                          style: TextStyle(
                              fontSize: 2.3 * SizeConfig.textMultiplier,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: SizeConfig.mainpurple)),
                            onPressed: () async {
                              if(await interstitialAd.isLoaded){
                                interstitialAd.show();
                                Get.to(Edit2(states, city, profession,
                                    sub_profession, locality, partner_id));
                              }else{
                                Get.to(Edit2(states, city, profession,
                                    sub_profession, locality, partner_id));
                              }
                            },
                            color: SizeConfig.mainpurple,
                            textColor: Colors.white,
                            child: Text("more updates".toUpperCase(),
                                style: GoogleFonts.gotu(
                                    fontSize: 3 * SizeConfig.textMultiplier,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: SpinKitFadingCircle(
                color: Colors.black,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mode_edit,
                    color: SizeConfig.mainpurple,
                  ),
                  Text(
                    'EDIT',
                    style: GoogleFonts.gotu(
                        color: SizeConfig.mainpurple,
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
