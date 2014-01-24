package scenariofactory.widgets
{
	import fl.controls.Slider;
	import fl.containers.ScrollPane;
	import fl.controls.ComboBox;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.events.SliderEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Timer;
	// classes Timer

	// classes du modèle (Scenario pour la variable d'instance, DossierPatients pour listPatients)
	import scenariofactory.Scenario;
	import scenariofactory.widgets.DossierPatients;
	import scenariofactory.widgets.PatientAgenda;

	public class Agenda extends Widget
	{
		// déclaration manuelle des occurrences de symboles placées sur la scène
		public var boutonAgenda:MovieClip;
		public var boutonAjoutCreneau:MovieClip;
		public var libelleCreneaux:TextField;
		public var libelleDuree:TextField;
		public var tfDureeCreneau:TextField;
		public var sldDureeCreneau:Slider;
		public var textDebug:TextField;
		public var agendaTime:TextField;
		public var calendrier:MovieClip;
		public var conteneurCalendrier:ScrollPane;
		public var libellePatient:TextField;
		public var cbPatients:ComboBox;
		
		// message d'information affiché au joueur
		private var message:String;

		// largeur de la légende des heures
		private static const LARGEUR_LEGENDE_HEURE:int = 36;
		
		// nb de jours affichés dans la semaine
		private static const NB_JOURS_SEMAINE:int = 6;
		
		// largeur d'un jour en pixel dans l'agenda
		private static const LARGEUR_JOUR:int = 100;
		
		// hauteur d'une heure en pixel dans l'agenda
		// (prendre soit qu'il soit divisible par 4 puisque le plus petit
		//  créneau possible est de 1/4 d'heure)
		public static const HAUTEUR_HEURE:int = 40;

		// heures du début de la journée de travail
		private static const HEURE_DEBUT:int = 8;
		
		// nombre d'heures de travail affichées
		private static const NB_HEURES:int = 12;
		
		// date actuelle courant tout au long du jeu
		private static var dateCourante:Date;
		
		// container of slots
		var conteneurCreneaux:Sprite = new Sprite;
		
		// rectangle for avatar drag
		private var rect:Rectangle;
		// selected slot
		var selectedSlot:Creneau;
		// selected duration (en minutes)
		var dureeCreneau:int;
		// patients 
		//var listPatients:Array = [];
		// open or close
		private var isOpen:Boolean = true;
		// Timer
		private var agendaTimer:Timer;
		// temps
		var listeJours:Array = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi',
		                        'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
		var idJourCourant:Number = 0;

		// constructor
		public function Agenda()
		{
			trace("occurence of Agenda : "+this.name);

			// bouton
			boutonAgenda.addEventListener(MouseEvent.CLICK, openOrClose);
			
			// rectangle for drag
			initRectangle(2 * NB_JOURS_SEMAINE * LARGEUR_JOUR + LARGEUR_LEGENDE_HEURE,
			              NB_HEURES * HAUTEUR_HEURE);
			
			// add slot
			boutonAjoutCreneau.addEventListener(MouseEvent.CLICK, buttonAddSlot);
			
			// handler for duration;
			sldDureeCreneau.addEventListener(SliderEvent.CHANGE, HchangeDureeCreneau);

			textDebug.text = "";
			
			// masquage des éléments (ne marche pas, cf. méthode demarrer()
			//conteneurCalendrier.addEventListener(Event.INIT, function (e:Event) { masqueElements(); });
		}

		/* ---------------------------------------------------------------- */
		/*            Fonctions de communication avec le joueur             */
		/* ---------------------------------------------------------------- */

		private function afficherMessage(message:String) {
			Scenario.getInstance().messageGeneral._afficherMessage(message + "\n");
		}

		// indique qu'un créneau ne peut être positionné dans le passé
		private function afficherMsgPosCreneauPasse() {
			message = "Un créneau ne peut être positionné dans le passé. " + 
			          "Il a donc été remis à sa position initiale.";	
			afficherMessage(message);
		}
		
		// indique qu'un créneau ne peut être positionné s'il intersecte avec un autre
		private function afficherMsgPosCreneauIntersecte() {
			message = "Un créneau ne peut être positionné en intersection avec un autre. " + 
			          "Il a donc été remis à sa position initiale.";	
			afficherMessage(message);
		}
		
		// démarre effectivement l'agenda, en particulier relativement à son timer
		public function demarrer() {
			trace("Agenda > demarrer()");
			
			// création du fond de l'agenda (calendrier sur deux semaines)
			// et rattachement au conteneur permettant de le visualiser en scrollant
			// (remarque : ne marche pas dans le constructeur, trop tôt sans doute)
			calendrier = new AGEND_Fond;
			conteneurCalendrier.source = calendrier;
			
			// container for slots
			calendrier.addChild(conteneurCreneaux);

			// on masque les éléments à ce moment-là car sinon fond (ScrollPane) n'est
			// pas masqué dans le constructeur (a priori car il n'est pas encore totalement
			// initialisé), malgré le fait d'attendre l'événement Event.INI
			masqueElements();
			
			// initialisation du libellé de la durée par défaut d'un créneau
			dureeCreneau = sldDureeCreneau.value;
			changeDureeCreneau(dureeCreneau);
			
			// time running (timer de Scenario pas possible car pas forcément créé !)
			agendaTimer = new Timer(5000,0);
			agendaTimer.addEventListener("timer",updateAgenda);
			agendaTimer.start();
		}

		// conversion d'une position (x, y) dans l'agenda vers un jour-heure-minute
		// pour plus de commodités, on va utiliser la classe A.S. Date en se plaçant
		// à un mois d'une année dont le jour 1 tombe un lundi : lundi 01/04/2013
		public static function DateFromPosXY(X: int, Y:int):Date {
			X = X - LARGEUR_LEGENDE_HEURE;
			var jour:Number			= 1 + Math.floor(X / LARGEUR_JOUR);
			if (X > NB_JOURS_SEMAINE * LARGEUR_JOUR) {
				X -= LARGEUR_LEGENDE_HEURE;
				jour++;	// pour compter le dimanche qui n'est pas affiché
			}
			var deltaHeures:Number	= Math.floor(Y / HAUTEUR_HEURE);
			var heures:Number		= HEURE_DEBUT + deltaHeures;
			var minutes:Number		= Math.round((Y - deltaHeures * HAUTEUR_HEURE) * 60 / HAUTEUR_HEURE);

			return new Date(2013, 3, jour, heures, minutes);
		}
		
		// retourne la date correspondant à la position du curseur de temps
		public function getDateCourante(): Date {
			return DateFromPosXY(calendrier.maintenant.x, calendrier.maintenant.y);	
		}
		
		public static function dateFinCreneau(c:Creneau):Date {
			var dateDebut:Date = c.date;
			var jourDebut:Number	= dateDebut.getDate();
			var heuresDebut:Number	= dateDebut.getHours();
			var minutesDebut:Number	= dateDebut.getMinutes();
			var dureeMinutes:Number = c.duration * 60;
			var jourFin:Number		= jourDebut;
			var heuresFin:Number	= heuresDebut;
			var minutesFin:Number	= minutesDebut;
			
			minutesFin += dureeMinutes;
			if (minutesFin >= 60) {
				// un créneau reste à l'intérieur d'une même journée
				minutesFin -= 60;
				heuresFin++;
			}
			
			return new Date(2013, 3, jourFin, heuresFin, minutesFin);
		}

		public static function compareDates(d1:Date, d2:Date) {
			return d1.getTime() - d2.getTime();
		}

		// contrôler le démarrage ou la fin de créneaux de consultation des patients
		// en fonction de la date actuelle
		private function controlerDebutFinCreneaux(date:Date) {
			var listeCreneauxPatients:Vector.<Creneau> = new Vector.<Creneau>();
			var creneau:Creneau;
			var patient:PatientAgenda;	// patient concerné par un créneau démarrant ou se terminant
			var civilitePatient:String;	// civilité de ce patient
			var indiceCreneau:int;		// indice du créneau concerné dans la liste des créneaux de ce patient
			var message:String;			// message affiché au joueur concernant ce patient
			var dossierPatients:DossierPatients = Scenario.getInstance().dossierPatients;
			
			// 1) recueil de tous les créneaux des patients qui ne sont encore passés
			for each (patient in PatientAgenda.listePatients) {
				listeCreneauxPatients = listeCreneauxPatients.concat(patient.getListeCreneauxAgenda().filter(Creneau.estPasPasse));
			}
			Creneau.trieListeCreneaux(listeCreneauxPatients);
			trace("Liste des créneaux en cours ou à venir :");
			Creneau.traceListeCreneaux(listeCreneauxPatients);
			
			// 2) parcours de ces créneaux à la recherche de :
			for each (creneau in listeCreneauxPatients) {
				// 2.a) les créneaux qui viennent de démarrer
				if (creneau.etat == Creneau.FUTUR && (creneau.compareDateACreneau(date) >= 0)) {
					patient = PatientAgenda.getPatientParId(creneau.idPatient);
					civilitePatient = patient.getCivilite();
					indiceCreneau = patient.setCreneauEnCours(creneau);
					// ce créneau ne pourra plus être déplacé
					// (FIXME améliorer en migrant dans classe Creneau, ainsi que les méthodes
					//        addSlot() .. positionSlot())
					creneau.removeEventListener(MouseEvent.MOUSE_DOWN, dragSlot);
					creneau.removeEventListener(MouseEvent.MOUSE_UP,   stopSlot);
					// il faut vérifier que le créneau correspond bien à quelque chose
					// cf. PatientAgenda.setCreneauEnCours > commentaires
					if (creneau.etat != Creneau.INVALIDE) {
						trace("Le créneau suivant du patient " + civilitePatient  + " passe dans l'état \"en cours\" : " +
							  creneau.toString());
						message = "Le patient " + civilitePatient + " vient d'arriver au cabinet pour sa séance n° " +
						          (indiceCreneau + 1);
						afficherMessage(message);
					}
					else {
						message = "Le patient " + civilitePatient + " a un créneau dans l'agenda qui vient de démarrer, " +
						          "mais ce créneau ne peut être utilisé, car ";
					 	if (!patient.accesTraitement) {
							message += "il s'agit d'un créneau destiné a priori à une séance de traitement, " +
								       "mais aucune thérapie pertinente n'a encore été choisie.";
						}
						else {
							message += "il s'agit d'un créneau surnuméraire par rapport aux nombre de séances " +
								  	   "nécessaires à la thérapie choisie.";
						}
						afficherMessage(message);
					}
				}
				// 2.b) les créneaux en cours qui viennent de se terminer
				if (creneau.etat == Creneau.EN_COURS && (compareDates(date, dateFinCreneau(creneau)) > 0)) {
					patient = PatientAgenda.getPatientParId(creneau.idPatient);
					civilitePatient = patient.getCivilite();
					
					// on regarde si le joueur n'a pas eu le temps de proposer ses
					// actions de vérification ou son diagnostic pour la première séance,
					// ou ses actions de traitement pour une séance de traitement,
					// auquel cas il faudra invalider le créneau en question
					var creneauAInvalider = false;
					if (patient.premiereSeanceEnCours() &&
					    (!patient.accesDiagnostic || !patient.diagnosticChoisi)) {
						creneauAInvalider = true;
						dossierPatients.afficherMsgSeanceActionsVerifEchue(civilitePatient);
					}
					else if (patient.seanceTraitementEnCours() &&
					         !patient.listeStatutsActionsChoisiesParSeance[patient.indiceCreneauEnCours - 1]) {
						creneauAInvalider = true;
						dossierPatients.afficherMsgSeanceActionsTraitementEchue(civilitePatient);
					}
					
					if (creneauAInvalider) {
						// le créneau doit être invalidé
						patient.invalideCreneauEnCours();
					}
					else {
						// le créneau passe simplement dans le passé
						indiceCreneau/* not used*/ = patient.setCreneauPasse(creneau);
						trace("Le créneau suivant du patient " + civilitePatient  + " passe dans l'état \"passé\" : " +
							  creneau.toString());
						message = "Le patient " + civilitePatient + " vient de quitter le cabinet sa séance terminée";
						afficherMessage(message);
					}
					
				}
			}
		}
		
		private function updateAgenda(event:Event)
		{
			// y
			calendrier.maintenant.y += 5;
			// test sur journée
			if (calendrier.maintenant.y > NB_HEURES * HAUTEUR_HEURE)
			{
				if (idJourCourant < 2 * NB_JOURS_SEMAINE - 1) {
					// on n'a pas encore atteint la fin de la semaine
					idJourCourant++;
					calendrier.maintenant.y = 0;
					calendrier.maintenant.x = LARGEUR_LEGENDE_HEURE + idJourCourant * LARGEUR_JOUR +
						(idJourCourant >= NB_JOURS_SEMAINE ? LARGEUR_LEGENDE_HEURE : 0);
				}
				else {
					// la fin de la semaine est atteinte
					calendrier.maintenant.y -= 5;
					agendaTimer.stop();
				}
			}
			// affichage
			dateCourante = getDateCourante();
			
			var minutestext:String = dateCourante.getMinutes().toString();
			if (dateCourante.getMinutes() < 10){
				minutestext = "0" + minutestext;
			}
			agendaTime.text = listeJours[idJourCourant] + " " +
			                  dateCourante.getDate() + "/" + (dateCourante.getMonth() + 1) + ", " +
							  dateCourante.getHours() + ":" + minutestext;
							  
			controlerDebutFinCreneaux(dateCourante);
		}

		public function openOrClose(e:MouseEvent):void
		{
			// openOrClose
			if (isOpen)
			{
				Scenario.getInstance().dossierPatients.textDebug2.text = "";
				demasqueElements();
				Scenario.getInstance().dossierPatients.masqueElements();
			}
			else
			{
				textDebug.text = "";
				masqueElements();
			}
		}
		public function masqueElements():void
		{
			isOpen = true;
			conteneurCalendrier.visible = false;
			boutonAjoutCreneau.visible = false;
			libelleCreneaux.visible = false;
			libelleDuree.visible = false;
			tfDureeCreneau.visible = false;
			sldDureeCreneau.visible = false;
			libellePatient.visible = false;
			cbPatients.visible = false;
			textDebug.visible = false;
		}
		public function demasqueElements():void
		{
			isOpen = false;
			conteneurCalendrier.visible = true;
			boutonAjoutCreneau.visible = true;
			libelleCreneaux.visible = true;
			libelleDuree.visible = true;
			tfDureeCreneau.visible = true;
			sldDureeCreneau.visible = true;
			libellePatient.visible = true;
			cbPatients.visible = true;
			textDebug.visible = true;
		}

		private function dureeMinutesToString(dureeMin:int) {
			var dureeString:String;
			var dureeHeure = Math.floor(dureeMin / 60);

			dureeMin = dureeMin % 60;
			if (dureeHeure > 0) {
				dureeString = dureeHeure + " h " +
				              (dureeMin > 0 ? dureeMin : "");
			}
			else {
				dureeString = dureeMin + " min";
			}

			return dureeString;
		}
		
		function HchangeDureeCreneau(event:SliderEvent):void
		{
			dureeCreneau = event.value;
			changeDureeCreneau(dureeCreneau);
		}

		function changeDureeCreneau(dureeCreneau:int):void
		{
			tfDureeCreneau.text = dureeMinutesToString(dureeCreneau);
			textDebug.appendText("\ndurée : " + dureeCreneau);
		}

		public function buttonAddSlot(e:MouseEvent):void
		{
			// remove all focus
			removeAllFocus();
			// Launched by click on "add slot button")
			var durationS:int = dureeCreneau;
			// duration, position x, position y, patient id
			// (- 120 pour que le créneau à ajouter soit visible dans conteneurCalendrier)
			textDebug.appendText("\n" + e.currentTarget.x + "," + e.currentTarget.y);
			addSlot(durationS, e.currentTarget.x, e.currentTarget.y - 120);
		}

		public function addSlot(durationS:int, positionX:Number, positionY:Number, idPatient:Number=0):void
		{
			textDebug.appendText("\nslot: duration : " + durationS.toString());
			// adding slot on scene;
			var slot:Creneau = new Creneau;
			var dureeHeures:Number = durationS / 60;
			slot.etat = Creneau.FUTUR;
			slot.duration = dureeHeures; // en nombre d'heures
			slot.idPatient = idPatient;
			slot.x = positionX;
			slot.y = positionY;
			slot.slotBackground.height *= dureeHeures;
			slot.focus.height *= dureeHeures;
			// delete button
			slot.deleteButton.visible = false;
			slot.deleteButton.addEventListener(MouseEvent.CLICK, deleteSlot);
			// drag;
			slot.addEventListener(MouseEvent.MOUSE_DOWN, dragSlot);
			slot.addEventListener(MouseEvent.MOUSE_UP,   stopSlot);
			slot.buttonMode = true;	// -> curseur en forme de main
			// add to stage
			conteneurCreneaux.addChild(slot);
		}

		private function dragSlot(e:MouseEvent):void
		{
			// remove all focus
			removeAllFocus();
			// selected slot
			selectedSlot = e.currentTarget as Creneau;
			// focus and delete button
			selectedSlot.focus.visible = true;
			selectedSlot.deleteButton.visible = true;
			// avant le démarrage du glisser-déposer, on mémorise la position de départ
			// du créneau afin de la restaurer si la position d'arrivée est incorrecte
			selectedSlot.x0 = selectedSlot.x; 
			selectedSlot.y0 = selectedSlot.y; 
			// drag
			e.currentTarget.startDrag(false, rect);
		}

		private function stopSlot(e:MouseEvent):void
		{
			displayProperties(selectedSlot);
			selectedSlot.stopDrag();
			positionSlot();
		}

		private function deleteSlot(e:MouseEvent):void
		{
			// supprimer le créneau de la liste globale de tous les créneaux
			// (s'il est associé à un patient, il est aussi supprimé de la liste de ses créneaux)
			selectedSlot.supprimer();
			
			// delete slot
			conteneurCreneaux.removeChild(selectedSlot);
			selectedSlot = null;
			// cb invisible
			cbPatients.visible = false;
		}

		private function positionSlot():void
		{
			// accurately position slot (grid LARGEUR_JOUR px x HAUTEUR_HEURE/4 px)
			var gridX:Number = LARGEUR_JOUR;
			var gridY:Number = HAUTEUR_HEURE / 4;
			var noSemaineSlot = (selectedSlot.x > LARGEUR_JOUR * NB_JOURS_SEMAINE +
			                                      LARGEUR_LEGENDE_HEURE ? 2 : 1);
			var xPosition:Number = noSemaineSlot * LARGEUR_LEGENDE_HEURE +
			                       Math.round((selectedSlot.x - (noSemaineSlot * LARGEUR_LEGENDE_HEURE)) / gridX) * gridX;
			var dateCreneau:Date;
			var posCreneauValide:Boolean = true;
			
			// recalage si le créneau déborde de la première semaine
			if (noSemaineSlot == 1) {
				xPosition = Math.min(xPosition, LARGEUR_LEGENDE_HEURE + (NB_JOURS_SEMAINE - 1) * LARGEUR_JOUR);
			}
			var yPosition:Number = Math.round(selectedSlot.y / gridY) * gridY;
			selectedSlot.setPosition(xPosition, yPosition);
			
			// vérification de la validité du créneau :
			// 1) il doit être dans le futur
			// 2) et ne pas intersecter avec un autre créneau déjà présent
			dateCourante = getDateCourante();
			if (selectedSlot.compareDateACreneau(dateCourante) >= 0) {
				posCreneauValide = false;
				afficherMsgPosCreneauPasse();
			}
			else if (selectedSlot.creneauIntersecte()) {
				posCreneauValide = false;
				afficherMsgPosCreneauIntersecte();
			}
			
			if (posCreneauValide) {
				textDebug.appendText("\ndate du créneau : " + selectedSlot.date.toString());
				
				// tri éventuel des créneaux du même patient concerné par ce créneau
				if (selectedSlot.idPatient > 0) {
					PatientAgenda.getPatientParId(selectedSlot.idPatient).trieListeCreneaux();
				}
			}
			else {
				// on signale le problème à l'utilisateur et on repositionne
				// le créneau à sa position de départ
				selectedSlot.setPosition(selectedSlot.x0, selectedSlot.y0);
			}
		}
		
		private function initRectangle(largeur:Number,hauteur:Number):void
		{
			rect = new Rectangle(LARGEUR_LEGENDE_HEURE, HAUTEUR_HEURE,
			                     largeur - LARGEUR_JOUR, hauteur - HAUTEUR_HEURE);
		}

		private function removeAllFocus():void
		{
			for (var i:uint = 0; i < conteneurCreneaux.numChildren; i++)
			{
				var currentSlot:Creneau = Creneau(conteneurCreneaux.getChildAt(i));
				// remove focus and delete button
				currentSlot.focus.visible = false;
				currentSlot.deleteButton.visible = false;
			}
		}
		public function displayProperties(slot:Creneau):void
		{
			cbPatients.visible = true;
			// patient
			cbPatients.selectedIndex = slot.idPatient;
		}
		public function initializeCbPatients(listPatients:Vector.<PatientAgenda>):void
		{
			trace("dans initializeCbPatients()");
			cbPatients.removeAll();
			cbPatients.addItem( { label:"patient...", data:-1 } );
			// get patient list from dossierPatients;
			if (listPatients != null)
			{
				var libellePatient:String;
				for each (var patient:PatientAgenda in listPatients)
				{
					libellePatient = patient.getCivilite();
					//cbPatients.addItem( { label:listPatients[l].nomPatient, data:l } );
					cbPatients.addItem( { label:libellePatient, data:patient.idPatient } );
					trace("patient : " + patient.idPatient + ", nom = " + patient.nomPatient);
				}
				cbPatients.addEventListener(Event.CHANGE, changePatient);
				cbPatients.visible = false;
			}
		}
		private function changePatient(e:Event):void
		{
			textDebug.appendText("\naffectation du patient " + cbPatients.selectedItem.data + " (" +
								 cbPatients.selectedItem.label + ")" + " au créneau sélectionné");
			
			// on supprime le créneau de l'éventuel patient auquel il était déjà attaché
			if (selectedSlot.idPatient > 0) {
				PatientAgenda.getPatientParId(selectedSlot.idPatient).removeCreneau(selectedSlot);
				textDebug.appendText("\nsuppression du créneau [" + selectedSlot.date.toString() + "]" +
									 " du patient " + PatientAgenda.getPatientParId(selectedSlot.idPatient).nomPatient);
			}

			// change and display slot properties
			selectedSlot.idPatient = cbPatients.selectedItem.data;
			selectedSlot.textPatient.text = cbPatients.selectedItem.label;

			// on vérifie qu'on n'a pas sélectionné le choix du titre de la combo box ("patient ...")
			if (selectedSlot.idPatient > 0) {
				// on ajoute ce créneau à la liste des créneaux de ce patient
				PatientAgenda.getPatientParId(selectedSlot.idPatient).addCreneau(selectedSlot);
				textDebug.appendText("\najout du créneau [" + selectedSlot.date.toString() + "]" +
									 " au patient " + PatientAgenda.getPatientParId(selectedSlot.idPatient).nomPatient);
			}
		}
	}
}