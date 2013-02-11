package scenariofactory.widgets
{

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	// classes Timer
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	// Carte: non nécessaire car scenariofactory.widgets.*; importés dans scenario
	//import Carte;

	public class Poker extends Widget
	{

		var scenarioChoisi:Number;
		var listeChoix:Array;
		private var nbChoix:Number;
		var container:Sprite;
		var listePositions:Array;
		var nouvelleMise:Array;
		var nbMises:Number;
		var indiceMise:Number;
		// cartes
		var carte1:Carte;
		var carte2:Carte;
		var carte3:Carte;
		var carte4:Carte;
		var carte5:Carte;
		var carte6:Carte;
		var carte7:Carte;
		var carte8:Carte;
		var carteMission:Carte;
		// Timer
		private var gameTimerMise:Timer;

		// constructor
		public function Poker()
		{
			trace("occurence of Poker : "+this.name);
			this.visible = false;
			boutonCouche.enabled = false;
			boutonSuit.enabled = false;
			boutonRelance.enabled = false;
			boutonVoir.enabled = false;
			boutonCouche.addEventListener(MouseEvent.CLICK, clicBouton);
			boutonSuit.addEventListener(MouseEvent.CLICK, clicBouton);
			boutonRelance.addEventListener(MouseEvent.CLICK, clicBouton);
			boutonVoir.addEventListener(MouseEvent.CLICK, clicBouton);
			//;
			listeChoix = new Array();
			nbChoix = 0;
			// positions des cartes
			listePositions = [[700,500],[770,500],[420,500],[490,500],[420,200],[490,200],[700,200],[770,200]];
			// container des cartes
			container = new Sprite  ;
			container.name = "container";
			container.x = 0;
			container.y = 0;
			addChild(container);
			// timer
			gameTimerMise = new Timer(1000,0);
			gameTimerMise.addEventListener("timer", ajouteUneMise);
		}

		private function clicBouton(e:MouseEvent):void
		{
			trace("clic sur "+e.target.name);
			nbChoix++;
			listeChoix[nbChoix] = e.target.name;
		}

		public function resetPoker():void
		{
			trace("resetPoker");
			nbChoix = 0;
			listeChoix = new Array();
			// container
			while (container.numChildren>0)
			{
				container.removeChildAt(0);
			}
			//mise
			for (var imi:Number=1; imi<5; imi++)
			{
				this["mise" + imi].texteMise.text = Number(0);
			}
			// message
			messageBox.text = "";
		}

		public function choixScenario():void
		{
			this.scenarioChoisi = Math.ceil(Math.random() * 3);
			//this.scenarioChoisi = Math.ceil(Math.random()*2);
			//this.scenarioChoisi = 3;

			trace("scenario : "+this.scenarioChoisi);
			// affichage 
			scenarioBox.text = "scenario " + this.scenarioChoisi;
		}

		public function masquerBox():void
		{
			messageBox.visible = false;
		}

		public function getScenario():Number
		{
			trace("getScenario : "+this.scenarioChoisi);
			return this.scenarioChoisi;
		}
		public function choix1():String
		{
			trace("choix1 : "+this.listeChoix[1]);
			return this.listeChoix[1];
		}
		public function choix2():String
		{
			trace("choix2 : "+this.listeChoix[2]);
			return this.listeChoix[2];
		}
		public function choix3():String
		{
			trace("choix3 : "+this.listeChoix[3]);
			return this.listeChoix[3];
		}
		public function ajouteMise(liste:Array):void
		{
			trace("ajouteMise");
			// nouvelle mise
			nouvelleMise = [];
			nbMises = 0;
			indiceMise = 1;
			for (var item:String in liste)
			{
				trace("   mise : "+item+"-"+liste[item].texte+"-"+liste[item].evenement);
				nbMises++;
				nouvelleMise[Number(item)] = [item,liste[item].texte,liste[item].evenement];
			}
			trace("   nombre de mises :"+nbMises);
			// timer
			gameTimerMise.start();
		}

		public function ajouteUneMise(event:Event)
		{
			// indiceMise va de 1 à 
			if (indiceMise <= nbMises)
			{
				trace("   mise "+indiceMise+", joueur "+nouvelleMise[indiceMise][1]+ " : "+Number(nouvelleMise[indiceMise][2]));
				// mise;
				var mise:Number = Number(nouvelleMise[indiceMise][2]);
				this["mise" + indiceMise].texteMise.text = Number(this["mise" + indiceMise].texteMise.text) + mise;
				// diminution des gains
				this["gain" + indiceMise].texteMise.text = Number(this["gain" + indiceMise].texteMise.text) - mise;
				// focus si mise non nulle
				if (mise != 0)
				{
					this["focus" + indiceMise].play();
				}
				indiceMise++;
			}
			else
			{
				gameTimerMise.stop();
			}
		}
		public function ajouteMise_old(liste:Array):void
		{
			trace("ajouteMise : "+this.scenarioChoisi);
			// mise
			for (var item:String in liste)
			{
				trace("   mise : "+item+"-"+liste[item].texte+"-"+liste[item].evenement);
				var im:Number = Number(item);
				var mise:Number = Number(liste[item].evenement);
				// mise
				this["mise" + im].texteMise.text = Number(this["mise" + im].texteMise.text) + mise;
				// diminution des gains
				this["gain" + im].texteMise.text = Number(this["gain" + im].texteMise.text) - mise;
			}
		}
		public function initialiseGains(liste:Array):void
		{
			trace("dans initialiseGains()");
			// gain
			for (var item:String in liste)
			{
				var imgi:Number = Number(item);
				var gainInitial:Number = Number(liste[item].evenement);
				this["gain" + imgi].texteMise.text = gainInitial;
				trace("   gain initial J"+imgi+" : "+gainInitial);
			}
		}
		public function afficheGains(liste:Array):void
		{
			trace("afficheGains : "+this.scenarioChoisi);
			// gain
			for (var item:String in liste)
			{
				trace("   gain : "+item+"-"+liste[item].texte+"-"+liste[item].evenement);
				var img:Number = Number(item);
				var gain:Number = Number(liste[item].evenement);
				this["gain" + img].texteMise.text = Number(this["gain" + img].texteMise.text) + gain;
			}
		}
		public function giveCards(liste:Array):void
		{
			trace("giveCards : "+this.scenarioChoisi);
			//messageBox.text = "distribution\n";
			// cartes
			for (var item:String in liste)
			{
				trace("   card : "+item+"-"+liste[item].texte+"-"+liste[item].evenement);
				displayOneCard(item,liste[item].texte,liste[item].evenement);
			}
		}
		public function displayOneCard(numero:String,joueur:String,carte:String):void
		{
			// carte
			var ic:Number = Number(numero);
			var icm1:Number = Number(numero) - 1;
			// carte attention : si paramètre, on ne peut pas utiliser directement le symbole sur la scène (provoque erreur)
			this["carte" + ic] = new Carte(numero,joueur,carte,container);
			this["carte" + ic].x = listePositions[icm1][0];
			this["carte" + ic].y = listePositions[icm1][1];
			this["carte" + ic].name = carte;
			this["carte" + ic].visible = true;
			container.addChild(this["carte"+ic]);
			// message;
			var msgOneCard:String = " card n°" + this["carte" + ic].numero + ", player : " + joueur + ", card " + carte + "\n";
			//messageBox.text = messageBox.text + msgOneCard;
		}
		public function showCards():void
		{
			trace("showCards");
			//messageBox.text = messageBox.text + "\n" + "cartes montrées";
			for (var ii=1; ii<=8; ii++)
			{
				this["carte" + ii].afficheImage();
			}
		}
		public function afficheInformations(liste:Array):void
		{
			trace("afficheInformations : "+this.scenarioChoisi);
			var msg:String = "";
			for (var item:String in liste)
			{
				trace("   information : "+item+"-"+liste[item].texte+"-"+liste[item].evenement);
				msg = msg + "   " + liste[item].texte + " : " + liste[item].evenement + "\n";
			}
			messageBox.text = messageBox.text + "\n" + msg;
		}
		public function activeBoutons():void
		{
			trace("activeBoutons");
			boutonCouche.enabled = true;
			boutonSuit.enabled = true;
			boutonRelance.enabled = true;
			boutonVoir.enabled = true;
		}
		public function activeSuit():void
		{
			boutonSuit.enabled = true;
		}
		public function inactiveSuit():void
		{
			boutonSuit.enabled = false;
		}
		public function activeRelance():void
		{
			boutonRelance.enabled = true;
		}
		public function inactiveRelance():void
		{
			boutonRelance.enabled = false;
		}
		public function activeCouche():void
		{
			boutonCouche.enabled = true;
		}
		public function inactiveCouche():void
		{
			boutonCouche.enabled = false;
		}
		public function activeVoir():void
		{
			boutonVoir.enabled = true;
		}
		public function inactiveVoir():void
		{
			boutonVoir.enabled = false;
		}
		public function inactiveBoutons():void
		{
			trace("inactiveBoutons");
			boutonCouche.enabled = false;
			boutonSuit.enabled = false;
			boutonRelance.enabled = false;
			boutonVoir.enabled = false;
		}
		public function afficheMission(liste:Array)
		{
			//messageBox.text = messageBox.text + "\n" + liste[0] + "=" + liste[1] + " (scenario " + scenarioChoisi + ")";
			messageBox.text = messageBox.text + liste[0] + " : " + liste[1] + "\n";
			this.carteMission = new Carte("0","C",liste[1],container);
			this.carteMission.x = 571;
			this.carteMission.y = 280;
			this.carteMission.visible = true;
			container.addChild(this.carteMission);
		}
	}
}