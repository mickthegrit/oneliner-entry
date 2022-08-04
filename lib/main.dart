// import 'dart:io';

// import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';
import 'package:one_liner_entry/app_constants.dart';
import 'package:one_liner_entry/views/home_view.dart';
import 'package:one_liner_entry/views/manual_page.dart';
import 'package:one_liner_entry/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:one_liner_entry/reminder_creator.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // boilerplate code 
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /// TODO need the following for auto-switch to Android 
    // final _p = PlatformProvider.of(context)?.platform;

    return PlatformApp(
      title: AppConstants.appName,
      home: MyHomePage(platform: TargetPlatform.iOS),
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    );
  }
}

// Initiate the first form 
class MyHomePage extends StatefulWidget {
  final TargetPlatform platform;

  //const BasicTabbedPage({Key? key, required this.platform}) : super(key: key);

  const MyHomePage({Key? key, required this.platform}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Defining a corresponding State class.
// This class holds data related to the form.
class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  String statusS = '';

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );


  // String _inputText = '';
  ReminderCreator reminder = ReminderCreator();

  late TextEditingController _controller;



  // This needs to be captured here in a stateful widget
  late PlatformTabController tabController;

  late List<Widget> tabs;

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _controller = TextEditingController();

    // If you want further control of the tabs have one of these
    tabController = PlatformTabController(
      initialIndex: 0,
    );

