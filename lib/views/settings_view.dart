import 'package:one_liner_entry/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatefulWidget {
  final int index;
  final TargetPlatform platform;

  const SettingsView(this.index, this.platform, {Key? key}) : super(key: key);
    @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  Future<void>? _launched;

  final Uri emailLaunchUrl = Uri(
    scheme: 'mailto',
    path: AppConstants.emailAddressSupport,
    query: 'subject=${AppConstants.emailSubjectSupport}'
    // queryParameters: <String, String>{
    //   'subject': 
    //   },
  );

  var supportWebsiteUri = Uri(
    scheme: 'https',
    host: AppConstants.homeURL,
    path: AppConstants.appSupportUrl,
  );

  var appStoreUri = Uri(
    scheme: 'https',
    host: AppConstants.appStoreHost,
    path: AppConstants.appStoreOLEPath,
  );

  Future<void> _launchEmail(Uri url) async {
    bool wasSuccessfulRun = await launchUrl(
      url,
      mode: LaunchMode.platformDefault,
      webViewConfiguration: const WebViewConfiguration( 
        //useSafariVC: false,
        //useWebView: false,
        enableJavaScript: true,
        enableDomStorage: true,
        //universalLinksOnly: false,
        headers: <String, String>{},
        //webOnlyWindowName: null,
      ),
                
    );
    if (!wasSuccessfulRun ) {
      wasSuccessfulRun = await launchUrl(
        url,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!wasSuccessfulRun ){
        // email didn't work - navigate to support webpage 
        _launchWebLinkIos( supportWebsiteUri, true);
      }
      
    }
  }

  Future<void> _launchInstallationStore(Uri url) async {

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
  

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
    // appBar: PlatformAppBar(
    //   title: PlatformText('Test email and Twitter'),
    //   // backgroundColor: Colors.green,
    // ),
    body: Center( 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PlatformText(
            'Version: ${AppConstants.appVersion} \n100% open-source app \nMade with 💚 in Greece 🇬🇷',
            textAlign: TextAlign.center,
            style: platformThemeData(
              context,
              material: (data) => data.textTheme.bodyMedium,
              cupertino: (data) => data.textTheme.actionTextStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformElevatedButton(
              child: PlatformText('🙋 Support'),
              onPressed: () => setState(() {
                _launched = _launchEmail( emailLaunchUrl );
              }),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformElevatedButton(
              child: PlatformText('📝🌟 Rate and feedback'),
              onPressed: () => setState(() {
                _launched = _launchInstallationStore( appStoreUri );
              })
            ),
          ),

          PlatformElevatedButton(
            child: PlatformText('Show Licences'),
            onPressed: () { showLicensePage(context: context, applicationName: AppConstants.appName); },
                // onPressed: () {showAboutDialog(context: context) ; },
          ),
          //),

        ]
      )
    ),
  
  );

  
}
