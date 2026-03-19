<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Examen;
use App\Models\PassageExamen;
use Carbon\Carbon;

class ExamenController 
{
    public function getDashboardData(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['error' => 'Non authentifié'], 401);
        }

        $recherche = $request->query('recherche');

        $recents = PassageExamen::with(['examen.matiere'])
            ->where('user_id', $user->id)
            ->when($recherche, function ($q) use ($recherche) {
                $q->whereHas('examen.matiere', function ($q2) use ($recherche) {
                    $q2->where('nom', 'like', "%$recherche%");
                });
            })
            ->orderBy('date_passage', 'desc')
            ->take(2)
            ->get();

        $avenir = Examen::with('matiere')
            ->where('date_examen', '>', now())
            ->when($recherche, function ($q) use ($recherche) {
                $q->whereHas('matiere', function ($q2) use ($recherche) {
                    $q2->where('nom', 'like', "%$recherche%");
                });
            })
             ->orderBy('date_examen', 'asc') //  IMPORTANT (ordre logique)
             ->take(2) 
             ->get();

        return response()->json([
            'recents' => $recents->map(fn($p) => $this->formatPassage($p)),
            'avenir' => $avenir->map(fn($e) => $this->formatExamen($e)),
        ]);
    }

    public function getPasses(Request $request)
    {
        return response()->json(
            PassageExamen::with(['examen.matiere'])
                ->where('user_id', $request->user()->id)
                ->get()
                ->map(fn($p) => $this->formatPassage($p))
        );
    }

    public function getAvenir(Request $request)
    {
        return response()->json(
            Examen::with('matiere')
                ->where('date_examen', '>', now())
                ->get()
                ->map(fn($e) => $this->formatExamen($e))
        );
    }

    public function getAujourdhui(Request $request)
    {
        return response()->json(
            Examen::with('matiere')
                ->whereDate('date_examen', now()->toDateString())
                ->get()
                ->map(fn($e) => $this->formatExamen($e))
        );
    }

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