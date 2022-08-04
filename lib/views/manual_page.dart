import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:one_liner_entry/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ManualView extends StatefulWidget {
  const ManualView({Key? key}) : super(key: key);

  @override
  _ManualViewState createState() => _ManualViewState();
}

class _ManualViewState extends State<ManualView> {

  Future<void>? _launched;

  List entriesExamples = [ 
    'Short walk in 30',
    'Meditation break 20:00 Set timer',
    'Cook lasagna in 2 hours',
    'Dentist tomorrow 9:30',
    'Dinner Angelo on Monday at 7pm',     
    'Outdoors exercise Sat at 10',
    'Trip NYC next w/end Treat time!!!',
    'Landlord chat 5 Sep 4:15pm No rent rise',
    'Review weight loss plan Oct at 18:00',
    'Sign up to Gym next month at 0815',
    'Physio 25/7 (or 25/7/2023 or 25/7/23)',
    'Physio 9//25 (or 9//25/2023 or 9//25/23)',
  ];

  String getEntryExamples() {
    var _v = entriesExamples[0] + '\n\n';
    for (int i=1; i< entriesExamples.length; i++){
      _v = _v + entriesExamples[i] + '\n\n';
    }
    return _v ;
  }

  var manualWebsiteUri = Uri(
    scheme: 'https',
    host: AppConstants.homeURL,
    path: AppConstants.appManualUrl,
  );

  Future<void> _launchWebLinkIos(Uri url, bool launchExternalApp) async {
    final bool nativeAppLaunchSucceeded = await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
    );
    if (!nativeAppLaunchSucceeded && launchExternalApp) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override 
  Widget build(BuildContext context) => PlatformScaffold(
    appBar: PlatformAppBar(
      title: const Text('Manual'),
      // centerTitle: true,
      backgroundColor: Colors.amber,

    ),
    body:
      SafeArea( 
        minimum: const EdgeInsets.all(15.0),
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PlatformText(
              'Examples\n',
              textAlign: TextAlign.center,
              style: platformThemeData(
                context,
                material: (data) => data.textTheme.bodyMedium,
                cupertino: (data) => data.textTheme.actionTextStyle,
              ),
            ),
            PlatformText(
              getEntryExamples(),
              textAlign: TextAlign.left,
              style: platformThemeData(
                context,
                material: (data) => data.textTheme.bodyMedium,
                cupertino: (data) => data.textTheme.actionTextStyle,
              ),
            ),
            PlatformElevatedButton(
              child: PlatformText('Complete Manual (web)'),
              onPressed: () => setState(() {
                _launched = _launchWebLinkIos( manualWebsiteUri, true);
              })
            ),
          ]
        ),
      ),
  );
}
