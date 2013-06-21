package scenariofactory.widgets
{

	// classe de chargement
	import flash.net.URLLoader;
	// classe fournissant des valeurs qui déterminent le mode de réception des données téléchargées
	import flash.net.URLLoaderDataFormat;
	// classe pour les URL de chargement
	import flash.net.URLRequest;
	//  classe d'événements
	import flash.events.Event;
	// classe pour refléter simplement le code d’état HTTP
	import flash.events.HTTPStatusEvent;
	// classe pour accéder aux informations sur l'échec d’une opération d’envoi ou de chargement.
	import flash.events.IOErrorEvent;
	// classes Timer
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	// classe globale
	import GlobalVarContainer;

	// classes du modèle
	import Evenement_jeu;
	import Message;
	import scenariofactory.Scenario;

	public class OdontoGame extends Widget
	{
		const DUREE:Number = 10;

		// variable d'état
		public var gameIsLoaded:Boolean = false;
		public var dureeEnSecondes:Number;
		// déclaration du chargeur
		private var chargeur:URLLoader;

		// attributs
		private var listeEvenements_jeu:Array;
		private var nbEvenements_jeu:Number;
		public var nbEvenements_jeu_lances:Number = 0;
		private var listeMessages:Array;
		private var nbMessages:Number;
		public var listeTempsPoisson:Array;
		private var evenementEnCours:Evenement_jeu;

		// Timer
		private var gameTimerO:Timer;

		// constructeur
		public function OdontoGame()
		{
			// création de l'objet OdontoGame
			trace("occurence de OdontoGame : " + this.name);

			// initialisation
			this.listeEvenements_jeu = [];
			this.nbEvenements_jeu = 0;
			GlobalVarContainer.vars.nbChargementsEnCours = 0;

			gameTimerO = new Timer(1000,0);
			gameTimerO.addEventListener("timer",checkLoading);
			gameTimerO.start();
		}

		private function checkLoading(event:Event)
		{
			// teste si le nombre de chargements en cours est = 0
			trace("checkLoading : nbChargementsEnCours=" + GlobalVarContainer.vars.nbChargementsEnCours);
			if (GlobalVarContainer.vars.nbChargementsEnCours == 0)
			{
				gameTimerO.stop();
				afficheDonnees();
			}
		}

		public function load():void
		{
			trace("load...");
			var gameFile:String = "./dalada/jeu.scenario";

			// création du loader
			chargeur = new URLLoader  ;
			// choix du format
			chargeur.dataFormat = URLLoaderDataFormat.TEXT;
			// écouteurs
			chargeur.addEventListener(Event.COMPLETE,chargementTermine);
			chargeur.addEventListener(HTTPStatusEvent.HTTP_STATUS,codeHTTP);
			chargeur.addEventListener(IOErrorEvent.IO_ERROR,erreurChargement);
			// chargement du scénario;
			trace("   chargement de " + gameFile);
			chargeur.load(new URLRequest(gameFile));
			GlobalVarContainer.vars.nbChargementsEnCours++;
		}

		private function chargementTermine(pEvt:Event):void
		{
			trace("   chargement terminé");
			// transformation de la chaîne en xml
			var donnneesXML:XML = new XML(pEvt.target.data);
			// création des listes
			creeObjets(donnneesXML);
			// affichage des données
			GlobalVarContainer.vars.nbChargementsEnCours--;

			// temporaire
			Scenario.getInstance().messageGeneral.texteMessage.width = 307;
			Scenario.getInstance().messageGeneral.texteMessage.height = 560; // 400 (pour voir la zone de débug)
		}
		private function codeHTTP(pEvt:HTTPStatusEvent):void
		{
			// affiche : 0
			trace("code HTTP : " + pEvt.status);
		}
		private function erreurChargement(pEvt:IOErrorEvent):void
		{
			trace("erreur de chargement");
		}
		private function creeObjets(pXML:XML):void
		{
			trace("\n---------------------------------------------------------------------------------------------");
			trace("dans creeObjets()");
			// namespace
			//var xx:Namespace = new Namespace("http://www.w3.org/2001/XMLSchema-instance");

			var duree:String = pXML. @ duree;
			this.dureeEnSecondes = Number(duree);
			trace("\dureeEnSecondes=" + dureeEnSecondes);

			for each (var element:XML in pXML.*)
			{
				// repose_sur
				if (element.name() == "repose_sur")
				{
					// création de l'événement
					var evenement_jeu:Evenement_jeu = new Evenement_jeu(element);
				}
				this.listeEvenements_jeu = Evenement_jeu.listeEvenements;
				this.nbEvenements_jeu = Evenement_jeu.nbEvenements;
			}
			// création des temps de Poisson
			this.listeTempsPoisson = creeTempsPoisson();

			// jeu prêt
			this.gameIsLoaded = true;
		}
		public function creeTempsPoisson():Array
		{
			// temps
			//var liste:Array = [11, 23, 40, 55];
			var liste:Array = [5, 40];
			return liste;
		}
		public function tempsEvenementAtteint():Boolean
		{
			// test si temps de jeu > prochain temps
			if (Scenario.getInstance().gameTimer.currentCount > this.listeTempsPoisson[0])
			{
				// temps atteint
				trace("temps de jeu : " + Scenario.getInstance().gameTimer.currentCount + ", listeTempsPoisson : " + listeTempsPoisson);
				listeTempsPoisson.shift();
				return true;
			}
			else
			{
				return false;
			}
		}
		public function tempsFinDeJeuAtteint():Boolean
		{
			// test si temps de jeu > temps limite
			if (Scenario.getInstance().gameTimer.currentCount >= this.dureeEnSecondes)
			{
				// fin de jeu
				trace("\n---------------------------------------------------------------------------------------------");
				trace("fin de jeu");
				trace("---------------------------------------------------------------------------------------------");
				return true;
			}
			else
			{
				return false;
			}
		}
		public function GameIsReady():Boolean
		{
			trace("gameIsLoaded : " + gameIsLoaded);
			if (gameIsLoaded == true)
			{
				// affichage du téléphone
				Scenario.getInstance().telephone.rendreVisible();

				return true;
			}
			else
			{
				return false;
			}
		}
		function afficheDonnees():void
		{
			trace("\n---------------------------------------------------------------------------------------------");
			trace("---------------------------------------------------------------------------------------------");
			trace("Données du jeu : " + this.nbEvenements_jeu + " événement(s)");
			for (var i:Number = 0; i < this.listeEvenements_jeu.length; i++)
			{
				var unEvenement:Evenement_jeu = listeEvenements_jeu[i];
				unEvenement.traceEvenement();
			}
			trace("\n---------------------------------------------------------------------------------------------");
			trace("---------------------------------------------------------------------------------------------");
		}
		public function lanceEvenement():void
		{
			for (var i:Number = 0; i < this.listeEvenements_jeu.length; i++)
			{
				//var unEvenement:Evenement_jeu = listeEvenements_jeu[i];
				// on fait descendre la pile d'événements
				var unEvenement:Evenement_jeu = listeEvenements_jeu.shift();
				listeEvenements_jeu.push(unEvenement);
				// si cet événement pas déjà joué et pas d'autre événéments en cours 
				if (! unEvenement.dejaJoue && ! Evenement_jeu.evenementsEnCours)
				{
					nbEvenements_jeu_lances++;
					trace("\n---------------------------------------------------------------------------------------------");
					trace("Lancement d'un événement, time=" + Scenario.getInstance().gameTimer.currentCount + ", nombre d'événements lancés =" + nbEvenements_jeu_lances);
					// nombre d'événements lancés
					this.evenementEnCours = unEvenement;
					// indicateur événement en cours
					Evenement_jeu.evenementsEnCours = true;
					// test du type
					switch (unEvenement.type)
					{
						case "org.unf3s.dalada:Evt_Tel" :
							// seulement si téléphone pas décroché
							if (!Scenario.getInstance().telephone.decroche)
							{
								lanceEvenementTelephonique(unEvenement);
							}
							break;
						default :
							trace("   Evénement non répertorié");
					}

					trace("\n---------------------------------------------------------------------------------------------");
					break;
				}
			}
		}
		private function lanceEvenementTelephonique(evenement:Evenement_jeu):void
		{
			trace("   Evénement téléphonique");
			var id:Number = evenement.id;
			// téléphone
			Scenario.getInstance().telephone.sonner();
			
			/* création des règles :
			decrocher : si décroche alors (vaut acceptation du cas : placement de la séance dans un endroit libre dans le futur)
			- événement en cours > True
			- destruction règle "decrocher"
			- activation règle "raccrocher"
			- destruction règle "pas_decrocher"
			- message 1 + cet événement est joué
			- création de séquence
			
			raccrocher : si raccroche (après avoir décroché) alors 
			- destruction règle raccrocher
			- evenementsEnCours > false
			
			pas_decrocher : si décroche pas après certaine durée alors 
			- arrêter sonnerie
			- plus d'événement en cours
			- destruction règle "pas_decrocher"
			- destruction règle "decrocher"
			- destruction règle "raccrocher"
			- malus
			
			suite :
				- oui/non - 1h [OU séance créée autom dans agenda]
				
				- doit planifer/définir les actions de la séance dans le fichier patient - 3h
				- temps avance, lorsque arrive à la séance question :  - 1h
					- actions prévue faites autom et annoncées - 1h
				- question diag 1 ou 2 ? > widget- 2h
					selon le diag il doit créer les autre séances / agenda et définir les actions dans le dossier
					
			*/
			// règle de décrochage téléphone
			var regleXML:XML = <regle nom="decrocher" active="true"><conditions><condition cible="telephone" methode="estDecroche" valeur="true"/></conditions><evenements><evenement nom="message"/></evenements></regle>;
			Scenario.getInstance().creerRegle(regleXML);
			// règle de raccrochage téléphone
			regleXML = <regle nom="raccrocher" active="false"><conditions><condition cible="telephone" methode="estDecroche" valeur="false"/></conditions><evenements><evenement nom="raccroche"/></evenements></regle>;
			Scenario.getInstance().creerRegle(regleXML);
			// règle de fin de sonnerie après 7 secondes
			regleXML = <regle nom="pas_decrocher" active="true"><conditions><condition cible="telephone" methode="getSonnerie" valeur="7"/></conditions><evenements><evenement nom="passe_evenement"/></evenements></regle>;
			Scenario.getInstance().creerRegle(regleXML);
			// règle d'acceptation de patient
			regleXML = <regle nom="acceptation_patient" active="true"><conditions><condition cible="bouton_oui_non" methode="getAnswer" valeur="oui"/></conditions><evenements><evenement nom="acceptation_patient"/></evenements></regle>;
			Scenario.getInstance().creerRegle(regleXML);
			// règle de refus de patient
			regleXML = <regle nom="refus_patient" active="true"><conditions><condition cible="bouton_oui_non" methode="getAnswer" valeur="non"/></conditions><evenements><evenement nom="refus_patient"/></evenements></regle>;
			Scenario.getInstance().creerRegle(regleXML);
			
			// événement message
			var evenementXML:XML = <evenement nom="message">
			<effet cible="odonto_game" action="lanceMessageTelephonique" parametre=""/>
			<effet cible="decrocher" action="detruire" typeCible="regle" />
			<effet cible="raccrocher" action="rendreActive" typeCible="regle" />
			<effet cible="pas_decrocher" action="detruire" typeCible="regle" />
			<effet cible="bouton_oui_non" action="rendreVisible" parametre=""/>
			<effet cible="bouton_oui_non" action="setQuestion" parametre="variable">
				<variable nom="texte" valeur="Acceptez-vous ce patient ?" />
			</effet>
			<effet cible="bouton_oui_non" action="rendreVisible" parametre=""/>
			</evenement>;
			Scenario.getInstance().creerEvenement(evenementXML);

			// événement raccroche
			evenementXML = <evenement nom="raccroche">
			<effet cible="raccrocher" action="detruire" typeCible="regle" />
			<effet cible="odonto_game" action="plusEvenementEnCours" parametre=""/>
			</evenement>;
			Scenario.getInstance().creerEvenement(evenementXML);

			// événement passe_evenement
			evenementXML = <evenement nom="passe_evenement">
			<effet cible="telephone" action="arreter" parametre="" />
			<effet cible="pas_decrocher" action="detruire" typeCible="regle" />
			<effet cible="decrocher" action="detruire" typeCible="regle" />
			<effet cible="raccrocher" action="detruire" typeCible="regle" />
			<effet cible="odonto_game" action="passeEvenementEnCours" parametre=""/>
			</evenement>;
			Scenario.getInstance().creerEvenement(evenementXML);

			// événement acceptation_patient
			evenementXML = <evenement nom="acceptation_patient">
			<effet cible="acceptation_patient" action="detruire" typeCible="regle" />
			<effet cible="refus_patient" action="detruire" typeCible="regle" />
			<effet cible="odonto_game" action="accepteOuRefusePatient" parametre="variable">
				<variable nom="resultat" valeur="oui" />
			</effet>
			</evenement>;
			Scenario.getInstance().creerEvenement(evenementXML);

			// événement refus_patient
			evenementXML = <evenement nom="refus_patient">
			<effet cible="acceptation_patient" action="detruire" typeCible="regle" />
			<effet cible="refus_patient" action="detruire" typeCible="regle" />
			<effet cible="odonto_game" action="accepteOuRefusePatient" parametre="variable">
				<variable nom="resultat" valeur="non" />
			</effet>
			</evenement>;
			Scenario.getInstance().creerEvenement(evenementXML);

		}
		public function accepteOuRefusePatient(liste:Array):void
		{
			trace("   accepteOuRefusePatient (événement : "+this.evenementEnCours.libelle+") : "+liste[1]);
		}
		public function lanceMessageTelephonique():void
		{
			trace("   Message téléphonique (événement : "+this.evenementEnCours.libelle+")");
			Scenario.getInstance().messageGeneral.rendreVisible();
			Scenario.getInstance().messageGeneral._afficherMessage(this.evenementEnCours.listeMessages[0].message_ + "\n");
			// cet événement est joué
			this.evenementEnCours.dejaJoue = true;
		}
		public function plusEvenementEnCours():void
		{
			trace("   plus d'événement en cours");
			// pas d'événement en cours
			Evenement_jeu.evenementsEnCours = false;
		}
		public function passeEvenementEnCours():void
		{
			trace("   événement en cours passé");
			// pas d'événement en cours
			Evenement_jeu.evenementsEnCours = false;
			// malus
			this.evenementEnCours.malus = true;
		}
	}
}