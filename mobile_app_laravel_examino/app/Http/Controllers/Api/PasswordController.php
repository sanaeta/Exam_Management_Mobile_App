<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PasswordController 
{
    // Étape 1 : envoyer code
    public function sendResetEmail(Request $request)
    {
        $request->validate([
            'email' => 'required|email'
        ]);

        // Normalisation email
        $email = strtolower(trim($request->email));

       $user = User::whereRaw('LOWER(email) = ?', [$email])->first();

        if (!$user) {
            return response()->json(['message' => 'Email non trouvé'], 404);
        }
    
        // Génération code STRING (important)
        $code = (string) rand(100000, 999999);

        // Insert / Update
        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $email],
            [
                'token' => $code,
                'created_at' => now()
            ]
        );

        // Envoi email
        Mail::raw("Votre code de sécurité Examino est : $code", function ($message) use ($email) {
            $message->to($email)->subject('Code de sécurité Examino');
        });

        return response()->json(['message' => 'Email envoyé'], 200);
    }

    // Étape 2 : vérifier code + reset password
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'code' => 'required',
            'password' => 'required|min:6'
        ]);

        $email = strtolower(trim($request->email));
        $codeSaisi = trim($request->code);

        $record = DB::table('password_reset_tokens')
            ->where('email', $email)
            ->first();

        if (!$record) {
            return response()->json(['message' => 'Aucun code généré pour cet email'], 400);
        }

        // Expiration (10 minutes)
        if (now()->diffInMinutes($record->created_at) > 10) {
            return response()->json(['message' => 'Code expiré'], 400);
        }

        // Comparaison stricte STRING
        if ((string)$record->token !== (string)$codeSaisi) {

            return response()->json([
                'message' => 'Code incorrect'
            ], 400);
        }

        // Update password
        $user = User::where('email', $email)->first();

        if (!$user) {
            return response()->json(['message' => 'Utilisateur introuvable'], 404);
        }

        $user->password = Hash::make($request->password);
        $user->save();

       

        return response()->json(['message' => 'Mot de passe réinitialisé avec succès'], 200);
    }
}