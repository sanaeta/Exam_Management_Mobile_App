import 'package:flutter/material.dart';
import '../../configuration/theme/app_theme.dart'; 

class PageAccueil extends StatelessWidget {
  const PageAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    // On récupère la couleur depuis AppTheme
    final Color couleurPrincipale = AppTheme.primaryColor;
    // On crée une version claire pour le deuxième bouton
    final Color couleurBoutonClair = couleurPrincipale.withOpacity(0.7);
    const Color texteSombre = Color(0xFF333333);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
         
          Expanded(
            flex: 6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Image.asset(
                  'assets/images/accueil_img.png', 
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => 
                    Icon(Icons.school, size: 100, color: couleurPrincipale),
                ),
              ),
            ),
          ),

          // 2. Slogan 
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "L'examen en ligne n'a jamais été aussi facile",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: texteSombre,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ),

          SizedBox(
            height: 80,
            child: Row(
              children: [
                // Bouton S'inscrire 
               Expanded(
  child: InkWell(
    onTap: () {
      // Redirection vers la page d'inscription
      Navigator.pushNamed(context, '/register');
    },
    child: Container(
      color: couleurPrincipale,
      child: const Center(
        child: Text(
          "s'inscrire",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ),
),
                // Bouton Se Connecter 
                Expanded(
  child: InkWell(
    onTap: () {
      // Redirection vers la page de connexion
      Navigator.pushNamed(context, '/login');
    },
    child: Container(
      color: couleurBoutonClair,
      child: Center(
        child: Text(
          "se connecter",
          style: TextStyle(color: couleurPrincipale, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ),
),
              ],
            ),
          ),
        ],
      ),
    );
  }
}