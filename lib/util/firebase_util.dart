import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore sFirebaseCloud = FirebaseFirestore.instance;
CollectionReference<Map<String, dynamic>> collectionRefImage =
    sFirebaseCloud.collection('images');
