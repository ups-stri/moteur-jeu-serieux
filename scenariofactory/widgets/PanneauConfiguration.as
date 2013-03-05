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
			//this.visible = false;
			masquerPanel();
			// button
			boutonOpen.addEventListener(MouseEvent.CLICK, openPanel);
			boutonOK.addEventListener(MouseEvent.CLICK, closePanel);
			boutonWifi.addEventListener(MouseEvent.CLICK, HGoWifi);
			boutonPartage.addEventListener(MouseEvent.CLICK, HGoPartage);
			boutonVPN.addEventListener(MouseEvent.CLICK, HGoVPN);
		}

		private function openPanel(e:MouseEvent):void
		{
			goWifi();
			boutonOK.visible = true;
		}

		private function HGoWifi(e:MouseEvent):void
		{
			goWifi();
		}
		private function goWifi():void
		{
			this.gotoAndStop(5);
			boutonWifi.visible = false;
			boutonPartage.visible = true;
			boutonVPN.visible = true;
			choixWifi.rendreVisible();
			choixPartageReseau.masquer();
			loginForm.masquer();
		}

		private function HGoPartage(e:MouseEvent):void
		{
			this.gotoAndStop(10);
			boutonWifi.visible = true;
			boutonPartage.visible = false;
			boutonVPN.visible = true;
			choixWifi.masquer();
			choixPartageReseau.rendreVisible();
			loginForm.masquer();
		}

		private function HGoVPN(e:MouseEvent):void
		{
			this.gotoAndStop(15);
			boutonWifi.visible = true;
			boutonPartage.visible = true;
			boutonVPN.visible = false;
			choixWifi.masquer();
			choixPartageReseau.masquer();
			loginForm.rendreVisible();
		}

		private function masquerPanel():void {
			trace("boutonOK.visible : " + boutonOK.visible);
			boutonOK.visible = false;
			trace("boutonOK.visible : " + boutonOK.visible);
			loginForm.masquer();
			choixWifi.masquer();
			choixPartageReseau.masquer();			
		}
		
		public function fermer():void
		{
			trace("fermer");
			this.gotoAndStop(1);
			masquerPanel();
		}

		private function closePanel(e:MouseEvent):void
		{
			trace("closePanel");
			fermer();
		}

		public function changerUnPeu():void
		{
			loginForm.x = loginForm.x + 4;
			loginForm.y = loginForm.y + 4;
			boutonOK.y = boutonOK.y + 5;
		}


	}
}