package scenariofactory.widgets {
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.controls.List;
	import fl.controls.TextArea;
	import fl.data.DataProvider;
	import fl.controls.DataGrid;
	import fl.events.DataGridEvent;

	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;

	import scenariofactory.widgets.DossierPatients.ListeChoixOrdonnes;

	// Symbole (rectangle pour la barre de gauche)

	// classes du modèle
	
	public class DossierPatients extends Widget
	{
		// déclaration manuelle des occurrences de symboles placées sur la scène
		public var boutonDossierPatient:MovieClip;
		public var boutonAjoutPatient:MovieClip;
		public var textDebug2:TextArea;
		public var patientProperties:MovieClip;
		public var lignes:MovieClip;
		public var fond:MovieClip;
		public var fondGris:MovieClip;
		
		// message d'information affiché au joueur
		private var message:String;
		
		// container of patients
		var container:Sprite = new Sprite;
		// selected patient
		var selectedPatient:PatientAgenda;
		// selected tab
		var selectedTab:String;
		var defaultTab:String = "civilite";
		// rectangle for avatar drag
		private var rect:Rectangle;
		// open or close
		private var isOpen:Boolean = true;
	
		// classes du modèle (Scenario pour la variable d'instance, Agenda pour listePatients)
		import scenariofactory.Scenario;
		import scenariofactory.widgets.Agenda;

		// constructor
		public function DossierPatients()
		{
			trace("occurence of DossierPatients : "+this.name);
			// bouton
			boutonDossierPatient.addEventListener(MouseEvent.CLICK, openOrClose);
			// container for patients;
			addChild(container);
			// add patient
			boutonAjoutPatient.addEventListener(MouseEvent.CLICK, functionAddPatient);
			// debug;
			textDebug2.text = "";
			//textDebug2.visible = false;
			// patient properties
			patientProperties.allTabs.addEventListener(MouseEvent.CLICK, functionTabProperties);
			patientProperties.boutonSauverPatient.addEventListener(MouseEvent.CLICK, HSaveProperties);
			patientProperties.actionsVerification.listeChoixOrdonnes.boutonValiderChoix.addEventListener(MouseEvent.CLICK, HValiderActionsVerif);
			patientProperties.diagnostic.boutonValiderDiagnostic.addEventListener(MouseEvent.CLICK, HValiderDiagnostic);
			patientProperties.traitement.boutonValiderTherapie.addEventListener(MouseEvent.CLICK, HValiderTherapie);
			patientProperties.traitement.listeChoixOrdonnes.boutonValiderChoix.addEventListener(MouseEvent.CLICK, HValiderActionsTraitement);
			patientProperties.contexte.visible				= false;
			patientProperties.actionsVerification.visible	= false;
			patientProperties.diagnostic.visible			= false;
			patientProperties.traitement.visible			= false;
			
			// Civilité
			
			// Contexte
			
			// Diagnostic
			
			// Traitement
			
			// création des colonnes de dgListeSeancesTraitement
			var dgListeSeancesTraitement:DataGrid = patientProperties.traitement.dgListeSeancesTraitement;
			dgListeSeancesTraitement.columns = ["creneau","libelle_seance"];
			dgListeSeancesTraitement.columns[0].width = 80; 
			dgListeSeancesTraitement.columns[0].headerText = "Créneau";
			dgListeSeancesTraitement.columns[1].headerText = "Libellé séance";
			dgListeSeancesTraitement.addEventListener("change", HSelectionSeance);
			
			masqueElements();

		}
		public function masqueElements():void
		{
			textDebug2.appendText("\nmasqueElements");
			boutonAjoutPatient.visible = false;
			patientProperties.visible = false;
			lignes.visible = false;
			fond.visible = false;
			fondGris.visible = false;
			container.visible = false;
		}
		public function demasqueElements():void
		{
			textDebug2.appendText("\ndemasqueElements");
			boutonAjoutPatient.visible = true;
			lignes.visible = true;
			fond.visible = true;
			fondGris.visible = true;
			container.visible = true;
			if (PatientAgenda.getNbPatients() > 0)
			{
				patientProperties.visible = true;
			}
		}
		
		/* ---------------------------------------------------------------- */
		/*            Fonctions de communication avec le joueur             */
		/* ---------------------------------------------------------------- */

		private function afficherMessage(message:String) {
			Scenario.getInstance().messageGeneral.afficherMessage(message);
		}

		// statut indique si la création est ok		
		private function afficherMsgCreationPatientAttendu(statut:Boolean, civilite:String) {
			if (statut) {
				message = "Vous avez bien créé la fichier du patient " +
				          civilite + " comme attendu.";
			}
			else {
				message = "Vous venez de créer la fiche du patient " +
				          civilite + " non prévu par le jeu.";
			}
			afficherMessage(message);
		}
		
		private function afficherMsgListeActionsVerif(statut:Boolean, civilite:String) {
			message = "Votre liste d'actions de vérification du patient " + civilite;
			if (statut) {
				message += " contient bien toutes les actions requises," +
				           " vous pouvez accéder au diagnostic.";
			}
			else {
				message += " ne contient pas toutes les actions requises," +
				           " vous ne pouvez pas accéder au diagnostic." +
				           " Il vous faut replanifier une première séance " +
				           " pour tenter votre chance à nouveau.";				
			}
			afficherMessage(message);
		}
		
		private function afficherMsgDiagnostic(statut:Boolean, civilite:String,
											   listeDiagnosticsCorrects:Array) {
			message = "Votre diagnostic relatif au patient " + civilite;
			if (statut) {
				message += " est bien un diagnostic correct.";
			}
			else {
				message += " est un diagnostic incorrect.";
				message += " Les diagnostics corrects étaient : " +
				           listeDiagnosticsCorrects.map(Diagnostic.getMaladie).join(", ") +
						   ".";		
			}
			afficherMessage(message);
		}
		
		private function afficherMsgTherapie(statut:Boolean, civilite:String) {
			message = "Votre choix de thérapie relative au patient " + civilite;
			if (statut) {
				message += " est bien une thérapie pertinente.";
			}
			else {
				message += " n'est pas une thérapie pertinente.";
			}
			afficherMessage(message);
		}
		
		/* ---------------------------------------------------------------- */

		public function HSaveProperties(e:MouseEvent):void
		{
			//textDebug2.appendText("\nsaving patient n°"+selectedPatient.idPatient);
			saveProperties();
		}

		public function HValiderActionsVerif(e:MouseEvent):void
		{
			validerActionsVerif();
		}

		public function HValiderDiagnostic(e:MouseEvent):void
		{
			validerDiagnostic();
		}

		public function HValiderTherapie(e:MouseEvent):void
		{
			validerTherapie();
		}

		public function HValiderActionsTraitement(e:MouseEvent):void
		{
			validerActionsTraitement();
		}
		
		/* ---------------------------------------------------------------- */

		private function reglerOngletsActifs():void {
			// on n'active les onglets contexte, diagnostic et traitement seulement
			// si le patient correspond à un patient d'un cas du jeu en cours
			if (selectedPatient.cas != null) {
				textDebug2.appendText("\ndisplayProperties() : activation onglets médicaux du patient");
				patientProperties.allTabs.contexte.alpha = 1;
				patientProperties.allTabs.diagnostic.alpha = 1;
				patientProperties.allTabs.traitement.alpha = 1;
			}
			else {
				textDebug2.appendText("\ndisplayProperties() : désactivation onglets médicaux du patient");
				patientProperties.allTabs.contexte.alpha = 0.5;
				patientProperties.allTabs.diagnostic.alpha = 0.5;
				patientProperties.allTabs.traitement.alpha = 0.5;
			}
		}
			
		/* ---------------------------------------------------------------- */
		/*                         Onglet Civilité                          */
		/* ---------------------------------------------------------------- */

		public function saveCivilite():void
		{
			// update patient name label
			selectedPatient.textPatient.text = patientProperties.civilite.textNomPatient.text;
			
			var cbSexePatient:ComboBox = patientProperties.civilite.cbSexePatient;
			var cbLieuPatient:ComboBox = patientProperties.civilite.cbLieuPatient;

			// saving Civilité
			selectedPatient.nomPatient				= patientProperties.civilite.textNomPatient.text;
			selectedPatient.prenomPatient			= patientProperties.civilite.textPrenomPatient.text;
			selectedPatient.sexePatient				= cbSexePatient.selectedIndex;
			selectedPatient.agePatient				= Number(patientProperties.civilite.textAgePatient.text);
			selectedPatient.lieuPatient				= cbLieuPatient.selectedIndex;
			selectedPatient.motifConsultIniPatient	= patientProperties.civilite.textMotifConsultIniPatient.text;
			selectedPatient.commentairesPatient		= patientProperties.civilite.textCommentairesPatient.text;
			
			// récupération éventuelle des informations de choix de ce patient
			// depuis une instance de la classe Patient, identifiée par son nom :
			// - contexte dentaire et patient
			// - liste des actions de vérification devant être effectuées lors
			//   de la première séance (rempli après le chargement des actions en question)
			//   ainsi que la liste des diagnostics proposés
			// - liste des thérapies proposés et de leurs séances d'actions de traitement
			var patient:Patient = Patient.getPatientParNom(selectedPatient.nomPatient);
			if (patient != null) {
				// on ne récupère les infos du cas que si on ne l'a pas déjà fait
				if (selectedPatient.cas == null) {
					afficherMsgCreationPatientAttendu(true, selectedPatient.getCivilite());
					var cas:Cas = patient.getCas();
					selectedPatient.cas = cas; // mémorisation du cas dont relève ce patient
					trace("récupération du cas du patient patient : " + selectedPatient.getCivilite() + ", cas : " + selectedPatient.cas);
					var nbActions:Number = cas.premiereSeance.listeActions.length;
					var libelleAction:String;
					trace("Récupération des actions de vérification de la première séance : " +
						  cas.premiereSeance.libelle + " (" + nbActions + ")");
					selectedPatient.listeActionsVerification = new Array();

					for (var i:int = 0; i < nbActions; i++) {
						libelleAction = cas.premiereSeance.listeActions[i].libelle;
						trace(libelleAction);
						selectedPatient.listeActionsVerification.push(libelleAction);
						// le choix du diagnostic n'est pas visible tant que les actions
						// de vérifications requises n'ont pas toutes été trouvées
					}
					
					reglerOngletsActifs();
				}
			}
			else {
				afficherMsgCreationPatientAttendu(false, selectedPatient.getCivilite());
			}
		}

		/* ---------------------------------------------------------------- */
		/*                         Onglet Contexte                          */
		/* ---------------------------------------------------------------- */

		/* ---------------------------------------------------------------- */
		/*                        Onglet Diagnostic                         */
		/* ---------------------------------------------------------------- */

		public function saveActionsPremiereSeance():void
		{
			// saving actions de vérification
			// listeChoixOrdonnes est du type listeChoixOrdonnes
			//var	listeChoixOrdonnes:listeChoixOrdonnes fait dysfonctionner Flash CS5
			var	listeChoixOrdonnes:MovieClip = patientProperties.actionsVerification.listeChoixOrdonnes;
			var listeChoixActionsVerif:Array = listeChoixOrdonnes.getListeChoix();
			textDebug2.appendText("\nsaving actions "+ listeChoixActionsVerif);
			selectedPatient.listeActionsPremiereSeance = listeChoixActionsVerif;
		}

		public function saveDiagnostic():void
		{
			var listDiagnostics:List = patientProperties.diagnostic.listDiagnostics;
			selectedPatient.indiceDiagnosticChoisi = listDiagnostics.selectedIndex;
		}
		
		
		public function validerActionsVerif():void
		{
			// on sauvegarde avant de vérifier
			saveActionsPremiereSeance();
			
			// vérification proprement dite
			var cas:Cas = selectedPatient.cas;
			var listeChoixActionsVerif:Array = selectedPatient.listeActionsPremiereSeance;				
			// on vérifie si les actions requises de vérification ont bien été sélectionnées,
			// si oui, on rend accessible le choix du diagnostic
			selectedPatient.accesDiagnostic = true;
			for each (var actionVerif:Action in cas.premiereSeance.listeActions) {
				if (actionVerif.requise) {
					if (listeChoixActionsVerif.indexOf(actionVerif.libelle) < 0) {
						selectedPatient.accesDiagnostic = false;
						break;
					}
				}
			}
			patientProperties.diagnostic.visible = selectedPatient.accesDiagnostic;
			afficherMsgListeActionsVerif(selectedPatient.accesDiagnostic, selectedPatient.getCivilite());
			
			if (selectedPatient.accesDiagnostic) {
				// récupération et affichage de la liste des diagnostics possibles
				var listeDiagnostics:Array = cas.listeDiagnostics;
				selectedPatient.dpListDiagnostics = new DataProvider();
				for each (var diagnostic:Diagnostic in listeDiagnostics) {
					trace("diagnostic.maladie : " + diagnostic.maladie);
					selectedPatient.dpListDiagnostics.addItem({label:diagnostic.maladie});
				}
				patientProperties.diagnostic.listDiagnostics.dataProvider = selectedPatient.dpListDiagnostics;
			}
			else {
				// la séance est invalidée, le joueur va devoir planifier une nouvelle séance
				selectedPatient.invalideCreneauEnCours();
			}

			// mise à jour de la visibilité du bouton de validation des actions  
			updateProperties();
		}

		public function validerDiagnostic():void
		{
			// on sauvegarde avant de vérifier
			saveDiagnostic();

			// vérification proprement dite
			var cas:Cas = selectedPatient.cas;
			var listeDiagnostics:Array = cas.listeDiagnostics;
			// on vérifie si le diagnostic choisi est bien un des diagnostics corrects
			var listeDiagnosticsCorrects:Array = listeDiagnostics.filter(Diagnostic.estCorrect);
			var diagnosticChoisi:Diagnostic = listeDiagnostics[selectedPatient.indiceDiagnosticChoisi];
			afficherMsgDiagnostic(diagnosticChoisi.correct, selectedPatient.getCivilite(),
			                      listeDiagnosticsCorrects);
			selectedPatient.diagnosticChoisi = true;
			if (diagnosticChoisi.correct) {
				// TODO : attribuer des points au joueur
			}
			else {
				// TODO : attribuer un malus au joueur
			}
			
			// récupération des différentes thérapies proposées
			var listeTherapies:Array = cas.listeTherapies;
			var therapie:Therapie;
			selectedPatient.dpCBTherapies = new DataProvider();
			for each (therapie in listeTherapies) {
				trace("therapie.libelle : " + therapie.libelle);
				selectedPatient.dpCBTherapies.addItem({label:therapie.libelle});
			}

			// mise à jour de la visibilité du bouton de choix du diagnostic  
			updateProperties();
		}
		
		/* ---------------------------------------------------------------- */
		/*                        Onglet Traitement                         */
		/* ---------------------------------------------------------------- */

		public function saveTherapie():void
		{
			var cbListeTherapies:ComboBox = patientProperties.traitement.cbListeTherapies;
			selectedPatient.indiceTherapieChoisie = cbListeTherapies.selectedIndex;
		}
		
		public function saveActionsTraitement():void
		{
			var	listeChoixOrdonnes:MovieClip = patientProperties.traitement.listeChoixOrdonnes;
			var listeChoixActionsTraitement:Array = listeChoixOrdonnes.getListeChoix();
			textDebug2.appendText("\nsaving actions "+ listeChoixActionsTraitement);
			selectedPatient.setListeActionsTraitementChoisiesSeanceSelectionee(listeChoixActionsTraitement);
		}
		
		public function validerTherapie():void
		{
			// on sauvegarde avant de vérifier
			saveTherapie();

			// vérification proprement dite
			var cas:Cas = selectedPatient.cas;
			var listeTherapies:Array = cas.listeTherapies;
			var therapieChoisie:Therapie = listeTherapies[selectedPatient.indiceTherapieChoisie];
			afficherMsgTherapie(therapieChoisie.pertinente, selectedPatient.getCivilite());
			selectedPatient.accesTraitement = therapieChoisie.pertinente;
			if (therapieChoisie.pertinente) {
				// TODO : attribuer des points au joueur
				
				// récupération des actions de traitement des séances
				// *** correspondant à la première thérapie pour le moment
				// (si cela n'a pas encore été fait)
				if (selectedPatient.listeActionsTraitementParSeance == null) {
					var listeSeances:Array/*Vector.<Seance>*/ = therapieChoisie.listeSeances;
					var listActionsTraitement:Array;
					var dgListeSeancesTraitement:DataGrid = patientProperties.traitement.dgListeSeancesTraitement;
					selectedPatient.listeActionsTraitementParSeance			= new Array();
					selectedPatient.listeActionsTraitementChoisiesParSeance	= new Array();
					for each (var seance:Seance in listeSeances) {
						// ajout du libellé de la séance au tableau des séances
						dgListeSeancesTraitement.addItem({creneau:"---", libelle_seance:seance.libelle});
						
						// constitution de la liste des actions de traitement de cette séance
						listActionsTraitement = new Array();
						var listeActions:Array = seance.listeActions;
						for each (var action:Action in listeActions) {
							listActionsTraitement.push(action.libelle);
						}
						selectedPatient.listeActionsTraitementParSeance.push(listActionsTraitement);
						selectedPatient.listeActionsTraitementChoisiesParSeance.push(new Array());
					}
				}
					 
			}
			else {
				// TODO : attribuer un malus au joueur
			}
			
			// mise à jour de la visibilité du bouton de choix de thérapie 
			updateProperties();
		}
		
		public function validerActionsTraitement():void
		{
			// on sauvegarde avant de vérifier
			saveActionsTraitement();
		}

		/* ---------------------------------------------------------------- */
		/*          Bouton de sauvegarde commun à tous les onglets          */
		/* ---------------------------------------------------------------- */

		public function saveProperties():void
		{
			textDebug2.appendText("\nsaving patient n°"+selectedPatient.idPatient+", tab "+patientProperties.currentFrame);
			//attention : propriétés des images suivantes peut-être pas accessibles => sauver tab par tab ? patientProperties.currentFrame;
			// selectedPatient est un PatientAgenda
			
			switch (selectedTab) {
				case "civilite":
					saveCivilite();
					break;
				case "contexte":
					break;
				case "diagnostic":
					saveActionsPremiereSeance();
					if (selectedPatient.accesDiagnostic) {
						saveDiagnostic();
					}
					break;
				case "traitement":
					// sauvegarde de la thérapie si elle n'a pas encore été choisie
					if (!selectedPatient.accesTraitement) {
						saveTherapie();
					}
					saveActionsTraitement();
					break;
			}
			
			// update Agenda
			updateAgenda();
		}

		// onglet traitement : sélection d'une séance dans la liste des séances de la thérapie choisie
		public function HSelectionSeance(e:Event):void {
			var indiceSeance:int = DataGrid(e.target).selectedIndex;
			selectionSeance(indiceSeance);
		}
		
		// onglet traitement : sélection automatique d'une séance qui vient de démarrer
		// dans la liste des séances de la thérapie choisie
		public function selectionSeanceEnCours(indiceSeance:int):void {
			var dgListeSeancesTraitement:DataGrid = patientProperties.traitement.dgListeSeancesTraitement;
			dgListeSeancesTraitement.selectedIndex = indiceSeance;
			selectionSeance(indiceSeance);
		}
		
		public function selectionSeance(indiceSeance:int):void {
			selectedPatient.indiceSeanceSelectionee = indiceSeance;
			updateProperties();
		}
		
		public function updateProperties():void
		{
			textDebug2.appendText("\nupdateProperties() : patient n°"+selectedPatient.idPatient+", tab "+selectedTab+", nom "+selectedPatient.nomPatient);
			// updating properties for selected patient
			
			// Civilité
			patientProperties.civilite.textNomPatient.text				= selectedPatient.nomPatient;
			patientProperties.civilite.textPrenomPatient.text			= selectedPatient.prenomPatient;
			patientProperties.civilite.cbSexePatient.selectedIndex		= selectedPatient.sexePatient;
			patientProperties.civilite.textAgePatient.text				= (selectedPatient.agePatient > 0 ? selectedPatient.agePatient : "");
			patientProperties.civilite.cbLieuPatient.selectedIndex		= selectedPatient.lieuPatient;
			patientProperties.civilite.textMotifConsultIniPatient.text	= selectedPatient.motifConsultIniPatient;
			patientProperties.civilite.textCommentairesPatient.text		= selectedPatient.commentairesPatient;
			//attention : propriétés des images suivantes peut-être pas accessibles => afficher tab par tab ? patientProperties.currentFrame
		
			// Contexte dentaire et contexte patient
			// -------------------------------------
			
			trace("selectedPatient.cas : " + selectedPatient.cas);
			// 1) suppression éventuelle des précédents contextes affichés
			trace("1) suppression éventuelle des précédents contextes affichés");
			for each (nomBlocCBCritere in ["blocCBCritereDentaire", "blocCBCriterePatient"]) {
				if (patientProperties.contexte.getChildByName(nomBlocCBCritere)) {
					blocCBCritere = Sprite(patientProperties.contexte.getChildByName(nomBlocCBCritere));
					// utiliser ligne suivante à partir de Flash Player V11 :
					// blocCBCritere.removeChildren();
					for(var i:uint = 0; i < blocCBCritere.numChildren; i++)
					{
						blocCBCritere.removeChildAt(i);
					}
				}
				else {
					// on le crée s'il n'existe pas encore
					blocCBCritere = new Sprite;
					blocCBCritere.name = nomBlocCBCritere;
					patientProperties.contexte.addChild(blocCBCritere);
				}
			}
			
			if (selectedPatient.cas != null) {
				var nomBlocCBCritere:String
				var blocCBCritere:Sprite;
				// 2) ajout des contextes dentaire et patient de ce patient
				trace("2) ajout des contextes dentaire et patient de ce patient");
				var cas:Cas = selectedPatient.cas;
				var contexteDentaire:Contexte_Dentaire = cas.contexte_dentaire;
				var contextePatient:Contexte_Patient   = cas.contexte_patient;
				const HAUTEUR_CB_CRITERE:int = 18;
				const LARGEUR_CB_CRITERE:int = 500;
				var nomTfTitre:String;
				var tfTitre:TextField;
				
				for each (var nomTfTitre_nomBlocCBCritere_contexte:Object in
							  [{nomTfTitre: "tfContexteDentaire", nomBlocCBCritere: "blocCBCritereDentaire", contexte:contexteDentaire},
							   {nomTfTitre: "tfContextePatient",  nomBlocCBCritere: "blocCBCriterePatient",  contexte:contextePatient}]) {
					nomTfTitre = nomTfTitre_nomBlocCBCritere_contexte.nomTfTitre;
					trace("nomTfTitre : " + nomTfTitre);
					tfTitre = TextField(patientProperties.contexte[nomTfTitre]);
					trace("tfTitre : " + tfTitre);
					nomBlocCBCritere = nomTfTitre_nomBlocCBCritere_contexte.nomBlocCBCritere;
					trace("nomBlocCBCritere : " + nomBlocCBCritere);
					blocCBCritere = Sprite(patientProperties.contexte.getChildByName(nomBlocCBCritere));
					trace("blocCBCritere : " + blocCBCritere);
					var leContexte:Object = nomTfTitre_nomBlocCBCritere_contexte.contexte;
					trace("leContexte : " + leContexte);
					// on n'utilise pas contexte.libelle pour le moment
					// (qui pourrait être par ex. affecté à ftTitre.text)
					// parcours des critères du contexte en question
					var y:int = tfTitre.y;
					var cbCritere:CheckBox;
					for each (var critere:Critere in leContexte.listeCriteres) {
						y += HAUTEUR_CB_CRITERE;
						cbCritere = new CheckBox;
						cbCritere.enabled = false;
						cbCritere.y = y;
						cbCritere.width = LARGEUR_CB_CRITERE;
						cbCritere.label = critere.condition;
						cbCritere.selected = critere.valeur;
						blocCBCritere.addChild(cbCritere);
					}
				}
			}
						
			// Sélection des actions de vérification devant mener au diagnostic
			if (selectedPatient.listeActionsVerification != null) {
				/* FIXME ceci pose encore problème à la compilation -> à résoudre :
				var listeChoixOrdonnes:ListeChoixOrdonnes = patientProperties.actionsVerification.listeChoixOrdonnes;*/
				patientProperties.actionsVerification.listeChoixOrdonnes.setListeChoixPossibles(selectedPatient.listeActionsVerification);
				patientProperties.actionsVerification.listeChoixOrdonnes.setListeChoix(selectedPatient.listeActionsPremiereSeance);
				
				// accès au bouton de validation des actions de vérification si la première séance
				// de vérification est bien en cours et qu'on n'a pas déjà effectué cette validation
				var premiereSeanceEnCours:Boolean = selectedPatient.premiereSeanceEnCours();
				var accesDiagnostic:Boolean = selectedPatient.accesDiagnostic;
				patientProperties.actionsVerification.listeChoixOrdonnes.boutonValiderChoix.visible =
					premiereSeanceEnCours && !accesDiagnostic;
				
				// affichage du diagnostic si l'accès a déjà été donné
				if (selectedPatient.accesDiagnostic) {
					var listDiagnostics:List = patientProperties.diagnostic.listDiagnostics;
					listDiagnostics.dataProvider = selectedPatient.dpListDiagnostics;
					// sélection de l'éventuel diagnostic choisi par le joueur
					if (selectedPatient.indiceDiagnosticChoisi >= 0) {
						listDiagnostics.selectedIndex = selectedPatient.indiceDiagnosticChoisi;
					}
					// accès au bouton de validation du diagnostic si la première séance
					// de traitement est bien en cours et qu'il a n'a pas déjà été donné
					patientProperties.diagnostic.boutonValiderDiagnostic.visible =
						selectedPatient.premiereSeanceEnCours() &&
						!selectedPatient.diagnosticChoisi;
					
					// accès à la partie traitement si le diagnostic a été choisi
					if (selectedPatient.diagnosticChoisi) {
						// affichage de la liste des thérapies ainsi que de l'éventuelle thérapie choisie
						var cbListeTherapies:ComboBox = patientProperties.traitement.cbListeTherapies;
						cbListeTherapies.dataProvider = selectedPatient.dpCBTherapies;
						if (selectedPatient.indiceTherapieChoisie >= 0) {
							cbListeTherapies.selectedIndex = selectedPatient.indiceTherapieChoisie;
						}
						// la sélection d'une thérapie dans la liste de celles proposées n'est possible
						// que si une thérapie pertinente n'a pas encore été sélectionnée
						cbListeTherapies.enabled = !selectedPatient.accesTraitement;
					
						// accès au bouton de validation de la thérapie choisie à n'importe quel moment
						// (meme si une séance de traitement n'est pas en cours), mais seulement
						// si on n'a pas déjà effectué cette validation
						var seanceTraitementEnCours:Boolean = selectedPatient.seanceTraitementEnCours();
						var accesTraitement:Boolean = selectedPatient.accesTraitement;
						patientProperties.traitement.boutonValiderTherapie.visible = !accesTraitement;
	
						// Sélection des actions de traitement de l'éventuelle séance (de traitement) en cours,
						// ou d'un séance sélectionnée par le joueur
						if (selectedPatient.seanceTraitementSelectionnee()) {
							var listActionsTraitement:Array =
								selectedPatient.getListeActionsTraitementSeanceSelectionee();
							var listActionsTraitementChoisies:Array =
								selectedPatient.getListeActionsTraitementChoisiesSeanceSelectionee();
							patientProperties.traitement.listeChoixOrdonnes.setListeChoixPossibles(listActionsTraitement);
							patientProperties.traitement.listeChoixOrdonnes.setListeChoix(listActionsTraitementChoisies);
						}
						else {
							patientProperties.traitement.listeChoixOrdonnes.setListeChoixPossibles([]);
						}
						// accès au bouton de validation des actions de traitement si :
						// - une séance de traitement est bien en cours
						// - c'est bien cette séance qui est sélectionnée dans la liste des séances
						// - on n'a pas déjà effectué cette validation
						patientProperties.traitement.listeChoixOrdonnes.boutonValiderChoix.visible =
							seanceTraitementEnCours &&
							(selectedPatient.indiceCreneauEnCours - 1 == selectedPatient.indiceSeanceSelectionee) &&
							!/*TODO*/false;
					}
				}

			}
			else {
				patientProperties.actionsVerification.listeChoixOrdonnes.setListeChoixPossibles([]);
			}

		}

		public function functionTabProperties(e:MouseEvent):void
		{
			//textDebug2.appendText("\ncurrentTarget (all tabs) : "+e.currentTarget.name)
			//textDebug2.appendText("\ntarget (tab) : "+e.target.name)
			// current tab
			var theTabBack:MovieClip = e.target as MovieClip;
			selectedTab = theTabBack.parent.name;
			//textDebug2.appendText("\n>selected patient : "+this.selectedPatient);
			if ((selectedTab == "civilite") || 
			    (selectedTab != "civilite" && selectedPatient.cas != null)) {
				displayProperties(selectedTab);
			}
		}
		public function displayProperties(selectedTab:String):void
		{
			textDebug2.appendText("\ndisplayProperties() : patient n°"+selectedPatient.idPatient+", tab "+selectedTab);
			// remove all focus on patients but selected patient;
			removeAllFocus();
			selectedPatient.focus.visible = true;
			selectedPatient.deleteButton.visible = true;

			// update all tabs
			for (var p:uint = 0; p < patientProperties.allTabs.numChildren; p++)
			{
				if (patientProperties.allTabs.getChildAt(p).name != selectedTab)
				{
					patientProperties.allTabs.getChildAt(p).fondTab.visible = true;
				}
				else
				{
					patientProperties.allTabs.getChildAt(p).fondTab.visible = false;
				}
			}
			
			reglerOngletsActifs();
			
			// change tab
			patientProperties.civilite.visible = false;
			patientProperties.contexte.visible = false;
			patientProperties.actionsVerification.visible = false;
			patientProperties.diagnostic.visible = false;
			patientProperties.traitement.visible = false;

			switch (selectedTab) {
				case "civilite":
					patientProperties.civilite.visible = true;
					patientProperties.boutonSauverPatient.visible = true;
					patientProperties.actionsVerification.listeChoixOrdonnes.boutonValiderChoix.visible = false;
					break;
				case "contexte":
					patientProperties.contexte.visible = true;
					patientProperties.boutonSauverPatient.visible = false;
					patientProperties.actionsVerification.listeChoixOrdonnes.boutonValiderChoix.visible = false;
					break;
				case "diagnostic":
					patientProperties.actionsVerification.visible = true;
					patientProperties.diagnostic.visible = selectedPatient.accesDiagnostic;
					patientProperties.boutonSauverPatient.visible = true;
					patientProperties.actionsVerification.listeChoixOrdonnes.boutonValiderChoix.visible = true;
					break;
				case "traitement":
					patientProperties.traitement.visible = true;
					patientProperties.boutonSauverPatient.visible = true;
					patientProperties.actionsVerification.listeChoixOrdonnes.boutonValiderChoix.visible = false;
					break;
			}

			// update all properties
			updateProperties();

			// display information;
			patientProperties.visible = true;
		}

		public function functionAddPatient(e:MouseEvent):void
		{
			// remove all focus
			removeAllFocus();
			// Launched by click on "add patient button")
			var newPatient:PatientAgenda = addPatient();
			selectedPatient = newPatient;
			// diplay properties;
			selectedTab = defaultTab;
			displayProperties(selectedTab);
		}

		public function updateAgenda():void
		{
			trace("dans updateAgenda()");
			Scenario.getInstance().agenda.initializeCbPatients(PatientAgenda.listePatients);
		}

		public function openOrClose(e:MouseEvent):void
		{
			// openOrClose
			if (isOpen)
			{
				isOpen = false;
				this.gotoAndStop(5);
				demasqueElements();
			}
			else
			{
				isOpen = true;
				this.gotoAndStop(1);
				masqueElements();
			}
		}

		public function addPatient():PatientAgenda
		{

			textDebug2.appendText("\npatient n°" + PatientAgenda.getNbPatients());
			// adding patient on scene;
			var patient:PatientAgenda = new PatientAgenda(this);
			// add to stage;
			container.addChild(patient);

			return patient;
		}

		// launched by CLICK on patient
		public function functionDisplayProperties(e:MouseEvent)
		{
			selectedPatient = e.currentTarget as PatientAgenda;
			// selected patient default tab
			displayProperties(defaultTab);
		}
		
		public function deletePatient(e:MouseEvent):void
		{
			// selected patient has been defined in functionDisplayProperties()
			var patientDeleted:Number = selectedPatient.idPatient;
			// listePatients starts at 0
			textDebug2.appendText("\ndelete patient n°"+patientDeleted+" "+PatientAgenda.listePatients.length+" patients in list");

			// new list;
			var listePatientsNew:Vector.<PatientAgenda>  = new Vector.<PatientAgenda>();
			var nbpatientsNew:Number = 0;
			for (var l:Number=0; l<PatientAgenda.listePatients.length; l++)
			{
				if (PatientAgenda.listePatients[l].idPatient != patientDeleted)
				{
					listePatientsNew[nbpatientsNew] = PatientAgenda.listePatients[l];
					nbpatientsNew++;
				}
			}
			PatientAgenda.listePatients = listePatientsNew;

			// removing from container
			var k:int = container.numChildren;
			textDebug2.appendText("\ndeleting "+k+" patients");
			while ( k -- )
			{
				var currentPatient = container.getChildAt(k);
				textDebug2.appendText("\nremoving child at "+k);
				container.removeChildAt(k);
			}

			// filling again;
			textDebug2.appendText("\nlistePatients.length : " + PatientAgenda.getNbPatients());
			for (l=0; l<PatientAgenda.listePatients.length; l++)
			{
				textDebug2.appendText("\n > getting patient "+PatientAgenda.listePatients[l].nomPatient);
				PatientAgenda.listePatients[l].y = l*PatientAgenda.listePatients[l].height;
				container.addChild(PatientAgenda.listePatients[l]);
			}
			// remove focus
			removeAllFocus();
			// remove informations
			patientProperties.visible = false;
			// update agenda
			updateAgenda();

		}

		private function removeAllFocus():void
		{
			for (var i:uint = 0; i < container.numChildren; i++)
			{
				var currentPatient = container.getChildAt(i);
				// remove focus and delete button
				currentPatient.focus.visible = false;
				currentPatient.deleteButton.visible = false;
			}
		}

	}
}