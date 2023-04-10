import 'package:one_liner_entry/app_constants.dart';
import 'package:one_liner_entry/string_parser_utilities.dart';

class ReminderCreator{

  /// The reminder's description. 
  /// Default: in AppConstants 
  /// TODO: configurable in the app 
  String desc = '';

  /// Optional note for the generated event / reminder  
  String note ='';

  /// upper case the string token for reviewing it
  String _tokenUC = '';

  /// An event can benefit from an alert
  /// Default: AppConstants 30 
  /// TODO: Configurable and allow input  
  int _alert = AppConstants.defaultAlert;

  /// A weekend event can benefit from a special alert
  /// Default: AppConstants 30 
  /// TODO: Configurable and allow input  
  // int _secondAlert = AppConstants.defaultAlertHoursForWeekendEvents.inHours;

  /// Stores the optionally-supplied target time. 
  DateTime _timeSupplied = DateTime(1980);

  /// Stores the optionally-supplied end target time. 
  DateTime _endTimeSupplied = DateTime(1980);

  /// Stores the optionally-supplied target time.
  /// Default: configurrable TODO
  Duration _eventDuration = Duration( minutes: AppConstants.defaultEventDurationInMinutes );

  /// AM
  static const String _am = 'AM';
  /// PM
  static const String _pm = 'PM';

  List<String> timeIdentifiersUS = [_am, _pm];

  /// For start clock time or value
  bool hasStartTimeBeenIdentified = false;
  //hasTimeBeenIdentified

  /// For start date 
  bool hasStartDateBeenIdentified = false;

  /// For days relevant to today: today, yesterday, Monday etc. 
  int suppliedRelevantDayIndex = -1; 

  /// By default an integer count / numeric target DateTime does not exist 
  int suppliedTargetTimeIndex = -1;

  /// By default a PM / AM US after time does not exist 
  int suppliedTargetUSIndex = -1;

  /// By default a month literal does not exist 
  int suppliedMonthIndex = -1;

  /// By default a year literal does not exist 
  int suppliedYearIndex = -1;

  /// The app will not have a default number of minutes to be used for reminders - it's like a backlog / for review.
  /// It is possible for the user though to change the behaviour and automatically set target time  
  /// by enabling the following WHEN the app will support it as a configurrable option.
  /// TODO Roadmap 
  bool useDefaultTimer = false;

  /// Ignore supplied time when X minutes or hours have been passed 
  bool specialSuppliedUnitProcessed = false;

  /// when only dates are passed, do not use the time / hours from DateTime.now() - make it an all day entry
  bool isAllDayEntry = false;

  /// Suppress default alerts by using special keywords 
  bool _disableAlert = false;

  /// Saves the 
  bool isWeekendPeriodAllDay = false; 

  /// Saves the time distance from now - future. Eg. X minutes / Days / weeks / months / years 
  Duration _dur = const Duration( minutes: 30);

  /// If a day has not been set, this is their default value in the past, more than 10 years ago
  int ignoreDayInThePast = - 50000;


  List<int> ignoreTokensAtPosition = <int>[];

  List<String> _tokens = [];
  DateTime _tempNow = DateTime.now();

  void enableDefaultTimer(){
    useDefaultTimer = true;
  }
  void disableDefaultTimer(){
    useDefaultTimer = false;
  }

  String getDesc(){ 
    return desc; 
  }

  String getNote(){ 
    return note; 
  }

  /// If only date has been specified 
  bool isAllDay(){
    return isAllDayEntry;
  }

  bool isLeapYear(int year){

    return (year % 4 == 0 && year % 100 != 0 ) || year % 400 == 0 ;

  }

  /// Leap Years have one extra day. When a future date is calculated, then this need to be kept in mind 
  int extraDaysForFinalYear(int yearsInFuture){
    int leapDays = 0;
    DateTime now = DateTime.now();
    int currentYear = now.year;
  
    // add to leap Days this year's day if current month is less than March and the day is max Feb 28th 
    if (  ( (now.day <32 && now.month == 1 ) || ( now.day < 29 && now.month == 2 ) ) && isLeapYear( currentYear ) ) { 
      leapDays = leapDays + 1;
    } 

    for ( int i = 0; i < yearsInFuture; i++){
      if ( isLeapYear( currentYear + i + 1) ) {
        leapDays = leapDays + 1;
      }
    } 
    return leapDays;

  }

