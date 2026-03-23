<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ReclamationMail extends Mailable
{
   public $infos;
    public function __construct($infos) { $this->infos = $infos; }
    public function build() {
        return $this->subject('Nouvelle Réclamation - Examino')
                    ->html("<h2>Réclamation reçue</h2>
                            <p><strong>Étudiant(e) :</strong> {$this->infos['user']}</p>
                            <p><strong>Matière :</strong> {$this->infos['matiere']}</p>
                            <p><strong>Message :</strong> {$this->infos['message']}</p>");
    }
}
