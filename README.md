# oneliner-entry

One Liner Entry is an open-source app (iOS / iPadOS) that processes a string input and identifies the following fields:
- event title 
- even start "date and time" or "time and date"
- (optional) note.

The above is the order the values are expected to be entered.

See latest documentation at https://bluewhitemarionette.com/index.php/one-liner-entry/

For the event start date / time it is possible to use:
- pairs of numbers and time units, like 
    - 40 minutes 
    - 2 hours
    - 5 days 
    - 3 weeks 
    - 6 months 
    - 2 years 
    Apart from the time units 'minutes' and 'hours', the others can be combined with time as well, in a 24h format or US format. 
    - 5 days 15:00 
    - 2 weeks 10:00am
    - 3 months 4:15pm 
- specific days (full name or 3-letters)
    - Monday
    - Tuesday 
    - Wed
    - Thu 
- Weekend or w/end
    This will create two-days all-day event on the coming w/end. 
- operators next OR following, followed by a period unit, followed by optional time. Examples: 
    - next week (that's Monday next week)
    - following month 
        1st day of the following month
    - next w/end OR weekend 
        7 days after the first w/end from today's date
    - next year 
        1st day of next year 
- specific dates in the following formats (month name in full or first 3 letters)
    - 5 Mar
    - 20 April
    - 7 July 2024
    If an invalid date is entered, eg 31 April, then the number of extra days is pushed to next month - that is 1 March. 
- operators today, tomorrow and yesterday, followed by optional time. 'tod' is processed like 'today', and 'tom' like 'tomorrow'.
- Default duration: 45 minutes  