  /// Returns HH:MM
  String getSuppliedTime24h(){
    int hours = _timeSupplied.hour;
    int minutes = _timeSupplied.minute;
    String _hours = hours < 10 ? '0$hours' : '$hours'; 
    String _minutes = minutes < 10 ? '0$minutes' : '$minutes'; 

    return '$_hours:$_minutes'; 
  }

  DateTime getStartDate() { 

    return _timeSupplied;
  }

  DateTime getEndDate() {

    return _endTimeSupplied;
  }

  Duration getEventDuration() {
    return _eventDuration;
  }

  /// Returns the time in the future this event should be created 
  Duration getDuration(){ 
    return _dur; 
  }

  /// The number of minutes before the due time of the Start of the event 
  int getAlert() { 
    return _alert;
  }

  bool isAlertSuppressed(){
    return _disableAlert;
  }

  /// Returns the number of days to add to the _start week day so that the outcome is _end week day in the future
  static int daysToAdd(int _start, int _end){
    
    if ( _end == _start){
      // for example both are Tuesdays , then a week from today 
      return 7;
    }
    else if (_end > _start ) {
      // for example start is Mon 1 , and end Tue 2, then one day, simple subtraction 
      return _end - _start;
    }
    
    // default. For example start is Wednesday 3, end is Tuesday 2 , we want 6 days, that's 7 - (3 - 2 )
    return 7 - (_start - _end); 
  }

  int daysToAddFromLiterals(String _val){

    // check if we are dealing with specific week day
    if ( AppConstants.weekDaysShortToInt.containsKey( _val )) {
      if (desc.endsWith(' on')){
        desc = desc.substring(0 , desc.length - 3);
      }
      return daysToAdd( _tempNow.weekday, AppConstants.weekDaysShortToInt[ _val ] as int);  
    }
    
    if ( AppConstants.weekDaysToInt.containsKey( _val )) {
      if (desc.endsWith(' on')){
        desc = desc.substring(0 , desc.length - 3);
      }
      return daysToAdd( _tempNow.weekday, AppConstants.weekDaysToInt[ _val ] as int);  
    }

    if ( _val ==  'WEEK' ) {
      return daysToAdd( _tempNow.weekday, AppConstants.weekDayForNextWeek );  
    }

    // default 
    return 0;
  }

