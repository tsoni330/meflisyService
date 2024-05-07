import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:upkeephousepartner/Manager/MyConnectivity.dart';
import '../size_config.dart';

class Edit2 extends StatefulWidget {
  String state, city, profession, subprofession, locality, partner_id;

  Edit2(this.state, this.city, this.profession, this.subprofession,
      this.locality, this.partner_id);

  @override
  _Edit2State createState() => _Edit2State();
}

class _Edit2State extends State<Edit2> {
  String _mySelection, _myCitySelection;
  String _myCategorySelection;

  final String url = 'https://upkeephouse.com/working_states.php';

  List data, city_data, locality_data, category_data, subcategory_data;


  List<bool> inputs = new List<bool>();
  List<String> location;
  List<bool> subinputs = new List<bool>();
  List<String> sublocation, subkeywords;
  String locationString = '', sublocationString = '', keywordString = '', error;

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

  @override
  void initState() {

    getCityData(widget.state);
    // checkUserAccount1();
    getCategoryData();

    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
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
    });

    client.close();
    return 'Success';
  }

  uploadInfo() async {
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

    String url = "https://upkeephouse.com/upload_partner2.php";

    FormData newData = new FormData.fromMap({
      'state': widget.state,
      'city': _myCitySelection != null ? _myCitySelection : widget.city,
      'profession': _myCategorySelection != null
          ? _myCategorySelection
          : widget.profession,
      'sub_profession': sublocationString.length > 0
          ? sublocationString
          : widget.subprofession,
      'partner_id': widget.partner_id,
      'locality': locationString.length > 0 ? locationString : widget.locality
    });
    await Dio().post(url, data: newData).then((response) => {
          if (response.statusCode == 200)
            {
              if (response.data.toString() != '1')
                {
                  print(response.data.toString()),
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
                  getLocalityData(_myCitySelection, widget.state);
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
              'More Updates',
              style: GoogleFonts.gotu(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: new ListView(
          children: <Widget>[
            Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Previous City:- ' + widget.city.toUpperCase(),
                        style: TextStyle(
                            fontSize: 2.3 * SizeConfig.textMultiplier,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: DropDown2(widget.state),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: DropDown3(_myCitySelection, widget.state),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Previous Profession:- ' +
                            widget.profession.toUpperCase(),
                        style: TextStyle(
                            fontSize: 2.3 * SizeConfig.textMultiplier,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Category(category_data),
                      ),
                    ],
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
                  error != null
                      ? Text(
                          error,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.gotu(
                              fontSize: 2.3 * SizeConfig.textMultiplier,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: SizeConfig.mainpurple)),
                          onPressed: () {
                            Get.back();
                          },
                          color: SizeConfig.mainpurple,
                          textColor: Colors.white,
                          child: Text("Back".toUpperCase(),
                              style: GoogleFonts.gotu(
                                  fontSize: 3 * SizeConfig.textMultiplier,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(width: 30,),
                      Container(
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: SizeConfig.mainpurple)),
                          onPressed: () {
                            //uploadInfo();
                            if (locationString.length <= 0 || sublocationString.length <= 0) {
                              setState(() {
                                error = 'Please select and fill all fields';
                              });
                            } else {
                              setState(() {
                                error = null;
                              });
                              uploadInfo();
                              //print(locationString.length.toString()+' '+sublocationString.length.toString());
                            }
                          },
                          color: SizeConfig.mainpurple,
                          textColor: Colors.white,
                          child: Text("Update".toUpperCase(),
                              style: GoogleFonts.gotu(
                                  fontSize: 3 * SizeConfig.textMultiplier,
                                  fontWeight: FontWeight.bold)),
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
          ],
        ),
      ),
    );
  }
}
