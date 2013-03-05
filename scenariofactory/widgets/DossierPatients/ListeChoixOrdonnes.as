﻿package scenariofactory.widgets.DossierPatients {
	import fl.controls.CheckBox;

	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	// gestion d'une liste ordonnée de choix (par checkbox) de libellés
	// les libellés choisis (cochés) constituent par convention
	// la première partie de la liste
	public class ListeChoixOrdonnes extends MovieClip {
		
		// déclaration manuelle des occurrences de symboles placées dans le clip
		public var boutonValiderChoix:MovieClip;


		// hauteur en pixels de chaque choix
		static private var HAUTEUR_CHOIX = 25;
		
		// chaque élément est une instance du symbole de clip ChoixOrdonne contenant
		// un checkBox de nom "cbChoix" contenant le libellé du choix cbChoix.label
		// et si le choix a été sélectionné cbChoix.selected
		private var listeChoixOrdonnes:Vector.<ChoixOrdonne> = new Vector.<ChoixOrdonne>();
		private var nbChoixOrdonnes:Number = 0;

		// dictionnaire des choix par leur nom
		// listeChoixParLibelle["libellé d'un choix"] = listeChoixOrdonnes[indice de ce choix]
		private var listeChoixParLibelle:Array;		
		
		public function ListeChoixOrdonnes() {
			// constructor code
		}
		
		private function getChoixLibelle(choix:ChoixOrdonne):String {
			var cbChoix:CheckBox = choix.cbChoix;
			return cbChoix.label;
		}
		
		private function setChoixLibelle(choix:ChoixOrdonne, libelleChoix:String):void {
			var cbChoix:CheckBox = choix.cbChoix;
			cbChoix.label = libelleChoix;
		}
		
		private function getChoixEstChoisi(choix:ChoixOrdonne):Boolean {
			var cbChoix:CheckBox = choix.cbChoix;
			return cbChoix.selected;
		}
		
		private function setChoixEstChoisi(choix:ChoixOrdonne, estChoisi:Boolean):void {
			var cbChoix:CheckBox = choix.cbChoix;
			cbChoix.selected = estChoisi;
			placerChoix(choix, estChoisi);
		}
		
		// estChoisi = true  : le choix est placé à la fin des choix cochés
		// estChoisi = false : le choix est placé au début des choix non cochés
		private function placerChoix(choix:ChoixOrdonne, estChoisi:Boolean):void {
			var indiceChoix:int = listeChoixOrdonnes.indexOf(choix);
			if (estChoisi) {
				while (indiceChoix > 0 && !getChoixEstChoisi(listeChoixOrdonnes[indiceChoix - 1])) {
					indiceChoix = monterChoix(choix);
				}
				// on permet que ce dernier choix coché puisse monter
				// (si il en était empêché car premier des non cochés) et
				// on permet aussi que le choix coché précédent puisse descendre
				// (si il en était empêché car dernier des cochés)
				if (indiceChoix > 0) {
					choix.monter.visible = true;
					listeChoixOrdonnes[indiceChoix - 1].descendre.visible = true;
				}
				// on empêche que ce dernier choix coché migre vers les non cochés
				// et que le premier des non cochés ne migre vers les cochés
				choix.descendre.visible = false;
				if (indiceChoix < nbChoixOrdonnes - 1) {
					listeChoixOrdonnes[indiceChoix + 1].monter.visible = false;
				}
			}
			else {
				while (indiceChoix < (nbChoixOrdonnes - 1) && getChoixEstChoisi(listeChoixOrdonnes[indiceChoix + 1])) {
					indiceChoix = descendreChoix(choix);
				}
				// on permet que ce premier choix non coché puisse descendre
				// (si il en était empêché car dernier des cochés) et
				// on permet aussi que le choix non coché suivant puisse monter
				// (si il en était empêché car premier des non cochés)
				if (indiceChoix < nbChoixOrdonnes - 1) {
					choix.descendre.visible = true;
					listeChoixOrdonnes[indiceChoix + 1].monter.visible = true;
				}
				// on empêche que ce premier choix non coché migre vers les cochés
				// et que le dernier des cochés ne migre vers les non cochés
				choix.monter.visible = false;
				if (indiceChoix > 0) {
					listeChoixOrdonnes[indiceChoix - 1].descendre.visible = false;
				}
			}
		}
		
		public function setListeChoixPossibles(listeLibelleChoix) {
			var i:int;
			
			// suppression de l'existant
			listeChoixParLibelle = new Array();
			for each (var choix:ChoixOrdonne in listeChoixOrdonnes) {
				removeChild(choix);
			}
			listeChoixOrdonnes = new Vector.<ChoixOrdonne>();
			nbChoixOrdonnes = 0;
			
			// ajout de la liste indiquée
			for each (var libelleChoix:String in listeLibelleChoix) {
				addChoix(libelleChoix);
			}
			
			// conditions aux limites des boutons monter et descendre
			if (nbChoixOrdonnes > 0) {
				listeChoixOrdonnes[0].monter.visible 						= false;
				listeChoixOrdonnes[nbChoixOrdonnes - 1].descendre.visible	= false;
				
			}
			
			// positionnement du bouton "Valider" et association de la fonction d'écoute
			boutonValiderChoix.y = nbChoixOrdonnes * HAUTEUR_CHOIX;
		}
		
		private function addChoix(libelleChoix:String) {
			trace("addChoix : " + libelleChoix);
			var choix:ChoixOrdonne = new ChoixOrdonne;
			listeChoixOrdonnes.push(choix);
			choix.y = nbChoixOrdonnes * HAUTEUR_CHOIX;
			nbChoixOrdonnes++;
			listeChoixParLibelle[libelleChoix] = choix;
			
			var cbChoix:CheckBox = choix.cbChoix;
			cbChoix.label = libelleChoix;
			cbChoix.addEventListener(MouseEvent.CLICK, updateChoix);
			
			var btMonter:SimpleButton		= choix.monter;
			var btDescendre:SimpleButton	= choix.descendre;
			btMonter.addEventListener(MouseEvent.CLICK,		clicMonterChoix);
			btDescendre.addEventListener(MouseEvent.CLICK,	clicDescendreChoix);

			addChild(choix);
		}
		
		// positionnement de la liste (et l'ordre) des libellés choisis par le joueur
		// les choix de joueur sont placés par convention en début de liste
		// (cf. méthode setChoixEstChoisi)
		public function setListeChoix(listeLibelleChoix):void {
			for each (var libelleChoix:String in listeLibelleChoix) {
				var choix:ChoixOrdonne = listeChoixParLibelle[libelleChoix];
				setChoixEstChoisi(choix, true);
			}
		}
		
		// obtenir la liste ordonnée des choix effectués par le joueur
		public function getListeChoix():Array {
			var listeChoix:Array = new Array();
			for (var i:int = 0; (i < nbChoixOrdonnes) && getChoixEstChoisi(listeChoixOrdonnes[i]); i++) {
				listeChoix.push(getChoixLibelle(listeChoixOrdonnes[i]));
			}
			return listeChoix;
		}

		// prise en compte du clic sur le bouton monter en regard d'un choix
		private function clicMonterChoix(evt:MouseEvent):void {
			var choix:ChoixOrdonne = evt.target.parent;
			monterChoix(choix);
		}
		// retourne le nouvel indice du choix après son déplacement
		private function monterChoix(choix:ChoixOrdonne):int {
			var indiceChoix:int = listeChoixOrdonnes.indexOf(choix);
			// mise à jour des ordonnées des choix concernés
			listeChoixOrdonnes[indiceChoix - 1].y = choix.y;
			choix.y -= HAUTEUR_CHOIX;
			// suppression de la liste du choix à monter
			listeChoixOrdonnes.splice(indiceChoix, 1);
			// réinsertion à sa nouvelle place du choix monté
			listeChoixOrdonnes.splice(indiceChoix - 1, 0, choix);
			// maj éventuelle des conditions aux limites des boutons monter et descendre
			if (!choix.descendre.visible) {
				choix.descendre.visible = true;
				listeChoixOrdonnes[indiceChoix].descendre.visible = false;
			}
			if (!listeChoixOrdonnes[indiceChoix].monter.visible) {
				choix.monter.visible = false;
				listeChoixOrdonnes[indiceChoix].monter.visible = true;
			}
			return indiceChoix - 1;
		}
		
		// prise en compte du clic sur le bouton descendre en regard d'un choix
		private function clicDescendreChoix(evt:MouseEvent):void {
			var choix:ChoixOrdonne = evt.target.parent;
			descendreChoix(choix);
		}
		// retourne le nouvel indice du choix après son déplacement
		private function descendreChoix(choix:ChoixOrdonne):int {
			var indiceChoix:int = listeChoixOrdonnes.indexOf(choix);
			// mise à jour des ordonnées des choix concernés
			listeChoixOrdonnes[indiceChoix + 1].y = choix.y;
			choix.y += HAUTEUR_CHOIX;
			// suppression de la liste du choix à descendre
			listeChoixOrdonnes.splice(indiceChoix, 1);
			// réinsertion à sa nouvelle place du choix descendu
			listeChoixOrdonnes.splice(indiceChoix + 1, 0, choix);
			// maj éventuelle des conditions aux limites des boutons monter et descendre
			// en tenant compte de l'étanchéité à maintenir entre choix cochés et non cochés
			if (!choix.monter.visible) {
				choix.monter.visible = true;
				listeChoixOrdonnes[indiceChoix].monter.visible = false;
			}
			if (!listeChoixOrdonnes[indiceChoix].descendre.visible) {
				choix.descendre.visible = false;
				listeChoixOrdonnes[indiceChoix].descendre.visible = true;
			}
			return indiceChoix + 1;
		}
		
		// mise à jour éventuelle de la place du choix selon
		// qu'il est coché ou décoché (cf. methode placerChoix)
  		private function updateChoix(e:MouseEvent):void {
            var cbChoix:CheckBox = CheckBox(e.target);
			var choix:ChoixOrdonne = ChoixOrdonne(cbChoix.parent);
			placerChoix(choix, cbChoix.selected);
        }
	}
	
}
