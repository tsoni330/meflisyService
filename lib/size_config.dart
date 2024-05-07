import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share/share.dart';

class SizeConfig{
  static double _screenWidth;
  static double _screenHeight;
  static double _blockSizeHorizontal=0;
  static double _blockSizeVertical=0;
  static double textMultiplier;
  static double imageSizeMultiplier;
  static double heightMultiplier;
  static Color mainpurple= Color(0xFF6784CC);
  static Color mainyellow= Color(0xFF33589b);

  void init(BoxConstraints constraints){
    _screenWidth=constraints.maxWidth;
    _screenHeight=constraints.maxHeight;

    _blockSizeHorizontal=_screenWidth/100;
    _blockSizeVertical=_screenHeight/100;

    textMultiplier=_blockSizeVertical;
    imageSizeMultiplier=_blockSizeHorizontal;
    heightMultiplier=_blockSizeVertical;
  }

  static void shareApp(BuildContext context){
    final RenderBox box = context.findRenderObject();
    Share.share('https://play.google.com/store/apps/details?id=com.upkeephouse.upkeephousepartner',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

}