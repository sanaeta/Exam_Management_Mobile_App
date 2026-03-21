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
        .getListByEndpoint('examens-passes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context, vertExamino),

          const Padding(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Liste des examens passés",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<ModeleExamen>>(
              future: _getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: vertExamino));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucun examen passé"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final exam = snapshot.data![i];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/correction',
                          arguments: exam.id,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          // ✅ BORDURE EN ORANGE
                          border: Border.all(color: orangeExamino, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2)
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ 1. MATIÈRE EN VERT (LA PLUS IMPORTANTE)
                                Text(
                                  exam.titre,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: vertExamino),
                                ),
                                const SizedBox(height: 6),
                                // ✅ 2. DATE EN NOIR FONCÉ (IMPORTANTE)
                                Text(
                                  exam.date,
                                  style: const TextStyle(
                                      color: Colors.black, 
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                const SizedBox(height: 10),
                                // ✅ 3. ENSEIGNANT (DISCRET)
                                Text(
                                  "Enseignant: ${exam.enseignant ?? ''}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black45,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            // ICÔNE CHEVRON
                            Icon(
                              Icons.arrow_forward_ios,
                              color: vertExamino,
                              size: 22,
                            ),
                          ],
                        ),
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

  Widget _buildHeader(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        15,
        MediaQuery.of(context).padding.top + 15,
        15,
        20,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 25),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Text(
                  nomEtudiant,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Examens passés",
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const Text(
            "Ecole Supérieur de technologie Salé - UM5",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}