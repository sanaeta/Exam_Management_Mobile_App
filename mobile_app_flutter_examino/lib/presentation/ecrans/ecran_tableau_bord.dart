import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/modele_examen.dart';
import '../../data/appels_reseau/source_examen_distante.dart';

class EcranTableauBord extends StatefulWidget {
  const EcranTableauBord({super.key});

  @override
  State<EcranTableauBord> createState() => _EcranTableauBordState();
}

class _EcranTableauBordState extends State<EcranTableauBord> {
  final Color vertExamino = const Color(0xFF326E5C);
  final Color orangeExamino = const Color(0xFFFF8A65);

  String rechercheMatiere = "";
  String nomEtudiant = "";

  late Future<Map<String, List<ModeleExamen>>> futureData;

  @override
  void initState() {
    super.initState();
    _loadUser();
    futureData = _loadFromAPI();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nomEtudiant =
          "${prefs.getString('user_nom') ?? ''} ${prefs.getString('user_prenom') ?? ''}";
    });
  }

  Future<Map<String, List<ModeleExamen>>> _loadFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? "";

    return SourceExamenDistante(token: token).getExamensDashboard(
      recherche: rechercheMatiere.isEmpty ? null : rechercheMatiere,
    );
  }

  void _refresh() {
    setState(() {
      futureData = _loadFromAPI();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<Map<String, List<ModeleExamen>>>(
              future: futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: vertExamino));
                }

                final recents = snapshot.data?['recents'] ?? [];
                final avenir = snapshot.data?['avenir'] ?? [];

                if (rechercheMatiere.isNotEmpty) {
                  final resultats = [...recents, ...avenir];
                  return _buildSearchResults(resultats, recents);
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _sectionTitle("Examens Récents", '/examens_passes'),
                      _buildHorizontalList(recents, true),
                      _sectionTitle("Examens à venir", '/examens_avenir'),
                      _buildHorizontalList(avenir, false),
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
    return Container(
      padding: EdgeInsets.fromLTRB(
        15,
        MediaQuery.of(context).padding.top + 15,
        15,
        20,
      ),
      decoration: BoxDecoration(
        color: vertExamino,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                ),
              ),
              Text(nomEtudiant,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          const Text("Bonjour !",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Quel Examen désirez-vous voir ?",
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (v) {
                      rechercheMatiere = v;
                      _refresh();
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Chercher votre Examen",
                      hintStyle: TextStyle(color: Colors.white60),
                      prefixIcon: Icon(Icons.search, color: Colors.white60),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                icon: Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.filter_alt_outlined, color: Colors.white),
                ),
                onSelected: (v) => Navigator.pushNamed(context, v),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: '/examens_passes', child: Text('Examens Passés')),
                  const PopupMenuItem(value: '/examens_aujourdhui', child: Text("Examens d'aujourd'hui")),
                  const PopupMenuItem(value: '/examens_avenir', child: Text('À venir')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<ModeleExamen> list, List<ModeleExamen> recents) {
    if (list.isEmpty) return const Center(child: Text("Aucun résultat"));
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final exam = list[i];
        final isRecent = recents.contains(exam);

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              isRecent ? '/examens_passes' : '/examens_avenir',
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: vertExamino,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(exam.titre,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(exam.date,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String t, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: vertExamino)),
          InkWell(
            onTap: () => Navigator.pushNamed(context, route),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(border: Border.all(color: vertExamino)),
              child: Text("Voir plus",
                  style: TextStyle(fontSize: 10, color: vertExamino)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<ModeleExamen> list, bool recent) {
    if (list.isEmpty) return const SizedBox(height: 50, child: Center(child: Text("Aucun examen")));
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: list.length,
        itemBuilder: (c, i) => Container(
          width: 140,
          margin: const EdgeInsets.only(right: 15, bottom: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: orangeExamino, width: 3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(list[i].titre,
                  style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
              const SizedBox(height: 10),
              recent
                  ? Text("Note: ${list[i].note ?? '?'}")
                  : Text(list[i].date, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}