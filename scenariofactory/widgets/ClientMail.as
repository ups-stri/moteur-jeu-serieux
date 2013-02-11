﻿package scenariofactory.widgets
{

	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class ClientMail extends Widget
	{

		// var active:Boolean = false; // not used
		var _mailOpen:Boolean = false;

		// constructor
		public function ClientMail()
		{
			trace("occurence of ClientMail : "+this.name);
			// interactivity
			this.iconeMail.addEventListener(MouseEvent.CLICK, clickOnIcon);
		}

		private function clickOnIcon(e:MouseEvent):void
		{
			if (this.iconeMail.enabled) {	// devrait être inutile
				this._mailOpen = !this._mailOpen;
				trace("click on "+e.target.name+", mail open: "+this._mailOpen);
			}
		}
		
		public function disableButton():void
		{
			trace("dans méthode disableButton");
			this.iconeMail.enabled = false;
			this.iconeMail.alpha = 0.5;
		}
		
		public function enableButton():void
		{
			this.iconeMail.enabled = true;
			this.iconeMail.alpha = 1.0;
		}

		public function mailOpen():Boolean
		{
			return _mailOpen;
		}
	}
}