  void updateValuesBasedOnRelevantDate( int _index ){

    String _nextTokenUC = _index + 1 <= _tokens.length - 1 ? _tokens[_index + 1].toUpperCase() : '';

    ignoreTokensAtPosition.add(_index);

    // default - never - more than 10 years in the past  
    int dayDiff = ignoreDayInThePast; 

    isWeekendPeriodAllDay = AppConstants.weekendLiterals.contains( _tokenUC ) ? true: false;
    
    if ( <String>['TODAY', 'TOD'].contains( _tokenUC ) ){ 
      dayDiff = 0;
    } else if ( <String>['TOMORROW', 'TOM'].contains( _tokenUC ) ){ 
      dayDiff = 1;
    }else if ( _tokenUC == 'YESTERDAY'){
      dayDiff = -1;
    }
    else if ( AppConstants.monthsShortToNumber.containsKey( _tokenUC ) || AppConstants.monthsToNumber.containsKey( _tokenUC ) ) {
      // default value 
      int _yearToUse = _tempNow.year;

      int _specifiedMonth = AppConstants.monthsShortToNumber.containsKey( _tokenUC ) ?
                              ( AppConstants.monthsShortToNumber[ _tokenUC ] ) as int
                              : ( AppConstants.monthsToNumber[ _tokenUC ] ) as int;

      if ( StringParserUtilities.isValidInteger( _nextTokenUC ) && (_nextTokenUC.length == 4 || _nextTokenUC.length == 2) && int.parse( _nextTokenUC ) > 0 ){
        // if 2-digits year, enhance it
        _yearToUse = _nextTokenUC.length == 4 ? int.parse( _nextTokenUC ) : int.parse( _nextTokenUC ) + 2000;
        suppliedYearIndex = _index + 1;
      }
      else if( ( _tempNow.month >= _specifiedMonth ) ) { 
        _yearToUse++; 
      }

      if ( hasStartTimeBeenIdentified ) { 
        _timeSupplied = DateTime( _yearToUse, _specifiedMonth, 1, _timeSupplied.hour, _timeSupplied.minute ); 
      }
      else {
        _timeSupplied = DateTime( _yearToUse, _specifiedMonth, 1 ); 
        isAllDayEntry = true;
      }
      hasStartDateBeenIdentified = true;

      return; 
    }
    else if ( <String>['NEXT', 'FOLLOWING'].contains( _tokenUC ) ){

      if ( _nextTokenUC == 'MONTH'){

        int _targetMonth = _tempNow.month == 12 ? 1 : _tempNow.month + 1; 
        int _targetYear = _tempNow.month == 12 ? _tempNow.year + 1 : _tempNow.year ; 

        if ( hasStartTimeBeenIdentified ) { 
          _timeSupplied = DateTime( _targetYear, _targetMonth, 1, _timeSupplied.hour, _timeSupplied.minute ) ;        
        } 
        // else this is a an all Day event - specify new time Supplied DateTime 
        else {
          // for next month - easy - set 1st of next month and return 
          _timeSupplied = DateTime( _targetYear, _targetMonth, 1 );
          isAllDayEntry = true;
        }
        ignoreTokensAtPosition.add(_index + 1);
        // required so that next token is used for note
        hasStartDateBeenIdentified = true;
        return; 
      }
      else if ( _nextTokenUC == 'YEAR' ){
        // for next year - easy - set 1st of Jan and return 

        // use the supplied time if already defined 
        if ( hasStartTimeBeenIdentified ) { 
          _timeSupplied = DateTime( _tempNow.year + 1, 1, 1, _timeSupplied.hour, _timeSupplied.minute);

        }
        // else this is a an all Day event - specify new time Supplied DateTime 
        else {
          _timeSupplied = DateTime( _tempNow.year + 1, 1, 1 );
          isAllDayEntry = true;
        }
        ignoreTokensAtPosition.add(_index + 1);
        // required so that next token is used for note
        hasStartDateBeenIdentified = true;
        return; 
      }
      else if ( AppConstants.monthsShortToNumber.containsKey( _nextTokenUC ) || AppConstants.monthsToNumber.containsKey( _nextTokenUC ) ) {
        int _yearToUse = _tempNow.year + 1;
        int _specifiedMonth = AppConstants.monthsShortToNumber.containsKey( _nextTokenUC ) ?
                                  ( AppConstants.monthsShortToNumber[ _nextTokenUC ] ) as int
                                  : ( AppConstants.monthsToNumber[ _nextTokenUC ] ) as int;
        if( ( _tempNow.month >= _specifiedMonth ) ) { 
          _yearToUse++; 
        }

        if ( hasStartTimeBeenIdentified ) { 
          _timeSupplied = DateTime( _yearToUse, _specifiedMonth, 1, _timeSupplied.hour, _timeSupplied.minute ); 
        }
        else {
          _timeSupplied = DateTime( _yearToUse, _specifiedMonth, 1 ); 
          isAllDayEntry = true; 
        }
        hasStartDateBeenIdentified = true;

        ignoreTokensAtPosition.add( _index + 1 );
        return;
      }
      
      // check for weekdays-combo difference aka. next Wednesday - has to be greater than zero 
      int _x = daysToAddFromLiterals( _nextTokenUC );

      if ( _x > 0 ){
        dayDiff = _x + 7;
        ignoreTokensAtPosition.add(_index + 1);  
        
        if ( AppConstants.weekendLiterals.contains( _nextTokenUC ) ) {
          isWeekendPeriodAllDay = true;
        }
      }

    }
    else {
      // check for weekdays difference - has to be greater than zero 
      int _t = daysToAddFromLiterals( _tokenUC );
      if ( _t > 0 ){
        dayDiff = _t;  
      }
      if ( AppConstants.weekendLiterals.contains( _tokenUC ) ) {
          isWeekendPeriodAllDay = true;
      }
    }

    // if a value has been identified
    if ( dayDiff > ignoreDayInThePast) {
      DateTime _temp = _tempNow.add(Duration(days: dayDiff));

      // if time was already identified and this is not a weekend, use it    
      if ( hasStartTimeBeenIdentified && !isWeekendPeriodAllDay) { 
        _timeSupplied = DateTime( _temp.year, _temp.month, _temp.day, _timeSupplied.hour, _timeSupplied.minute ) ; 
        
      } 
      // else this is a an all Day event - specify new time Supplied DateTime 
      else {
        _timeSupplied = DateTime( _temp.year, _temp.month , _temp.day ) ;
        
        if ( isWeekendPeriodAllDay ) {
          _endTimeSupplied = _timeSupplied.add( const Duration(days: 1 )); 
        }

        isAllDayEntry = true;
      }
      // required so that next token is used for note
      hasStartDateBeenIdentified = true; 
    }

  }



