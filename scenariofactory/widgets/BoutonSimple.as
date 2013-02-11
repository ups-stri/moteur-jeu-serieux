package scenariofactory.widgets{

	import flash.display.MovieClip;
	import fl.controls.Button;
	import flash.events.MouseEvent;

	public class BoutonSimple extends Button {

		var boutonClique:Boolean;

		// constructeur
		public function BoutonSimple() {
			trace("occurence de BoutonSimple : "+this.name);
			this.visible = false;
			boutonClique = false;
			// interactivité
			this.addEventListener(MouseEvent.CLICK, boutonAppuye);
		}

		private function boutonAppuye(e:MouseEvent):void {
			boutonClique = true;
		}
		public function clique():Boolean {
			if (boutonClique==true) {
				// reset
				boutonClique = false;
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

		public function masquer():void {
			this.visible = false;
		}
		public function afficher():void {
			this.visible = true;
		}
	}
}