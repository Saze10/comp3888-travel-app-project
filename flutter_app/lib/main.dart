import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_services/authentication_service.dart';
import 'package:flutter_app/screens/Dashboard.dart';
import 'package:flutter_app/screens/Plan.dart';
import 'package:flutter_app/screens/BottomNavigation.dart';
import 'package:flutter_app/screens/Login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/screens/Profile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

bool USE_FIRESTORE_EMULATOR = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1080, 1920),
      builder: () => MultiProvider(
        providers: [
          Provider<AuthenticationService>(
            create: (_) => AuthenticationService(FirebaseAuth.instance),
          ),
          StreamProvider(
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges,
            initialData: null,
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          routes: {
            "/": (context) => BottomNavigatorBar(),
            "login": (context) => LoginPage(),
            "plan": (context) => Plan(),
            "profile": (context) => Profile(),
            "dashboard": (context) => Dashboard(),
          },
          theme: ThemeData(
            primaryColor: Colors.blue,
          ),
          initialRoute: "/",
        ),
      ),
    );
  }
}
