﻿package scenariofactory.widgets
{

	import flash.events.Event;
	import flash.events.MouseEvent;

	public class ListeSimple2 extends Widget
	{

		var choix:String;

		// constructor
		public function ListeSimple2()
		{
			trace("occurence of ListeSimple2 : "+this.name);
		}

		public function remplirEtAfficher(liste:Array):void
		{
			trace("                dans afficher de ListeSimple "+liste);
			// fill the listbox
			listeItems.setSize(80, 22);
			listeItems.removeAll();
			//listeItems.prompt = "Selectionnez";
			for (var item:String in liste)
			{
				listeItems.addItem( { label:liste[item].texte, data:liste[item].evenement } );
			}
			listeItems.addEventListener(Event.CHANGE, definitChoix);
			listeItems.selectedIndex = 0;
			choix = listeItems.selectedItem.data;
		}

		private function definitChoix(e:Event):void
		{
			choix = listeItems.selectedItem.data;
			trace("dans definitChoix() : "+choix);
		}

		public function choixEffectue():String
		{
			trace("dans choixEffectue() : choix : "+choix);
			//
			return choix;
		}
	}
}