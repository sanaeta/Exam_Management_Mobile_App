import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/appels_reseau/source_examen_distante.dart';

class EcranCorrection extends StatefulWidget {
  const EcranCorrection({super.key});
  @override
  State<EcranCorrection> createState() => _EcranCorrectionState();
}

class _EcranCorrectionState extends State<EcranCorrection> {
  final Color vertExamino = const Color(0xFF326E5C);
  final Color orangeExamino = const Color(0xFFFF8A65);
  final TextEditingController _messageController = TextEditingController();

  String nomEtudiant = "";
  Future<Map<String, dynamic>>? futureData;
  int? idExamenActuel;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is int) {
        idExamenActuel = args;
        _load(idExamenActuel!);
      }
      _isInit = true;
    }
  }

  void _load(int id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nomEtudiant = "${prefs.getString('user_nom') ?? ''} ${prefs.getString('user_prenom') ?? ''}";
      futureData = SourceExamenDistante(token: prefs.getString('token') ?? "").getCorrection(id);
    });
  }

  // --- FONCTION DE RÉCLAMATION AVEC EFFET DE CHARGEMENT ---
  void _afficherDialogueReclamation() {
    bool _isSending = false; // État local au dialogue

    showDialog(
      context: context,
      barrierDismissible: !_isSending, // Empêche de fermer pendant l'envoi
      builder: (context) {
        return StatefulBuilder( // ✅ Permet de mettre à jour le bouton dans le dialogue
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Déposer une réclamation", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Décrivez  l'erreur constatée sur votre note ou la correction.",
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    enabled: !_isSending, // Désactive le champ pendant l'envoi
                    decoration: InputDecoration(
                      hintText: "Votre message...",
                      hintStyle: const TextStyle(fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isSending ? null : () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vertExamino,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isSending ? null : () async {
                      if (_messageController.text.trim().isEmpty) return;

                      // 1. Activer le chargement
                      setDialogState(() => _isSending = true);

                      final prefs = await SharedPreferences.getInstance();
                      bool succes = await SourceExamenDistante(token: prefs.getString('token')!)
                          .envoyerReclamation(idExamenActuel!, _messageController.text);

                      // 2. Désactiver le chargement
                      setDialogState(() => _isSending = false);

                      Navigator.pop(context); // Fermer le dialogue

                      // 3. Afficher le résultat
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(succes ? "Réclamation envoyée avec succès !" : "Échec de l'envoi"),
                        backgroundColor: succes ? Colors.green : Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ));

                      if (succes) _messageController.clear();
                    },
                    child: _isSending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Envoyer", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text("Erreur serveur : ${snapshot.error}"));
                if (!snapshot.hasData) return const Center(child: Text("Pas de données"));

                final data = snapshot.data!;
                final questions = data['questions'] as List;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildScoreBox(data['correctes'], data['fausses'], data['total']),
                      const Padding(
                        padding: EdgeInsets.only(left: 25, bottom: 10, top: 10),
                        child: Align(alignment: Alignment.centerLeft, child: Text("Liste des Questions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
                      ),
                      ...questions.map((q) => ItemQuestionCorrection(questionData: q)).toList(),
                      const SizedBox(height: 80), 
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _afficherDialogueReclamation,
        backgroundColor: orangeExamino,
        icon: const Icon(Icons.edit_note, color: Colors.white, size: 28),
        label: const Text("Réclamation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<Map<String, dynamic>>(
      future: futureData,
      builder: (context, snapshot) {
        String titre = snapshot.hasData ? snapshot.data!['titre'] : "Examen";
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(15, MediaQuery.of(context).padding.top + 10, 15, 20),
          decoration: BoxDecoration(color: vertExamino, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white, size: 30)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Text(nomEtudiant, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titre, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text("Ecole Supérieure de Technologie de Salé", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreBox(int ok, int no, int total) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _scoreCol("CORRECTES :", "$ok/$total"),
          Container(height: 40, width: 1, color: Colors.black12),
          _scoreCol("FAUSSES :", "$no/$total"),
        ],
      ),
    );
  }
  Widget _scoreCol(String label, String val) => Column(children: [Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
}

class ItemQuestionCorrection extends StatefulWidget {
  final Map<String, dynamic> questionData;
  const ItemQuestionCorrection({super.key, required this.questionData});
  @override
  State<ItemQuestionCorrection> createState() => _ItemQuestionCorrectionState();
}

class _ItemQuestionCorrectionState extends State<ItemQuestionCorrection> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    bool isCorrect = widget.questionData['is_correct'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            contentPadding: EdgeInsets.zero,
            title: Text(widget.questionData['enonce'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(isCorrect ? "correcte" : "fausse", style: TextStyle(color: isCorrect ? Colors.lightGreen : Colors.redAccent, fontWeight: FontWeight.bold)),
            trailing: Icon(_isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right, size: 30, color: Colors.black54),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                children: [
                  _reponseBox("votre réponse:  ${widget.questionData['votre_reponse']}", const Color(0xFFF48FB1)),
                  const SizedBox(height: 8),
                  _reponseBox("réponse correcte:  ${widget.questionData['reponse_correcte']}", const Color(0xFFA5D6A7)),
                ],
              ),
            ),
        ],
      ),
    );
  }
  Widget _reponseBox(String text, Color color) => Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)));
}