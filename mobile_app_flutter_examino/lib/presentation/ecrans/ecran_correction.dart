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
  String nomEtudiant = "";
  Future<Map<String, dynamic>>? futureData;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final id = ModalRoute.of(context)!.settings.arguments as int;
      _load(id);
      _isInit = true;
    }
  }

  void _load(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? "";
    setState(() {
      nomEtudiant = "${prefs.getString('user_nom') ?? ''} ${prefs.getString('user_prenom') ?? ''}";
      futureData = SourceExamenDistante(token: token).getCorrection(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fond gris très clair
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
                      // Génération de la liste des questions
                      ...questions.map((q) => ItemQuestionCorrection(questionData: q)).toList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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

// --- WIDGET POUR CHAQUE LIGNE DE QUESTION (AVEC OPTION EXPAND) ---
class ItemQuestionCorrection extends StatefulWidget {
  final Map<String, dynamic> questionData;
  const ItemQuestionCorrection({super.key, required this.questionData});

  @override
  State<ItemQuestionCorrection> createState() => _ItemQuestionCorrectionState();
}

class _ItemQuestionCorrectionState extends State<ItemQuestionCorrection> {
  bool _isExpanded = false; // Gère l'affichage du détail

  @override
  Widget build(BuildContext context) {
    bool isCorrect = widget.questionData['is_correct'];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            contentPadding: EdgeInsets.zero,
            title: Text(widget.questionData['enonce'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(
              isCorrect ? "correcte" : "fausse",
              style: TextStyle(color: isCorrect ? Colors.lightGreen : Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              size: 30,
              color: Colors.black54,
            ),
          ),
          
          // --- SECTION DÉTAIL (Affichée seulement si _isExpanded est vrai) ---
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                children: [
                  _reponseBox("votre réponse:  ${widget.questionData['votre_reponse']}", const Color(0xFFF48FB1)), // Rose clair
                  const SizedBox(height: 8),
                  _reponseBox("réponse correcte:  ${widget.questionData['reponse_correcte']}", const Color(0xFFA5D6A7)), // Vert clair
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _reponseBox(String text, Color color) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
  );
}