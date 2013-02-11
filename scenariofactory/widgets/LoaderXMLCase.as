﻿package scenariofactory.widgets
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
	// cas
	import Cas;

	public class LoaderXMLCase extends Widget
	{
		// variable d'état
		public var gameIsLoaded:Boolean = false;
		// déclaration du chargeur
		private var chargeur:URLLoader;
		private var chargeurCas:URLLoader;

		// constructeur
		public function LoaderXMLCase()
		{
			trace("occurence de LoaderXMLCase : "+this.name);
		}

		public function load():void
		{
			trace("load...");
			var gameFile:String = "./dalada/jeu.scenario";

			// initialisations
			/*
			listeEvenements=new Array();
			listeRegles=new Array();
			listeCibles=new Array();
			listeVariables=new Array();
			nbEvenements = 0;
			nbRegles = 0;
			*/

			// création du loadeur
			chargeur = new URLLoader  ;
			// choix du format
			chargeur.dataFormat = URLLoaderDataFormat.TEXT;
			// écouteurs
			chargeur.addEventListener(Event.COMPLETE,chargementTermine);
			chargeur.addEventListener(HTTPStatusEvent.HTTP_STATUS,codeHTTP);
			chargeur.addEventListener(IOErrorEvent.IO_ERROR,erreurChargement);
			// chargement du scénario;
			trace("   chargement de "+gameFile);
			chargeur.load(new URLRequest(gameFile));
		}

		private function chargementTermine(pEvt:Event):void
		{
			trace("   chargement terminé");
			// transformation de la chaîne en xml
			var donnneesXML:XML = new XML(pEvt.target.data);
			// création des listes
			creerListes( donnneesXML );
			// affichages des données
			//afficheDonnées();
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
		private function creerListes(pXML:XML):void
		{

			trace("dans creerListes()");
			// namespace
			var xx:Namespace = new Namespace("http://www.w3.org/2001/XMLSchema-instance");

			trace("\n"+pXML);
			trace("");
			for each (var element:XML in pXML.*)
			{
				// repose_sur
				if (element.name() == "repose_sur")
				{
					// <repose_sur xsi:type="..." libelle="ET02" relatif_a="...">
					var libelle:String = element. @ libelle;
					var type:String = element. @ xx::type;
					/* 
					Ici traiter les différents type Evt_Tel, Evt_Agenda...
					*/
					var relatif_a:String = element. @ relatif_a;
					var motif:String = element. @ motif;
					var objet:String = element. @ objet;
					trace("\n+repose_sur : type="+type+", libelle="+libelle+", relatif_a="+relatif_a+", motif="+motif+", objet="+objet);
					//;
					for each (var propertyE:XML in element.*)
					{
						if (propertyE.name() == "comporte")
						{
							var message_:String = propertyE. @ message;
							trace("   message : "+ message_);
						}
					}
					// traitement du "relatif_a"
					if (relatif_a != "")
					{
						// création du loader de cas
						/*
						chargeurCas = new URLLoader  ;
						chargeurCas.dataFormat = URLLoaderDataFormat.TEXT;
						chargeurCas.addEventListener(Event.COMPLETE,chargementCasTermine);
						chargeurCas.addEventListener(HTTPStatusEvent.HTTP_STATUS,codeHTTP);
						chargeurCas.addEventListener(IOErrorEvent.IO_ERROR,erreurChargement);
						// chargement du cas;
						trace("   chargement de "+"./"+relatif_a);
						chargeurCas.load(new URLRequest("./dalada/"+relatif_a));
						*/
						var nouveauCas:Array = creeCas(relatif_a);
						/*
						var nouveauCas2:Cas = creeCas2(relatif_a);
						var unCas:Cas = new Cas("test");
						*/
					}
				}
			}
			// jeu prêt
			gameIsLoaded = true;
		}
		public function GameIsReady():Boolean
		{
			if (gameIsLoaded == true)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		// ------------------------------------------------------------
		// Traitement des cas
		// ------------------------------------------------------------
		private function creeCas(cas:String):Array
		{
			trace("   cas à traiter : "+ cas);
			var nouveauCas:Array = new Array  ;
			// création du loader
			chargeurCas = new URLLoader  ;
			chargeurCas.dataFormat = URLLoaderDataFormat.TEXT;
			chargeurCas.addEventListener(Event.COMPLETE,chargementCasTermine);
			chargeurCas.addEventListener(HTTPStatusEvent.HTTP_STATUS,codeHTTP);
			chargeurCas.addEventListener(IOErrorEvent.IO_ERROR,erreurChargement);
			// chargement du cas;
			trace("   chargement de "+"./"+cas);
			chargeurCas.load(new URLRequest("./dalada/"+cas));

			return nouveauCas;
		}
		private function chargementCasTermine(pEvt:Event):void
		{
			trace("   chargement cas terminé");
			// transformation de la chaîne en xml
			var donnneesXML:XML = new XML(pEvt.target.data);
			// création du cas
			trace("dans chargementCasTermine() :"+pEvt.currentTarget.name);
			trace("\n"+donnneesXML);
		}
	}

}