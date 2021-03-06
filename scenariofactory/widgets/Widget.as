﻿package scenariofactory.widgets
{

	import flash.display.MovieClip;
	import scenariofactory.Scenario;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Widget extends MovieClip
	{

		private var frontable:Boolean;
		// constructeur
		public function Widget()
		{
			this.visible = false;
			// écouteur de clic sur ce widget
			this.addEventListener(MouseEvent.CLICK,bringToFront);
			this.frontable = true;

		}
	
		// methodes
		public function setFrontable():void
		{
			this.frontable = true;
		}
		
		public function unsetFrontable():void
		{
			this.frontable = false;
		}
		
		public function estVisible():Boolean
		{
			if (this.visible == true)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		public function masquer():void
		{
			this.visible = false;
		}
		public function rendreVisible():void
		{
			this.visible = true;
		}
		public function bringToFront(e:MouseEvent):void{
			if(this.frontable) {
				//Scenario.getInstance()._bringToFront(e);
			}
        }
		
		//definir la hauteur du widget
		public function setHeight(liste:Array)
		{
			this.height = Number(liste[1]);
		}
		
		//definir la largeur du widget
		public function setWidth(liste:Array)
		{
			this.width = Number(liste[1]);
		}
	}
}