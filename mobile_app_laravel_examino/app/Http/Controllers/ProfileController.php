<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ProfileController 
{
    public function show(Request $request)
    {
        return response()->json($request->user(), 200);
    }

    public function update(Request $request)
    {
        $user = $request->user();

        // Validation
        $request->validate([
            'nom' => 'sometimes|string|max:50',
            'prenom' => 'sometimes|string|max:50',
            'email' => 'sometimes|email|unique:users,email,'.$user->id,
            'password' => 'sometimes|min:6'
        ]);

        try {
            if ($request->has('nom')) $user->nom = $request->nom;
            if ($request->has('prenom')) $user->prenom = $request->prenom;
            if ($request->has('email')) $user->email = $request->email;
            
            if ($request->has('password') && !empty($request->password)) {
                $user->password = Hash::make($request->password);
            }

            $user->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Modification enregistrée avec succès !',
                'user' => $user
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Erreur serveur : ' . $e->getMessage()
            ], 500);
        }
    }
}