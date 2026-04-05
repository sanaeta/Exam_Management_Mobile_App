import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_app_flutter_examino/configuration/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isCodeSent = false;
  bool _isLoading = false;

  final String baseUrl = "http://10.0.2.2:8000/api";

  // Étape 1 : envoyer code
  
  Future<void> _demanderCode() async {
    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      _showSnack("Veuillez entrer un email");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password/forgot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() => _isCodeSent = true);
        _showSnack("Code envoyé par email !");
      } else {
        _showSnack(data['message'] ?? "Erreur");
      }
    } catch (e) {
      _showSnack("Erreur réseau");
    }

    setState(() => _isLoading = false);
  }

  // Étape 2 : reset password

  Future<void> _resetFinal() async {
    final email = _emailController.text.trim().toLowerCase();
    final code = _codeController.text.trim();
    final password = _newPasswordController.text.trim();

    // VALIDATIONS
    if (code.length != 6) {
      _showSnack("Le code doit contenir 6 chiffres");
      return;
    }

    if (password.length < 6) {
      _showSnack("Mot de passe trop court");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showSuccess();
      } else {
        _showSnack(data['message'] ?? "Erreur");
      }
    } catch (e) {
      _showSnack("Erreur réseau");
    }

    setState(() => _isLoading = false);
  }


  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Succès !"),
        content: const Text(
            "Votre mot de passe a été modifié. Connectez-vous avec le nouveau."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: const Text("Aller à la connexion"),
          )
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white60),
      prefixIcon: Icon(icon, color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              // HEADER
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock, size: 80, color: AppTheme.primaryColor),
                    SizedBox(height: 10),
                    Text(
                      "MOT DE PASSE\nOublié?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Veuillez suivre les instructions\npour sécuriser votre compte.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // BODY
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isCodeSent) ...[
                        const Text("Email",
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputStyle(
                              "Entrez votre email", Icons.email_outlined),
                        ),
                      ] else ...[
                        const Text("Code reçu par email",
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration:
                              _inputStyle("Code à 6 chiffres", Icons.security),
                        ),
                        const SizedBox(height: 15),
                        const Text("Nouveau mot de passe",
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputStyle(
                              "Nouveau mot de passe", Icons.lock_outline),
                        ),
                      ],

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFB2DFDB).withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : (_isCodeSent
                                  ? _resetFinal
                                  : _demanderCode),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                  _isCodeSent
                                      ? "Confirmer le changement"
                                      : "Envoyer le code",
                                  style: const TextStyle(
                                    color: Color(0xFF1B4D3E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const Spacer(),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Revenir à la connexion",
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_circle_left_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}