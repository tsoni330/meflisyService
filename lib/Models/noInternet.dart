import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upkeephousepartner/size_config.dart';


class noInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: RadialGradient(
              colors: [SizeConfig.mainyellow, SizeConfig.mainpurple]
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.network_check,
                size: SizeConfig.imageSizeMultiplier*40,
                color: Colors.white,
              ),
              Text('No Internet',style: GoogleFonts.gotu(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 2.5*SizeConfig.textMultiplier
              ),)
            ],
          ),
        ),
      ),
    );
  }
}
