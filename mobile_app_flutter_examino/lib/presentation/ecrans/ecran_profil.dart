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
    setState(() => isLoading = true);
    var data = await ApiService().getUserProfile();
    if (mounted) {
      setState(() {
        userData = data;
        isLoading = false;
      });
    }
  }

  void _modifierChamp(String champDb, String titre, String valeurInitiale) {
    TextEditingController controller = TextEditingController(
      text: champDb == 'password' ? '' : valeurInitiale
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isPassword = (champDb == 'password');
            bool isValid = isPassword 
                ? controller.text.length >= 6 
                : controller.text.trim().isNotEmpty;

            return AlertDialog(
              title: Text("Modifier $titre"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    onChanged: (value) => setDialogState(() {}),
                    decoration: AppTheme.inputDecoration("Nouveau $titre", Icons.edit),
                  ),
                  if (isPassword)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text("Min. 6 caractères (${controller.text.length}/6)",
                        style: TextStyle(color: controller.text.length >= 6 ? Colors.green : Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Annuler")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValid ? const Color.fromARGB(255, 18, 52, 42) : Colors.grey,
                  ),
                  onPressed: isValid ? () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    
                    Navigator.pop(dialogContext);
                    setState(() => isLoading = true);
                    
                    Map<String, dynamic> resultat = await ApiService().updateProfile({champDb: controller.text});
                    
                    if (!mounted) return; 

                    if (resultat.containsKey('user') || resultat['status'] == 'success') {
                      _chargerProfil(); 
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(resultat['message'] ?? "Mis à jour avec succès !"), 
                          backgroundColor: Colors.green,
                        )
                      );
                    } else {
                      setState(() => isLoading = false);
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(resultat['message'] ?? "Erreur lors de la modification"), 
                          backgroundColor: Colors.red,
                        )
                      );
                    }
                  } : null, 
                  child: const Text("Sauvegarder", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCard(String titre, String valeur, String champDb) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFFEBE6E4), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 5),
                // Affichage en clair sans mélange
                Text(valeur, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 18, 52, 42), minimumSize: const Size(80, 35)),
            onPressed: () => _modifierChamp(champDb, titre, valeur),
            child: const Text("Modifier", style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Vos informations", style: TextStyle(color: AppTheme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Center(child: Image.asset('assets/images/profil_img.jpeg', height: 180, errorBuilder: (c, e, s) => const Icon(Icons.person, size: 80))),
                  const SizedBox(height: 30),
                  
                  _buildCard("NOM", userData?['nom'] ?? 'Non renseigné', "nom"),
                  _buildCard("PRÉNOM", userData?['prenom'] ?? 'Non renseigné', "prenom"),
                  _buildCard("GMAIL", userData?['email'] ?? '', "email"),
                  _buildCard("MOT DE PASSE", "********", "password"),
                ],
              ),
            ),
    );
  }
}