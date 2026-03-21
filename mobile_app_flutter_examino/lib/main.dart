import 'package:flutter/material.dart';
import 'package:mobile_app_flutter_examino/presentation/ecrans/page_accueil.dart';
import 'package:mobile_app_flutter_examino/presentation/ecrans/login_screen.dart';
import 'package:mobile_app_flutter_examino/presentation/ecrans/register_screen.dart';
import 'package:mobile_app_flutter_examino/presentation/ecrans/forgot_password_screen.dart';
import 'package:mobile_app_flutter_examino/presentation/ecrans/ecran_tableau_bord.dart';
import 'package:mobile_app_flutter_examino/presentation/ecrans/ecran_examens_aujourdhui.dart';
import 'package:mobile_app_flutter_examino/presentation/ecrans/ecran_examens_passes.dart';
import 'package:mobile_app_flutter_examino/presentation/ecrans/ecran_examens_avenir.dart';
import 'package:mobile_app_flutter_examino/presentation/ecrans/ecran_profil.dart';
import 'package:mobile_app_flutter_examino/presentation/ecrans/ecran_correction.dart';



void main() { runApp(const MyApp()); }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Examino App', 
      debugShowCheckedModeBanner: false, 
      initialRoute: '/', 
     routes: {
        '/': (context) => const PageAccueil(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const EcranTableauBord(),
        '/register':(context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/examens_passes': (context) => const EcranExamensPasses(),
        '/examens_avenir': (context) => const EcranExamensAvenir(),
        '/examens_aujourdhui': (context) => const EcranExamensAujourdhui(),
         '/correction': (context) => const EcranCorrection(),
        '/profile': (context) => const EcranProfil(),    
          },
    );
  }
}