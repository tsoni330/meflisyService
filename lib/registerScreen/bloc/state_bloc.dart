import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';


// ignore: camel_case_types
class state_bloc extends ChangeNotifier{

  String _stateValue;
  String _cityValue;

  String get cityValue => _cityValue;

  String get stateValue => _stateValue;

  List _cityList;

  List get cityList => _cityList;

  Dio dio = new Dio();
  bool isCityDataLoading=false;

  String _localityValue;

  String get localityValue => _localityValue;


  List _localityList;

  List get localityList => _localityList;

  getCityData(String value) async{
    print('the value is '+value);
    FormData formData = new FormData.fromMap({
      "state": value
    });
    Response response= await dio.post('http://upkeephouse.com/get_cityname.php'
        ,data:formData
        );
    if(response.statusCode==200){
      isCityDataLoading=true;
      _cityList= jsonDecode(response.data);
    }
    notifyListeners();
  }

  getLocalityData(String state,String city)async{
    FormData formData = new FormData.fromMap({
      "state": state,
      "city": city
    });
    Response response= await dio.post('http://upkeephouse.com/get_locality.php'
        ,data:formData
    );
    if(response.statusCode==200){
      _localityList= jsonDecode(response.data);
      print('the locality is '+response.data.toString());
    }
    notifyListeners();
  }

  setStateValue(String value){
    _stateValue=value;
    _localityList=null;
    _cityList=null;
    getCityData(value);
    notifyListeners();
  }
  setCityValue(String value){
    _cityValue=value;
    _localityList=null;
    getLocalityData(_stateValue,_cityValue);
    notifyListeners();
  }

  setLocalityValue(String value){
    _localityValue=value;
    notifyListeners();
  }

}