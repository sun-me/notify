import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notify/model/push_notification.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import 'notification_badge.dart';

class NotificationRegister {

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  static void registerNotification( WidgetRef ref, FirebaseMessaging fbMessaging,
      dynamic pNotificationInfo, dynamic pTotalNotifications) async {
    await Firebase.initializeApp();
    fbMessaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await fbMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
            'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');

        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );

        // setState(() {
        //   _notificationInfo = notification;

        ref.read(pNotificationInfo).update((state) => state = notification);
          // _totalNotifications++;
        // });

        if (ref.read(pNotificationInfo) != null) {
          // For displaying the notification as an overlay
          // import 'package:overlay_support/overlay_support.dart';
          showSimpleNotification(
            Text(ref.read(pNotificationInfo)!.title!),
            leading: NotificationBadge(totalNotifications: ref.watch(pTotalNotifications)),
            subtitle: Text(ref.read(pNotificationInfo)!.body!),
            background: Colors.cyan.shade700,
            duration: Duration(seconds: 2),
          );
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }
}