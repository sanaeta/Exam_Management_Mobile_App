<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Models\Examen;
use App\Models\PassageExamen;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;


class ExamenController 
{
    //Données pour la page d'accueil (Tableau de bord)
     
    public function getDashboardData(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['error' => 'Non authentifié'], 401);

        $recherche = $request->query('recherche');

        // 1. RÉCENTS : Les 2 derniers examens passés
        $recents = PassageExamen::with(['examen.matiere'])
            ->where('user_id', $user->id)
            ->when($recherche, function ($q) use ($recherche) {
                $q->whereHas('examen.matiere', fn($q2) => $q2->where('nom', 'like', "%$recherche%"));
            })
            ->orderBy('date_passage', 'desc')
            ->take(2)
            ->get();

        // 2. À VENIR : Les 2 prochains examens 
        $avenir = Examen::with('matiere')
            ->whereDate('date_examen', '>', Carbon::today()) 
            ->whereDoesntHave('passages', fn($q) => $q->where('user_id', $user->id))
            ->when($recherche, function ($q) use ($recherche) {
                $q->whereHas('matiere', fn($q2) => $q2->where('nom', 'like', "%$recherche%"));
            })
            ->orderBy('date_examen', 'asc')
            ->take(2)
            ->get();

        return response()->json([
            'recents' => $recents->map(fn($p) => $this->formatPassage($p)),
            'avenir' => $avenir->map(fn($e) => $this->formatExamen($e)),
        ]);
    }

    /**
     * liste des examens passés
     */
    public function getPasses(Request $request)
    {
        return response()->json(
            PassageExamen::with(['examen.matiere'])
                ->where('user_id', $request->user()->id)
                ->orderBy('date_passage', 'desc')
                ->get()
                ->map(fn($p) => $this->formatPassage($p))
        );
    }

    /**
     * Liste complète des examens à venir
     */
    public function getAvenir(Request $request)
    {
        return response()->json(
            Examen::with('matiere')
                ->whereDate('date_examen', '>', Carbon::today()) // à venir
                ->orderBy('date_examen', 'asc')
                ->get()
                ->map(fn($e) => $this->formatExamen($e))
        );
    }

    /**
     * Liste complète des examens d' AUJOURD'HUI 
     */
   public function getAujourdhui(Request $request)
{
    $user = $request->user();

    // On récupère les examens d'aujourd'hui...
    $aujourdhui = Examen::with('matiere')
        ->whereDate('date_examen', now()->toDateString())
        // ... MAIS on exclut ceux qui ont déjà une ligne dans passage_examens pour cet utilisateur
        ->whereDoesntHave('passages', function ($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->get();

    return response()->json($aujourdhui->map(fn($e) => $this->formatExamen($e)));
}

    /**
     * Récupération de la correction dynamique pour un examen
     */
 public function getCorrection($id, Request $request) {
    $user = $request->user();
    $examen = Examen::with(['questions.propositions', 'matiere'])->findOrFail($id);

    // Récupérer uniquement les réponses de cet étudiant pour cet examen
    $idsQuestions = $examen->questions->pluck('id_question');
    $reponsesEtudiant = DB::table('reponses')
        ->where('id_etudiant', $user->id)
        ->whereIn('id_question', $idsQuestions)
        ->get()
        ->keyBy('id_question');

    $questionsData = $examen->questions->map(function ($q) use ($reponsesEtudiant) {
        $rep = $reponsesEtudiant[$q->id_question] ?? null;
        $correctProp = $q->propositions->where('est_vrai', 1)->first();
        
        $status = 'non_repondu';
        $userTexte = 'Aucune réponse sélectionnée';

        if ($rep) {
            $userProp = $q->propositions->where('id_proposition', $rep->id_proposition)->first();
            if ($userProp) {
                $userTexte = $userProp->texte;
                $status = ($userProp->est_vrai == 1) ? 'correct' : 'faux';
            }
        }

        return [
            'enonce' => $q->enonce,
            'status' => $status, 
            'votre_reponse' => $userTexte,
            'reponse_correcte' => $correctProp ? $correctProp->texte : 'N/A',
        ];
    });

    return response()->json([
        'titre' => $examen->matiere->nom,
        'correctes' => $questionsData->where('status', 'correct')->count(),
        'fausses' => $questionsData->where('status', 'faux')->count(),
        'non_repondues' => $questionsData->where('status', 'non_repondu')->count(),
        'total' => $questionsData->count(),
        'questions' => $questionsData
    ]);
}

    // --- Fonctions privées de formatage ---

    private function formatPassage($p)
    {
        return [
            'id_examen' => $p->examen->id_examen,
            'titre' => $p->examen->matiere->nom,
            'enseignant' => $p->examen->matiere->enseignant ?? 'Non assigné',
            'date' => Carbon::parse($p->date_passage)->format('Y-m-d'),
            'heure' => Carbon::parse($p->date_passage)->format('H:i'),
            'duree' => $p->examen->duree . " minutes",
            'note_obtenue' => $p->note . "/20",
        ];
    }

    private function formatExamen($e)
    {
        return [
            'id_examen' => $e->id_examen,
            'titre' => $e->matiere->nom,
            'enseignant' => $e->matiere->enseignant ?? 'Non assigné',
            'date' => Carbon::parse($e->date_examen)->format('Y-m-d'),
            'heure' => Carbon::parse($e->date_examen)->format('H:i'),
            'duree' => $e->duree . " minutes",
        ];
    }

    public function postReclamation(Request $request) {
    // 1. Validation
    $request->validate([
        'id_examen' => 'required',
        'message' => 'required|min:5'
    ]);

    $user = $request->user();

    try {

        DB::table('reclamations')->insert([
            'message' => $request->message,
            'statut' => 'en_attente',
            'id_etudiant' => $user->id,
            'id_examen' => $request->id_examen,
            'date_depot' => now()
        ]);

        //  Récupérer le nom de la matière pour l'email
        $matiereNom = DB::table('examen')
            ->join('matieres', 'examen.id_matiere', '=', 'matieres.id')
            ->where('examen.id_examen', $request->id_examen)
            ->value('matieres.nom');

        //  Envoi Email via Mailtrap
        $details = [
            'user' => $user->nom . ' ' . $user->prenom,
            'matiere' => $matiereNom ?? 'Inconnue',
            'message' => $request->message
        ];

        Mail::to('administration@um5.ac.ma')->send(new \App\Mail\ReclamationMail($details));

        return response()->json(['message' => 'Réclamation transmise avec succès'], 200);

    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Erreur technique lors de l\'enregistrement',
            'error_debug' => $e->getMessage()
        ], 500);
    }
}

