import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/appels_reseau/source_examen_distante.dart';
import '../../data/models/modele_examen.dart';

class EcranExamensPasses extends StatefulWidget {
  const EcranExamensPasses({super.key});

  @override
  State<EcranExamensPasses> createState() => _EcranExamensPassesState();
}

class _EcranExamensPassesState extends State<EcranExamensPasses> {
  final Color vertExamino = const Color(0xFF326E5C);
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
        .getListByEndpoint('examens-passes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Liste des examens passés",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ModeleExamen>>(
              future: _getData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(color: vertExamino));
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucun examen passé"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final exam = snapshot.data![i];

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: vertExamino.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: vertExamino),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exam.titre,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: vertExamino)),
                          const SizedBox(height: 5),
                          Text(exam.date, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 5),
                          Text("Enseignant: ${exam.enseignant ?? ''}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
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
        20,
      ),
      decoration: BoxDecoration(
        color: vertExamino,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
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
              "Examens passés",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}