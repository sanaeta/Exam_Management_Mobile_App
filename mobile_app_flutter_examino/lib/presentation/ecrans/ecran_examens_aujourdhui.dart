import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/appels_reseau/source_examen_distante.dart';
import '../../data/models/modele_examen.dart';

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
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nomEtudiant =
          "${prefs.getString('user_nom') ?? ''} ${prefs.getString('user_prenom') ?? ''}";
    });
  }

  Future<List<ModeleExamen>> _getData() async {
    final prefs = await SharedPreferences.getInstance();
    return SourceExamenDistante(token: prefs.getString('token') ?? "")
        .getListByEndpoint('examens-aujourdhui');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FutureBuilder<List<ModeleExamen>>(
              future: _getData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(color: vertExamino));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final exam = snapshot.data![i];

                    return Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exam.titre,
                              style: TextStyle(
                                  color: vertExamino,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                          const SizedBox(height: 5),
                          Text(exam.heure, style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 10),
                          Text("Enseignant: ${exam.enseignant ?? ''}",
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: orangeExamino),
                              child: const Text("Passer",
                                  style: TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
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
      padding: EdgeInsets.fromLTRB(
        15,
        MediaQuery.of(context).padding.top + 15,
        15,
        25,
      ),
      decoration: BoxDecoration(
        color: vertExamino,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white)),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Text(nomEtudiant,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Examens d'aujourd'hui",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}