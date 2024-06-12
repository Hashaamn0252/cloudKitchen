import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_theme_data.dart';
import 'package:flutterrestaurant/config/router.dart' as router;
import 'package:flutterrestaurant/provider/common/ps_theme_provider.dart';
import 'package:flutterrestaurant/provider/ps_provider_dependencies.dart';
import 'package:flutterrestaurant/repository/ps_theme_repository.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/language.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_manager/theme_manager.dart';
import 'config/ps_colors.dart';
import 'config/ps_config.dart';
import 'db/common/ps_shared_preferences.dart';

Future<void> main() async {
  // add this, and it should be the first line in main method
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getString('codeC') == null) {
    await prefs.setString('codeC', '');
    await prefs.setString('codeL', '');
  }

  await Firebase.initializeApp();
  MobileAds.instance.initialize();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  if (Platform.isIOS) {
    FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);
  }

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  //check is apple signin is available
  await Utils.checkAppleSignInAvailable();

  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
      path: 'assets/langs',
      saveLocale: true,
      // startLocale: PsConfig.defaultLanguage.toLocale(),
      supportedLocales: getSupportedLanguages(),
      child: PSApp()));
}

List<Locale> getSupportedLanguages() {
  final List<Locale> localeList = <Locale>[];
  for (final Language lang in PsConfig.psSupportedLanguageList) {
    localeList.add(Locale(lang.languageCode!, lang.countryCode));
  }
  print('Loaded Languages');
  return localeList;
}

class PSApp extends StatefulWidget {
  @override
  _PSAppState createState() => _PSAppState();
}

// Future<dynamic> initAds() async {
//   if (PsConfig.showAdMob && await Utils.checkInternetConnectivity()) {
//     // FirebaseAdMob.instance.initialize(appId: Utils.getAdAppId());
//   }
// }

class _PSAppState extends State<PSApp> {
  Completer<ThemeData>? themeDataCompleter;
  PsSharedPreferences? psSharedPreferences;

  @override
  void initState() {
    super.initState();
  }

  Future<ThemeData> getSharePerference(
      EasyLocalization provider, dynamic data) {
    Utils.psPrint('>> get share perference');
    if (themeDataCompleter == null) {
      Utils.psPrint('init completer');
      themeDataCompleter = Completer<ThemeData>();
    }

    if (psSharedPreferences == null) {
      Utils.psPrint('init ps shareperferences');
      psSharedPreferences = PsSharedPreferences.instance;
      Utils.psPrint('get shared');
      //SharedPreferences sh = await
      psSharedPreferences!.futureShared.then((SharedPreferences sh) {
        psSharedPreferences!.shared = sh;

        Utils.psPrint('init theme provider');
        final PsThemeProvider psThemeProvider = PsThemeProvider(
            repo: PsThemeRepository(psSharedPreferences: psSharedPreferences!));

        Utils.psPrint('get theme');
        final ThemeData themeData = psThemeProvider.getTheme();

        themeDataCompleter!.complete(themeData);
        Utils.psPrint('themedata loading completed');
      });
    }

    return themeDataCompleter!.future;
  }

  List<Locale> getSupportedLanguages() {
    final List<Locale> localeList = <Locale>[];
    for (final Language lang in PsConfig.psSupportedLanguageList) {
      localeList.add(Locale(lang.languageCode!, lang.countryCode));
    }
    print('Loaded Languages');
    return localeList;
  }

  @override
  Widget build(BuildContext context) {
    // init Color
    PsColors.loadColor(context);

    return MultiProvider(
        providers: <SingleChildWidget>[
          ...providers,
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Panacea-Soft',
          // theme: theme,
          initialRoute: '/',
          onGenerateRoute: router.generateRoute,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: EasyLocalization.of(context)!.supportedLocales,
          locale: EasyLocalization.of(context)!.locale,
        )
        // ThemeManager(
        //     defaultBrightnessPreference: BrightnessPreference.light,
        //     data: (Brightness brightness) {
        //       if (brightness == Brightness.light) {
        //         return themeData(ThemeData.light());
        //       } else {
        //         return themeData(ThemeData.dark());
        //       }
        //     },
        //     loadBrightnessOnStart: true,
        //     themedWidgetBuilder: (BuildContext context, ThemeData theme) {
        //       return ;
        //   }
        // ),
        );
  }
}