  /// review cases: H HH HHMM 0HMM HMM HHMMam HHMMpm 
  bool isNextTokenTime( int processedIndex ) {
    // if there is one more token
    if (processedIndex < _tokens.length - 1 ){
      
      var _tokenUC = _tokens[ processedIndex +1].toUpperCase();

      // max length 6, so if longer return false 
      if (_tokenUC.length > 6 ) { return false; }

      if ( _tokenUC.endsWith(_am) || _tokenUC.endsWith(_pm)) { 
        _tokenUC = _tokenUC.substring(0, _tokenUC.length - 2);
      }

      if ( StringParserUtilities.isValidInteger( _tokenUC ) ) {
        var _int = int.parse( _tokenUC ); 

        switch ( _tokenUC.length ) {
          case 1: 
            // all good - acceptable
            return true;
          case 2: 
            // max value 23 , else fail 
            return  (_int > 23 ? false: true ); 
          case 3: 
            // last two digits are minutes, so first one is hours, therefore max 959
            return  (_int > 959 ? false: true );
          case 4: 
            // max is 2359 for 24 hours format or 1159 for 12 hours format
            return  (_int > 2359 ? false: true ); 
        }
      
      }

      // the following might be needed if parseInt fails to remove the leading 0 when converting to Integer
      // if ( _token.length == 4 && _token.substring(0, 1) == 0 ) {
      //   _token = _token.substring(1); 
      // }

      
    }

    return false; 
  }

  void addIdentifiedTimeToStartDateTime( int _hours , int _minutes ) {

    // if the DateTime object has not been initialised yet, simply put the hours and minutes accordingly 
    if ( _timeSupplied.year == 1980) {

      _timeSupplied = DateTime( _tempNow.year, _tempNow.month, _tempNow.day, _hours, _minutes );    

      // if the current hours' value is greater than the supplied one
      //   or if ( hours are equal and current minutes are more or equal than supplied ones) then add one day
      if ( _tempNow.hour > _timeSupplied.hour  
          || ( _tempNow.hour == _timeSupplied.hour && _tempNow.minute >= _timeSupplied.minute) ) {
        _timeSupplied = _timeSupplied.add( const Duration(days: 1) );
      }
    }
    else{
      
      _timeSupplied = DateTime( _timeSupplied.year, _timeSupplied.month, _timeSupplied.day, _hours, _minutes);   
    }
    isAllDayEntry = false;
  }

 
  void processComboWithSlash( int _index ) {
    bool isUsStyle = _tokenUC.contains('//');

    var _dateTokens = _tokenUC.replaceAll('//', '/').split('/');
    var _len = _dateTokens.length;

    // ensure they are all integers
    if ( 4 > _len && _len > 1) {
      int _first = 0; 
      int _second = 0;

      int _monthToUse = 0;
      int _dayToUse = 0; 
      int _yearToUse = 0 ;

      for ( int i = 0; i < _len ; i++ ){
        if ( StringParserUtilities.isValidInteger( _dateTokens[i] ) ){
          
          switch ( i ) { 
            case 0: 
              _first = int.parse( _dateTokens[i]);
              break; 
            case 1: 
              _second = int.parse( _dateTokens[i]);
              break;
            case 2: 
              _yearToUse = int.parse( _dateTokens[i]);
              break;
          }
        }
      }

      // if the year was in two digits format
      if ( _first > 0 && _second > 0 && _yearToUse > 0 && _yearToUse < 100 ){ _yearToUse = _yearToUse + 2000; }

      if ( _first > 0 && _second > 0){
        if (isUsStyle) {
          _dayToUse = _second;
          _monthToUse = _first;
        }
        else {
          _monthToUse = _second;
          _dayToUse = _first;
        }

        if ( _yearToUse == 0 ) {
          // if ( identical months and day less or equal to today) or month less than current one, future year 
          if ( (_monthToUse == _tempNow.month && _dayToUse <= _tempNow.day) || _monthToUse < _tempNow.month) {
            _yearToUse = _tempNow.year + 1 ; 
          }
          else {
            _yearToUse = _tempNow.year;
          }
        }

        if ( hasStartTimeBeenIdentified ){ 
          _timeSupplied = DateTime( _yearToUse, _monthToUse, _dayToUse, _timeSupplied.hour, _timeSupplied.minute); 
        }
        else {
          _timeSupplied = DateTime( _yearToUse, _monthToUse, _dayToUse );
          isAllDayEntry = true; 
        }
        hasStartDateBeenIdentified = true;

        ignoreTokensAtPosition.add(_index); 

      }

    }
  }

