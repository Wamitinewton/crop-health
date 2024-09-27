// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:farmshield/feature_message/controllers/appwrite_controllers.dart';
import 'package:farmshield/feature_message/controllers/fcm_controllers.dart';
import 'package:farmshield/feature_message/controllers/local_saved_data.dart';
import 'package:farmshield/feature_message/providers/chat_provider.dart';
import 'package:farmshield/feature_message/providers/user_data_provider.dart';
import 'package:farmshield/feature_message/views/chat_page.dart';
import 'package:farmshield/feature_message/views/home.dart';
import 'package:farmshield/feature_message/views/phone_login.dart';
import 'package:farmshield/feature_message/views/profile.dart';
import 'package:farmshield/feature_message/views/search_users.dart';
import 'package:farmshield/feature_message/views/update_profile.dart';
import 'package:farmshield/firebase_options.dart';
import 'package:farmshield/gemini_bloc/gemini_bloc.dart';
import 'package:farmshield/language/lang.dart';
import 'package:farmshield/provider/firebase_collections.dart';
import 'package:farmshield/settings/account_screen.dart';
import 'package:farmshield/theme/consts/theme_data.dart';
import 'package:farmshield/theme/provider/dark_theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'screens/auth_wrapper.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// function to listen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification Received in background...");
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId = Provider.of<UserDataProvider>(
            navigatorKey.currentState!.context,
            listen: false)
        .getUserId;
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        updateOnlineStatus(status: true, userId: currentUserId);
        print("app resumed");
        break;
      case AppLifecycleState.inactive:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app inactive");

        break;
      case AppLifecycleState.paused:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app paused");

        break;
      case AppLifecycleState.detached:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app detched");

        break;
      case AppLifecycleState.hidden:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app hidden");
    }
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(LifecycleEventHandler());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Gemini.init(
      apiKey: "AIzaSyCmRZkw13CKugZKfpBWCf718FZigfSmGdQ", enableDebugging: true);
  await LocalSavedData.init();

  // initialize firebase messaging
  await PushNotifications.init();

  // initialize local notifications
  await PushNotifications.localNotiInit();
  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // on background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
      navigatorKey.currentState!.pushNamed("/message", arguments: message);
    }
  });

// to handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    if (message.notification != null) {
      PushNotifications.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }
  });

  // for handling in terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed(
        "/home",
      );
    });
  }

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  LanguageProvider languageChangeProvider = LanguageProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePreferences.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(create: (_) => themeChangeProvider),
        ChangeNotifierProvider(create: (_) => languageChangeProvider),
        BlocProvider(create: (context) => GeminiBloc()),
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child:
          Consumer<DarkThemeProvider>(builder: (context, themeProvider, child) {
        return GetMaterialApp(
          navigatorKey: navigatorKey,
          translations: LocalString(),
          locale: Locale('en', 'US'),
          debugShowCheckedModeBanner: false,
          theme: Styles.themeData(themeProvider.getDarkTheme, context),
          home: const AuthWrapper(),
          routes: {
            "/login": (context) => PhoneLogin(),
            "/home": (context) => HomePage(),
            "/chat": (context) => ChatPage(),
            "/profile": (context) => ProfilePage(),
            "/update": (context) => UpdateProfile(),
            "/search": (context) => SearchUsers(),
            "/account": (context) => AccountScreen()
          },
        );
      }),
    );
  }
}
