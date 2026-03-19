<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

// PAS BESOIN DE "use App\Http\Controllers\Controller" car il est déjà dans le même namespace
class ProfileController
{
    public function show(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Non authentifié'], 401);
        }
        
        return response()->json($user->load('filiere'), 200);
    }

    public function update(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'email' => 'sometimes|email|unique:users,email,'.$user->id,
            'password' => 'sometimes|min:6'
        ]);

        $user->update($request->only(['nom', 'prenom', 'email']));
        
        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
            $user->save();
        }

        return response()->json([
            'message' => 'Profil mis à jour',
            'user' => $user->load('filiere')
        ], 200);
    }
}