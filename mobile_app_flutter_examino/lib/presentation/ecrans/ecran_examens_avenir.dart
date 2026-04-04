import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/appels_reseau/source_examen_distante.dart';
import '../../data/models/modele_examen.dart';

class EcranExamensAvenir extends StatefulWidget {
  const EcranExamensAvenir({super.key});
  @override
  State<EcranExamensAvenir> createState() => _EcranExamensAvenirState();
}

class _EcranExamensAvenirState extends State<EcranExamensAvenir> {
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
    return SourceExamenDistante(token: prefs.getString('token') ?? "").getListByEndpoint('examens-avenir');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, vertExamino),
          const Padding(padding: EdgeInsets.all(20), child: Align(alignment: Alignment.centerLeft, child: Text("Liste des prochains examens", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)))),
          Expanded(
            child: FutureBuilder<List<ModeleExamen>>(
              future: _getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: vertExamino));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aucun examen à venir"));
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final exam = snapshot.data![i];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: orangeExamino, width: 4)),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(exam.titre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: vertExamino)), Text(exam.date, style: const TextStyle(fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 10),
                        _row(Icons.person, exam.enseignant ?? '', vertExamino),
                        _row(Icons.access_time, exam.heure, vertExamino),
                        _row(Icons.timer_outlined, exam.duree, vertExamino),
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

  Widget _buildHeader(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(15, MediaQuery.of(context).padding.top + 15, 15, 20),
      decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white, size: 25)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Row(children: [const Icon(Icons.account_circle, color: Colors.white, size: 20), const SizedBox(width: 5), Text(nomEtudiant, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))]),
              ),
            ],
          ),
          const Text("Examens à venir", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("Ecole superieur de technologie de salé-UM5", style: TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _row(IconData i, String t, Color c) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Icon(i, size: 22, color: c), const SizedBox(width: 10), Text(t, style: const TextStyle(fontWeight: FontWeight.bold))]));
}