package scenariofactory
{
	import scenariofactory.widgets.BoutonImage;
	import scenariofactory.widgets.BoutonSimple;
	import scenariofactory.widgets.ButtonYesNo;
	import scenariofactory.widgets.Carte;
	import scenariofactory.widgets.CheckBoxSimple;
	import scenariofactory.widgets.ClientMail;
	import scenariofactory.widgets.Creneau;
	import scenariofactory.widgets.DossierPatients;
	import scenariofactory.widgets.EntreeSimple;
	import scenariofactory.widgets.ListeSimple;
	import scenariofactory.widgets.ListeSimple2;
	import scenariofactory.widgets.LoaderImage;
	import scenariofactory.widgets.LoaderVideo;
	import scenariofactory.widgets.LoaderXMLCase;
	import scenariofactory.widgets.LoginForm;
	import scenariofactory.widgets.MessageSimple;
	import scenariofactory.widgets.Mise;
	import scenariofactory.widgets.OdontoGame;
	import scenariofactory.widgets.PC;
	import scenariofactory.widgets.PanneauConfiguration;
	import scenariofactory.widgets.PatientAgenda;
	import scenariofactory.widgets.Poker;
	import scenariofactory.widgets.RadioButtonsSimple;
	import scenariofactory.widgets.Restitution;
	import scenariofactory.widgets.Telephone;
	import scenariofactory.widgets.TelephoneSimple;
	import scenariofactory.widgets.Widget;
	import scenariofactory.widgets.ZoneDeClic;
	import scenariofactory.widgets.Agenda;

	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	// classe de base
	// classe de chargement
	// classe fournissant des valeurs qui déterminent le mode de réception des données téléchargées
	// classe pour les URL de chargement
	//  classe d'événements
	// classe pour refléter simplement le code d’état HTTP
	// classe pour accéder aux informations sur l'échec d’une opération d’envoi ou de chargement.

	// classes Timer

	// Evenements et règles

	// widgets

	public dynamic class Scenario extends MovieClip {
		
		// singleton
		private static var _instance:Scenario=null;
		
		// jeu lancé
		public var jeuLance:Boolean = false;

		// déclaration du chargeur
		private var chargeur:URLLoader;

		// déclarations des éléments du scénario
		private var listeEvenements:Array;
		private var listeRegles:Array;
		private var listeCibles:Array;
		private var listeVariables:Array;
		private var nbEvenements:Number;
		private var nbRegles:Number;

		// Timer
		public var gameTimer:Timer;

		//public function Scenario(scenarioFile:String) {
		public function Scenario()
		{
			// instance de scénario
			_instance = this;
			
			//trace("Scenario : "+scenarioFile);
			var scenarioFile:String = "scenario.xml";
			// initialisations
			listeEvenements=new Array();
			listeRegles=new Array();
			listeCibles=new Array();
			listeVariables=new Array();
			nbEvenements = 0;
			nbRegles = 0;

			// création du loadeur
			chargeur = new URLLoader  ;
			// choix du format
			chargeur.dataFormat = URLLoaderDataFormat.TEXT;
			// écouteurs
			chargeur.addEventListener(Event.COMPLETE,chargementTermine);
			chargeur.addEventListener(HTTPStatusEvent.HTTP_STATUS,codeHTTP);
			chargeur.addEventListener(IOErrorEvent.IO_ERROR,erreurChargement);
			// chargement du scénario;
			trace("   chargement de "+scenarioFile);
			chargeur.load(new URLRequest(scenarioFile));

		}

		public static function getInstance():Scenario{
            return _instance;
        }
		
		public function _bringToFront(e:MouseEvent):void{
			trace("clic on "+e.currentTarget.name+", numChildren="+numChildren);
			// ciblage de l'objet qui reçoit l'événement (propriété currentTarget) puis cast en DisplayObjectContainer et changement d'index au plus haut (nombre d'enfants - 1, puisque ça commmence à 0)
			setChildIndex(DisplayObjectContainer(e.currentTarget),numChildren - 1);
        }
		
		private function chargementTermine(pEvt:Event):void
		{
			// transformation de la chaîne en xml
			var donnneesXML:XML = new XML(pEvt.target.data);
			// création des listes
			creerListes( donnneesXML );
			// affichages des cibles et des méthodes
			afficheCiblesEtMethodes();
			// changement de page dans le document et lancement de fonction test
			//myGotoAndStop(10,test3);
			// lancement moteur
			moteur2();

		}
		private function moteur2():void
		{
			// lancement
			jeuLance = true;
			// moteur (Classe Timer) : toutes les secondes, une infinité de fois
			gameTimer = new Timer(500,0);
			gameTimer.addEventListener("timer", checkRules);
			gameTimer.start();
		}

		public function jeuEstLance():Boolean
		{
			if (this.jeuLance == true)
			{
				return true;
			}
			else
			{
				return false;
			}
		}

		public function disableRules()
		{
			trace("in disableRules")
			for (var regle:String in listeRegles){	
				//if(listeRegles[regle].nom != "lancement"){
					listeRegles[regle].active = false;
				//}
			}
		}
		private function checkRules(event:Event)
		{
			trace("");
			trace("in checkRules : time="+gameTimer.currentCount);
			var nomCible:String;
			
			// règles
			for (var regle:String in listeRegles)
			{
				// test si règle est active
				if (listeRegles[regle].active && !listeRegles[regle].detruite)
				{
					trace("   % test de règle "+listeRegles[regle].nom);
					// tableau de conditions de cette règle
					var listeValeursDeCondition:Array = new Array();

					// boucle sur les conditions (si aucune condition alors valeurDeConditionFinale
					var valeurDeConditionFinale:Boolean = true;
					var nbConditions:Number = listeRegles[regle].listeConditions.length;
					if (nbConditions > 0)
					{
						trace("      nombre de conditions : "+listeRegles[regle].listeConditions.length);
						for (var m:Number = 0; m<listeRegles[regle].listeConditions.length; m++)
						{
							// initialisation
							listeValeursDeCondition[m] = false;
							// définition de la cible
							// MB : 20/10/11 : simplification et clarification du code de ce cas
							var condition:Object = listeRegles[regle].listeConditions[m];
							nomCible = condition.cible;
							var cibleR:Object = objetCibleParNom(nomCible);
							
							// définition de la méthode
							var methodeR = condition.methode;
							var valeurR = condition.valeur;
							trace("      test de condition : cible="+cibleR.name+", methode="+methodeR+", valeur="+valeurR);
							var test:String = cibleR[methodeR]();
							trace("         valeur de la méthode "+methodeR+" : "+test);
							// test
							if (test == valeurR)
							{
								listeValeursDeCondition[m] = true;
							}
							trace("         valeur de la condition : "+listeValeursDeCondition[m]);
						}
						// test final sur toutes les conditions ("ET")
						valeurDeConditionFinale = listeValeursDeCondition[0];

						for (var p:Number = 1; p<listeValeursDeCondition.length; p++)
						{
							valeurDeConditionFinale = valeurDeConditionFinale && listeValeursDeCondition[p];
						}
					}

					trace("      valeur de condition finale : "+valeurDeConditionFinale);

					if (valeurDeConditionFinale == true)
					{
						trace("         on lance les événements de cette règle");
						for (var l:Number = 0; l<listeRegles[regle].listeEvenements.length; l++)
						{
							var evenementRegle:String = listeRegles[regle].listeEvenements[l].nom;
							trace("            on lance les effets de l'evenement="+evenementRegle);
							for (var r:Number = 0; r<listeEvenements[evenementRegle].listeEffets.length; r++)
							{
								trace("               effet cible="+listeEvenements[evenementRegle].listeEffets[r].cible+", action="+listeEvenements[evenementRegle].listeEffets[r].action+", typeCible="+listeEvenements[evenementRegle].listeEffets[r].typeCible+", parametre="+listeEvenements[evenementRegle].listeEffets[r].parametre);
								// cible de la méthode;
								if (listeEvenements[evenementRegle].listeEffets[r].typeCible == "regle")
								{
									// on cible une règle
									var regleCible:String = listeEvenements[evenementRegle].listeEffets[r].cible;
									var action:String = listeEvenements[evenementRegle].listeEffets[r].action;
									//var cible2 = this[listeEvenements[evenementRegle].listeEffets[r].cible];
									trace("                  effet sur règle="+regleCible+", methode="+action+", la règle se nomme ");

									listeRegles[regleCible][action]();
								}
								else
								{
									// TBD mettre ce qui suit dans une fonction et traiter l'attribut "after"
									// MB : 20/10/11 : simplification et clarification du code de ce cas
									// on cible pour un effet
									// root (Document) ou une autre occurence de classe;
									var effet:Object = listeEvenements[evenementRegle].listeEffets[r];
									nomCible = effet.cible;
									var objetCible:Object = objetCibleParNom(nomCible);
									
									// action : avec ou sans paramètre requis (si pas de paramètre il y aura une chaîne vide)
									if (effet.parametre == "")
									{
										objetCible[effet.action]();
									}
									else
									{
										objetCible[effet.action](effet.listeItems);
									}
								}
							}
						}
					}
				}
			}
		}

		/*
		   Function: objetCibleParNom
		
		   Retourne l'objet (clip ou bouton) d'après le chemin cible.
		
		   Parameters:
		
			  nomCible - chemin cible du clip, sous forme String.
		
		   Returns:
		
			  Clip ou bouton ciblé.
		*/
		public function objetCibleParNom(nomCible:String):Object
		{
			var objetCible = this;
			var tabNomClip:Array = nomCible.split(".");
			
			if (nomCible != "root") {
				for (var i:Number = 0 ; i < tabNomClip.length ; i++) {
					objetCible = objetCible[tabNomClip[i]];
				}
			}
			
			return objetCible;
		}
		
		public function stoppeTemps()
		{
			// arrêt du timer 
			trace("                arrêt du timer");
			gameTimer.stop();
		}
		public function relanceTemps()
		{
			trace("                relance du timer");
			gameTimer.start();

		}
		public function creeVariable(liste:Array)
		{
			// sauvegarde de la variable
			listeVariables[liste[0]] = liste[1];
			trace("                  création d'une variable : nom="+liste[0]+", valeur="+listeVariables[liste[0]]);
			// création de la function de test
			
			this[liste[0]] = function () {
				trace("test de la variable "+listeVariables[liste[0]]);
				/*
				if(this.listeVariables[listeItems[0]] == listeItems[1]){
					trace("test  OK");
					return true;
				}else {
					trace("test  NOK");
					return false;
				}*/
				return listeVariables[liste[0]];
			}
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
		public function creerListes(pXML:XML):void
		{

			trace("dans creerListes()");
			trace(pXML);
			trace("");
			for each (var element:XML in pXML.*)
			{
				if (element.name() == "evenement")
				{
					creerEvenement(element);
				}
				else if (element.name() == "regle")
				{
					creerRegle(element);
				}
			}
			trace("");
		}

		function afficheCiblesEtMethodes():void
		{
			// recherche de cibles et méthodes

			var listeVide:Array = new Array();
			// évenements
			for (var evenement:String in listeEvenements)
			{
				var evenementCourant:Evenement = listeEvenements[evenement];
				for (var k:Number = 0; k<listeEvenements[evenement].listeEffets.length; k++)
				{
					var cibleE:String = listeEvenements[evenement].listeEffets[k].cible;
					if (listeCibles[cibleE] == null)
					{
						listeCibles[cibleE] = new Cible(cibleE,listeVide);
					}
					var action:String = listeEvenements[evenement].listeEffets[k].action;
					listeCibles[cibleE].listeMethodes.push(action);
				}
			}

			// règles;
			for (var regle:String in listeRegles)
			{
				for (var m:Number = 0; m<listeRegles[regle].listeConditions.length; m++)
				{
					var cibleR:String = listeRegles[regle].listeConditions[m].cible;
					if (listeCibles[cibleR] == null)
					{
						listeCibles[cibleR] = new Cible(cibleR,listeVide);
					}
					var actionR:String = listeRegles[regle].listeConditions[m].action;
					listeCibles[cibleR].listeMethodes.push(actionR);
				}
			}

			// trace;
			for (var cible:String in listeCibles)
			{
				trace("# cible "+cible);
				for (var w:Number=0; w<listeCibles[cible].listeMethodes.length; w++)
				{
					//trace("   méthode "+listeCibles[cible].listeMethodes[w]);
				}
			}
			trace("");

		}
		function toBoolean(str:String):Boolean
		{
			var res:Boolean = false;
			if (str.toLowerCase() == "true")
			{
				res = true;
			}
			return res;
		}
		public function creerEvenement(element:XML):void{
					/* récupération des infos
					<evenement nom="appel_telephonique">
					   <effet action="sonner" cible="telephone1" />
					   <effet action="afficher_item_aleatoire" cible="item_simple1" parametre="liste">
					      <liste>
					         <item id="1" nom="Nouveau patient" evenement="appel_nouveau_patient "/>
					         <item id="2" nom="Retard patient" evenement="retard_patient "/>
					         <item id="3" nom="RDV decommandé" evenement="rdv_decommande "/>
					         <item id="4" nom="Consultation" evenement="consultation "/>
					      </liste>
					   </effet>
					</evenement>
					*/
					var item:XML;
					var id:String;
					var unItem:Object;
			
					// attributs
					var nomE:String = element. @ nom;
					trace("> création nouvel évenement : "+nomE);
					// enfants
					var listeEffetsE=new Array();
					var k:Number = 0;
					for each (var propertyE:XML in element.*)
					{
						if (propertyE.name() == "effet")
						{
							var action:String = propertyE. @ action;
							var cible:String = propertyE. @ cible;
							var typeCible:String = propertyE. @ typeCible;
							var parametre:String = propertyE. @ parametre;
							// enfants
							var listeItems=new Array();
							for each (var parametreCible:XML in propertyE.*)
							{
								trace("   parametreCible : "+parametreCible);
								if (parametreCible.name() == "liste")
								{
									//trace("   dans liste");
									for each (item in parametreCible.*)
									{
										id = item. @ id;
										var texte:String = item. @ label;
										var evenement:String = item. @ evenement;
										// objet
										unItem = new Object();
										unItem.texte = texte;
										unItem.evenement = evenement;

										listeItems[id] = unItem;
									}
								}
								else if (parametreCible.name() == "liste2")
								{
									trace("   dans liste2");
									for each (item in parametreCible.*)
									{
										id = item. @ id;
										var itemName:String = item. @ name;
										var itemValue:String = item. @ value;
										// objet
										unItem = new Object();
										unItem.itemName = itemName;
										unItem.itemValue = itemValue;
										trace("   item n°"+id+", item="+itemName+", value="+itemValue);

										listeItems[id] = unItem;
									}
								}
								else if (parametreCible.name() == "image")
								{
									trace("   dans image");
									var image:String = parametreCible. @ source;
									listeItems[0] = image;
								}
								else if (parametreCible.name() == "variable")
								{
									var nomVariable:String = parametreCible. @ nom;
									var valeurVariable:String = parametreCible. @ valeur;
									listeItems[0] = nomVariable;
									listeItems[1] = valeurVariable;
								}
							}
							// objet
							var unEffet:Object = new Object();
							unEffet.action = action;
							unEffet.cible = cible;
							unEffet.typeCible = typeCible;
							unEffet.parametre = parametre;
							unEffet.listeItems = listeItems;

							listeEffetsE[k] = unEffet;
							k++;
						}
					}
					// construction de l'objet
					var unEvenement:Evenement = new Evenement(nomE,listeEffetsE);
					listeEvenements[nomE] = unEvenement;
					nbEvenements++;
			
		}
		public function creerRegle(element:XML):void{
					/* récupération des infos
					<regle nom="ouverture_liste_pendant_appel">
					   <conditions>
					<condition cible="root" methode="temps1" valeur="true"/>
					   </conditions>
					   <evenements>
					      <evenement nom="affichage_liste_pendant_appel"/>
					      <evenement nom="stoppe_jeu"/>
					   </evenements>
					</regle>
					*/
					var item:XML;
					var id:String;
					var unItem:Object;

					var nomRegle:String = element. @ nom;
					trace("> création nouvelle règle : "+nomRegle);
					var active:Boolean = toBoolean(element. @ active);
					// enfants
					for each (var propertyR:XML in element.*)
					{
						if (propertyR.name() == "conditions")
						{
							var listeConditions=new Array();
							var m:Number = 0;
							for each (var condition:XML in propertyR.*)
							{
								var cibleR:String = condition. @ cible;
								var methodeR:String = condition. @ methode;
								var valeurR:String = condition. @ valeur;
								// objet
								var uneCondition:Object = new Object();
								uneCondition.cible = cibleR;
								uneCondition.methode = methodeR;
								uneCondition.valeur = valeurR;

								listeConditions[m] = uneCondition;
								m++;
							}
						}
						else if (propertyR.name() == "evenements")
						{
							var listeEvenementsRegle=new Array();
							var l:Number = 0;
							for each (var evenementDeRegle:XML in propertyR.*)
							{
								// TBD traiter l'attribut "after"
								var nomER:String = evenementDeRegle. @ nom;
								// objet
								var unEvenementDeRegle:Object = new Object();
								unEvenementDeRegle.nom = nomER;

								listeEvenementsRegle[l] = unEvenementDeRegle;
								l++;
							}
						}
					}
					// construction de l'objet
					var uneRegle:Regle = new Regle(nomRegle,listeConditions,listeEvenementsRegle,active);
					listeRegles[nomRegle] = uneRegle;
					nbRegles++;
			
		}
		public function supprimerRegle(regleADetruire:Regle):void
		{
			trace("                      > destruction de la règle "+regleADetruire.nom);
			// juin06 : Améliorer
			/*
			listeRegles[regleADetruire.nom] = null;
			regleADetruire = null
			*/
			// provisoire
			regleADetruire.detruite = true;
			
		}
	}
}