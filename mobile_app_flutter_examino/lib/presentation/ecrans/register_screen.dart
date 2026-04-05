import 'package:flutter/material.dart';
import 'package:mobile_app_flutter_examino/configuration/theme/app_theme.dart';
import 'package:mobile_app_flutter_examino/configuration/connexion_api/api_service.dart';

class RegisterScreen extends StatefulWidget { 
  const RegisterScreen({super.key}); 
  @override State<RegisterScreen> createState() => _RegisterScreenState(); 
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _nomController = TextEditingController(); 
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController();
  
  List<dynamic> _listeFilieres = []; 
  String? _selectedFiliereId; 
  bool _isLoading = false;

  @override 
  void initState() { 
    super.initState(); 
    _chargerFilieres(); 
  }

  void _chargerFilieres() async { 
    var f = await ApiService().getFilieres(); 
    if (mounted) {
      setState(() => _listeFilieres = f); 
    }
  }

  void _register() async {
    // Validation de la filière
    if (_selectedFiliereId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une filière"), backgroundColor: Colors.orange)
      );
      return;
    }

    setState(() => _isLoading = true);

    // Appel au service d'inscription
    bool success = await ApiService().register(
      _nomController.text.trim(), 
      _prenomController.text.trim(), 
      _emailController.text.trim(), 
      _passwordController.text.trim(), 
      int.parse(_selectedFiliereId!)
    );

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inscription réussie ! Connectez-vous."), backgroundColor: Colors.green)
        );

        // REDIRECTION VERS LA PAGE DE CONNEXION
        
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // MESSAGE D'ERREUR
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'inscription. Vérifiez vos informations."), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25), 
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight, 
                child: IconButton(
                  icon: const Icon(Icons.cancel, color: AppTheme.primaryColor), 
                  onPressed: () => Navigator.pop(context,"/")
                )
              ),
              const Text("S'inscrire", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)), 
              const SizedBox(height: 15),
              Image.asset('assets/images/register_img.png', height: 130, errorBuilder: (c,e,s) => const Icon(Icons.person_add, size: 80, color: Colors.grey)), 
              const SizedBox(height: 25),
              
              TextField(controller: _nomController, decoration: AppTheme.inputDecoration("Nom", Icons.person_outline)), 
              const SizedBox(height: 15),
              TextField(controller: _prenomController, decoration: AppTheme.inputDecoration("Prénom", Icons.person_outline)), 
              const SizedBox(height: 15),
              TextField(controller: _emailController, decoration: AppTheme.inputDecoration("Email", Icons.email_outlined)), 
              const SizedBox(height: 15),
              TextField(controller: _passwordController, obscureText: true, decoration: AppTheme.inputDecoration("Mot de passe", Icons.lock_outline)), 
              const SizedBox(height: 15),
              
              DropdownButtonFormField<String>(
                decoration: AppTheme.inputDecoration("Choisir votre filière", Icons.school_outlined), 
                value: _selectedFiliereId, 
                items: _listeFilieres.map((f) => DropdownMenuItem<String>(
                  value: f['id'].toString(), 
                  child: Text(f['nom'])
                )).toList(), 
                onChanged: (v) => setState(() => _selectedFiliereId = v)
              ),
              
              const SizedBox(height: 35), 
              
              SizedBox(
                width: double.infinity, 
                height: 50, 
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ), 
                  onPressed: _isLoading ? null : _register, 
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("S'inscrire", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
                )
              ),
              
              const SizedBox(height: 25), 
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  const Text("Vous avez déjà un compte ? ", style: TextStyle(fontSize: 13)), 
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'), 
                    child: const Text("Se connecter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline, color: AppTheme.primaryColor))
                  )
                ]
              )
            ]
          )
        )
      ),
    );
  }
}