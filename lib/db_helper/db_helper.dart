import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class DbHelper{
  static const String collectionUser = 'User';
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<void> massageResive(RemoteMessage message) async{
    print('title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('massage: ${message.data}');
  }


  Future<void> initNotification() async{
    await FirebaseMessaging.instance.requestPermission();
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('token is : $fcmToken');
    FirebaseMessaging.onBackgroundMessage(massageResive);
  }



  Future<void> addUser(User user, String userName,) async {
    try {
      await _db.collection(collectionUser).doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'User Name': userName,
        'Rule': 'User',
        // Add other user details as needed
      });
    } catch (error) {
      print('Error is: ${error.toString()}');
    }
  }
}



