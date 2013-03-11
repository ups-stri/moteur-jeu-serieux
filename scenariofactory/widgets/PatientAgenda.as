package scenariofactory.widgets {
	import fl.data.DataProvider;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class PatientAgenda extends MovieClip {
		// déclaration manuelle des occurrences de symboles placées sur la scène
		public var textPatient:TextField;
		public var focus:MovieClip;
		public var deleteButton:MovieClip;
		public var slotBackground:MovieClip;

		// dossier de patients auquel appartient ce patient
		private var dossierPatients:DossierPatients;
		
		private static var lastIdUniquePatient:int = 0;
		public static var listePatients:Vector.<PatientAgenda>  = new Vector.<PatientAgenda>();
		
		public var idPatient:int;
		public var nomPatient:String;
		public var prenomPatient:String;
		
		// cf. classe Patient pour le détails des différentes valeurs possibles
		public var sexePatient:Number;
		
		public var agePatient:Number;
		
		// cf. classe Patient pour le détails des différentes valeurs possibles
		public var lieuPatient:Number;
		
		public var motifConsultIniPatient:String;
		public var commentairesPatient:String;
		
		// cas dont relève ce patient
		public var cas:Cas;

		// liste des actions proposées au joueur
		// (pas initialisé à [], reste plutôt à null pour qu'on sache
		//  que ces actions n'ont pas encore été affectées depuis la lecture du XML,
		//  au cas où aucune action de vérification ne soit prévue pour un cas)
		public var listeActionsVerification:Array;
		// liste de ces actions qu'il a sélectionné
		public var listeActionsPremiereSeance:Array = [];

		// liste des actions de traitement pour chacune des séances de traitement prévues
		// chaque élément est un tableau des actions prévues pour la séance en question
		public var listeActionsTraitementParSeance:Array;
		// liste des actions choisies par le joueur pour chaque séance de traitement
		public var listeActionsTraitementChoisiesParSeance:Array;
		public var listeStatutsActionsChoisiesParSeance:Vector.<Boolean>;

		public var dpListDiagnostics:DataProvider;
		public var indiceDiagnosticChoisi:int = -1;
		
		public var dpCBTherapies:DataProvider;
		public var indiceTherapieChoisie:int = -1;
		
		// l'accès au diagnostic est fourni dès que les actions de vérifications
		// requises ont été trouvées par le joueur
		public var accesDiagnostic:Boolean = false;
		
		// détermine la visibilité du bouton de choix du diagnostic
		public var diagnosticChoisi:Boolean = false;
		
		// l'accès au traitement est fourni dès qu'une thérapie pertinente
		// a été choisie par le joueur
		public var accesTraitement:Boolean = false;
		
		// indice de l'éventuelle séance de traitement
		// (de la thérapie choisie) sélectionnée
		public var indiceSeanceSelectionee:int = -1;
		
		// liste ordonnée chronologiquement des créneaux créés dans l'agenda pour ce patient
		private var listeCreneauxAgenda:Vector.<Creneau> = new Vector.<Creneau>();
		
		// indice dans cette liste de l'éventuel créneau en cours, sachant que
		// les créneaux invalidés (première séance avec erreur sur les actions de
		// vérification ou sur le diagnostic) ne sont pas comptés
		// (unCreneauEnCours = true alors si un créneau est en cours,
		//  alors stocké dans creneauEnCours)
		private static var INDICE_CRENEAU_INIT = -1; // avant le premier créneau
		public var indiceCreneauEnCours:int = INDICE_CRENEAU_INIT;
		public var unCreneauEnCours:Boolean = false;
		private var creneauEnCours:Creneau;
		
		public function PatientAgenda(dossierPatients:DossierPatients) {
			trace("PatientAgenda créé");
			this.dossierPatients = dossierPatients;
			lastIdUniquePatient++;
			this.idPatient = lastIdUniquePatient;
			this.x						= 0;
			this.y						= (listePatients.length) * this.height;
			this.nomPatient				= "";
			this.prenomPatient			= "";
			this.sexePatient			= 0;
			this.agePatient				= 0;
			this.lieuPatient			= 0;
			this.motifConsultIniPatient	= "";
			this.commentairesPatient	= "";
			
			// delete button
			this.deleteButton.visible = false;
			this.deleteButton.addEventListener(MouseEvent.CLICK, dossierPatients.deletePatient);
			
			// clic
			this.addEventListener(MouseEvent.MOUSE_UP, dossierPatients.functionDisplayProperties);
			
			// add to list of PatientAgenda;
			listePatients.push(this);
		}

		public function getCivilite():String {
			return prenomPatient + " " + nomPatient;
		}
		
		public static function getNbPatients():Number {
			return lastIdUniquePatient;
		}
		
		public static function getPatientParId(idPatient:int):PatientAgenda {
			return listePatients[idPatient - 1];
		}
		
		public function getListeCreneauxAgenda():Vector.<Creneau> {
			return listeCreneauxAgenda;
		}
		
		public function premiereSeanceEnCours():Boolean {
			return unCreneauEnCours && (indiceCreneauEnCours == 0);
		}
		
		public function seanceTraitementEnCours():Boolean {
			return unCreneauEnCours && (indiceCreneauEnCours > 0);
		}
		
		public function getListeActionsTraitementSeanceEnCours():Array {
			return listeActionsTraitementParSeance[indiceCreneauEnCours - 1];
		}
		
		public function getListeActionsTraitementChoisiesSeanceEnCours():Array {
			return listeActionsTraitementChoisiesParSeance[indiceCreneauEnCours - 1];
		}
		
		public function seanceTraitementSelectionnee():Boolean {
			return indiceSeanceSelectionee >= 0;
		}
		
		public function getListeActionsTraitementSeanceSelectionee():Array {
			return listeActionsTraitementParSeance[indiceSeanceSelectionee];
		}
		
		public function getListeActionsTraitementChoisiesSeanceSelectionee():Array {
			return listeActionsTraitementChoisiesParSeance[indiceSeanceSelectionee];
		}
		
		public function setListeActionsTraitementChoisiesSeanceSelectionee(listeChoixActionsTraitement:Array):void {
			listeActionsTraitementChoisiesParSeance[indiceSeanceSelectionee] =
				listeChoixActionsTraitement;
		}
		
		public function traceListeCreneaux():void {
			trace("Liste des crénaux du patient " + prenomPatient + " " + nomPatient);
			for each (var creneau:Creneau in listeCreneauxAgenda) {
				trace("- " + creneau.toString());
			}
		}
		
		public function trieListeCreneaux():void {
			Creneau.trieListeCreneaux(listeCreneauxAgenda);
			traceListeCreneaux();
		}
		
		// indique que ce créneau est en cours (vient de démarrer) et retourne son indice
		public function setCreneauEnCours(creneau:Creneau):int {
			creneau.etat = Creneau.EN_COURS;
			creneauEnCours = creneau;
			unCreneauEnCours = true;
			indiceCreneauEnCours++;
			if (seanceTraitementEnCours()) {
				// s'il s'agit d'un créneau d'une séance de traitement, sélectionner
				// la séance en question dans le tableau de la liste des séances
				dossierPatients.selectionSeanceEnCours(indiceCreneauEnCours - 1);
			}
			else {
				// mise à jour éventuelle de l'accès aux boutons de validation d'actions
				dossierPatients.updateProperties();
			}
			return indiceCreneauEnCours;
		}
		
		// indique que ce créneau est en cours (vient de démarrer) et retourne son indice
		public function invalideCreneauEnCours():void {
			creneauEnCours.etat = Creneau.INVALIDE;
			unCreneauEnCours = false;
			// TODO : tester ce que ça donne en dehors du premier créneau
			indiceCreneauEnCours--;
			// mise à jour éventuelle de l'accès aux boutons de validation d'actions
			dossierPatients.updateProperties();
		}
		
		// indique que ce créneau est terminé et retourne son indice
		public function setCreneauPasse(creneau:Creneau):int {
			creneau.etat = Creneau.PASSE;
			unCreneauEnCours = false;
			// mise à jour éventuelle de l'accès aux boutons de validation d'actions
			dossierPatients.updateProperties();
			return indiceCreneauEnCours;
		}
		
		// ajout d'un créneau dans l'agenda pour ce patient
		public function addCreneau(creneau:Creneau) {
			listeCreneauxAgenda.push(creneau);
			trieListeCreneaux();
		}

		// suppression d'un créneau dans l'agenda pour ce patient
		public function removeCreneau(creneau:Creneau) {
			listeCreneauxAgenda.splice(listeCreneauxAgenda.indexOf(creneau), 1);
			traceListeCreneaux();
		}
	}
	
}