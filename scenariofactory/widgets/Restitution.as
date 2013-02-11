﻿package scenariofactory.widgets
{

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import scenariofactory.Scenario;

	public class Restitution extends Widget
	{

		var choice:String = "";
		var listeRestitution:Array = [];
		var listeVideos:Array = [];

		// constructor
		public function Restitution()
		{
			trace("occurence of Restitution : "+this.name);
			// loader
			loader.visible = false;

			listeRestitution[0] = "Eléments généraux";	 					
			listeRestitution[1] = "Sur le choix d'une machine"; 					// choix_machine : portable ou PC
			listeRestitution[2] = "Sur le choix du partage réseau";					// partage_reseau : ou ou non
			listeRestitution[3] = "Sur le fait d'éteindre le PC fixe";				// a_eteint_PC : 0 ou 1
			listeRestitution[4] = "Sur le choix du type de connexion";				// choix_connexion : wi-fi ou filaire
			listeRestitution[5] = "Sur le double popup de connexion";				// doute_VPN : non, technicien, patron
			listeRestitution[6] = "Sur le popup de l'enfant";						// refus_popup_enfant : oui on non
			listeRestitution[7] = "Sur l'utilisation d'une clé USB";				// refus_cle_enfant : oui on non
			listeRestitution[8] = "Sur le choix de l'accès à l'image du rapport";	// choix_acces_elements : mail ou cle
			listeRestitution[9] = "Sur l'impression réseau";						// impression_reseau : oui on non
			listeRestitution[10] = "Sur le prêt de machine";						// demande_conjoint : ou on non
			//listeRestitution[11] = "Sur les images cadeau";
			
		}

		public function setTitle(liste:Array)
		{
			trace("setTitle()");
			// display title
			textTitle.text = liste[1];
		}

		public function displayItems(liste:Array):void
		{
			trace("displayItems() restitution");
			// liste : <item id="0" name="choix_machine" value="root" />...
			// liste : <item id="1" name="choix_machine" value="root" />...

			// format
			var format:TextFormat = new TextFormat();
			format.font = "Arial";
			format.color = 0xFFFFFF;
			format.size = 14;
			format.bold = false;
			format.underline = false;
			
			var separation:Number = 25;

			// textAreaRestitution
			for (var oneItem:String in liste)
			{
				var conteneurVar:String = liste[oneItem].itemValue;
				var conteneurClip:MovieClip = this.root as MovieClip;
				conteneurClip = (nomVar == "root" ? conteneurClip : conteneurClip[conteneurVar]);
				var nomVar:String    = liste[oneItem].itemName;
				var accesValeurVar:Object = conteneurClip[nomVar];
				var valeurVar:String = (accesValeurVar == null ? "indéfini" : (accesValeurVar)());
				
				trace("   item n°"+oneItem+", item="+liste[oneItem].itemName+", value="+liste[oneItem].itemValue);
				//this["button"+item].label = liste[item].texte;
				var textItem = new TextField();
				textItem.x = 40;
				textItem.y = 50 + Number(oneItem) * separation;
				textItem.autoSize = TextFieldAutoSize.LEFT;
				textItem.background = false;
				textItem.border = false;
				textItem.defaultTextFormat = format;
				textItem.text = listeRestitution[Number(oneItem)] + " : " + valeurVar;
				addChild(textItem);
				
				// icône vidéo
				var iconeVideo:IconeVideo = new IconeVideo;
				iconeVideo.name = oneItem;
				iconeVideo.x = 10;
				iconeVideo.y = 50 + Number(oneItem) * separation;
				iconeVideo.addEventListener(MouseEvent.CLICK, displayVideo);
				iconeVideo.numeroItem = oneItem;
				iconeVideo.item = liste[oneItem].itemName;
				iconeVideo.valeurVar = valeurVar;
				addChild(iconeVideo);
			}
		}
		public function displayVideo(e:MouseEvent):void
		{
			trace("displayVideo(), currentTarget : "+e.currentTarget.name);
			trace("n° : "+e.currentTarget.numeroItem+", item : "+e.currentTarget.item+", valeur variable : "+e.currentTarget.valeurVar);
			var videoName = "actifs/actifs_restitution/"+e.currentTarget.numeroItem+"_"+e.currentTarget.item+"_"+e.currentTarget.valeurVar+"_expert.flv";
			trace("vidéo : "+videoName);
			loader.visible = true;
			loader.source = videoName;
		}

	}
}