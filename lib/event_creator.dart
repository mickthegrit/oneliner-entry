import 'package:one_liner_entry/app_constants.dart';

class EventCreator{
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  void initialize(String input){
    startDate = DateTime.now();
    // default value 
    endDate = startDate.add( Duration( minutes :  AppConstants.defaultAlert ) );

    input.split(" ");

  }
}