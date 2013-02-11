﻿package scenariofactory.widgets
{

	import flash.events.Event;
	import flash.events.MouseEvent;

	public class LoginForm extends Widget
	{
		private var message:String;
		private var login:String;
		private var motDePasse:String;

		private var loginSaisi:String;
		private var motDePasseSaisi:String;

		private var authentifie:Boolean = false;
		
		/*
		   Constructor: LoginForm
		
		   Initialise le formulaire login / mot de passe.
		*/
		public function LoginForm()
		{
			trace("occurrence de LoginForm : "+ this.name);
			this.visible = false;
			// button
			boutonValider.addEventListener(MouseEvent.CLICK, verifierAuthentification);
			boutonDeconnecter.addEventListener(MouseEvent.CLICK, deconnexion);
		}

		/*
		   Function: definirMessage
		
		   Définit le message introduisant la saisie du login et du mot de passe.
		
		   Parameters:
		
			  liste - liste[1] contient le message en question.
		*/
		public function definirMessage(liste:Array):void {
			this.message   = liste[1];
			messageLa.text = this.message;
			trace("définition message authentification : " + this.message);
		}
		// message complémentaire
		public function definirMessage2(liste:Array):void {
			this.message   = liste[1];
			message2La.text = this.message;
			trace("définition message complémentaire : " + this.message);
		}

		/*
		   Function: definirPassword
		
		   Définit le login et le mot de passe à saisir dans le formulaire.
		
		   Parameters:
		
			  liste - contenant les paramètres en question.
		
		   See Also:
		
			  <verifierAuthentification>
		*/
		public function definirLoginMotDePasse(liste:Array):void {
			this.login    = liste["1"].evenement;
			this.motDePasse = liste["2"].evenement;
			trace("définition login / mot de passe : " + login + " / " + motDePasse);
		}

		/*
		   Function: verifierAuthentification
		
		   Vérifie la validité du couple login / mot de passe.
		*/
		private function verifierAuthentification(e:MouseEvent):void {
			loginSaisi = loginTi.text;
			motDePasseSaisi = motDePasseTi.text;
			authentifie = (loginSaisi == login && motDePasseSaisi == motDePasse);
			erreurLa.visible = !authentifie;
			if (authentifie) {
				loginLa.visible = false;
				loginTi.visible = false;
				motDePasseLa.visible = false;
				motDePasseTi.visible = false;
				boutonValider.visible = false;
				boutonDeconnecter.visible = true;
			}
		}

		private function deconnexion(e:MouseEvent):void {
			deconnecter();
		}

		/*
		   Function: deconnecter
		
		   Effectue une déconnexion VPN de l'utilisateur.
		*/
		public function deconnecter():void {
			trace("déconnexion VPN");
			loginTi.text = "";;
			motDePasseTi.text = "";
			authentifie = false;
			loginLa.visible = true;
			loginTi.visible = true;
			motDePasseLa.visible = true;
			motDePasseTi.visible = true;
			boutonValider.visible = true;
			boutonDeconnecter.visible = false;
		}

		/*
		   Function: estAuthentifie
		
		   Indique si l'authentification s'est passé avec succès.
		
		   Returns:
		
			  true si c'est bien le cas.
		
		   See Also:
		
			  <verifierAuthentification>
		*/
		public function estAuthentifie():Boolean {
			return authentifie;
		}

	}
}