  void process(String input){
    // initialisation 
    desc = '';
    note = '';

    int _minutes = useDefaultTimer ? AppConstants.defaultAlert : 0;
    
    _dur = Duration( minutes :  _minutes);

    // trim the string before converting it to a list 
    List<String> _tempTokens = input.trim().split(" ");
    
    for ( int i = 0; i < _tempTokens.length; i++ ) {
      if (_tempTokens[i].trim() != '' ){
        // Only process the trimmed values that are not empty space
        _tokens.add( _tempTokens[i].trim() );
      }
    }
 
    hasStartTimeBeenIdentified = false;
    hasStartDateBeenIdentified = false; 

    suppliedTargetTimeIndex = -1;
    suppliedTargetUSIndex = -1;
    suppliedMonthIndex = -1;
    suppliedYearIndex = -1;
    suppliedRelevantDayIndex = -1;

    _tempNow = DateTime.now();

    // special processing for due time and date, and am/pm
    bool isThisDueTimeToken; 

    // Iterate the tokens to identify literal and numeric tokens 
    // Everything before the numeric token will be the reminder description
    for ( int i = 0; i < _tokens.length; i++ ) {

      _tokenUC = _tokens[i].toUpperCase();

      // assume this is a valid word / token for description or note or other string fields 
      isThisDueTimeToken = false; 

      // if it's one of the 'at HHMM' supported combos
      if ( AppConstants.timePrequel.contains( _tokenUC ) && isNextTokenTime( i ) && !hasStartTimeBeenIdentified ) {
        isThisDueTimeToken = true;
        hasStartTimeBeenIdentified = true;

        ignoreTokensAtPosition.add( i + 1 );

        var _timeTokenUC = _tokens[i + 1].toUpperCase(); 

        // if it ends with PM store this detail
        bool isPMTime = _timeTokenUC.endsWith(_pm);

        // alternatively it might be a separate token but only check if the identified time token didn't end with AM or PM
        if( ( !( _timeTokenUC.endsWith(_am) ) && !( _timeTokenUC.endsWith(_pm) ) ) 
                && _tokens.length - i > 2 
                && ( _tokens[i + 2].toUpperCase().compareTo(_am) == 0 || _tokens[i + 2].toUpperCase().compareTo(_pm) == 0) ) {
            
            isPMTime =  _tokens[i + 2].toUpperCase().compareTo(_pm) == 0 ;
            
            // ignore the processed AM/PM token
            ignoreTokensAtPosition.add( i + 2 );
        }

        _timeTokenUC = _timeTokenUC.replaceAll(_am, '').replaceAll(_pm, '');

        int _hours = 0;
        int _minutes = 0;

        int _timeLen = _timeTokenUC.length;
        switch ( _timeLen ) { 
          
          // H 
          case 1:

            _hours = int.parse( _timeTokenUC ); 
            break;

          // HH eg. 12
          case 2: 

            _hours = int.parse( _timeTokenUC ); 
            break;

          // HMM eg. 630
          case 3: 

            _hours = int.parse( _timeTokenUC.substring(0,1) ); 
            _minutes = int.parse( _timeTokenUC.substring(1) ); 
            break;

          // HH eg. 1345
          case 4: 

            _hours = int.parse( _timeTokenUC.substring(0,2) ); 
            _minutes = int.parse( _timeTokenUC.substring(2) ); 
            break;

        }

        if ( isPMTime && _hours < 13 ) { _hours = _hours + 12;  }

        addIdentifiedTimeToStartDateTime( _hours, _minutes );

      }

      // if it's a numeric token and it wasn't processed earlier 
      // Boil egg 5
      // Birthday 1 Jan 1980 
      else if ( StringParserUtilities.isValidInteger( _tokens[i] ) && int.parse( _tokens[i] ) > 0 && suppliedYearIndex != i ) {

        // either an integer (for some unit or mm for month)

        // identify now if there is at least one more token and it is a month literal and process it accordingly
        if( _tokens.length - (i + 1) > 0 && !hasStartDateBeenIdentified
                  && ( AppConstants.monthsShortToNumber.containsKey( _tokens[i+1].toUpperCase() ) 
                      || AppConstants.monthsToNumber.containsKey( _tokens[i+1].toUpperCase() ) ) 
                  ) {

          isThisDueTimeToken = true;

          int _specifiedMonth = AppConstants.monthsShortToNumber.containsKey( _tokens[i+1].toUpperCase() ) ?
                                  ( AppConstants.monthsShortToNumber[ _tokens[i+1].toUpperCase() ] ) as int
                                  : ( AppConstants.monthsToNumber[ _tokens[i+1].toUpperCase() ] ) as int;
          
          // save the index to skip it in the future 
          suppliedMonthIndex = i + 1; 
          ignoreTokensAtPosition.add( i + 1 );

          int _specifiedDay = int.parse( _tokens[i] );

          // default behaviour - use current year if not one set
          int _yearToUse = _tempNow.year; 

          // check if there is a token after the month and it is a valid year value (2 or 4 digits)
          // in which case use it. 
          if ( _tokens.length - (i + 2) > 0 
            && ( _tokens[ i + 2 ].length == 4 || _tokens[ i + 2 ].length == 2)
            && StringParserUtilities.isValidInteger( _tokens[ i + 2 ] ) 
            // safety check for 00 year 
            && int.parse(_tokens[ i + 2 ]) > 0 ) {

            // if 2-digits year, enhance it
            _yearToUse = _tokens[ i + 2 ].length == 4 ? int.parse(_tokens[ i + 2 ]) : int.parse(_tokens[ i + 2 ]) + 2000;
            suppliedYearIndex = i + 2;  
            ignoreTokensAtPosition.add( i + 2 );
           
          }

          else 
            // no year has been supplied, therefore ensure that this entry is for the future, not past month or day this year
            if( (_tempNow.month > _specifiedMonth ) 
                  || ( _tempNow.month == _specifiedMonth && _tempNow.day >=  _specifiedDay) ) { 
              _yearToUse++; 
          }

          // if time was already identified, use it
          if ( hasStartTimeBeenIdentified ) { 
            _timeSupplied = DateTime( _yearToUse, _specifiedMonth, _specifiedDay, _timeSupplied.hour, _timeSupplied.minute ) ; 
            hasStartDateBeenIdentified = true;
            
          } 
          // else this is a an all Day event - specify new time Supplied DateTime 
          else {
            _timeSupplied = DateTime( _yearToUse, _specifiedMonth, _specifiedDay ) ; 
            isAllDayEntry = true;
            // required so that next token is used for note
            hasStartDateBeenIdentified = true; 
          }        

        }
        else {
          // only process the numeric value if a start time has not already been set
          if ( !hasStartTimeBeenIdentified ) {
            isThisDueTimeToken = true;

            if ( _tokens.length == 1) {
              // If the number is the only item in the list, set the default description for non-supplied ones 
              desc = AppConstants.defaultEmptyDescription;
            }
            else if (desc.endsWith(' in')){
              desc = desc.substring(0 , desc.length - 3);
            }

            isAllDayEntry = false;

            suppliedTargetTimeIndex = i; 

            bool isUnitSupplied = false;

            // the token after the numeric value for the reminder might be a time unit (singular or plural)
            // If yes, set it

            // if this is the adjacent following token from the numeric count, then this might be a time unit
            if( _tokens.length - (i + 1) > 0) {

              String _unit = _tokens[i+1].toUpperCase();
              // if not in plural, convert it as the list contains the units in plural
              if ( !_unit.endsWith('S')){
                _unit = _unit + 'S';
              }

              // check if it's a time unit
              if ( AppConstants.timeUnits.contains( _unit ) ){
                isUnitSupplied = true;
                                
                // BINGO!!! Dealing with unit literal 

                int _inputValue = int.parse( _tokens[i]) ;

                switch ( _unit ) {
                  case 'MINUTES': 
                    _dur = Duration( minutes: _inputValue  ) ;

                    // save this info so that time won't be processed
                    specialSuppliedUnitProcessed = true;
                    hasStartTimeBeenIdentified = true;
                    ignoreTokensAtPosition.add( i + 1 );
                    
                    break;

                  case 'HOURS':
                    _dur = Duration( hours: _inputValue ) ;

                    // save this info so that time won't be processed
                    specialSuppliedUnitProcessed = true;
                    hasStartTimeBeenIdentified = true; 
                    ignoreTokensAtPosition.add( i + 1 );
                    break;

                  case 'DAYS':
                    _dur = Duration( days: _inputValue  ) ;
                    if (!hasStartTimeBeenIdentified) {
                      isAllDayEntry = true;
                    }
                    hasStartDateBeenIdentified = true; 
                    ignoreTokensAtPosition.add( i + 1 );
                    break;

                  case 'WEEKS':
                    _dur = Duration( days: _inputValue * 7 ) ;
                    if (!hasStartTimeBeenIdentified) {
                      isAllDayEntry = true;
                    }
                    hasStartDateBeenIdentified = true;
                    ignoreTokensAtPosition.add( i + 1 );
                    break;

                  case 'MONTHS':
                    _dur = Duration( days: _inputValue * AppConstants.defaultDaysPerMonth ) ;
                    if (!hasStartTimeBeenIdentified) {
                      isAllDayEntry = true;
                    }
                    hasStartDateBeenIdentified = true;
                    ignoreTokensAtPosition.add( i + 1 );
                    break;

                  case 'YEARS':
                    int leapDays = extraDaysForFinalYear(_inputValue); 

                    _dur = Duration( days: ( _inputValue * AppConstants.daysPerYear ) + leapDays , 
                                    hours: 0 );

                    if (!hasStartTimeBeenIdentified) {
                      isAllDayEntry = true;
                    }
                    hasStartDateBeenIdentified = true; 
                    ignoreTokensAtPosition.add( i + 1 );

                    break;

                  default: 
                  // it was already set in minutes on the original assignment, so do nothing here. 

                } // SWITCH end

              } // end of time unit processing 

            }

            // if a unit was not supplied, then default to minutes
            if ( !isUnitSupplied ) {
              // default case - minimal input - one integer
              hasStartTimeBeenIdentified = true; 
              isAllDayEntry = false; 
              _dur = Duration( minutes: int.parse( _tokens[i] ) ) ;
            }

            _timeSupplied = _tempNow.add( _dur );

            if (desc.endsWith(' in')){
              desc = desc.substring(0 , desc.length - 3);
            }

            // if all day event -  reset the hours and minutes
            if ( isAllDayEntry ) {
              _timeSupplied = DateTime( _timeSupplied.year, _timeSupplied.month, _timeSupplied.day, 0, 0 );
            }
            else{
              // strip out microseconds 
              _timeSupplied = DateTime( _timeSupplied.year, _timeSupplied.month, _timeSupplied.day, _timeSupplied.hour, _timeSupplied.minute );
                
            }

          }
        }
      }
      // if it's not a weekend period, check if it's a time token : numbers US style
      else if ( !isWeekendPeriodAllDay && _tokenUC.contains(':') && !specialSuppliedUnitProcessed && !hasStartTimeBeenIdentified) {

        // If it ends with am or pm (US style), save the info and remove from string
        int pmHoursToBeAdded = 0 ; 
        
        if ( _tokenUC.endsWith(_pm) || _tokenUC.endsWith(_am)) {
          // add 12 hours if in PM US mode 
          pmHoursToBeAdded = _tokenUC.endsWith(_pm) ? 12 : 0;

          // remove the US meridian from the time string
          _tokenUC = _tokenUC.substring(0 , _tokenUC.length -2);
        }

        // identify now if there is at least one more token and the next token is US indicator and process it accordingly
        else if( _tokens.length - i > 1 
                  && ( _tokens[i+1].toUpperCase().compareTo(_pm) == 0 || _tokens[i+1].toUpperCase().compareTo(_am) == 0) ) {
            
            // add 12 hours if in PM US mode 
            pmHoursToBeAdded = _tokens[i+1].toUpperCase().compareTo(_pm) == 0 ? 12 : 0;
            suppliedTargetUSIndex = i+1;

            if ( _tokens.length == 2) {
              // If the number is the only item in the list, set the default description for non-supplied ones 
              desc = AppConstants.defaultEmptyDescription;
            }
        }
        
        // Check if it has only numbers
        List<String> _timeTokens = _tokenUC.split(":");

        if (_timeTokens.length == 2) { 
          if ( ( StringParserUtilities.isValidInteger( _timeTokens[0] ) && int.parse( _timeTokens[0]) < 24 ) 
              && ( StringParserUtilities.isValidInteger( _timeTokens[1] ) && int.parse( _timeTokens[1]) < 60 ) ) {

            // BINGO!!!  

            addIdentifiedTimeToStartDateTime( int.parse( _timeTokens[0] ) + pmHoursToBeAdded, int.parse( _timeTokens[1] ) ); 

            isThisDueTimeToken = true;
            hasStartTimeBeenIdentified = true;

            if ( _tokens.length == 1) {
              // If the number is the only item in the list, set the default description for non-supplied ones 
              desc = AppConstants.defaultEmptyDescription;
            }
            // if the word at was used before the suggested time, remove it 
            else if (desc.endsWith(' at')){
              desc = desc.substring(0 , desc.length - 3);
            }
            // if the time follows the date, then the word at would have been in the note 
            else if (note == 'at'){
              note = '';
            }
          }
        }
        
      }
      // check if it's a date relevant to today that hasn't been already processed 
      else if ( !hasStartDateBeenIdentified && 
                (!( ignoreTokensAtPosition.contains(i) )) && ( AppConstants.specialOperators.contains( _tokenUC ) 
                || AppConstants.specialShortOperators.contains( _tokenUC ) || AppConstants.weekDaysShortToInt.containsKey( _tokenUC )
                 || AppConstants.weekDaysToInt.containsKey( _tokenUC ) || AppConstants.monthsToNumber.containsKey( _tokenUC ) 
                 || AppConstants.monthsShortToNumber.containsKey( _tokenUC ) ) ) {
        updateValuesBasedOnRelevantDate( i );
      } 
      else if ( _tokenUC.contains( '/' ) && !hasStartDateBeenIdentified ) {
        // check for dd/mm or mm/dd format
        processComboWithSlash( i );
      }
      // check if it's a no-alert keyword and act on it
      else if(AppConstants.noAlertLiterals.contains(_tokenUC) ){
        _disableAlert = true;
        ignoreTokensAtPosition.add( i );

      }

      // do not process this token if it was processed earlier as single or duet or triplet
      if( suppliedTargetUSIndex == i || suppliedMonthIndex == i || suppliedYearIndex == i || ignoreTokensAtPosition.contains(i) ) {
        isThisDueTimeToken = true;
      }

      if ( isThisDueTimeToken ) {
        // do not deal with description or note or other fields 

      }
      // else we are dealing with a string 
      else { 

        // Initialise the reminder description with the first token (it is a string)
        if ( i == 0 ) {
            desc = _tokens[i];
        }         
        else { 

          // Only add to the description if the target Date and Time hasn't been identified, 
          // as the string after the  duration will be used as note 
          if ( !hasStartDateBeenIdentified && !hasStartTimeBeenIdentified ) {
            desc = '$desc ${_tokens[i]}';
          }
          else {

            // Use it as note
            // Initialise note with the first token after duration
            if (note == '') { 
              note = _tokens[i];
            }
            else {
              // concatenate with the existing note value 
              note = '$note ${_tokens[i]}';
            }
          }
        
        }
      } // end of processing a string token 

    } // end of the loop processing the tokens 

    if (_timeSupplied.year == 1980 && _dur.inMinutes > 0 ){

      _timeSupplied = _tempNow.add(_dur);
      // strip out microseconds - required for testing
      _timeSupplied = DateTime(_timeSupplied.year, _timeSupplied.month, _timeSupplied.day, 
                        _timeSupplied.hour, _timeSupplied.minute);    
    } 

    // if no end time has been created so far, create it based on supplied DateTime 
    // If it's not an All Day event, then add the identified event duration.  
    if( _endTimeSupplied.year == 1980 ) {
      
      _endTimeSupplied = _timeSupplied.add( isAllDayEntry ? Duration(minutes: 0) : _eventDuration ); 
      
    }
    if( isAllDayEntry) {
      _alert = AppConstants.defaultAlertHoursForAllDayEvents.inMinutes;
    }

    // for weekend entries allow a different default one 
    //if ( isWeekendPeriodAllDay ) {
    //  _alert = AppConstants.defaultAlertHoursForWeekendEvents.inHours;
    //}

  }

}