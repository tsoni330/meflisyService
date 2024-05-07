import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../size_config.dart';

class newVersion extends StatefulWidget {
  String info;

  newVersion(this.info);

  @override
  _newVersionState createState() => _newVersionState();
}

class _newVersionState extends State<newVersion> {

  _launchURL() async {
    const url = 'https://play.google.com/store/apps/details?id=com.upkeephouse.upkeephousepartner';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: RadialGradient(
              colors: [SizeConfig.mainyellow, SizeConfig.mainpurple]),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.info,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 2.5 * SizeConfig.textMultiplier),
              ),
              SizedBox(height: 5,),
              Icon(
                Icons.system_update,
                size: SizeConfig.imageSizeMultiplier * 40,
                color: Colors.white,
              ),
              Text(
                'Update App',
                style: GoogleFonts.gotu(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 2.5 * SizeConfig.textMultiplier),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.white)),
                  onPressed: () async {
                    _launchURL();
                  },
                  color: Colors.white,
                  textColor: SizeConfig.mainpurple,
                  child: Text("Update App".toUpperCase(),
                      style: GoogleFonts.gotu(
                          fontSize: 3 * SizeConfig.textMultiplier,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
