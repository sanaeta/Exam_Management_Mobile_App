import 'package:flutter/material.dart';
import 'package:mobile_app_flutter_examino/configuration/theme/app_theme.dart';
import 'package:mobile_app_flutter_examino/configuration/connexion_api/api_service.dart';

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState() => _LoginScreenState(); }

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    bool success = await ApiService().login(_emailController.text, _passwordController.text);
    setState(() => _isLoading = false);
    if (success) {
      if(mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email ou mot de passe incorrect"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        Align(alignment: Alignment.topRight, child: IconButton(icon: const Icon(Icons.cancel, color: AppTheme.primaryColor), onPressed: () {})),
        const Text("Connexion", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
        Image.asset('assets/images/login_img.png', height: 150, errorBuilder: (c,e,s) => const Icon(Icons.image, size: 100)), const SizedBox(height: 30),
        TextField(controller: _emailController, decoration: AppTheme.inputDecoration("Email", Icons.email_outlined)), const SizedBox(height: 15),
        TextField(controller: _passwordController, obscureText: true, decoration: AppTheme.inputDecoration("mot de passe", Icons.lock_outline)), const SizedBox(height: 30),
        SizedBox(width: 150, height: 45, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), onPressed: _isLoading ? null : _login, child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Se Connecter", style: TextStyle(color: Colors.white)))),
        const SizedBox(height: 15), GestureDetector(onTap: () => Navigator.pushNamed(context, '/forgot_password'), child: const Text("Mot de passe oublié", style: TextStyle(decoration: TextDecoration.underline, fontSize: 12))),
        const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Vous n'avez pas de compte ? ", style: TextStyle(fontSize: 12)), GestureDetector(onTap: () => Navigator.pushNamed(context, '/register'), child: const Text("S'inscrire", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))])
      ]))),
    );
  }
}