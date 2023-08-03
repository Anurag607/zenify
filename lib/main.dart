import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:redux/redux.dart';
import 'package:zenify/fcm_api.dart';
import 'package:zenify/pages/main_page.dart';
import 'package:zenify/pages/notification_page.dart';
import 'package:zenify/pages/onboarding_screen.dart';
import 'package:zenify/redux/reducer.dart';
import 'package:zenify/redux/states/navigation_state.dart';
import 'package:zenify/redux/states/sidebar_state.dart';
import 'package:zenify/redux/states/song_state.dart';
import 'package:zenify/utils/database.dart';
import 'package:zenify/utils/songModelAdapter.dart';
import 'models/menu.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SongTypeAdapter());
  await Hive.openBox('zenifyData');
  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FCMApi().initNotification();
  runApp(const MyApp());
}

const defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(
    color: Color(0xFFDEE3F2),
    width: 1,
  ),
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _zenifyData = Hive.box('zenifyData');

  ZenifyDatabase db = ZenifyDatabase();

  final Store<NavigationState> _bottomnavbarStore = Store<NavigationState>(
    navigationReducer,
    initialState: NavigationState(tabIndex: 0),
  );

  final Store<SongState> _currentSongStore = Store<SongState>(
    songReducer,
    initialState: SongState(currentSongIndex: 0),
  );

  final Store<SidebarMenuState> _sidebarStore = Store<SidebarMenuState>(
    sidebarMenuReducer,
    initialState:
        SidebarMenuState(selectedTab: sidebarMenus.first, isClosed: false),
  );

  @override
  void initState() {
    // db.clearDatabase();
    if (_zenifyData.get("userDetails") == null) {
      db.saveUserDetails();
    } else {
      db.getUserDetails();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: _bottomnavbarStore,
      child: StoreProvider(
        store: _currentSongStore,
        child: StoreProvider(
          store: _sidebarStore,
          child: MaterialApp(
              title: 'Zenify',
              debugShowCheckedModeBanner: false,
              color: HexColor("#102844"),
              theme: ThemeData(
                colorScheme: ColorScheme.light(
                  primary: HexColor("#102844"),
                  secondary: HexColor("#102844"),
                  error: const Color(0xFFE45C5C),
                ),
                textTheme: GoogleFonts.quicksandTextTheme(
                  Theme.of(context).textTheme,
                ),
                scaffoldBackgroundColor: HexColor("#102844"),
                useMaterial3: true,
                inputDecorationTheme: const InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  errorStyle: TextStyle(height: 0),
                  border: defaultInputBorder,
                  enabledBorder: defaultInputBorder,
                  focusedBorder: defaultInputBorder,
                  errorBorder: defaultInputBorder,
                ),
              ),
              initialRoute: db.userDetails["name"]!.isEmpty ? '/' : '/home',
              routes: {
                '/': (context) => const OnbodingScreen(),
                '/home': (context) => const MainPage(),
                '/notification': (context) => const NotificationPage(),
              }),
        ),
      ),
    );
  }
}
