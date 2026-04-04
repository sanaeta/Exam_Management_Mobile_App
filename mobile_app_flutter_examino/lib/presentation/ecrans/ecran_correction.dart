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

void _afficherDialogueReclamation() {
  bool _isSending = false;
  String? _errorText;

  showDialog(
    context: context,
    barrierDismissible: !_isSending,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              "Déposer une réclamation",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Décrivez l'erreur constatée sur votre note ou la correction.",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  enabled: !_isSending,
                  onChanged: (_) {
                    if (_errorText != null) {
                      setDialogState(() => _errorText = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Votre message...",
                    hintStyle: const TextStyle(fontSize: 14),
                    errorText: _errorText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSending
                      ? null
                      : () async {
                          final message = _messageController.text.trim();
                          if (message.isEmpty) {
                            setDialogState(() {
                              _errorText = "Veuillez saisir un motif valide";
                            });
                            return;
                          }

                          setDialogState(() => _isSending = true);

                          final prefs = await SharedPreferences.getInstance();
                          bool succes = await SourceExamenDistante(
                                  token: prefs.getString('token')!)
                              .envoyerReclamation(idExamenActuel!, message);

                          setDialogState(() => _isSending = false);

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                succes
                                    ? "Réclamation envoyée avec succès !"
                                    : "Échec de l'envoi",
                              ),
                              backgroundColor:
                                  succes ? Colors.green : Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          if (succes) _messageController.clear();
                        },
                  child: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Envoyer",
                          style: TextStyle(color: Colors.white),
                        ),
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
                if (snapshot.hasError) return Center(child: Text("Erreur serveur"));
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
                    child: Row(
                      children: [
                        const Icon(Icons.account_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 5),
                        Text(nomEtudiant, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
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
    String status = widget.questionData['status'] ?? (widget.questionData['is_correct'] ? 'correct' : 'faux');
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            contentPadding: EdgeInsets.zero,
            title: Text(widget.questionData['enonce'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: _buildSubtitle(status),
            trailing: Icon(_isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right, size: 30, color: Colors.black54),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                children: [
                  if (status == 'non_repondu')
                    _reponseBox("Aucune réponse sélectionnée", Colors.grey.shade300)
                  else
                    _reponseBox("votre réponse:  ${widget.questionData['votre_reponse']}", 
                                status == 'correct' ? const Color(0xFFA5D6A7) : const Color(0xFFF48FB1)),
                  const SizedBox(height: 8),
                  _reponseBox("réponse correcte:  ${widget.questionData['reponse_correcte']}", const Color(0xFFA5D6A7)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(String status) {
    if (status == 'correct') {
      return const Text("correcte", style: TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold));
    } else if (status == 'faux') {
      return const Text("fausse", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold));
    } else {
      return const Text("Non répondu", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold));
    }
  }

  Widget _reponseBox(String text, Color color) => Container(
    width: double.infinity, 
    padding: const EdgeInsets.all(12), 
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), 
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))
  );
}