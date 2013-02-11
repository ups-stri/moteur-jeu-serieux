﻿package scenariofactory.widgets
{

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;

	public class RadioButtonsSimple extends Widget
	{

		private var titre:String;
		var isSelected:String = "";

		// constructor
		public function RadioButtonsSimple()
		{
			trace("occurence of RadioButtonsSimple : "+this.name);
			// interactivity
			this.addEventListener(MouseEvent.CLICK, clickEvent);
		}

		private function clickEvent(e:MouseEvent):void
		{
			trace("click on "+e.target.name);
			this.isSelected = e.target.label;
			trace("   > choice: "+this.isSelected);
		}

		public function setTitre(liste:Array):void
		{
			trace("setTitre()");
			titre = liste[1];
			this.titreChoix.text = titre;
		}
		
		public function setLabels(liste:Array):void
		{
			trace("setLabels()");
			for (var item:String in liste) {
				trace("   item="+item+", texte="+liste[item].texte);
				this["button"+item].label = liste[item].texte;
			}
		}
		
		public function setCheckedLabel(liste:Array):void
		{
			trace("setCheckedLabel() : liste="+liste[1]);
			this["button"+liste[1]].selected = true;
			this.isSelected = this["button"+liste[1]].label;
		}

		public function getCheckedLabel():String
		{
			trace("getCheckedLabel(): "+this.isSelected);
			return this.isSelected;
		}


		public function disableButton():void
		{
			this[this.name].enabled = false;
		}
		public function enableButton():void
		{
			this[this.name].enabled = true;
		}
	}
}