// 1. Récupérer les questions (Diagramme : afficherQuestions)
public function getQuestions($id) {
    $examen = Examen::with(['questions.propositions'])->findOrFail($id);
    return response()->json([
        'titre' => $examen->titre,
        'duree' => (int)$examen->duree,
        'total_questions' => $examen->questions->count(),
        'questions' => $examen->questions->map(fn($q) => [
            'id' => $q->id_question,
            'enonce' => $q->enonce,
            'propositions' => $q->propositions->map(fn($p) => [
                'id' => $p->id_proposition,
                'texte' => $p->texte
            ])
        ])
    ]);
}

// --- ENREGISTREMENT FINAL (Appelé une seule fois à la fin) ---
public function soumettre(Request $request, $id) {
    $user = $request->user();
    // Reçoit un JSON comme : {"10": 501, "11": 505} 
    // (id_question => id_proposition)
    $reponsesEnvoyees = $request->input('reponses'); 

    $examen = Examen::with('questions')->findOrFail($id);
    $noteFinale = 0;
    $pointsParQ = 20 / $examen->questions->count();

    // On boucle sur toutes les questions de l'examen
    foreach ($examen->questions as $question) {
        $idQ = $question->id_question; 
        
        // On vérifie si l'étudiant a donné une réponse pour CETTE question
        $idPropChoisie = $reponsesEnvoyees[$idQ] ?? null;

        if ($idPropChoisie) {
            // A. On enregistre la réponse dans la table 'reponses'
            DB::table('reponses')->insert([
                'id_etudiant' => $user->id,
                'id_question' => $idQ,
                'id_proposition' => $idPropChoisie,
                'created_at' => now()
            ]);

            // B. On vérifie si la proposition choisie est marquée 'est_vrai = 1'
            $correct = DB::table('propositions')
                ->where('id_proposition', $idPropChoisie)
                ->where('est_vrai', 1)
                ->exists();

            if ($correct) {
                $noteFinale += $pointsParQ;
            }
        }
        // Si pas d'idPropChoisie, on n'insère rien : la question restera "non répondue"
    }

    // C. Enregistrement de la note globale dans 'passage_examens'
    DB::table('passage_examens')->updateOrInsert(
        ['examen_id' => $id, 'user_id' => $user->id],
        ['note' => round($noteFinale, 2), 'date_passage' => now(), 'created_at' => now()]
    );

    return response()->json(['success' => true]);
}
}