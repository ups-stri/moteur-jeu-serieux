package scenariofactory.widgets
{

	import flash.events.Event;
	import flash.events.MouseEvent;

	public class PanneauConfiguration extends Widget
	{

		// MB : 20/10/11 : suppression des variables d'instance valeurSaisie et valeurPassword
		//                 déplacées dans LoginForm

		// constructor
		public function PanneauConfiguration()
		{
			trace("occurrence de PanneauConfiguration : "+this.name);
			this.visible = false;
			// button
			boutonOpen.addEventListener(MouseEvent.CLICK, openPanel);
			boutonOK.addEventListener(MouseEvent.CLICK, closePanel);
		}

		private function openPanel(e:MouseEvent):void
		{
			this.gotoAndStop(5);
			boutonOK.visible = true;
		}

		private function goWifi(e:MouseEvent):void
		{
			this.gotoAndStop(5);
		}

		private function goPartage(e:MouseEvent):void
		{
			this.gotoAndStop(10);
		}

		private function goVPN(e:MouseEvent):void
		{
			trace("goVPN");
			this.gotoAndStop(15);
		}

		private function closePanel(e:MouseEvent):void
		{
			this.gotoAndStop(1);
		}

		public function changerUnPeu():void
		{
			loginForm.x = loginForm.x + 4;
			loginForm.y = loginForm.y + 4;
			boutonOK.y = boutonOK.y + 5;
		}

		public function fermer():void
		{
			this.gotoAndStop(1);
		}


	}
}