import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
//import 'package:test/test.dart';
import 'package:one_liner_entry/app_constants.dart';
import 'package:one_liner_entry/reminder_creator.dart';

ReminderCreator reminder = ReminderCreator();
DateTime _now = DateTime.now();

String desc = "Turn off oven";
String note = "chicken cooking";
int minutes = 45;
int days = 20;
int weeks = 3;
int years = 1;
Duration defaultAllDayEventDuration = const Duration(hours: 24); 
List noteValues = [ note, ''];
List timeUnitPrefixValue = [ '', 'in '];
List mondayValues = [ 'Monday', 'Mon', 'on Monday', 'on Mon' ];
List nextMondayOrWeekValues = [ 'Monday', 'Mon', 'Week'];
List wednesdayValues = [ 'Wednesday', 'Wed'];
List todayValues = [ 'today', 'tod'];
List tomorrowValues = [ 'tomorrow', 'tom'];
List futureRelevantTokens = [ 'next', 'following'];
List janValues = [ 'jan', 'January'];
List aprValues = [ 'apr', 'April'];
List yearValues = [ 99, 2099];

/// 13:45 
List timeValuesAfternoon = [ '', '13:45' , '1:45pm', '1:45 pm', 'at 13:45', 'at 1:45pm', 'at 1:45 pm'];

/// 2:35 
List timeValuesAfterMidnight = [ '', '2:35' , '2:35am', '2:35 am', 'at 2:35' , 'at 2:35am', 'at 2:35 am'];

/// '' and 'next' and 'following' 
List nextValues = [ '', 'next', 'following'];

/// Default event Duration
Duration defEventDur = Duration(minutes:AppConstants.defaultEventDurationInMinutes);


void performStartDateTest(DateTime startDate, int _day, int _month ) {
    expect( startDate.day == _day, true );
    expect( startDate.month == _month, true );
    if( ( _now.day == _day && _now.month == _month) || _month < _now.month) { 
      expect( startDate.year == _now.year + 1 , true );
    }
    else {
      expect( startDate.year == _now.year , true );
    }        
}

/// Ensure the supplied variables match the input ones and the outcome is as expected
/// 
/// `minutesInFuture` The time in the future this event will be created
void performTests( String desc, int? minutesInFuture, String? note , bool isAllDay, bool? isFutureDate, Duration? distanceFromNow, Duration? diffStartWithEnd){

  expect(reminder.getDesc(), desc.trim());

  if (minutesInFuture !=null ) {
    expect(reminder.getDuration().inMinutes, minutesInFuture);
  }

  String _note = note ?? '' ; 
  expect(reminder.getNote() == _note, true );
  expect(reminder.isAllDay(), isAllDay);

  // check for identified date if one was supplied . 
  // Input dates like 'today 00:00' or 'yesterday' can have today's date.
  if ( isFutureDate != null ) {
    if ( isFutureDate ) { 
      expect(reminder.getStartDate().compareTo(_now) > 0 , true );
    }
    else{ 
      expect(reminder.getStartDate().compareTo(_now) < 0 , true );
    }
  }

  if  (distanceFromNow != null ) {
    int _hours = isAllDay? 0 : _now.hour;
    int _minutes = isAllDay? 0 : _now.minute ;
    DateTime _localNow = DateTime( _now.year, _now.month, _now.day, _hours, _minutes);
    expect( (reminder.getStartDate().difference( _localNow )).compareTo( distanceFromNow ) == 0 , true);
  }

  if  (diffStartWithEnd != null &&  !isAllDay ) {
    expect( ( reminder.getEndDate().difference( reminder.getStartDate() ) ).compareTo( diffStartWithEnd ) == 0 , true);
  }

  // Check for default alerts 
  if ( isAllDay ){
    expect(reminder.getAlert() == AppConstants.defaultAlertHoursForAllDayEvents.inMinutes, true ); 
  }else if (!isAllDay) {
    expect(reminder.getAlert() == AppConstants.defaultAlert, true);
  }
}

