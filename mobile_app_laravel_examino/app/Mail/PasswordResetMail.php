<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class PasswordResetMail extends Mailable
{
     public function build() {
        return $this->subject('Réinitialisation de votre mot de passe - Examino')
                    ->html("<h1>Bonjour,</h1><p>Vous avez demandé la réinitialisation de votre mot de passe.</p><p>Votre code temporaire est : <strong>123456</strong></p>");
    }
}
