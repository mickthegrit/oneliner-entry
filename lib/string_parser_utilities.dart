class StringParserUtilities {
  
  /// Returns true if dealing with a non-empty string that can be converted to an integer
  static bool isValidInteger(String string) {
    // Null or empty string is not a number
      // TODO: test it 
      // if (string == null || string.isEmpty) {
    if ( string.isEmpty ) {
      return false;
    }

    // Try to parse input string to number. 
    final number = int.tryParse(string);

    if (number == null) {
      return false;
    }

    return true;
  }


}