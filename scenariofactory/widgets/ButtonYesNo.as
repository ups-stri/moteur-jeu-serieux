﻿package scenariofactory.widgets
{

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.text.TextField;

	public class ButtonYesNo extends Widget
	{
		// déclaration manuelle des occurrences de symboles placées sur la scène
		public var yes:SimpleButton;
		public var no:SimpleButton;
		public var textQuestion:TextField;

		var choice:String = "";

		// constructor
		public function ButtonYesNo()
		{
			trace("occurence of ButtonYesNo : "+this.name);
			// interactivity
			yes.addEventListener(MouseEvent.CLICK, clickButton);
			no.addEventListener(MouseEvent.CLICK, clickButton);
		}

		private function clickButton(e:MouseEvent):void
		{
			trace("click on "+e.target.name);
			// button disappears
			this.visible = false;
			this.choice = e.target.name;
			/*
			if (e.target.name == "noButton")
			{
			this.choice == "no";
			}
			else if (e.target.name == "yes")
			{
			this.choice == "yes";
			}
			*/
			trace("   > choice: "+this.choice);
		}

		public function setQuestion(liste:Array)
		{
			var motifRemplacementCR = /\\n/g;
			// display question
			textQuestion.text = liste[1].replace(motifRemplacementCR, "\n");
		}

		public function getAnswer():String
		{
			trace("getAnswer(): "+choice);
			return this.choice;
		}

		public function resetButton():void
		{
			trace("resetButton()");
			this.choice = "";
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