void main() {

  test('Reminder creator - 0 days ... ', () {
    
    for (int i = 0; i< noteValues.length; i++ ){
      reminder = ReminderCreator();
      reminder.process( '$desc 0 days ${noteValues[i]}' );

      performTests( '$desc 0 days ${noteValues[i]}', null, null, false, null , null, null );
    }

  } );

  test('Reminder creator - 0 - no unit ... ', () {

    for (int i = 0; i< noteValues.length; i++ ){
      reminder = ReminderCreator();
      reminder.process( '$desc 0 ${noteValues[i]}' );

      performTests( '$desc 0 ${noteValues[i]}', null, null, false, null , null, null );
    }

  } );

  test('Reminder creator - multiple parameters - today ... ', () {
    
    DateTime _now = DateTime.now();

    for (int i = 0; i< noteValues.length; i++ ){
      for (int j = 0; j < todayValues.length; j++) {
        for (int k =0 ; k < timeValuesAfternoon.length; k++){
          reminder = ReminderCreator();
          reminder.process( '$desc ${todayValues[j]} ${timeValuesAfternoon[k]} ${noteValues[i]}' );

          performTests( desc, null, noteValues[i], timeValuesAfternoon[k] == '' ? true : false, null , null, null );
          assert(reminder.getStartDate().day == _now.day, true);
          assert(reminder.getStartDate().month == _now.month, true);
          assert(reminder.getStartDate().year == _now.year, true);

          if (timeValuesAfternoon[k] != ''){
            expect(reminder.getStartDate().hour == 13, true );
            expect(reminder.getStartDate().minute == 45, true );
          }
        }

        for (int k =0 ; k < timeValuesAfterMidnight.length; k++){
          reminder = ReminderCreator();
          reminder.process( '$desc ${todayValues[j]} ${timeValuesAfterMidnight[k]} ${noteValues[i]}' );

          performTests( desc, null, noteValues[i], timeValuesAfterMidnight[k] == '' ? true : false, null , null, null );
          assert(reminder.getStartDate().day == _now.day, true);
          assert(reminder.getStartDate().month == _now.month, true);
          assert(reminder.getStartDate().year == _now.year, true);

          if (timeValuesAfterMidnight[k] != ''){
            expect(reminder.getStartDate().hour == 2, true );
            expect(reminder.getStartDate().minute == 35, true );
          }
        }
      }
    }

  } );

  test('Reminder creator - multiple parameters - Monday ... ', () {
    
    DateTime _now = DateTime.now();
    
    for (int i = 0; i< noteValues.length; i++ ){
      for (int j = 0; j < mondayValues.length; j++) {
        for (int k =0 ; k < timeValuesAfternoon.length; k++){
          reminder = ReminderCreator();
          reminder.process( '$desc ${mondayValues[j]} ${timeValuesAfternoon[k]} ${noteValues[i]}' );

          performTests( desc, null, noteValues[i], timeValuesAfternoon[k] == '' ? true : false, true , null, null );

          int daysInFuture = ReminderCreator.daysToAdd(_now.weekday, reminder.getStartDate().weekday); // max same day 

          assert(reminder.getStartDate().weekday == DateTime.monday, true);

          // do comparisons only with year - month - day 
          DateTime _x = DateTime(reminder.getStartDate().year, reminder.getStartDate().month, reminder.getStartDate().day);
          assert( _x.compareTo( DateTime(_now.year, _now.month,_now.day).add(Duration(days: daysInFuture))) == 0 , true);
        
          if (timeValuesAfternoon[k] != ''){
            expect(reminder.getStartDate().hour == 13, true );
            expect(reminder.getStartDate().minute == 45, true );
          }
        
        }

        for (int k =0 ; k < timeValuesAfterMidnight.length; k++){
          reminder = ReminderCreator();
          reminder.process( '$desc ${mondayValues[j]} ${timeValuesAfterMidnight[k]} ${noteValues[i]}' );

          performTests( desc, null, noteValues[i], timeValuesAfterMidnight[k] == '' ? true : false, true , null, null );

          int daysInFuture = ReminderCreator.daysToAdd(_now.weekday, reminder.getStartDate().weekday); // max same day 

          assert(reminder.getStartDate().weekday == DateTime.monday, true);

          // do comparisons only with year - month - day 
          DateTime _x = DateTime(reminder.getStartDate().year, reminder.getStartDate().month, reminder.getStartDate().day);

          assert( _x.compareTo( DateTime(_now.year, _now.month,_now.day).add(Duration(days: daysInFuture))) == 0 , true);
        
          if (timeValuesAfterMidnight[k] != ''){
            expect(reminder.getStartDate().hour == 2, true );
            expect(reminder.getStartDate().minute == 35, true );
          }
        
        }
      }
    }

  } );

  test('Reminder creator - multiple parameters - next Monday or next week ... ', () {
    
    DateTime _now = DateTime.now();
    
    for (int i = 0; i< noteValues.length; i++ ) {
      for (int j = 0; j < nextMondayOrWeekValues.length; j++) {
        for (int k =0 ; k < timeValuesAfternoon.length; k++){
          reminder = ReminderCreator();
          reminder.process( '$desc next ${nextMondayOrWeekValues[j]} ${timeValuesAfternoon[k]} ${noteValues[i]}' );

          performTests( desc, null, noteValues[i], timeValuesAfternoon[k] == '' ? true : false, true , null, null );

          int daysInFuture = ReminderCreator.daysToAdd(_now.weekday, reminder.getStartDate().weekday); // max same day 

          assert(reminder.getStartDate().weekday == DateTime.monday, true);

          // do comparisons only with year - month - day 
          DateTime _x = DateTime(reminder.getStartDate().year, reminder.getStartDate().month, reminder.getStartDate().day);

          assert( _x.compareTo( DateTime(_now.year, _now.month,_now.day).add(Duration(days: daysInFuture + 7))) == 0 , true);

          if (timeValuesAfternoon[k] != ''){
            expect(reminder.getStartDate().hour == 13, true );
            expect(reminder.getStartDate().minute == 45, true );
          }
        }

        for (int k =0 ; k < timeValuesAfterMidnight.length; k++){
          reminder = ReminderCreator();
          reminder.process( '$desc next ${nextMondayOrWeekValues[j]} ${timeValuesAfterMidnight[k]} ${noteValues[i]}' );

          performTests( desc, null, noteValues[i], timeValuesAfterMidnight[k] == '' ? true : false, true , null, null );

          int daysInFuture = ReminderCreator.daysToAdd(_now.weekday, reminder.getStartDate().weekday); // max same day 

          assert(reminder.getStartDate().weekday == DateTime.monday, true);

          // do comparisons only with year - month - day 
          DateTime _x = DateTime(reminder.getStartDate().year, reminder.getStartDate().month, reminder.getStartDate().day);

          assert( _x.compareTo( DateTime(_now.year, _now.month,_now.day).add(Duration(days: daysInFuture + 7))) == 0 , true);

          if (timeValuesAfterMidnight[k] != ''){
            expect(reminder.getStartDate().hour == 2, true );
            expect(reminder.getStartDate().minute == 35, true );
          }
        }
      }
    }

  } );

  test('Reminder creator - multiple parameters - next month  ... ', () {
    
    DateTime _now = DateTime.now();
    
    for (int i = 0; i< noteValues.length; i++ ) {
      for (int k =0 ; k < timeValuesAfternoon.length; k++){
        reminder = ReminderCreator();
        reminder.process( '$desc next month ${timeValuesAfternoon[k]} ${noteValues[i]}' );

        performTests( desc, null, noteValues[i], timeValuesAfternoon[k] == '' ? true : false, true , null, null );

        assert(reminder.getStartDate().day == 1, true);
        if(_now.month == 12 ){
          assert(reminder.getStartDate().month == 1, true);
          assert(reminder.getStartDate().year == _now.year + 1 , true);
        }
        else {
          assert(reminder.getStartDate().month == _now.month + 1, true);
          assert(reminder.getStartDate().year == _now.year, true);
        }

        if (timeValuesAfternoon[k] != ''){
          expect(reminder.getStartDate().hour == 13, true );
          expect(reminder.getStartDate().minute == 45, true );
        }
      }

      for (int k =0 ; k < timeValuesAfterMidnight.length; k++){
        reminder = ReminderCreator();
        reminder.process( '$desc next month ${timeValuesAfterMidnight[k]} ${noteValues[i]}' );

        performTests( desc, null, noteValues[i], timeValuesAfterMidnight[k] == '' ? true : false, true , null, null ); 

        assert(reminder.getStartDate().day == 1, true);
        if(_now.month == 12 ){
          assert(reminder.getStartDate().month == 1, true);
          assert(reminder.getStartDate().year == _now.year + 1 , true);
        }
        else {
          assert(reminder.getStartDate().month == _now.month + 1, true);
          assert(reminder.getStartDate().year == _now.year, true);
        }

        if (timeValuesAfterMidnight[k] != ''){
          expect(reminder.getStartDate().hour == 2, true );
          expect(reminder.getStartDate().minute == 35, true );
        }
      }
      
    }

  } );

  test('Reminder creator - multiple parameters - next year  ... ', () {
    
    DateTime _now = DateTime.now();
    
    for (int i = 0; i< noteValues.length; i++ ) {

      // test the time before the date literal 
      for (int k =0 ; k < timeValuesAfternoon.length; k++){
        reminder = ReminderCreator();
        reminder.process( '$desc ${timeValuesAfternoon[k]} next year ${noteValues[i]}' );

        performTests( desc, null, noteValues[i], timeValuesAfternoon[k] == '' ? true : false, true , null, null );

        assert(reminder.getStartDate().day == 1, true);
        assert(reminder.getStartDate().month == 1, true);
        assert(reminder.getStartDate().year == _now.year + 1 , true);
  
        if (timeValuesAfternoon[k] != ''){
          expect(reminder.getStartDate().hour == 13, true );
          expect(reminder.getStartDate().minute == 45, true );
        }
      }

      // test the time after the date literal 
      for (int k =0 ; k < timeValuesAfternoon.length; k++){
        reminder = ReminderCreator();
        reminder.process( '$desc next year ${timeValuesAfternoon[k]} ${noteValues[i]}' );

        performTests( desc, null, noteValues[i], timeValuesAfternoon[k] == '' ? true : false, true , null, null );

        assert(reminder.getStartDate().day == 1, true);
        assert(reminder.getStartDate().month == 1, true);
        assert(reminder.getStartDate().year == _now.year + 1 , true);
  
        if (timeValuesAfternoon[k] != ''){
          expect(reminder.getStartDate().hour == 13, true );
          expect(reminder.getStartDate().minute == 45, true );
        }
      }

      // test the US format 
      for (int k =0 ; k < timeValuesAfterMidnight.length; k++){
        reminder = ReminderCreator();
        reminder.process( '$desc next year ${timeValuesAfterMidnight[k]} ${noteValues[i]}' );

        performTests( desc, null, noteValues[i], timeValuesAfterMidnight[k] == '' ? true : false, true , null, null ); 

        assert(reminder.getStartDate().day == 1, true);       
        assert(reminder.getStartDate().month == 1, true);
        assert(reminder.getStartDate().year == _now.year + 1 , true);

        if (timeValuesAfterMidnight[k] != ''){
          expect(reminder.getStartDate().hour == 2, true );
          expect(reminder.getStartDate().minute == 35, true );
        }
      }
      
    }

  } );

  test('Reminder creator - multiple parameters - weekend and next w/end ... ', () {
    
    DateTime _now = DateTime.now();
    List times = [];
    times.addAll(timeValuesAfterMidnight);
    times.addAll(timeValuesAfternoon);
    
    for (int i = 0; i< noteValues.length; i++ ) {
      for (int j = 0; j < AppConstants.weekendLiterals.length; j++) {
        for (int k =0 ; k < nextValues.length; k++){
          for (int l =0; l < times.length; l++ ){
            reminder = ReminderCreator();
            reminder.process( '$desc ${nextValues[k]} ${AppConstants.weekendLiterals[j]} ${times[l]} ${noteValues[i]}' );

            String _noteToCheck = times[l] != '' ? times[l] + ' ' + noteValues[i] : noteValues[i]; 
            if (noteValues[i] == '') {
              _noteToCheck = times[l] ; 
            }

            // ignore time values for weekends 
            performTests( desc, null, _noteToCheck,  true , true , null, null );

            int daysInFuture = ReminderCreator.daysToAdd(_now.weekday, reminder.getStartDate().weekday); // max same day 
            if (nextValues[k] != ''){
              daysInFuture = daysInFuture + 7;
            }

            assert(reminder.getStartDate().weekday == DateTime.saturday, true);

            // do comparisons only with year - month - day 
            DateTime _x = DateTime(reminder.getStartDate().year, reminder.getStartDate().month, reminder.getStartDate().day);

            assert( _x.compareTo( DateTime(_now.year, _now.month,_now.day).add(Duration(days: daysInFuture ))) == 0 , true);
            assert(reminder.getStartDate().hour == 0, true); 
            assert(reminder.getStartDate().minute == 0, true); 
            assert(reminder.getEndDate().hour == 0, true); 
            assert(reminder.getEndDate().hour == 0, true); 
          }
        }
      }
    }

  } );

  test('Reminder creator - multiple parameters - Wednesday ... ', () {
    
    DateTime _now = DateTime.now();
    
    for (int i = 0; i< noteValues.length; i++ ){
      for (int j = 0; j < wednesdayValues.length; j++) {
        reminder = ReminderCreator();
        reminder.process( '$desc ${wednesdayValues[j]} ${noteValues[i]}' );

        performTests( desc, null, noteValues[i], true, true , null, null );

        int daysInFuture = ReminderCreator.daysToAdd(_now.weekday, reminder.getStartDate().weekday); // max same day 

        assert(reminder.getStartDate().weekday == DateTime.wednesday, true);
        assert( reminder.getStartDate().compareTo( 
                DateTime(_now.year, _now.month,_now.day).add(Duration(days: daysInFuture))) == 0 , true);
      }
    }

  } );

  test('Reminder creator - multiple parameters - yesterday ... ', () {
    
    DateTime _yesterday = DateTime.now().subtract(const Duration(days: 1));

    for (int i = 0; i< noteValues.length; i++ ){
      for (int k =0 ; k < timeValuesAfternoon.length; k++){
        reminder = ReminderCreator();
        reminder.process( '$desc yesterday ${timeValuesAfternoon[k]} ${noteValues[i]}' );

        performTests( desc, null, noteValues[i], timeValuesAfternoon[k] ==''? true : false, false , null, null );
        assert(reminder.getStartDate().day == _yesterday.day , true);
        assert(reminder.getStartDate().month == _yesterday.month, true);
        assert(reminder.getStartDate().year == _yesterday.year, true);

        if (timeValuesAfternoon[k] != ''){
          expect(reminder.getStartDate().hour == 13, true );
          expect(reminder.getStartDate().minute == 45, true );
        }
      }

      for (int k =0 ; k < timeValuesAfterMidnight.length; k++){
        reminder = ReminderCreator();
        reminder.process( '$desc yesterday ${timeValuesAfterMidnight[k]} ${noteValues[i]}' );

        performTests( desc, null, noteValues[i], timeValuesAfterMidnight[k] ==''? true : false, false , null, null );
        assert(reminder.getStartDate().day == _yesterday.day , true);
        assert(reminder.getStartDate().month == _yesterday.month, true);
        assert(reminder.getStartDate().year == _yesterday.year, true);

        if (timeValuesAfterMidnight[k] != ''){
          expect(reminder.getStartDate().hour == 2, true );
          expect(reminder.getStartDate().minute == 35, true );
        }
      }

    }

  } );

  test('Reminder creator - multiple parameters - tomorrow ... ', () {
    
    DateTime _tomorrow = _now.add( const Duration(days: 1) );

    for (int i = 0; i< noteValues.length; i++ ){
      for (int j = 0; j < tomorrowValues.length; j++) {
        for (int k =0 ; k < timeValuesAfternoon.length; k++){
          reminder = ReminderCreator();
          reminder.process( '$desc ${tomorrowValues[j]} ${timeValuesAfternoon[k]} ${noteValues[i]}' );

          performTests( desc, null, noteValues[i], timeValuesAfternoon[k] == ''? true : false, true , null, null );
          assert(reminder.getStartDate().day == _tomorrow.day, true);
          assert(reminder.getStartDate().month == _tomorrow.month, true);
          assert(reminder.getStartDate().year == _tomorrow.year, true);

          if (timeValuesAfternoon[k] != ''){
            expect(reminder.getStartDate().hour == 13, true );
            expect(reminder.getStartDate().minute == 45, true );
          }        
        }

        for (int k =0 ; k < timeValuesAfterMidnight.length; k++){
          reminder = ReminderCreator();
          reminder.process( '$desc ${tomorrowValues[j]} ${timeValuesAfterMidnight[k]} ${noteValues[i]}' );

          performTests( desc, null, noteValues[i], timeValuesAfterMidnight[k] == ''? true : false, true , null, null );
          assert(reminder.getStartDate().day == _tomorrow.day, true);
          assert(reminder.getStartDate().month == _tomorrow.month, true);
          assert(reminder.getStartDate().year == _tomorrow.year, true);

          if (timeValuesAfterMidnight[k] != ''){
            expect(reminder.getStartDate().hour == 2, true );
            expect(reminder.getStartDate().minute == 35, true );
          }        
        }
      }
    }

  } );

  test('Reminder creator - multiple parameters - unit days - prefix in ... ', () {

    for (int j = 0; j< timeUnitPrefixValue.length; j++ ){
      for (int i = 0; i< noteValues.length; i++ ){
        reminder = ReminderCreator();
        reminder.process( '$desc ${timeUnitPrefixValue[j]} ${days.toString()} days ${noteValues[i]}' );

        performTests( desc, null, noteValues[i], true, true , Duration(days: days), defaultAllDayEventDuration );
      }
    }

  } );

  test('Reminder creator - multiple parameters - unit hours ... ', () {
    
    var _targetHours = 1;

    for (int i = 0; i< noteValues.length; i++ ){
      reminder = ReminderCreator();
      reminder.process( '$desc $_targetHours hour ${noteValues[i]}' );
      performTests( desc, _targetHours * 60, noteValues[i], false, true , Duration(hours: _targetHours),  defEventDur );
    }
    
  } );

  test('Reminder creator - multiple parameters - unit hours - no alerts - prefix in ... ', () {
    
    var _targetHours = 1;

    for (int j = 0; j< timeUnitPrefixValue.length; j++ ){
      for (int i = 0; i< AppConstants.noAlertLiterals.length; i++ ){
        reminder = ReminderCreator();
        reminder.process( '$desc ${timeUnitPrefixValue[j]} 1 hour ${AppConstants.noAlertLiterals[i]} $note' );
        performTests( desc, _targetHours * 60, note, false, true , Duration(hours: _targetHours),  defEventDur );
        expect(reminder.isAlertSuppressed(), true);
      }
    }
    
  } );

  test('Reminder creator - multiple parameters - unit weeks - prefix in... ', () {

    for (int j = 0; j< timeUnitPrefixValue.length; j++ ){    
      reminder = ReminderCreator();

      reminder.process( '$desc ${timeUnitPrefixValue[j]} ${weeks.toString()} weeks $note' );
      performTests( desc, null, note, true, true , Duration(days: weeks * 7 ),  defEventDur );
    }

    reminder = ReminderCreator();
    reminder.process( '$desc ${weeks.toString()} weeks' );
    performTests( desc, null, null, true, true , Duration(days: weeks * 7 ),  defEventDur );

  } );

  test('Reminder creator - multiple parameters - unit year - prefix in ... ', () {
    
    for (int j = 0; j< timeUnitPrefixValue.length; j++ ){
      reminder = ReminderCreator();

      reminder.process('$desc ${timeUnitPrefixValue[j]} ${years.toString()} year $note');
      performTests( desc, null, note, true, true , Duration( days: 365 ),  defEventDur );
    }

    reminder = ReminderCreator();
    reminder.process('$desc ${years.toString()} year');
    performTests( desc, null, null, true, true , Duration( days: 365 ),  defEventDur );

  } );

  test('Reminder creator - multiple parameters - no unit - numeric count ... ', () {

    for (int i = 0; i< noteValues.length; i++ ){
      reminder = ReminderCreator();
      reminder.process('$desc ${minutes.toString()} ${noteValues[i]}');
      performTests( desc, minutes, noteValues[i], false, true , Duration( minutes: minutes ),  defEventDur );
    }
    reminder = ReminderCreator();
    reminder.process('$desc in ${minutes.toString()} $note');
    performTests( desc, minutes, note, false, true , Duration( minutes: minutes ),  defEventDur );
   
  } );

  test('Reminder creator - only month name', () {

    int _futureYear10 = _now.year + 10;
    var _monJun = [ 'Jun', 'June', 'Jun $_futureYear10', 'June $_futureYear10' ];

    for( int j=0; j< _monJun.length; j++ ) { 
      reminder = ReminderCreator();
      reminder.process('Test ${_monJun[j]} some');
      performTests( 'Test', null, 'some', true, null , null,  defEventDur );
      
      expect(reminder.getStartDate().day == 1, true );
      expect(reminder.getStartDate().month == 6, true );

      if ( _monJun[j].length < 5) {
        if (_now.month >= 6) {
          expect(reminder.getStartDate().year == _now.year + 1 , true );
        }
        else {
          expect(reminder.getStartDate().year == _now.year, true );  
        }
      }
      else {
        expect(reminder.getStartDate().year == _futureYear10, true );
      }
    }

    var _monJul = [ 'Jul', 'July', 'Jul $_futureYear10', 'July $_futureYear10' ];

    for( int j=0; j< _monJul.length; j++ ) { 
      reminder = ReminderCreator();
      reminder.process('Test ${_monJul[j]} some');
      performTests( 'Test', null, 'some', true, null , null,  defEventDur );
      
      expect(reminder.getStartDate().day == 1, true );
      expect(reminder.getStartDate().month == 7, true );

      if ( _monJun[j].length < 5) {
        if (_now.month >= 7) {
          expect(reminder.getStartDate().year == _now.year + 1 , true );
        }
        else {
          expect(reminder.getStartDate().year == _now.year, true );
        }
      }
      else {
        expect(reminder.getStartDate().year == _futureYear10, true ); 
      }
    }
  } );

  test('Reminder creator - short hours - at H HH HMM HHMM pm am ... ', () {

    var _entries19 = [ '1900', '7pm', '7 pm']; 
    var _entries6 = [ '6', '600', '0600', '6am', '6 am'];
    var _entries0715 = [ '0715', '715', '715am', '715 am', '0715am', '0715 am'];
    var _entries2032 = [ '2032', '832pm', '832 pm', '0832pm', '0832 pm'];

    for (int i = 0; i< _entries19.length; i++ ){
      reminder = ReminderCreator();
      reminder.process('$desc today at ${_entries19[i]} chicken');
      expect(reminder.getSuppliedTime24h() == '19:00', true );
    }

    for (int i = 0; i< _entries6.length; i++ ){
      reminder = ReminderCreator();
      reminder.process('$desc today at ${_entries6[i]} chicken');
      expect(reminder.getSuppliedTime24h() == '06:00', true );
    }

    for (int i = 0; i< _entries0715.length; i++ ){
      reminder = ReminderCreator();
      reminder.process('$desc today at ${_entries0715[i]} chicken');
      expect(reminder.getSuppliedTime24h() == '07:15', true );
    }

    for (int i = 0; i< _entries2032.length; i++ ){
      reminder = ReminderCreator();
      reminder.process('$desc today at ${_entries2032[i]} chicken');
      expect(reminder.getSuppliedTime24h() == '20:32', true );
    }
   
  } );


  test('Reminder creator - mm//dd', () {

    var _dateValues = [ '10//12', '${_now.month}//${_now.day}', '05//06', '4//3' ];

    for (int i = 0; i< noteValues.length; i++ ){
      for( int j=0; j< _dateValues.length; j++ ) { 
        reminder = ReminderCreator();
        reminder.process('Test ${_dateValues[j]} ${noteValues[i]}');
        performTests( 'Test', null, noteValues[i], true, null , null,  defEventDur );
        
        //expect(reminder.getStartDate().day == 12, true );
        //expect(reminder.getStartDate().month == 10, true );

        switch ( j ) {
          case 0:  
            performStartDateTest( reminder.getStartDate() , 12, 10 );

            break; 
          case 1:
            performStartDateTest(reminder.getStartDate(), _now.day, _now.month); 

            break; 
          case 2: 
            // double digits with trailing zeros 
            performStartDateTest( reminder.getStartDate() , 6, 5 );

            break;
          case 3:
            performStartDateTest( reminder.getStartDate() , 3, 4 );

            break;

          default: 
            // nothing 

        }
      }
    }

    List _years = ['2023', '23'];
    for (int i = 0; i < _years.length; i++){
      reminder = ReminderCreator();
      reminder.process('Test me 10//15/${_years[i]}');
      expect(reminder.getStartDate().day == 15, true);
      expect(reminder.getStartDate().month == 10, true);
      expect(reminder.getStartDate().year == 2023, true);
    }
  });

  test('Reminder creator - dd/mm', () {

    var _dateValues = [ '10/12', '${_now.day}/${_now.month}', '05/06', '4/3' ];

    for (int i = 0; i< noteValues.length; i++ ){
      for( int j=0; j< _dateValues.length; j++ ) { 
        reminder = ReminderCreator();
        reminder.process('Test ${_dateValues[j]} ${noteValues[i]}');
        performTests( 'Test', null, noteValues[i], true, null , null,  defEventDur );
        
        switch ( j ) {
          case 0:  
            performStartDateTest( reminder.getStartDate() , 10, 12 );

            break; 
          case 1:
            performStartDateTest(reminder.getStartDate(), _now.day, _now.month); 

            break; 
          case 2: 
            // double digits with trailing zeros 
            performStartDateTest( reminder.getStartDate() , 5, 6 );

            break;
          case 3:
            performStartDateTest( reminder.getStartDate() , 4, 3 );

            break;

          default: 
            // nothing 

        }
    
      }
    } 

    List _years = ['2023', '23'];
    for (int i = 0; i < _years.length; i++){
      reminder = ReminderCreator();
      reminder.process('Test me 16/11/${_years[i]}');
      expect(reminder.getStartDate().day == 16, true);
      expect(reminder.getStartDate().month == 11, true);
      expect(reminder.getStartDate().year == 2023, true);
    }
  } );

  test('Reminder creator - NLP specific date - to be set in following year ', () {

    for (int i = 0; i< noteValues.length; i++ ){
      for(int j=0; j<janValues.length ; j++ ){ 
        reminder = ReminderCreator();
        reminder.process('Test 1 ${janValues[j]} ${noteValues[i]}');
        performTests( 'Test', null, noteValues[i], true, true , null,  defEventDur );
        
        expect(reminder.getStartDate().day == 1, true );
        expect(reminder.getStartDate().month == 1, true );
        if ( _now.month !=1 && _now.day != 1 ) {
          expect(reminder.getStartDate().year == _now.year + 1 , true );

          expect(_now.compareTo(reminder.getStartDate()) < 0, true );
        }
      }
    }

  } );

  test('Reminder creator - NLP specific day/month pair identical to today - to be set in 1 year from now ', () {
    
    // default values  for a start . They will be updated later 
    String _month = 'January';
    int? _monthInt = 1; 

    for( var k in AppConstants.monthsToNumber.keys  ){
      if ( _now.month == AppConstants.monthsToNumber[k]){
        _month = k;
        _monthInt = AppConstants.monthsToNumber[k]; 
      }
    }

    for (int i = 0; i< noteValues.length; i++ ){
      reminder = ReminderCreator();
      reminder.process('Test ${_now.day} $_month ${noteValues[i]}');
      performTests( 'Test', null, noteValues[i], true, true , null,  null );
      
      expect(reminder.getStartDate().day == _now.day, true );
      expect(reminder.getStartDate().month == _monthInt, true );
      
      expect(reminder.getStartDate().year == _now.year + 1, true );
    }

  } );

    test('Reminder creator - NLP specific date with year 2099 or 99 ', () {

    for (int i = 0; i < noteValues.length; i++ ){
      for (int j = 0 ; j < aprValues.length; j++) {
        for (int k = 0; k < yearValues.length; k++) { 
          reminder = ReminderCreator(); 
          reminder.process( '$desc 6 ${aprValues[j]} ${yearValues[k]} ${noteValues[i]}' );
          performTests( desc, null, noteValues[i], true, true , null,  null );
          
          expect(reminder.getStartDate().day == 6, true );
          expect(reminder.getStartDate().month == 4, true );
          expect(reminder.getStartDate().year == 2099, true );
        }
      }
    }
   
  } );

  test('Reminder creator - NLP specific date with time EU before year ', () {

    for (int i = 0; i< noteValues.length; i++ ){
      for (int j=0 ; j<aprValues.length; j++){
        for (int k =0; k<yearValues.length; k++) {  
          reminder = ReminderCreator();

          reminder.process('$desc 13:45 6 ${aprValues[j]} ${yearValues[k]} ${noteValues[i]}');
          
          performTests(desc, 0, noteValues[i], false, true , null,  const Duration(minutes: 45) );

          expect(reminder.getStartDate().day == 6, true );    
          expect(reminder.getStartDate().month == 4, true );
          expect(reminder.getStartDate().year == 2099, true );
          expect(reminder.getStartDate().hour == 13, true );
          expect(reminder.getStartDate().minute == 45, true );

          expect( reminder.getStartDate().add(Duration(hours: 1)).hour == reminder.getEndDate().hour , true); 
          expect(reminder.getEndDate().minute == 30, true ); 
        }
      }
    }
  } );

  test('Reminder creator - NLP specific date with year and time EU ', () {

    for (int j=0 ; j<aprValues.length; j++){
      reminder = ReminderCreator();

      reminder.process('$desc 6 ${aprValues[j]} 2099 13:45 $note');
      
      performTests(desc, 0, note, false, true , null,  const Duration(minutes: 45) );

      expect(reminder.getStartDate().day == 6, true );    
      expect(reminder.getStartDate().month == 4, true );
      expect(reminder.getStartDate().year == 2099, true );
      expect(reminder.getStartDate().hour == 13, true );
      expect(reminder.getStartDate().minute == 45, true );

      expect( reminder.getStartDate().hour + 1 == reminder.getEndDate().hour , true); 
      expect(reminder.getEndDate().minute == 30, true );
    } 
  } );

  test('Reminder creator - NLP specific date with year and time US am ', () {
    
    List _times = <String>[ '01:45am', '01:45 am'];

    for (int j=0 ; j< aprValues.length; j++){
      for (int i=0; i < _times.length; i++) {
        reminder = ReminderCreator();

        reminder.process('$desc 6 ${aprValues[j]} 2099 ${_times[i]} $note');
        performTests(desc, 0, note, false, true , null, const Duration(minutes: 45) );
        
        expect(reminder.isAllDay(), false);
        expect(reminder.getStartDate().day == 6, true );
        expect(reminder.getStartDate().month == 4, true );
        expect(reminder.getStartDate().year == 2099, true );
        expect(reminder.getStartDate().hour == 1, true );
        expect(reminder.getStartDate().minute == 45, true );
      }   
    }
  } );

  test('Reminder creator - NLP specific date with year and time US am space', () {
    
    reminder = ReminderCreator();

    reminder.process('$desc 6 may 2099 01:45 am $note');
    performTests(desc, 0, note, false, true , null, const Duration(minutes: 45) );
    
    expect(reminder.getStartDate().day == 6, true );
    expect(reminder.getStartDate().month == 5, true );
    expect(reminder.getStartDate().year == 2099, true );
    expect(reminder.getStartDate().hour == 1, true );
    expect(reminder.getStartDate().minute == 45, true );
   
  } );

  test('Reminder creator - NLP specific date with year and time US pm ', () {
    
    List startDate = [
      '6 may 2099 01:45pm',
      '6 may 2099 at 01:45pm',
      '01:45pm 6 may 2099',
      'at 01:45pm 6 may 2099'
      ];

    for (int i = 0; i< startDate.length; i++) {
      reminder = ReminderCreator();

      reminder.process( '$desc ${startDate[i]} $note' );
      performTests(desc, 0, note, false, true , null,  Duration(minutes: 45) );
      
      expect(reminder.getStartDate().day == 6, true );
      expect(reminder.getStartDate().month == 5, true );
      expect(reminder.getStartDate().year == 2099, true );
      expect(reminder.getStartDate().hour == 13, true );
      expect(reminder.getStartDate().minute == 45, true );
    }
  } );

  test('Reminder creator - NLP specific date with year and time US pm space ', () {
    
    reminder = ReminderCreator();

    reminder.process( '$desc 6 may 2099 01:45 pm $note' );
    performTests(desc, 0, note, false, true , null,  Duration(minutes: 45) );
    
    expect(reminder.getStartDate().day == 6, true );
    expect(reminder.getStartDate().month == 5, true );
    expect(reminder.getStartDate().year == 2099, true );
    expect(reminder.getStartDate().hour == 13, true );
    expect(reminder.getStartDate().minute == 45, true );
   
  } );

  test('Reminder creator - NLP specific date (no year) with time', () {
    
    reminder = ReminderCreator();

    reminder.process( '$desc 26 dec 13:45 $note' );
    performTests(desc, 0, note, false, true , null,  Duration(minutes: 45) );
    
    expect(reminder.getStartDate().day == 26, true );
    expect(reminder.getStartDate().month == 12, true );

    // TODO add year check 
    expect(reminder.getStartDate().hour == 13, true );
    expect(reminder.getStartDate().minute == 45, true );
  } );

  
  test('Reminder creator - missing space before minutes makes everything description ... ', () {
    
    reminder = ReminderCreator();

    String input = '$desc${minutes.toString()} $note';
    reminder.process(input);
    
    expect(reminder.getDesc(), input);
    expect(reminder.getDuration().inMinutes, 0);
    expect(reminder.getNote(), '');

    expect(reminder.getStartDate().year == 1980, true);
    expect(reminder.isAllDay(), false);
  } );

  test('Reminder creator - missing space after minutes makes everything description ... ', () {
    
    reminder = ReminderCreator();

    String input = '$desc ${minutes.toString()}$note';
    reminder.process(input);
    
    expect(reminder.getDesc(), input);
    expect(reminder.getDuration().inMinutes, 0);
    expect(reminder.getNote(), '');

    expect(reminder.getStartDate().year == 1980, true);
    expect(reminder.isAllDay(), false);
  } );

    test('Reminder creator - one parameter - numeric only that gets as description the default value ... ', () {
    
    reminder = ReminderCreator();

    reminder.process(minutes.toString());
    performTests( AppConstants.defaultEmptyDescription, minutes, '', false, true , 
                    Duration( minutes: minutes),  Duration(minutes: 45) );

  } );

  test('Reminder creator - only description - zero default timer ... ', () {
    
    reminder = ReminderCreator();

    reminder.process(desc);
    
    expect(reminder.getDesc(), desc);
    expect(reminder.getDuration().inMinutes, 0);
    expect(reminder.getNote(), '');

  } );

  test('Reminder creator - only description with leading and trailing space ... ', () {
    
    reminder = ReminderCreator();

    reminder.process( ' $desc ' );
    
    expect(reminder.getDesc(), desc);
    expect(reminder.getDuration().inMinutes, 0);
    expect(reminder.getNote(), '');

  } );

  test('Reminder creator - only description - default time force-enabled [not implemented yet for UI] ... ', () {
    
    reminder = ReminderCreator();
    reminder.enableDefaultTimer();

    reminder.process( ' $desc ');
    performTests( desc, AppConstants.defaultAlert, '', false, true , 
                    Duration(minutes: AppConstants.defaultAlert),  Duration(minutes: 45) );

  } );

  test('Reminder creator - time EU after lunch - 1 day 00:00 ', () {

    String suppliedTime = '00:00';
    DateTime _now = DateTime.now();
  
    reminder = ReminderCreator();
    //reminder.enableDefaultTimer();

    reminder.process( '$desc 1 day $suppliedTime $note');
    
    performTests( desc, null, note, false, true , null, const Duration(minutes: 45) );
    
    expect(reminder.getSuppliedTime24h() , suppliedTime);

    expect(reminder.getStartDate().hour == 0, true);
    expect(reminder.getStartDate().minute == 0, true);
    
    if ( 3 <= reminder.getStartDate().day && reminder.getStartDate().day <=28  ){
      expect(reminder.getStartDate().day - _now.day == 1 , true);  
    }

  } );

    test('Reminder creator - time EU after lunch - 1 week 00:00 ', () {

    String suppliedTime = '00:00';
    DateTime _now = DateTime.now();
  
    reminder = ReminderCreator();
//    reminder.enableDefaultTimer();

    reminder.process( '$desc 1 week $suppliedTime $note');
    performTests( desc, null, note, false, true , null, const Duration(minutes: 45) );
    
    expect(reminder.getSuppliedTime24h() , suppliedTime);

    DateTime _todaySameTime = DateTime(  _now.year, _now.month, _now.day, 0, 0) ;
    // DateTime _days7_midnight = DateTime( _days7.year, _days7.month, _days7.day, 0, 0 ); 

    expect(reminder.getStartDate().difference(_todaySameTime).inDays == 7, true  );

    // if ( 8 <= reminder.getStartDate().day && reminder.getStartDate().day <=28  ){
    //   expect(reminder.getStartDate().day - _now.day == 7 , true);  
    // }

  } );

  test('Reminder creator - time EU after lunch - 2 years 00:00 ', () {

    String suppliedTime = '00:00';
    DateTime _now = DateTime.now();
  
    reminder = ReminderCreator();

    reminder.process( '$desc 2 years $suppliedTime $note');
    performTests( desc, null, note, false, true , null,  Duration(minutes: 45) );
    
    expect(reminder.getSuppliedTime24h() , suppliedTime);

    expect(reminder.getStartDate().year - _now.year == 2 , true);  

  } );

  test('Reminder creator - time EU after lunch - 17:00 ', () {

    String suppliedTime = '17:00';
  
    reminder = ReminderCreator();

    reminder.process( '$desc $suppliedTime $note');
    performTests( desc, null, note, false, true , null, const Duration(minutes: 45) );
    
    expect(reminder.getSuppliedTime24h() , suppliedTime);

  } );

  test('Reminder creator - time EU - 00:00 ', () {

    String suppliedTime = '00:00';
  
    reminder = ReminderCreator();

    reminder.process( '$desc $suppliedTime $note');
    performTests( desc, null, note, false, true , null, const Duration(minutes: 45) );
    
    expect(reminder.getSuppliedTime24h() , suppliedTime);

  } );

  test('Reminder creator - time EU - 08:15 ', () {

    String suppliedTime = '08:15';
  
    reminder = ReminderCreator();

    reminder.process( '$desc $suppliedTime $note');
    performTests( desc, null, note, false, true , null, const Duration(minutes: 45) );
    
    expect(reminder.getSuppliedTime24h() , suppliedTime);

  } );

    test('Reminder creator - time US - 08:15am ', () {

      String suppliedTime = '08:15am';
    
      reminder = ReminderCreator();

      reminder.process( '$desc $suppliedTime $note');
      performTests( desc, null, note, false, true , null, const Duration(minutes: 45) );
      
      expect(reminder.getSuppliedTime24h() , '08:15');

  } );

  test('Reminder creator - time US with space - 08:15 am ', () {

    String suppliedTime = '08:15 am';
  
    reminder = ReminderCreator();

    reminder.process( '$desc $suppliedTime $note');
    performTests( desc, null, note, false, true , null, const Duration(minutes: 45) );
    
    expect(reminder.getSuppliedTime24h() , '08:15');

  } );

  test('Reminder creator - time US - 08:15pm ', () {

    String suppliedTime = '08:15pm';
    reminder = ReminderCreator();

    reminder.process( '$desc $suppliedTime $note');
    performTests( desc, null, note, false, true , null,  Duration(minutes: 45) );

    expect(reminder.getSuppliedTime24h() , '20:15');

  } );

 /**  test('Time parsing with : DateTime parsing understanding ', (){
    DateTime moonLanding = DateTime.parse('1969-07-08 20:18'); // 8:18pm
    expect(moonLanding.month, 7);
    expect(moonLanding.day, 8);

    moonLanding = DateTime.parse('1969-07-08 20:18'); // 8:18pm
    expect(moonLanding.month, 7);
    expect(moonLanding.day, 8);

    // moonLanding = DateTime.parse('08-07-1969 20:18:04Z'); // 8:18pm
    // expect(moonLanding.month, 7);
    // expect(moonLanding.day, 8);

    // moonLanding = DateTime.parse('8/7/1969 20:18:04Z'); // 8:18pm
    // expect(moonLanding.month, 7);
    // expect(moonLanding.day, 8);

    // moonLanding = DateTime.parse('20:18:04Z 8-7-1969'); // 8:18pm
    // expect(moonLanding.month, 7);
    // expect(moonLanding.day, 8);
    // expect(moonLanding.hour, 20);
  });
  */ 
}

