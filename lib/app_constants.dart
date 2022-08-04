class AppConstants { 

  static String appName = 'One Liner Entry';

  static String appVersion = '0.0.8';

  static String emailAddressSupport = 'onelinerentry@bluewhitemarionette.com';

  static String emailSubjectSupport = '$appName ($appVersion) - Support request';

  static String homeURL = 'bluewhitemarionette.com';

  static String appManualUrl = '/index.php/one-liner-entry';

  static String appSupportUrl = '/index.php/one-liner-entry/contact-onelinerentry/';

  static String appStoreHost = 'apps.apple.com';

  static String appStoreOLEPath = '/gb/app/one-liner-entry/id1629471090';

  /// When there is no inserted time unit for the alert, use the default one. 
  /// TODO ROADMAP :
  ///   Configurrable
  static int defaultAlert = 30;

  /// DEFAULT BEHAVIOUR
  /// When the supplied NLP day/month date is identical to today's date, eg. 5 May, 
  /// then the start year (and date) will be this year (today). 
  /// If an entry for next year is required, then the literal 1 year can be used. 
  ///  Alternatively, adding the next year after the supplied NLP date will have the same result. 
  /// TODO ROADMAP Low priority : allow this behaviour to be configurrable
  static bool logInFollowingYearDateMatchingTodaysDayMonthPair = false;

  /// when no end time is supplied, use the default one. 
  static int defaultEventDurationInMinutes = 45;

  /// For calculating future dates. Better early than late 
  /// TODO ROADMAP : configurrable - low priority
  static int defaultDaysPerMonth = 30;

  /// For all-day events create an alert in advance based on this value 
  static Duration defaultAlertHoursForAllDayEvents = const Duration(hours: 16);

  /// For all-day weekend events create an alert 2 days before at 08:00  
  static Duration defaultAlertHoursForWeekendEvents = const Duration(hours: 2*24 + 16);

  /// For calculating future dates. Better early than late
  static int daysPerYear = 365;

  /// When no description has been supplied but only a number, then use the following one. 
  /// TODO - ROADMAP: add to app configuration. low priority
  static String defaultEmptyDescription = 'REMIND ME';

  /// Used in specifying future dates
  /// Applicable in: 
  /// - reminders,
  /// - events. 
  /// TODO Roadmap: Allow multiple supplied time units, aka. 3 days 1 hour 30 minutes
  static List<String> timeUnits = [ 'MINUTES', 'HOURS', 'DAYS', 'WEEKS', 'MONTHS', 'YEARS' ];

  /// Convert month short names (3 letters long) to integer values for DateTime
  static Map<String,int> monthsShortToNumber = {
    'JAN': 1,
    'FEB': 2,
    'MAR': 3,
    'APR': 4,
    'MAY': 5,
    'JUN': 6,
    'JUL': 7,
    'AUG': 8,
    'SEP': 9,
    'OCT': 10,
    'NOV': 11,
    'DEC': 12
  }; 

  /// Convert month names to integer values for DateTime
  static Map<String,int> monthsToNumber = {
    'JANUARY': 1,
    'FEBRUARY': 2,
    'MARCH': 3,
    'APRIL': 4,
    'MAY': 5,
    'JUNE': 6,
    'JULY': 7,
    'AUGUST': 8,
    'SEPTEMBER': 9,
    'OCTOBER': 10,
    'NOVEMBER': 11,
    'DECEMBER': 12
  };

  /// Convert week day short names (3 letters long) to integer values for DateTime
  static Map<String,int> weekDaysShortToInt = {
    'MON': DateTime.monday,
    'TUE': DateTime.tuesday,
    'WED': DateTime.wednesday,
    'THU': DateTime.thursday,
    'FRI': DateTime.friday,
    'SAT': DateTime.saturday,
    'SUN': DateTime.sunday,

    'W/END': DateTime.saturday
  }; 

  /// Convert week day names to integer values for DateTime PLUS WEEKEND AND WEEK
  /// TODO LP: Arabic countries weekend is on Friday - configurable 
  static Map<String,int> weekDaysToInt = {
    'MONDAY': DateTime.monday,
    'TUESDAY': DateTime.tuesday,
    'WEDNESDAY': DateTime.wednesday,
    'THURSDAY': DateTime.thursday,
    'FRIDAY': DateTime.friday,
    'SATURDAY': DateTime.saturday,
    'SUNDAY': DateTime.sunday,

    'WEEKEND': DateTime.saturday,
  }; 

  /// The enum week day value for next week 
  /// LP TODO : configurable , some might prefer Sunday
  static int weekDayForNextWeek = DateTime.monday; 

  /// TODAY, TOMORROW, YESTERDAY, NEXT, FOLLOWING
  static List<String> specialOperators = <String>[ 'TODAY', 'TOMORROW', 'YESTERDAY', 'NEXT', 'FOLLOWING' ];

  /// TOD, TOM
  static List<String> specialShortOperators = <String>[ 'TOD', 'TOM' ];

  /// WEEKEND W/END
  static List<String> weekendLiterals = <String>['WEEKEND', 'W/END'];

  /// No alert keywords NOALERT NA NOAL 
  static List<String> noAlertLiterals = <String>[ 'NOALERT', 'NA', 'NOAL'];

  /// prequel token for time tokens
  static List timePrequel = ['AT', '@']; 
  
}