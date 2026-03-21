<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Examen;
use App\Models\PassageExamen;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class ExamenController 
{
    /**
     * Données pour la page d'accueil (Tableau de bord)
     * Affiche les 2 derniers passés et les 2 prochains (à partir de demain)
     */
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

        // 2. À VENIR : Les 2 prochains examens (Strictement APRÈS aujourd'hui)
        $avenir = Examen::with('matiere')
            ->whereDate('date_examen', '>', Carbon::today()) // ✅ FIX: Uniquement après aujourd'hui
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
     * Historique complet des examens passés
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
     * Liste complète des examens futurs (Demain et après)
     */
    public function getAvenir(Request $request)
    {
        return response()->json(
            Examen::with('matiere')
                ->whereDate('date_examen', '>', Carbon::today()) // ✅ FIX: Strictement futur
                ->orderBy('date_examen', 'asc')
                ->get()
                ->map(fn($e) => $this->formatExamen($e))
        );
    }

    /**
     * Liste complète des examens prévus pour AUJOURD'HUI uniquement
     */
    public function getAujourdhui(Request $request)
    {
        return response()->json(
            Examen::with('matiere')
                ->whereDate('date_examen', Carbon::today()) // ✅ FIX: Uniquement aujourd'hui
                ->orderBy('date_examen', 'asc')
                ->get()
                ->map(fn($e) => $this->formatExamen($e))
        );
    }

    /**
     * Récupération de la correction dynamique pour un examen
     */
    public function getCorrection($id, Request $request)
    {
        $user = $request->user();
        $examen = Examen::with(['questions.propositions', 'matiere'])->findOrFail($id);

        // On récupère les choix de l'utilisateur dans la table reponses
        // On utilise id_etudiant car c'est le nom dans ta migration reponses
        $userAnswers = DB::table('reponses')
            ->where('id_etudiant', $user->id)
            ->get()
            ->keyBy('id_question');

        $questionsData = $examen->questions->map(function ($q) use ($userAnswers) {
            $answer = $userAnswers[$q->id_question] ?? null;
            $correctProp = $q->propositions->where('est_vrai', 1)->first();
            $userProp = $answer ? $q->propositions->where('id_proposition', $answer->id_proposition)->first() : null;

            return [
                'id' => $q->id_question,
                'enonce' => $q->enonce,
                'is_correct' => $userProp ? (bool)$userProp->est_vrai : false,
                'votre_reponse' => $userProp ? $userProp->texte : 'Aucune réponse',
                'reponse_correcte' => $correctProp ? $correctProp->texte : 'N/A',
            ];
        });

        return response()->json([
            'titre' => $examen->matiere->nom,
            'correctes' => $questionsData->where('is_correct', true)->count(),
            'fausses' => $questionsData->where('is_correct', false)->count(),
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
}