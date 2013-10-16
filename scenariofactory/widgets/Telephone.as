package scenariofactory.widgets
{

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.controls.ComboBox;
	import flash.media.Sound;
	import flash.media.SoundChannel;

	import flash.net.URLRequest;

	import flash.utils.Timer;
	import flash.events.TimerEvent;

	public class Telephone extends Widget
	{

		var decroche:Boolean;
		var dureeSonnerie:Number;
		var sonTelephone:Sound;
		var channel:SoundChannel;

		// Timer
		private var telephoneTimer:Timer;

		// constructeur
		public function Telephone()
		{
			trace("occurrence de Telephone : "+this.name);
			// arrêt de la l'animation de Telephone
			combine.stop();
			// sonnerie ;
			dureeSonnerie = 0;
			// interactivité
			combine.addEventListener(MouseEvent.CLICK, clicTelephone);
		}

		public function sonner():void
		{
			combine.gotoAndStop(6);
			// son;
			demarreSon();
			// sonnerie
			dureeSonnerie = 0;
			telephoneTimer = new Timer(1000,0);
			telephoneTimer.addEventListener("timer", compteDureeSonnerie);
			telephoneTimer.start();
		}
		public function demarreSon():void
		{
			// son;
			if (sonTelephone == null) {
				sonTelephone = new Sound();
				sonTelephone.load(new URLRequest("./actifs/sons/231.mp3"));
			}
			channel = new SoundChannel();
			channel = sonTelephone.play();
			channel.addEventListener(Event.SOUND_COMPLETE, boucle);
		}
		public function boucle(e:Event):void
		{
			trace("dans  boucle()");
			channel.removeEventListener(Event.SOUND_COMPLETE, boucle);
			demarreSon();
		}
		private function compteDureeSonnerie(event:Event)
		{
			dureeSonnerie++;
		}

		// arrêt de la sonnerie :
		// - du timer associé qui comptait le nb de sonneries
		// - de la boucle sur le son d'une sonnerie élémentaire
		private function arreterSonnerie():void{
			if (telephoneTimer != null) {
				telephoneTimer.stop();
			}
			dureeSonnerie = 0;
			if (channel != null) {
				channel.removeEventListener(Event.SOUND_COMPLETE, boucle);
				channel.stop();
			}
		}
		
		public function arreter():void
		{
			decroche = false;
			combine.gotoAndStop(1);
			repertoire.disparait();
			arreterSonnerie();
		}

		// MB : 18/10/11 : cette méthode n'a pas besoin d'être publique
		private function clicTelephone(e:MouseEvent):void
		{
			if (decroche)
			{
				repertoire.disparait();
				combine.gotoAndStop(1);
				decroche = false;
			}
			else
			{
				// on rend visible la liste de sélection du destinataire
				repertoire.rendreVisible();
				// le téléphone est décroché;
				combine.gotoAndStop(12);
				decroche = true;
				arreterSonnerie();
			}
		}

		public function estDecroche():Boolean
		{
			return decroche;
		}

		public function getSonnerie():Number
		{
			return dureeSonnerie;
		}
		
		// definir la hauteur du telephone sur ses composants
		override public function setHeight(liste:Array)
		{  
			// rapport hauteur - largeur 
			var rapport:Number = this.height / this.width;
			super.setHeight(liste);
			
			var list:Array = new Array();
			list[1] = this.height / rapport;
			//on repositionne le telephone
			super.setWidth(list);
		}
		
		// definir la largeur du telephone sur ses composants
		override public function setWidth(liste:Array)
		{
			// rapport hauteur-largeur 
			var rapport:Number = this.height / this.width;
			super.setWidth(liste);
			
			var list:Array = new Array();
			list[1] = this.width * rapport;
			// on repositionne le telephone
			super.setHeight(list);
		}
	}
}