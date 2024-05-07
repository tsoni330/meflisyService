import 'dart:io';

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pin_put/pin_put.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:upkeephousepartner/HomeScreens/home.dart';

import 'package:url_launcher/url_launcher.dart';
import '../size_config.dart';

class register2Screen extends StatefulWidget {
  String name, aadharcard, mobilenumber, address, businessname;

  register2Screen(this.name, this.aadharcard, this.mobilenumber, this.address,
      this.businessname);

  @override
  _register2ScreenState createState() => _register2ScreenState();
}

class _register2ScreenState extends State<register2Screen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  bool accept = false;
  bool otpwaiting=false;

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  String _mySelection, _myCitySelection, _myCategorySelection;

  String firetoken;
  final String url = 'https://upkeephouse.com/working_states.php';

  List data, city_data, locality_data, category_data, subcategory_data;

  TextEditingController businessNameController,
      mobile_controller,
      refrence_controller;

  List<bool> inputs = new List<bool>();
  List<String> location;
  List<bool> subinputs = new List<bool>();
  List<String> sublocation, subkeywords;
  PermissionStatus cameraPermissionStatus;

  List user_data;
  String error = "";
  String phoneNumber;
  String smsCode;
  String verificationCode, only_number;
  String locationString = '', sublocationString = '', keywordString = '';

  String refrence_id = "No Refrence";

  String otp;

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  File getcameraFile, setcameraFile;

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<String> getStateData() async {
    http.Client client = new http.Client();
    var res = await client.get(Uri.encodeFull(url));
    var resBody = json.decode(res.body);
    setState(() {
      data = resBody;
    });
    client.close();
    return 'Success';
  }

  Future<String> getCategoryData() async {
    http.Client client = new http.Client();
    var res = await client.get(
        Uri.encodeFull("https://upkeephouse.com/service_category_list.php"));
    var resBody = json.decode(res.body);
    setState(() {
      category_data = resBody;
    });

    client.close();
    return 'Success';
  }

  Future<String> getCityData(String cityname) async {
    String cityurl = "https://upkeephouse.com/get_cityname.php";
    http.Client client = new http.Client();
    final response = await client.post(cityurl, body: {
      'state': cityname,
    });
    var resBody = json.decode(response.body);
    setState(() {
      city_data = resBody;
    });

    client.close();
    return 'Success';
  }

  Future<String> getLocalityData(String cityname, String statename) async {
    String localityurl = "https://upkeephouse.com/get_locality.php";
    http.Client client = new http.Client();
    var res = await client.post(Uri.encodeFull(localityurl),
        body: {'state': statename, 'city': cityname});
    var resBody = json.decode(res.body);
    setState(() {
      location = new List<String>();
      inputs = [];
      locality_data = resBody;
      for (int i = 0; i < locality_data.length; i++) {
        inputs.add(false);
      }
      print("The data after select city is ${locality_data}");
    });

    client.close();
    return 'Success';
  }

  Future<String> getSubCategoryData(String profession) async {
    String localityurl = "https://upkeephouse.com/service_subcategory_list.php";
    http.Client client = new http.Client();
    var res = await client
        .post(Uri.encodeFull(localityurl), body: {'profession': profession});
    var resBody = json.decode(res.body);

    setState(() {
      sublocation = new List<String>();
      subkeywords = new List<String>();
      subinputs = [];

      subcategory_data = resBody;
      for (int i = 0; i < subcategory_data.length; i++) {
        subinputs.add(false);

        subkeywords.add("");
      }
    });

    client.close();
    return 'Success';
  }

  imageSelectorCamera() async {
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

  PermissionStatus _status;

  void ItemChange(bool val, int index) {
    setState(() {
      if (val == false) {
        inputs[index] = val;
        location.remove(locality_data[index]['locality']);

        locationString = '';
        location.forEach((item) {
          locationString += '$item,';
        });

        if (locationString.length > 0) {
          print("The length is " + locationString);
          locationString =
              locationString.substring(0, locationString.length - 1);
        } else {
          print("The else length is " + locationString);
        }

        print(locationString);
      } else {
        inputs[index] = val;
        location.add(locality_data[index]['locality']);
        locationString = '';
        location.forEach((item) {
          locationString += '$item,';
        });
        locationString = locationString.substring(0, locationString.length - 1);
      }
    });
  }

  void SubItemChange(bool val, int index) {
    setState(() {
      if (val == false) {
        subinputs[index] = val;
        sublocation.remove(subcategory_data[index]['sub_category']);

        sublocationString = '';

        sublocation.forEach((item) {
          sublocationString += '$item,';
        });

        if (sublocationString.length > 0) {
          print("The length is " + sublocationString);
          sublocationString =
              sublocationString.substring(0, sublocationString.length - 1);
        } else {
          print("The else length is " + sublocationString);
        }
        print(sublocationString);
      } else {
        subinputs[index] = val;
        sublocation.add(subcategory_data[index]['sub_category']);

        sublocationString = '';

        sublocation.forEach((item) {
          sublocationString += '$item,';
        });

        sublocationString =
            sublocationString.substring(0, sublocationString.length - 1);
        print(sublocationString);
      }
    });
  }

  phoneVerification(String phonenumber ,String path) async {
    final prefs = await SharedPreferences.getInstance();
    await auth.verifyPhoneNumber(
        phoneNumber: '+91' + phonenumber,
        verificationCompleted: (PhoneAuthCredential authCredential) async {
          await auth.signInWithCredential(authCredential).then((value) {
            if (value.user != null) {
              uplaodImage(path);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            error = e.toString();
          });
        },
        codeSent: (String verificationId, int resendToken) async {
          smsCodeDialog(context, verificationId,path);
          setState(() {
            error = null;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            otp = verificationId;
          });
        });
  }

  smsCodeDialog(BuildContext context, String verificationId, String path) {
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
                      Get.back();
                      signinMannually(verificationId, otp, path);
                    },
                    child: Text(
                      "Verify",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: const Color(0xFF1BC0C5),
                  ),
                ],
              ));
        });
  }

  signinMannually(String verificationID, String otp, String path) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: otp);

    await auth.signInWithCredential(phoneAuthCredential).then((value) {
      if (value.user != null) {
        uplaodImage(path);
      }
    });
  }

  getCameraPermission() async {
    cameraPermissionStatus = await Permission.photos.status;
    if (cameraPermissionStatus.isPermanentlyDenied) {
      openAppSettings();
    } else {
      if (!cameraPermissionStatus.isGranted) {
        await Permission.photos.request();
      }
    }
  }

  uplaodImage(String path) async {
    final prefs= await SharedPreferences.getInstance();
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
              Text(
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
              )
            ],
          ),
        ),
        isDismissible: false,
        clipBehavior: Clip.antiAliasWithSaveLayer);

    await firebaseMessaging.getToken().then((value) {
      firetoken = value;
    });
    String url = "https://upkeephouse.com/register_partner.php";

    FormData newData = new FormData.fromMap({
      'name': widget.name,
      'state': _mySelection,
      'business_name': widget.businessname,
      'image':
          await MultipartFile.fromFile(path, filename: path.split("/").last),
      'city': _myCitySelection,
      'locality': locationString,
      'profession': _myCategorySelection,
      'sub_profession': sublocationString,
      'aadhar': widget.aadharcard,
      'number': widget.mobilenumber,
      'address': widget.address,
      'refrence_id': refrence_controller.text,
      'firetoken': firetoken != null ? firetoken : 'No token'
    });
    Response response = await Dio().post(url, data: newData);

    if (response.statusCode == 200) {
      if (response.data.toString() != '1') {
        setState(() {
          error = response.data.toString();
        });
        Get.back();
      } else {
        Get.back();
        prefs.setString('state', _mySelection);
        prefs.setString('partner_id', widget.mobilenumber);
        Get.offAll(Home());
      }
    } else {
      print('the status code is ' + response.statusCode.toString());
      error = 'Something went wronge. Http' +
          response.statusCode.toString() +
          ' error';
    }
  }

  @override
  void initState() {
    businessNameController = TextEditingController();
    mobile_controller = TextEditingController();
    refrence_controller = TextEditingController();

    getStateData();
    // checkUserAccount1();
    getCategoryData();
    getCameraPermission();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    imageCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Container(
          margin: EdgeInsets.only(left: 5, right: 5),
          child: Text(
            'Business Information',
            style: GoogleFonts.gotu(fontWeight: FontWeight.bold),
          ),
        ),
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
      ),
      body: new Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: new Form(
                key: this._formKey,
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: new ListView(
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: DropDown(data),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: DropDown2(_mySelection),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: DropDown3(_myCitySelection, _mySelection),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Category(category_data),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Subcategory(_myCategorySelection),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () => imageSelectorCamera(),
                        child: Container(
                          height: 47 * SizeConfig.imageSizeMultiplier,
                          width: 47 * SizeConfig.imageSizeMultiplier,
                          child: displaySelectedFile(setcameraFile),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
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
                                "Refrence Id",
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
                                borderRadius: BorderRadius.all(Radius.circular(
                                        5.0) //         <--- border radius here
                                    ),
                              ),
                              // margin: EdgeInsets.only(left: 5, top: 15, right: 5),
                              child: TextField(
                                controller: refrence_controller,
                                style: TextStyle(
                                    fontSize: 2.5 * SizeConfig.textMultiplier,
                                    color: SizeConfig.mainpurple),
                                decoration: InputDecoration(
                                  hintText: "Ex: 8888888888",
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
                                textInputAction: TextInputAction.done,
                                onChanged: (value) {
                                  if (value != null) {
                                    refrence_id = value;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: errormsg(error),
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            Checkbox(
                                value: accept,
                                onChanged: (bool value) {
                                  setState(() {
                                    accept = value;
                                  });
                                }),
                            GestureDetector(
                              onTap: () {
                                launch("https://upkeephouse.com/policy.docx");
                              },
                              child: Text(
                                "I agree Terms and Conditions",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2 * SizeConfig.textMultiplier),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        child: GestureDetector(
                          onTap: () {
                            if (_formKey.currentState.validate()) {
                              if (_myCategorySelection != null &&
                                  _myCitySelection != null &&
                                  sublocationString != null &&
                                  _mySelection != null &&
                                  locationString != null &&
                                  setcameraFile.path != null) {
                                if (accept == true) {
                                  if (widget.mobilenumber != refrence_id) {
                                    phoneVerification(widget.mobilenumber,setcameraFile.path);
                                    setState(() {
                                      error = '';
                                    });
                                  } else {
                                    setState(() {
                                      error =
                                          "You can't use your mobile number as refrence id";
                                    });
                                  }
                                } else {
                                  setState(() {
                                    error =
                                        "Please agree to term and condition";
                                  });
                                }
                              } else {
                                setState(() {
                                  error =
                                      "Please select State, city, profession, upload image etc";
                                });
                              }
                            } else {
                              setState(() {
                                error = "Please fill form carefully";
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 15, right: 15, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    SizeConfig.mainyellow,
                                    SizeConfig.mainpurple
                                  ]),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            margin: EdgeInsets.only(top: 15.0),
                            child: Text(
                              "Create Account",
                              style: GoogleFonts.gotu(
                                  fontSize: 3 * SizeConfig.textMultiplier,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget errormsg(String error) {
    return GestureDetector(
      child: new Container(
        child: error != null
            ? new Center(
                child: Container(
                  color: Colors.transparent,
                  child: Text(
                    error,
                    style: GoogleFonts.gotu(
                        fontSize: 2 * SizeConfig.textMultiplier,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            : SizedBox(),
      ),
    );
  }

  Widget displaySelectedFile(File file) {
    return GestureDetector(
      child: new Container(
        height: 50 * SizeConfig.imageSizeMultiplier,
        width: 40 * SizeConfig.imageSizeMultiplier,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0),
          borderRadius: BorderRadius.all(
              Radius.circular(5.0) //         <--- border radius here
              ),
        ),
        child: file == null
            ? new Center(
                child: Container(
                  child: Icon(
                    Icons.add_a_photo,
                    color: Colors.black,
                    size: SizeConfig.imageSizeMultiplier * 20,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                ),
              )
            : Container(
                child: new Image.file(
                  file,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
      ),
    );
  }

  Widget DropDown(List data) {
    if (data != null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0),
          borderRadius: BorderRadius.all(
              Radius.circular(5.0) //         <--- border radius here
              ),
        ),
        //margin: EdgeInsets.only(left: 5, top: 15, right: 5),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            iconSize: 50,
            iconEnabledColor: SizeConfig.mainpurple,
            iconDisabledColor: SizeConfig.mainpurple,
            items: data.map((item) {
              return new DropdownMenuItem(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    item['state'].toString(),
                    style: GoogleFonts.gotu(
                        color: SizeConfig.mainpurple,
                        fontSize: SizeConfig.textMultiplier * 2.2),
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
                    color: SizeConfig.mainpurple,
                    fontSize: SizeConfig.textMultiplier * 2.5),
              ),
            ),
            onChanged: (newVal) {
              setState(() {
                _mySelection = newVal;
                city_data = null;
                _myCitySelection = null;
                getCityData(_mySelection);
              });
            },
            value: _mySelection,
          ),
        ),
      );
    } else {
      return Center(
        child: SpinKitFadingCircle(
          color: Colors.black,
        ),
      );
    }
  }

  Widget DropDown2(String cityname) {
    if (cityname != null) {
      if (city_data != null) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(width: 2.0),
            borderRadius: BorderRadius.all(
                Radius.circular(5.0) //         <--- border radius here
                ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              iconSize: 50,
              iconEnabledColor: SizeConfig.mainpurple,
              iconDisabledColor: SizeConfig.mainpurple,
              items: city_data.map((item) {
                return new DropdownMenuItem(
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(
                      item['name'].toString().toUpperCase(),
                      style: GoogleFonts.gotu(
                          color: SizeConfig.mainpurple,
                          fontSize: SizeConfig.textMultiplier * 2.2),
                    ),
                  ),
                  value: item['name'].toString(),
                );
              }).toList(),
              hint: Container(
                margin: EdgeInsets.only(left: 10),
                child: Text(
                  "Select City/Town",
                  style: GoogleFonts.gotu(
                    color: SizeConfig.mainpurple,
                    fontSize: SizeConfig.textMultiplier * 2.5,
                  ),
                ),
              ),
              onChanged: (newVal) {
                setState(() {
                  _myCitySelection = newVal;
                  locality_data = null;
                  getLocalityData(_myCitySelection, _mySelection);
                });
              },
              value: _myCitySelection,
            ),
          ),
        );
      } else {
        return Center(
          child: SpinKitFadingCircle(
            color: Colors.black,
          ),
        );
      }
    }
  }

  Widget DropDown3(String cityname, String statename) {
    double maxWidth = MediaQuery.of(context).size.width;
    if (cityname != null) {
      if (locality_data != null) {
        return Container(
          alignment: Alignment.center,
          width: maxWidth,
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.only(left: 10, right: 5),
          decoration: BoxDecoration(
            border: Border.all(width: 2.0),
            borderRadius: BorderRadius.all(
                Radius.circular(5.0) //         <--- border radius here
                ),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Select your location where you want to give your services / अपना स्थान चुनें जहाँ आप अपनी सेवाएँ देना चाहते हैं",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 2 * SizeConfig.textMultiplier,
                      color: SizeConfig.mainpurple),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: locality_data == null ? 0 : locality_data.length,
                itemBuilder: (BuildContext context, int index) {
                  return new Card(
                    elevation: 0,
                    child: new Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(
                                5.0) //         <--- border radius here
                            ),
                      ),
                      padding: new EdgeInsets.all(3.0),
                      child: new Column(
                        children: <Widget>[
                          new CheckboxListTile(
                              value: inputs[index],
                              title: new Text(
                                locality_data[index]['locality'],
                                style: GoogleFonts.gotu(),
                                maxLines: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (bool val) {
                                ItemChange(val, index);
                              })
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      } else {
        return Center(
          child: SpinKitFadingCircle(
            color: Colors.black,
          ),
        );
      }
    }
  }

  Widget Category(List data) {
    if (data != null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0),
          borderRadius: BorderRadius.all(
              Radius.circular(5.0) //         <--- border radius here
              ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            iconSize: 50,
            iconEnabledColor: SizeConfig.mainpurple,
            iconDisabledColor: SizeConfig.mainpurple,
            items: data.map((item) {
              return new DropdownMenuItem(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://upkeephouse.com/category%20images/" +
                                  item['category'].toString() +
                                  ".png",
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          placeholder: (context, url) =>
                              CircularProgressIndicator() /*SpinKitWave(
                            color: Color(0xFF00ACC1),
                            size: 20.0,
                            type: SpinKitWaveType.start,
                          )*/
                          ,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                        margin: EdgeInsets.only(right: 9),
                        width: 10 * SizeConfig.imageSizeMultiplier,
                        height: 10 * SizeConfig.imageSizeMultiplier,
                      ),
                      new Text(
                        item['category'].toString().toUpperCase(),
                        style: GoogleFonts.gotu(
                            fontSize: 2 * SizeConfig.textMultiplier),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                value: item['category'].toString(),
              );
            }).toList(),
            hint: Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
                "Select Profession",
                style: GoogleFonts.gotu(
                    color: SizeConfig.mainpurple,
                    fontSize: SizeConfig.textMultiplier * 2.5),
              ),
            ),
            onChanged: (newVal) {
              setState(() {
                _myCategorySelection = newVal;
                subcategory_data = null;
                getSubCategoryData(_myCategorySelection);
              });
            },
            value: _myCategorySelection,
          ),
        ),
      );
    } else {
      return Center(
        child: SpinKitFadingCircle(
          color: Colors.black,
        ),
      );
    }
  }

  Widget Subcategory(String profession) {
    double maxWidth = MediaQuery.of(context).size.width;
    if (profession != null) {
      if (subcategory_data != null) {
        return Container(
          alignment: Alignment.center,
          width: maxWidth,
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.only(left: 10, right: 5),
          decoration: BoxDecoration(
            border: Border.all(width: 2.0),
            borderRadius: BorderRadius.all(
                Radius.circular(5.0) //         <--- border radius here
                ),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Select what you do / आप किस प्रकार का काम करते हैं, उसका चयन करें",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 2.25 * SizeConfig.textMultiplier,
                      color: SizeConfig.mainpurple),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount:
                    subcategory_data == null ? 0 : subcategory_data.length,
                itemBuilder: (BuildContext context, int index) {
                  return new Card(
                    elevation: 0,
                    child: new Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(
                                5.0) //         <--- border radius here
                            ),
                      ),
                      padding: new EdgeInsets.all(3.0),
                      child: new Column(
                        children: <Widget>[
                          new CheckboxListTile(
                              value: subinputs[index],
                              title: Row(
                                children: <Widget>[
                                  Container(
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "https://upkeephouse.com/sub_catogery images/" +
                                              subcategory_data[index]
                                                  ['sub_category'] +
                                              ".jpg",
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator() /*SpinKitWave(
                                            color: Color(0xFF00ACC1),
                                            size: 20.0,
                                            type: SpinKitWaveType.start,
                                          )*/
                                      ,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                    margin: EdgeInsets.only(right: 5),
                                    width: 10 * SizeConfig.imageSizeMultiplier,
                                    height: 10 * SizeConfig.imageSizeMultiplier,
                                  ),
                                  Expanded(
                                    child: new Text(
                                      subcategory_data[index]['sub_category']
                                          .toString()
                                          .toUpperCase(),
                                      maxLines: 3,
                                      style: GoogleFonts.gotu(
                                          fontSize:
                                              SizeConfig.textMultiplier * 2),
                                    ),
                                  ),
                                ],
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (bool val) {
                                SubItemChange(val, index);
                              })
                        ],
                      ),
                    ),
                  );
                  //return AutoSizeText(locality_data[index]['locality']);
                },
              ),
            ],
          ),
        );
      } else {
        return Center(
          child: SpinKitFadingCircle(
            color: Colors.black,
          ),
        );
      }
    }
  }
}
