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
    _chargerInfos();
  }

  void _chargerInfos() {
    setState(() {
      futureData = _loadFromAPI();
      _loadUser();
    });
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nomEtudiant = "${prefs.getString('user_nom') ?? ''} ${prefs.getString('user_prenom') ?? ''}";
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
                      const SizedBox(height: 10),
                      _sectionTitle("Examens Récents", '/examens_passes'),
                      _buildHorizontalList(recents, true),
                      const SizedBox(height: 10),
                      _sectionTitle("Examens à venir", '/examens_avenir'),
                      _buildHorizontalList(avenir, false),
                      const SizedBox(height: 30),
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
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Text(
                  nomEtudiant,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
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
                  height: 45, width: 45,
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

  Widget _sectionTitle(String t, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: vertExamino)),
          InkWell(
            onTap: () => Navigator.pushNamed(context, route),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: vertExamino.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: vertExamino.withOpacity(0.3)),
              ),
              child: Text(
                "Voir plus", 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: vertExamino)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<ModeleExamen> list, bool recent) {
    if (list.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text("Aucun examen", style: TextStyle(color: Colors.grey.shade400)),
      );
    }
    
    return SizedBox(
      height: 185, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 10),
        itemCount: list.length,
        itemBuilder: (c, i) => Container(
          width: 165,
          margin: const EdgeInsets.only(right: 20, bottom: 10, top: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: orangeExamino, width: 3.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // ✅ CENTRE TOUT LE CONTENU
            children: [
              // ✅ TITRE AVEC TRAIT FIN ET ESPACÉ
              Container(
                padding: const EdgeInsets.only(bottom: 6),
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12, width: 1.5))
                ),
                child: Text(
                  list[i].titre.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: vertExamino),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 15),
              
              if (recent) ...[
                // ✅ RÉCENTS : Note + En ligne
                Text(
                  "Note: ${list[i].note ?? '?'}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                const Text(
                  "En ligne",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
                ),
              ] else ...[
                // ✅ À VENIR : Date, Heure, Durée centrés avec icônes
                _rowAvenirCentered(Icons.calendar_month_outlined, list[i].date),
                _rowAvenirCentered(Icons.access_time, list[i].heure),
               
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ✅ HELPER POUR ALIGNEMENT CENTRÉ DES ICÔNES ET TEXTE
  Widget _rowAvenirCentered(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // ✅ Centre horizontalement dans la carte
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<ModeleExamen> list, List<ModeleExamen> recents) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final exam = list[i];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, recents.contains(exam) ? '/examens_passes' : '/examens_avenir'),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: vertExamino, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(exam.titre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(exam.date, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }
}