import 'package:one_liner_entry/reminder_creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:permission_handler/permission_handler.dart';


class HomeView extends StatefulWidget {
  final int index;
  final TargetPlatform platform;
  final TextEditingController _controller;

  HomeView(this.index, this.platform, this._controller, {Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  String _inputText = '';
  ReminderCreator reminder = ReminderCreator();

//  late TextEditingController _controller;

    /// Check for Calendar access and if all ok show the Log-Event-Modal with the right values 
  void _askCalAccess() async {

    if (await Permission.calendar.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
    //}
    // ask for calendar access 
    //      var status = await Permission.calendar.status;
    //    if (status.isDenied) {
        // We didn't ask for permission yet or the permission has been denied before but not permanently.
      // statusS = 'Calendar enabled';
    }
    else {
      // // statusS = 'Calendar disabled - not possible to create events. ';
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return PlatformAlertDialog(
            title: PlatformText('Alert'),
            content: PlatformText(
                'The app does not have access to the calendars. Please enable it to continue using this app.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: PlatformText('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    reminder = ReminderCreator();

    reminder.process(_inputText );
    // only offer logging an event if a date has been identified 
    if (reminder.getStartDate().year > 1980 ) {
    
      final Event event = Event(
        title: reminder.getDesc(),
        description: reminder.getNote(),
        location: '',
        startDate: reminder.getStartDate(), 
        endDate: reminder.getEndDate(), 
        allDay: reminder.isAllDay(),
        iosParams: IOSParams( 
          reminder: Duration(
            minutes: reminder.getAlert(),
            /* Ex. hours:1 */), // on iOS, you can set alarm notification after your event.
        ),
        // androidParams: AndroidParams( 
        //   emailInvites: [], // on Android, you can add invite emails to your event.
        // ),
      );

      // suppress default alert if needed 
      if (reminder.isAlertSuppressed()){
        event.iosParams = const IOSParams() ;
      }

      Add2Calendar.addEvent2Cal(event);
    }
    else { 
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return PlatformAlertDialog(
            title: const Text('Alert'),
            content: const Text(
                'No start date has been identified. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _incrementCounter()  {
    _askCalAccess();
    
    setState(()  {

      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      // _counter++;
    });
  }



  @override 
  Widget build(BuildContext context) => PlatformScaffold(
    // appBar: PlatformAppBar(
      // title: PlatformText('Create an Event'),
      // backgroundColor: Colors.green,
      // ),
      body: 
        //Center(
        SafeArea( 
          minimum: const EdgeInsets.all(15.0),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              PlatformText(
                'Enter Title, start date and / or time and an optional note, and press Done on the keyboard:' + 
                // (orientation == Orientation.portrait ? '' : 
                '\n',
                textAlign: TextAlign.center,
                style: platformThemeData(
                  context,
                  material: (data) => data.textTheme.bodyMedium,
                  cupertino: (data) => data.textTheme.actionTextStyle,
                ),
              ),
              PlatformTextField(
                key: Key('input'),
                controller: widget._controller,
                autofocus: true,

                // CANNOT use the following because the Return / Enter adds new line rather than creating new event 
                // expands: true,
                // minLines: null,
                // maxLines: 2,

                onSubmitted: (String value) async {
                  // only resubmit the event if at least one character is different 
                  if (_inputText != value ){
                    _inputText = value;
                    _incrementCounter(); 
                  }
                }
              ),
              PlatformElevatedButton(
                child: PlatformText('Reset'),
                onPressed: () {  widget._controller.clear(); },
              ),
            ]
          ),
        ),
  );
  

}
