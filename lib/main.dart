import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery/util/constants.dart';
import 'package:image_gallery/util/image_gallery_list.dart';
import 'package:image_gallery/util/image_notifier.dart';
import 'package:image_gallery/widgets/home/home_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ImageNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => ImageGalleryList(),
        ),
      ],
      child: MaterialApp(
        title: 'Image Gallery',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          cardColor: Colors.white,
          primarySwatch: Constants.kPrimaryColor,
          canvasColor: Colors.white,
          fontFamily: 'SourceSansPro',
          textTheme: ThemeData.light().textTheme.copyWith(
                bodyText1: const TextStyle(
                    fontSize: 23,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
                bodyText2: const TextStyle(fontSize: 18),
              ),
          floatingActionButtonTheme:
              ThemeData.light().floatingActionButtonTheme.copyWith(
                    backgroundColor: Constants.kSecondaryColor,
                    largeSizeConstraints: const BoxConstraints(
                      minWidth: 80,
                      maxHeight: 80,
                      maxWidth: 80,
                      minHeight: 80,
                    ),
                  ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