    tabs = [
      HomeView(
        0,
        widget.platform,
        _controller,
        key: ValueKey('key0'),
      ),
      SettingsView(
        1,
        widget.platform,
        key: ValueKey('key1'),
      )
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = [ _packageInfo.appName, 'Settings'];
    final items = (BuildContext context) => [
      BottomNavigationBarItem(
        label: titles[0],
        icon: Icon(context.platformIcons.home),
      ),
      BottomNavigationBarItem(
        label: titles[1],
        icon: Icon(context.platformIcons.settings),
      ),
    ];
    
    return PlatformTabScaffold(
      iosContentPadding: true,
      tabController: tabController,
      appBarBuilder: (_, index) => PlatformAppBar(
        title: PlatformText(AppConstants.appName),
        trailingActions: <Widget>[
          PlatformIconButton(
            padding: EdgeInsets.zero,
            icon: Icon(context.platformIcons.info),
            onPressed: () {    
              Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ManualView())
              ); 
            },
          ),
        ],
        cupertino: (_, __) => CupertinoNavigationBarData(
          title: Text(titles[index]),
        ),
      ),
      bodyBuilder: (context, index) => IndexedStack(
        index: index,
        children: tabs,
      ),
      items: items(context),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   // This method is rerun every time setState is called, for instance as done
  //   // by the _incrementCounter method above.
  //   //
  //   // The Flutter framework has been optimized to make rerunning build methods
  //   // fast, so that you can just rebuild anything that needs updating rather
  //   // than having to individually change instances of widgets.
  //   return PlatformScaffold(
  //     appBar: PlatformAppBar(
  //       title: PlatformText( 
  //         AppConstants.appName ,
  //       ),
  //     ),
  //     body: Center( 
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           PlatformText(
  //             'Enter below the text for creating an Event and press enter:',
  //             style: platformThemeData(
  //               context,
  //               material: (data) => data.textTheme.bodyMedium,
  //               cupertino: (data) => data.textTheme.actionTextStyle,
  //             ),
  //           ),
  //           PlatformTextField(
  //             controller: _controller,

  //             onSubmitted: (String value) async {
  //               // only resubmit the event if at least one character is different 
  //               if (_inputText != value ){
  //                 _inputText = value;
  //                 // _incrementCounter(); 
  //               }
  //             }
  //           ),
  //         ]
  //       )
        
  //     )
  //   );

    // return Scaffold(
    //   appBar: AppBar(
    //     // Here we take the value from the MyHomePage object that was created by
    //     // the App.build method, and use it to set our appbar title.
    //     title: Text(widget.title),
    //     centerTitle: true,
    //     actions: [
    //       PopupMenuButton<int>(
    //         onSelected: (item) => onSelected(context, item),
    //         itemBuilder: (context) => [
    //           PopupMenuItem<int>(
    //             value: 0,
    //             child: Row(
    //               children: [
    //                 Icon(Icons.miscellaneous_services, color: Colors.black),
    //                 const SizedBox(width: 10),
    //                 const Text('Settings')  
    //               ],
    //             ) 
    //           ),
    //           PopupMenuItem<int>(
    //             value: 1,
    //             child: Row(
    //               children: [
    //                 Icon(Icons.book_outlined, color: Colors.black),
    //                 const SizedBox(width: 10),
    //                 const Text('Manual')
    //               ],
    //             )                
    //           ),
    //           PopupMenuItem<int>(
    //             value: 2,
    //             child: Row(
    //               children: [
    //                 Icon(Icons.medical_services_outlined, color: Colors.black),
    //                 const SizedBox(width: 10),
    //                 const Text('Support')
    //               ],
    //             )
    //           ),
    //           PopupMenuDivider(),
    //           PopupMenuItem<int>(
    //             value: 3,
    //             child: Row(
    //               children: [
    //                 Icon(Icons.info_outline, color: Colors.black),
    //                 const SizedBox(width: 10),
    //                 const Text('About')
    //               ],
    //             )
    //           ),
    //         ]
    //         )
    //     ],
    //   ),
    //   body: Center(
    //     // Center is a layout widget. It takes a single child and positions it
    //     // in the middle of the parent.
    //     child: Column(
    //       // Column is also a layout widget. It takes a list of children and
    //       // arranges them vertically. By default, it sizes itself to fit its
    //       // children horizontally, and tries to be as tall as its parent.
    //       //
    //       // Invoke "debug painting" (press "p" in the console, choose the
    //       // "Toggle Debug Paint" action from the Flutter Inspector in Android
    //       // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
    //       // to see the wireframe for each widget.
    //       //
    //       // Column has various properties to control how it sizes itself and
    //       // how it positions its children. Here we use mainAxisAlignment to
    //       // center the children vertically; the main axis here is the vertical
    //       // axis because Columns are vertical (the cross axis would be
    //       // horizontal).
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         const Text(
    //           'Enter below the text for creating a Calendar Event:',
    //         ),
    //         TextField(
    //           controller: _controller,
    //           onSubmitted: (String value) async {
    //             // only resubmit the event if at least one character is different 
    //             if (_inputText != value ){
    //               _inputText = value;
    //               _incrementCounter(); 
    //             }
                
    //             // await showDialog<void>(
    //             //   context: context,
    //             //   builder: (BuildContext context) {
    //             //     return AlertDialog(
    //             //       title: const Text('Alert!'),
    //             //       content: Text(
    //             //           'You typed "$value", which has length ${value.characters.length}.'),
    //             //       actions: <Widget>[
    //             //         TextButton(
    //             //           onPressed: () {
    //             //             Navigator.pop(context);
    //             //           },
    //             //           child: const Text('OK'),
    //             //         ),
    //             //       ],
    //             //     );
    //             //   },
    //             // );
    //           },
    //         ),
    //         // Text(
    //         //   '$_counter',
    //         //   style: Theme.of(context).textTheme.headline4,
    //         // ),
    //       ],
    //     ),
    //   ),
    //   // floatingActionButton: FloatingActionButton(
    //   //   onPressed: _incrementCounter,
    //   //   tooltip: 'Settings',
    //   //   child: const Icon(Icons.display_settings),
    //   // ) // This trailing comma makes auto-formatting nicer for build methods.
    // );
}

  // void onSelected(BuildContext context, int item){
  //   switch(item){
  //     case 0:
  //       Navigator.of(context).push(
  //         MaterialPageRoute(builder: (context) => SettingsView())
  //       );
  //       break; 
  //     case 1:
  //       Navigator.of(context).push(
  //         MaterialPageRoute(builder: (context) => ManualPage())
  //       );
  //       break;
  //     case 2:
  //       // Navigator.of(context).push(
  //       //   MaterialPageRoute(builder: (context) => SupportPage())
  //       // );
  //       break; 
  //     case 3:
  //       showAboutDialog(
  //         context: context, 
  //         applicationName: AppConstants.appName, 
  //         applicationVersion: AppConstants.appVersion
  //       );
  //       break; 
  //       // setState(() {
          
  //       // });
  //   }
  // }


