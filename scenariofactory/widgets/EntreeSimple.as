﻿package scenariofactory.widgets
{

	import flash.events.Event;
	import flash.events.MouseEvent;

	public class EntreeSimple extends Widget
	{

		var valeurSaisie:String;
		var valeurPassword:String;
		private var authentifie:Boolean = false;

		// constructor
		public function EntreeSimple()
		{
			trace("occurence of EntreeSimple : "+this.name);
			this.visible = false;
			textInput.addEventListener(Event.CHANGE, verifierEntree);
		}

		private function verifierEntree(e:Event):void
		{
			valeurSaisie = textInput.text;
			if (valeurSaisie == valeurPassword) {
				authentifie = true;
				this.visible = false;
			}
		}

		public function definirPassword(liste:Array):void
		{
			trace("definirPassword() : " + liste[1]);
			// definition de variables internes existantes
			this.valeurPassword = liste[1];
		}

		/*
		   Function: estAuthentifie
		
		   Indique si l'authentification s'est passé avec succès.
		
		   Returns:
		
			  true si c'est bien le cas.
		
		   See Also:
		
			  <verifierEntree>
		*/
		public function estAuthentifie():Boolean {
			return authentifie;
		}

	}
}