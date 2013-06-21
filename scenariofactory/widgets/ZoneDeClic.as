package scenariofactory.widgets{

	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import fl.controls.Button;
	import flash.events.MouseEvent;

	public class ZoneDeClic extends Button {

		var zoneCliquee:Boolean;
		var choix:String;
		var format:TextFormat = new TextFormat();

		// constructeur
		public function ZoneDeClic() {
			trace("occurence de ZoneDeClic : "+this.name);
			this.visible = false;
			zoneCliquee = false;
			// interactivité
			this.addEventListener(MouseEvent.CLICK, zoneAppuyee);

			// stylage et contenu initial du bouton
			format.size = 14;
			this.setStyle("textFormat", format);
			this.label = "";
		}

		private function zoneAppuyee(e:MouseEvent):void {
			zoneCliquee = true;
		}
		public function clique():Boolean {
			if (zoneCliquee==true) {
				// reset
				zoneCliquee = false;
				return true;
			} else {
				return false;
			}
		}
		public function estVisible():Boolean {
			if (this.visible==true) {
				return true;
			} else {
				return false;
			}
		}
		
		public function setLabel(liste:Array):void {
			trace("                dans setLabel de ZoneDeClic "+liste);
			this.label = liste[1];
		}
		
		public function setLabelVide():void {
			this.label = "";
		}

		public function rendreCliquable():void {
			//
			this.visible = true;
		}
		public function masquer():void {
			this.visible = false;
		}
		public function afficher():void {
			this.visible = true;
		}
		public function choixEffectue():String {
			trace("dans choixEffectue() : choix : "+choix);
			//
			return choix;
		}
	}
}