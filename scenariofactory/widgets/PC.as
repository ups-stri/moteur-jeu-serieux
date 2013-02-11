﻿package scenariofactory.widgets
{

	import flash.events.Event;
	import flash.events.MouseEvent;

	public class PC extends Widget
	{

		var choix:String;
		var PSIsClicked:Boolean = false;
		var isOn:Boolean = false;
		var nbExtinctions:Number = 0;

		// constructor
		public function PC()
		{
			trace("occurence of PC : "+this.name);
			buttonPC.addEventListener(MouseEvent.CLICK, clicButtonPC);
			buttonOK.addEventListener(MouseEvent.CLICK, clicButtonOK);
			// visibility of elements: in .fla
		}

		private function clicButtonPC(e:Event):void
		{
			trace("dans clicButtonPC()");
			PSIsClicked = true;
			listeItems.visible = true;
			buttonOK.visible = true;
		}

		private function clicButtonOK(e:Event):void
		{
			trace("dans clicButtonOK()");
			listeItems.visible = false;
			buttonOK.visible = false;
		}

		public function resetClick():void
		{
			trace("dans resetClick()");
			PSIsClicked = false;
		}

		public function clickPC():Boolean
		{
			trace("dans clickPC()");
			return PSIsClicked;
		}

		public function fillAndDisplay(liste:Array):void
		{
			trace("                dans afficher de ListeSimple "+liste);
			// fill the listbox
			listeItems.setSize(100, 22);
			listeItems.removeAll();
			//listeItems.prompt = "Selectionnez";
			for (var item:String in liste)
			{
				listeItems.addItem( { label:liste[item].texte, data:liste[item].evenement } );
			}
			listeItems.addEventListener(Event.CHANGE, definitChoix);
			listeItems.selectedIndex = 0;
			choix = listeItems.selectedItem.data;
			listeItems.visible = true;
			buttonOK.visible = true;
		}

		private function definitChoix(e:Event):void
		{
			choix = listeItems.selectedItem.data;
			trace("dans definitChoix() : "+choix);
		}

		public function getChoice():String
		{
			trace("in getState() : choix : "+choix);
			return choix;
		}
		
		public function getState():Boolean
		{
			trace("in getState() : "+isOn);
			return isOn;
		}

		public function setOn():void
		{
			isOn = true;
			focusPC.visible = true;
		}
		public function setOff():void
		{
			isOn = false;
			focusPC.visible = false;
			nbExtinctions++;
		}

		public function getNbExtinctions():Number
		{
			return nbExtinctions;
		}
	}
}