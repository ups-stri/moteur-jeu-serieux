﻿package scenariofactory.widgets
{

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;

	public class CheckBoxSimple extends Widget
	{

		var isSelected:Boolean = false;

		// constructor
		public function CheckBoxSimple()
		{
			trace("occurence of CheckBoxSimple : "+this.name);
			// interactivity
			this.addEventListener(MouseEvent.CLICK, clickEvent);
		}

		private function clickEvent(e:MouseEvent):void
		{
			trace("click on "+e.target.name);
			this.isSelected =e.target.selected;
			trace("   > choice: "+this.isSelected);
		}

		public function setLabel(liste:Array):void
		{
			this.checkBox.label = liste[1];
		}
		
		public function check():void
		{
			trace("check()");
			this.checkBox.selected = true;
			this.isSelected = true;
		}

		public function uncheck():void
		{
			trace("uncheck()");
			this.checkBox.selected = false;
			this.isSelected = false;
		}

		public function getCheck():Boolean
		{
			trace("getCheck(): "+isSelected);
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