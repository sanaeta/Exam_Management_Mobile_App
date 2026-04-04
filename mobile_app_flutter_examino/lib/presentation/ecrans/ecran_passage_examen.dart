import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EcranPassageExamen extends StatefulWidget {
  final int idExamen;
  const EcranPassageExamen({super.key, required this.idExamen});

  @override
  State<EcranPassageExamen> createState() => _EcranPassageExamenState();
}

class _EcranPassageExamenState extends State<EcranPassageExamen> {
  final Color vertExamino = const Color(0xFF326E5C);
  final Color orangeExamino = const Color(0xFFFF8A65);

  Map<String, dynamic>? data;
  int indexQuestion = 0;
  Map<String, int> mesReponses = {}; 
  Timer? _timer;
  int _tempsRestant = 0;
  bool isLoading = true;
  String nomEtudiant = "";

  @override
  void initState() {
    super.initState();
    _initialiserPage();
  }

  Future<void> _initialiserPage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nomEtudiant = "${prefs.getString('user_nom') ?? ''} ${prefs.getString('user_prenom') ?? ''}";
    });
    await _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final String url = 'http://10.0.2.2:8000/api/examens/${widget.idExamen}/questions';
    try {
      final res = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${prefs.getString('token')}',
        'Accept': 'application/json'
      });
      if (res.statusCode == 200) {
        setState(() {
          data = jsonDecode(res.body);
          _tempsRestant = (data!['duree'] as int) * 60;
          isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      debugPrint("Erreur : $e");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tempsRestant > 0) {
        if (mounted) setState(() => _tempsRestant--);
      } else {
        _timer?.cancel();
        _showTimeUpModal(); // ✅ DÉCLENCHE LE MODAL D'EXPIRATION
      }
    });
  }

  Future<void> _soumettreExamen() async {
    final prefs = await SharedPreferences.getInstance();
    final String url = 'http://10.0.2.2:8000/api/examens/${widget.idExamen}/soumettre';
    try {
      final res = await http.post(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${prefs.getString('token')}',
        'Content-Type': 'application/json'
      }, body: jsonEncode({'reponses': mesReponses}));
      
      if (res.statusCode == 200) {
        _timer?.cancel();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/examens_passes', (r) => r.settings.name == '/dashboard');
        }
      }
    } catch (e) {
      debugPrint("Erreur : $e");
    }
  }

  // --- MODAL D'EXPIRATION (TEMPS ÉCOULÉ) ---
  void _showTimeUpModal() {
    showDialog(
      context: context,
      barrierDismissible: false, // L'étudiant doit cliquer sur le bouton
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.timer_off_outlined, color: Colors.orange, size: 70),
          const SizedBox(height: 15),
          const Text("Temps expiré !", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 5),
          const Text("Votre session est terminée. Vos réponses sélectionnées vont être transmises.", textAlign: TextAlign.center),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: vertExamino, minimumSize: const Size(double.infinity, 50)),
            onPressed: () {
              Navigator.pop(c); // Ferme le modal
              _soumettreExamen(); // Envoie les données
            },
            child: const Text("Voir mon résultat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ]),
      ),
    );
  }

  // --- MODAL DE CONFIRMATION (SORTIE OU FIN VOLONTAIRE) ---
  void _confirmerAction({required bool estSortie}) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -20, top: -20,
              child: InkWell(
                onTap: () => Navigator.pop(c),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 10),
              Icon(estSortie ? Icons.warning_amber_rounded : Icons.check_circle_outline, 
                   color: estSortie ? Colors.red : Colors.green, size: 70),
              const SizedBox(height: 15),
              Text(
                estSortie ? "Vous devez soumettre vos réponses avant de quitter l'épreuve ?" : "Voulez-vous valider et terminer l'examen ?", 
                textAlign: TextAlign.center, 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: estSortie ? const Color(0xFFF06292) : vertExamino, minimumSize: const Size(double.infinity, 50)),
                onPressed: () {
                  Navigator.pop(c);
                  _soumettreExamen();
                },
                child: Text(estSortie ? "Soumettre et Quitter" : "Soumettre mes réponses", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ]),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator(color: vertExamino)));
    final questions = data!['questions'] as List;
    final q = questions[indexQuestion];
    bool aRep = mesReponses.containsKey(q['id'].toString());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
        _buildHeader(),
        const SizedBox(height: 30),
        _buildInfoBox(questions.length),
        const SizedBox(height: 40),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(q['enonce'], style: TextStyle(color: vertExamino, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        const SizedBox(height: 30),
        Expanded(child: ListView(children: q['propositions'].map<Widget>((p) => _buildOption(p, q['id'].toString())).toList())),
        _buildNavigationButtons(aRep, questions.length),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(15, MediaQuery.of(context).padding.top + 10, 15, 25),
      decoration: BoxDecoration(color: vertExamino, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(onPressed: () => _confirmerAction(estSortie: true), icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30)),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Row(children: [
              const Icon(Icons.account_circle, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(nomEtudiant, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Padding(padding: const EdgeInsets.only(left: 10), child: Text("${data!['titre']}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
        const SizedBox(height: 20),
        _buildTimerArea(),
      ]),
    );
  }

  Widget _buildTimerArea() {
    String m = (_tempsRestant ~/ 60).toString().padLeft(2, '0'), s = (_tempsRestant % 60).toString().padLeft(2, '0');
    return Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: orangeExamino, width: 3)), child: Row(mainAxisSize: MainAxisSize.min, children: [_timerUnit("question", "N°${indexQuestion + 1}"), const SizedBox(width: 40), _timerUnit("temps restant", "$m : $s")])));
  }

  Widget _timerUnit(String label, String value) => Column(children: [
    Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)), 
    const SizedBox(height: 2),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: Colors.black))
  ]);

  Widget _buildInfoBox(int t) => Container(margin: const EdgeInsets.symmetric(horizontal: 30), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFEBE6E4), borderRadius: BorderRadius.circular(15), border: Border.all(color: orangeExamino.withOpacity(0.5))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_timerUnit("Questions :", "$t"), _timerUnit("Durée :", "${data!['duree']} min")]));

  Widget _buildOption(dynamic p, String qId) {
    bool sel = mesReponses[qId] == p['id'];
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8), child: InkWell(onTap: () => setState(() => mesReponses[qId] = p['id']), child: Container(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20), decoration: BoxDecoration(color: sel ? Colors.grey[350] : const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(15), border: Border.all(color: sel ? vertExamino : Colors.transparent, width: 2)), child: Center(child: Text(p['texte'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))))));
  }

  Widget _buildNavigationButtons(bool aRep, int total) {
    return Padding(padding: const EdgeInsets.all(25), child: Row(children: [
      if (indexQuestion > 0) Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 55), side: BorderSide(color: vertExamino, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), onPressed: () => setState(() => indexQuestion--), child: const Text("RETOUR", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF326E5C))))),
      if (indexQuestion > 0) const SizedBox(width: 15),
      Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: aRep ? const Color(0xFF004D00) : Colors.grey[400], minimumSize: const Size(0, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), onPressed: aRep ? () => indexQuestion < total - 1 ? setState(() => indexQuestion++) : _confirmerAction(estSortie: false) : null, child: Text(indexQuestion < total - 1 ? "CONTINUER" : "TERMINER", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
    ]));
  }
}