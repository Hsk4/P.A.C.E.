import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifyService{
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();


  static Future<void> init() async{
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async{

      },
    ) ;
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async{
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'scheduler_tasks_channel',
        'Task Reminders ',
        channelDescription: 'Channel for task reminders',
        importance: Importance.max,
        priority: Priority.high,
       playSound: true
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );


    await _notificationsPlugin.show(
      id: id,
      title : title,
      body : body,
      notificationDetails: notificationDetails,
    );
  }


}