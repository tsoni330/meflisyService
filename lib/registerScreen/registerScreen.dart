import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upkeephousepartner/registerScreen/register2Screen.dart';

import '../size_config.dart';

class registerScreen extends StatefulWidget {
  @override
  _registerScreenState createState() => _registerScreenState();
}

class _registerScreenState extends State<registerScreen> {
  String errormsg;
  String phoneNumber;
  String name,
      aadharcard,
      address,
      state,
      profession,
      city,
      sub_profession,businessname,
      refrence_id;
  TextEditingController namecontorller,
      aadharcontroller,
      addresscontroller,
      phonecontorller, businessnamecontroller;

  FocusNode namefocus, aadharfocus, addressfocus, phonefocus, businessfocus;

  @override
  void initState() {
    namefocus = FocusNode();
    aadharfocus = FocusNode();
    addressfocus = FocusNode();
    phonefocus = FocusNode();
    businessfocus=FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    namefocus.dispose();
    aadharfocus.dispose();
    addressfocus.dispose();
    phonefocus.dispose();
    businessfocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(

      automaticallyImplyLeading: true,

      title: Container(
        margin: EdgeInsets.only(left: 5, right: 5),
        child: Text('Personal Information',style: GoogleFonts.gotu(fontWeight: FontWeight.bold),),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  SizeConfig.mainyellow,
                  SizeConfig.mainpurple
                ])
        ),
      ),

    ),

      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 5, top: 15, right: 5),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                      Radius.circular(5.0) //         <--- border radius here
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
                              isEnabled: true, color: Colors.black, width: 1),
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
                        controller: namecontorller,
                        autofocus: true,
                        focusNode: namefocus,
                        style: TextStyle(
                            fontSize: 2.5 * SizeConfig.textMultiplier,
                            color: SizeConfig.mainpurple),
                        decoration: InputDecoration(
                          hintText: "Ex: John Gates",
                          hintStyle: TextStyle(
                              color: SizeConfig.mainpurple,
                              fontSize: 2.3 * SizeConfig.textMultiplier),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                          EdgeInsets.only(left: 10, bottom: 11, top: 11),
                        ),
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(aadharfocus);
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
                  borderRadius: BorderRadius.all(
                      Radius.circular(5.0) //         <--- border radius here
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
                        "AadharCard Number",
                        style: NeumorphicStyle(
                          depth: 8, //customize depth here
                          color: SizeConfig.mainpurple,
                          border: NeumorphicBorder(
                              isEnabled: true, color: Colors.black, width: 1),
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
                    AutoSizeText(
                      'नोट: हम आपका आधार  कार्ड नंबर किसी को भी साझा नहीं करते यहां तक की हमारे एप्लीकेशन उपभोक्ता को भी नह। हम इसको सिक्योरिटी के उदेशय से  अपने पास रख्ते है। गलत नंबर देने पर आपका अकाउंट ससपेंड और हमेशा के लिए बंद कर दिया जायेगा। ',
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize:
                          2.2 * SizeConfig.textMultiplier),
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
                      child: TextField(
                        controller: aadharcontroller,
                        focusNode: aadharfocus,
                        style: TextStyle(
                            fontSize: 2.5 * SizeConfig.textMultiplier,
                            color: SizeConfig.mainpurple),
                        decoration: InputDecoration(
                          hintText: "Ex: 999988887777",
                          hintStyle: TextStyle(
                              color: SizeConfig.mainpurple,
                              fontSize: 2.3 * SizeConfig.textMultiplier),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                          EdgeInsets.only(left: 10, bottom: 11, top: 11),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(phonefocus);
                        },
                        onChanged: (value) => aadharcard = value,
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
                  borderRadius: BorderRadius.all(
                      Radius.circular(5.0) //         <--- border radius here
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
                        "Mobile Number",
                        style: NeumorphicStyle(
                          depth: 8, //customize depth here
                          color: SizeConfig.mainpurple,
                          border: NeumorphicBorder(
                              isEnabled: true, color: Colors.black, width: 1),
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
                        controller: phonecontorller,
                        focusNode: phonefocus,
                        style: TextStyle(
                            fontSize: 2.5 * SizeConfig.textMultiplier,
                            color: SizeConfig.mainpurple),
                        decoration: InputDecoration(
                          hintText: "Ex: 9671775251",
                          hintStyle: TextStyle(
                              color: SizeConfig.mainpurple,
                              fontSize: 2.3 * SizeConfig.textMultiplier),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                          EdgeInsets.only(left: 10, bottom: 11, top: 11),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(businessfocus);
                        },
                        onChanged: (value) => phoneNumber = value,
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
                  borderRadius: BorderRadius.all(
                      Radius.circular(5.0) //         <--- border radius here
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
                              isEnabled: true, color: Colors.black, width: 1),
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
                    AutoSizeText(
                      'नोट: अगर दुकान का नाम नहीं है तो आप यहां पर अपना ही नाम दाल दे।',
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize:
                          2.2 * SizeConfig.textMultiplier),
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
                        controller: businessnamecontroller,
                        focusNode: businessfocus,
                        style: TextStyle(
                            fontSize: 2.5 * SizeConfig.textMultiplier,
                            color: SizeConfig.mainpurple),
                        decoration: InputDecoration(
                          hintText: "Ex: Balaji Electronics",
                          hintStyle: TextStyle(
                              color: SizeConfig.mainpurple,
                              fontSize: 2.3 * SizeConfig.textMultiplier),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                          EdgeInsets.only(left: 10, bottom: 11, top: 11),
                        ),
                        keyboardType: TextInputType.text,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(addressfocus);
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
                  borderRadius: BorderRadius.all(
                      Radius.circular(5.0) //         <--- border radius here
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
                              isEnabled: true, color: Colors.black, width: 1),
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
                        controller: addresscontroller,
                        focusNode: addressfocus,
                        style: TextStyle(
                            fontSize: 2.5 * SizeConfig.textMultiplier,
                            color: SizeConfig.mainpurple),
                        decoration: InputDecoration(
                          hintText: "Ex: house no., nearest landmark, city name",
                          hintStyle: TextStyle(
                              color: SizeConfig.mainpurple,
                              fontSize: 2.3 * SizeConfig.textMultiplier),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                          EdgeInsets.only(left: 10, bottom: 11, top: 11),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        onChanged: (value) => address = value,
                      ),
                    ),
                  ],
                ),
              ),



              SizedBox(height: 10,),
              errormsg!=null?Container(
                child: Center(
                  child: Text(errormsg,style: TextStyle(
                      color: Colors.red,
                      fontSize: 16
                  ),),
                ),
              ):SizedBox(),

              GestureDetector(
                onTap: () {
                  if(name!=null){
                    if(aadharcard!=null){
                      if(phoneNumber!=null){
                        if(businessname!=null){
                          if(address!=null){
                            errormsg='';
                            print('yaa its working');
                            Get.to(register2Screen(name,aadharcard,phoneNumber,address,businessname));
                          }else{
                            setState(() {
                              errormsg='Please fill Address';
                            });
                          }
                        }else{
                          setState(() {
                            errormsg='Please fill Business Name';
                          });
                        }
                      }else{
                        setState(() {
                          errormsg='Please fill Phone number';
                        });
                      }
                    }else{
                      setState(() {
                        errormsg='Please fill Aadharcard number';
                      });
                    }
                  }else{
                    setState(() {
                      errormsg='Please fill Name';
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                      left: 15, right: 15, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[
                          SizeConfig.mainyellow,
                          SizeConfig.mainpurple
                        ]),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin: EdgeInsets.only(top: 15.0,left: 10,right: 10),
                  child: Text(
                    "Next",
                    style: GoogleFonts.gotu(
                        fontSize: 3 * SizeConfig.textMultiplier,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}
