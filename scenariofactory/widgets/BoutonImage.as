﻿package scenariofactory.widgets
{

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;

	public class BoutonImage extends Widget
	{

		var zoneCliquee:Boolean;
		var choix:String;

		// constructeur
		public function BoutonImage()
		{
			trace("occurence de BoutonImage : "+this.name);
			bouton_donne.visible = false;
			// interactivité
			this.addEventListener(MouseEvent.CLICK, zoneAppuyee);
			// les différents boutons sont appelés avec le même nom [évolution création dynamique avec l'image png]
			switch (this.name)
			{

				case "bouton_donne" :
					bouton_donne.visible = true;
					break;

				case 2 :
					break;

				case 3 :
					break;

			}
		}

		private function zoneAppuyee(e:MouseEvent):void
		{
			zoneCliquee = true;
		}
		public function clique():Boolean
		{
			if (zoneCliquee == true)
			{
				// reset
				zoneCliquee = false;
				return true;
			}
			else
			{
				return false;
			}
		}

		public function choixEffectue():String
		{
			trace("dans choixEffectue() : choix : "+choix);
			//
			return choix;
		}
		public function rendreInactif():void
		{
			this[this.name].enabled = false;
		}
		public function rendreActif():void
		{
			this[this.name].enabled = true;
		}
	}
}