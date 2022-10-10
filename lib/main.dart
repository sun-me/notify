import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notify/model/push_notification.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'notify/notification_badge.dart';

import 'notify/notification_register.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

final _notificationInfo = Provider<PushNotification>((ref) {
  return PushNotification( body: '', dataBody: '', dataTitle: '', title: '');
});

final _totalNotifications = Provider((ref) {
  return 0;
}) as int;

void main() {
  runApp(
    // Adding ProviderScope enables Riverpod for the entire project
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends HookConsumerWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Notify',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        debugShowCheckedModeBanner: false,
        home: Home(ref),
      ),
    );
  }
}

class Home extends HookConsumerWidget {
  late final FirebaseMessaging _messaging;


  Home(this.refs);

  final WidgetRef refs;

  // TODO 분리 했더니 실행 안됨
  // NotificationRegister.registerNotification(this.refs, this._messaging, _notificationInfo, _totalNotifications);

  // For handling notification when the app is in terminated state
  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );

      // setState(() {
      //   _notificationInfo = notification;
      //   _totalNotifications++;
      // });
    }
  }

  // @override
  // void initState() {
  //   _totalNotifications = 0;
  //   registerNotification();
  //   checkForInitialMessage();

    // For handling notification when the app is in background
    // but not terminated
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   PushNotification notification = PushNotification(
    //     title: message.notification?.title,
    //     body: message.notification?.body,
    //     dataTitle: message.data['title'],
    //     dataBody: message.data['body'],
    //   );
    //
    //   // setState(() {
    //   //   _notificationInfo = notification;
    //   //   _totalNotifications++;
    //   // });
    // });

  //   super.initState();
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notify'),
        brightness: Brightness.dark,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'App for capturing Firebase Push Notifications',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16.0),
          NotificationBadge(totalNotifications: _totalNotifications),
          const SizedBox(height: 16.0),
          _notificationInfo != null
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TITLE: ${ ref.watch(_notificationInfo).dataTitle ?? ref.watch(_notificationInfo)!.title}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'BODY: ${ ref.watch(_notificationInfo).dataBody ?? ref.watch(_notificationInfo)!.body}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          )
              : Container(),
        ],
      ),
    );
  }
}