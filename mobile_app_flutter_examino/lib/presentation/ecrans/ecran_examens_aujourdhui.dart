import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/appels_reseau/source_examen_distante.dart';
import '../../data/models/modele_examen.dart';
import 'ecran_passage_examen.dart'; 

class EcranExamensAujourdhui extends StatefulWidget {
  const EcranExamensAujourdhui({super.key});
  @override
  State<EcranExamensAujourdhui> createState() => _EcranExamensAujourdhuiState();
}

class _EcranExamensAujourdhuiState extends State<EcranExamensAujourdhui> {
  final Color vertExamino = const Color(0xFF326E5C);
  final Color orangeExamino = const Color(0xFFFF8A65);
  String nomEtudiant = "";

  @override
  void initState() { super.initState(); _loadUser(); }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { nomEtudiant = "${prefs.getString('user_nom') ?? ''} ${prefs.getString('user_prenom') ?? ''}"; });
  }

  Future<List<ModeleExamen>> _getData() async {
    final prefs = await SharedPreferences.getInstance();
    return SourceExamenDistante(token: prefs.getString('token') ?? "").getListByEndpoint('examens-aujourdhui');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FutureBuilder<List<ModeleExamen>>(
              future: _getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: vertExamino));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aucun examen pour aujourd'hui"));
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final exam = snapshot.data![i];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(exam.titre.toUpperCase(), style: TextStyle(color: vertExamino, fontWeight: FontWeight.w900, fontSize: 22)),
                        const SizedBox(height: 12),
                        Row(children: [Icon(Icons.access_time_filled, size: 18, color: orangeExamino), const SizedBox(width: 8), Text("Heure : ${exam.heure}", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16))]),
                        const SizedBox(height: 8),
                        Row(children: [const Icon(Icons.person, size: 18, color: Colors.grey), const SizedBox(width: 8), Text("Enseignant: ${exam.enseignant ?? ''}", style: const TextStyle(color: Colors.black54, fontSize: 14))]),
                        const SizedBox(height: 20),
                        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EcranPassageExamen(idExamen: exam.id))), style: ElevatedButton.styleFrom(backgroundColor: orangeExamino, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 2), child: const Text("PASSER L'EXAMEN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)))),
                      ]),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(15, MediaQuery.of(context).padding.top + 15, 15, 25),
      decoration: BoxDecoration(color: vertExamino, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Row(children: [const Icon(Icons.account_circle, color: Colors.white, size: 20), const SizedBox(width: 5), Text(nomEtudiant, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(padding: EdgeInsets.only(left: 10), child: Text("Examens d'aujourd'hui", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}