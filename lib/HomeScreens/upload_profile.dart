import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../size_config.dart';

class UploadImage extends StatefulWidget {
  String image;
  UploadImage(this.image);
  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {

  final String domainurl = 'https://www.upkeephouse.com/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
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
                'Upload Image',
                style: GoogleFonts.gotu(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45 * SizeConfig.imageSizeMultiplier,
              height: 45 * SizeConfig.imageSizeMultiplier,
              child: CachedNetworkImage(
                imageUrl: domainurl + widget.image,
                placeholder: (context, url) =>
                    SpinKitFadingCircle(
                      color: Colors.black,
                    ),
                imageBuilder: (context, imageprovider) =>
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.all(Radius.circular(20)),
                        image: DecorationImage(
                          image: imageprovider,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
