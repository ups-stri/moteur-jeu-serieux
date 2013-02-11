package scenariofactory.widgets{

	import flash.events.Event;
	import flash.events.MouseEvent;

	public class ListeSimple extends Widget {

		var choix:String = "";

		// constructor
		public function ListeSimple() {
			trace("occurence of ListeSimple : "+this.name);
			this.visible = false;
			// button
			boutonOK.visible = false;
		}

		public function remplirEtAfficher(liste:Array):void {
			remplir(liste);

			// display
			this.visible = true;
		}

		public function remplir(liste:Array):void {
			trace("                dans remplir de ListeSimple "+liste);
			// fill the listbox
			listeItems.setSize(100, 22);
			listeItems.removeAll();
			listeItems.prompt = "Selectionnez";
			for (var item:String in liste) {
				listeItems.addItem( { label:liste[item].texte, data:liste[item].evenement } );
			}
			choix = "";
			listeItems.addEventListener(Event.CHANGE, definitChoix);

			// display
			boutonOK.visible = false;
		}

		private function definitChoix(e:Event):void {
			trace("dans definitChoix()");
			// test
			//texte.text = "Sélection : "+listeItems.selectedItem.label+", "+listeItems.selectedItem.data;
			//
			choix = listeItems.selectedItem.data;
			// bouton
			if (choix != null) {
				boutonOK.visible = true;
			} else {
				boutonOK.visible = false;
			}
		}

		public function disparait():void {
			this.visible = false;
			listeItems.selectedIndex = -1;
			choix = "";
		}

		public function choixEffectue():String {
			trace("dans choixEffectue() : choix : "+choix);
			//
			return choix;
		}

	}
}