class ModeleExamen {
  final int id;
  final String titre;
  final String date;
  final String heure;
  final String duree;
  final String? enseignant;
  final String? note;

  ModeleExamen({
    required this.id, required this.titre, required this.date,
    required this.heure, required this.duree, this.enseignant, this.note
  });

  factory ModeleExamen.fromJson(Map<String, dynamic> json) {
    return ModeleExamen(
      id: json['id_examen'] ?? 0,
      titre: json['titre'] ?? '',
      date: json['date'] ?? json['date_formatee'] ?? '',
      heure: json['heure'] ?? json['heure_complete'] ?? '',
      duree: json['duree'] ?? '',
      enseignant: json['enseignant'] ?? 'Non assigné',
      note: json['note_obtenue'],
    );
  }
}