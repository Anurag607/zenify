import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zenify/main.dart';
import 'package:zenify/pages/notification_page.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log('Handling a message ${message.messageId}');
  log('Title: ${message.notification!.title}');
  log("Body: ${message.notification!.body}");
  log('Payload: ${message.data}');
  if (message.notification != null) {
    log('Message also contained a notification: ${message.notification}');
  }
}

void handleMessage(RemoteMessage? message) {
  if (message == null) return;

  log("routing");

  navigatorKey.currentState?.pushNamed(
    NotificationPage.route,
    arguments: message,
  );
}

class FCMApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.defaultImportance,
  );

  final _localNotification = FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotification() async {
    const ios = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: ios);
    await _localNotification.initialize(settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      log("onDidReceiveBackgroundNotificationResponse: ${response.payload}");
      if (response.payload != null) {
        final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
        handleMessage(message);
      }
    });

    final platform = _localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<void> initPushNotifications() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      handleBackgroundMessage(message);

      _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: _androidChannel.importance,
            icon: '@drawable/ic_launcher',
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future<bool> callOnFcmApiSendPushNotifications(List<String> userToken) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "registration_ids": userToken,
      "collapse_key": "type_a",
      "notification": {
        "title": 'Hello from Zenify,',
        "body":
            'This is a scheduler app i made which also comes with a music player. Take a look!',
        "image": "https://cdn-icons-png.flaticon.com/128/9437/9437514.png",
        "name": "Demo FCM push notification",
      }
    };

    final dynamic headers = {
      'content-type': 'application/json',
      'Authorization': "key=${dotenv.env['FCM_SERVER_KEY']}",
    };

    final response = await http.post(
      Uri.parse(postUrl),
      body: json.encode(data),
      headers: headers,
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      // on success do sth
      log('test ok push CFM');
      return true;
    } else {
      log(' CFM error');
      // on failure do sth
      return false;
    }
  }

  Future<void> initNotification() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    String identifier = "";
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        identifier = build.id.toString();
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        identifier = data.identifierForVendor!; //UUID for iOS
      }
    } on PlatformException {
      log('Failed to get platform version');
    }

    String fcmToken = "";
    await _firebaseMessaging.getToken().then((token) async {
      fcmToken = token!;
      log("FCMToken: $fcmToken");
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference users = firestore.collection('user');
      await users
          .doc(identifier)
          .set({
            'identifier': identifier,
            'fcmToken': fcmToken,
          })
          .then((value) => log("User Added"))
          .catchError(
            (error) => log("Failed to add user: $error"),
          );
    });
    log('User granted permission: ${settings.authorizationStatus}');
    initPushNotifications();
    initLocalNotification();
    callOnFcmApiSendPushNotifications([fcmToken]);
  }
}
