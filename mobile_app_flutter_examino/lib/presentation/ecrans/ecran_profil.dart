import 'package:flutter/material.dart';
import 'package:mobile_app_flutter_examino/configuration/theme/app_theme.dart';
import 'package:mobile_app_flutter_examino/configuration/connexion_api/api_service.dart';

class EcranProfil extends StatefulWidget {
  const EcranProfil({super.key});
  @override
  State<EcranProfil> createState() => _EcranProfilState();
}

class _EcranProfilState extends State<EcranProfil> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerProfil();
  }

  void _chargerProfil() async {
    var data = await ApiService().getUserProfile();
    if (mounted) {
      setState(() {
        userData = data;
        isLoading = false;
      });
    }
  }

  void _modifierChamp(String champDb, String titre, String valeurInitiale) {
    TextEditingController controller = TextEditingController(text: champDb == 'password' ? '' : valeurInitiale);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog( // Utilisation d'un nom de context différent ici
        title: Text("Modifier $titre"),
        content: TextField(
          controller: controller,
          obscureText: champDb == 'password',
          decoration: AppTheme.inputDecoration("Nouveau $titre", Icons.edit),
        ),
        actions:[
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 18, 52, 42)),
            onPressed: () async {
              Navigator.pop(dialogContext); // On ferme la boite d'abord
              setState(() => isLoading = true);
              
              bool ok = await ApiService().updateProfile({champDb: controller.text});
              
              // CORRECTION ICI : Règle l'avertissement bleu
              if (!mounted) return; 

              if (ok) {
                _chargerProfil(); 
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Modifié avec succès !"), backgroundColor: Colors.green));
              } else {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Sauvegarder", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String titre, String valeur, String champDb) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFFEBE6E4), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text(titre, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(valeur, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 20, 90, 25), minimumSize: const Size(80, 35)),
            onPressed: champDb == 'filiere' ? null : () => _modifierChamp(champDb, titre, valeur),
            child: const Text("Modifier", style: TextStyle(color: Color.fromARGB(255, 232, 230, 230), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Vos informations", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: AppTheme.primaryColor)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children:[
                  Image.asset('assets/images/profil_img.jpeg', height: 180, errorBuilder: (c, e, s) => const Icon(Icons.person, size: 100)),
                  const SizedBox(height: 30),
                  _buildCard("NOM", "${userData?['prenom'] ?? ''} ${userData?['nom'] ?? ''}", "nom"),
                  _buildCard("GMAIL", userData?['email'] ?? '', "email"),
                  _buildCard("FILIERE", userData?['filiere']?['nom'] ?? 'Inconnue', "filiere"),
                  _buildCard("MOT DE PASSE", "********", "password"),
                ],
              ),
            ),
    );
  }
}