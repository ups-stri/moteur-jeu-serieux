package scenariofactory.widgets
{
	import fl.controls.ComboBox;

	import scenariofactory.Scenario;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Timer;
	// classes Timer

	// classes du modèle (Scenario pour la variable d'instance, DossierPatients pour listPatients)

	public class Agenda extends Widget
	{
		// déclaration manuelle des occurrences de symboles placées sur la scène
		public var boutonAgenda:MovieClip;
		public var boutonAjoutCreneau:MovieClip;
		public var radioButtonsDuration:MovieClip;
		public var textDebug:TextField;
		public var maintenant:MovieClip;
		public var agendaTime:TextField;
		public var fond:MovieClip;
		public var cbPatients:ComboBox;
		
		// largeur d'un jour en pixel dans l'agenda
		private static const LARGEUR_JOUR:int = 100;
		
		// hauteur d'une heure en pixel dans l'agenda
		// (prendre soit qu'il soit divisible par 4 puisque le plus petit
		//  créneau possible est de 1/4 d'heure)
		private static const HAUTEUR_HEURE:int = 40;

		// heures du début de la journée de travail
		private static const HEURE_DEBUT:int = 8;
		
		// nombre d'heures de travail affichées
		private static const NB_HEURES:int = 13;
		
		// date actuelle courant tout au long du jeu
		private static var dateCourante:Date;
		
		// container of slots
		var container:Sprite = new Sprite  ;
		// rectangle for avatar drag
		private var rect:Rectangle;
		// selected slot
		var selectedSlot:Creneau;
		// selected duration
		var selectedDuration:Number = 1;
		// patients 
		//var listPatients:Array = [];
		// open or close
		private var isOpen:Boolean = true;
		// Timer
		private var agendaTimer:Timer;
		// temps
		var listeJours:Array = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi'];
		var idJourCourant:Number = 0;

		// constructor
		public function Agenda()
		{
			trace("occurence of Agenda : "+this.name);

			// bouton
			boutonAgenda.addEventListener(MouseEvent.CLICK, openOrClose);
			// container for slots;
			addChild(container);
			// rectangle for drag
			initRectangle(600,520);
			// add slot
			boutonAjoutCreneau.addEventListener(MouseEvent.CLICK, buttonAddSlot);
			// handler for duration;
			radioButtonsDuration.addEventListener(MouseEvent.CLICK, radioHandler);
			//;
			textDebug.text = "";
			// comboBox for patients (launched by DossierPatients)
			// mask elements
			masqueElements();
			// time running (timer de Scenario pas possible car pas forcément créé !)
			agendaTimer = new Timer(5000,0);
			agendaTimer.addEventListener("timer",updateAgenda);
			agendaTimer.start();

		}

		// conversion d'une position (x, y) dans l'agenda vers un jour-heure-minute
		// pour plus de commodités, on va utiliser la classe A.S. Date en se plaçant
		// à un mois d'une année dont le jour 1 tombe un lundi : lundi 01/04/2013
		public static function DateFromPosXY(X: int, Y:int):Date {
			var jour:Number			= 1 + Math.floor(X / LARGEUR_JOUR);
			var deltaHeures:Number	= Math.floor(Y / HAUTEUR_HEURE);
			var heures:Number		= HEURE_DEBUT + deltaHeures;
			var minutes:Number		= Math.floor((Y - deltaHeures * HAUTEUR_HEURE) * 60 / HAUTEUR_HEURE);

			return new Date(2013, 3, jour, heures, minutes);
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
					indiceCreneau = patient.setCreneauEnCours(creneau);
					civilitePatient = patient.getCivilite();
					trace("Le créneau suivant du patient " + civilitePatient  + " passe dans l'état \"en cours\" : " +
						  creneau.toString());
					message = "Le patient " + civilitePatient + " vient d'arriver au cabinet pour sa séance n° " +
					          (indiceCreneau + 1);
					Scenario.getInstance().messageGeneral._afficherMessage(message);
				}
				// 2.b) les créneaux en cours qui viennent de se terminer
				if (creneau.etat == Creneau.EN_COURS && (compareDates(date, dateFinCreneau(creneau)) > 0)) {
					patient = PatientAgenda.getPatientParId(creneau.idPatient);
					indiceCreneau/* not used*/ = patient.setCreneauPasse(creneau);
					civilitePatient = patient.getCivilite();
					trace("Le créneau suivant du patient " + civilitePatient  + " passe dans l'état \"passé\" : " +
						  creneau.toString());
					message = "Le patient " + civilitePatient + " vient de quitter le cabinet sa séance terminée";
					Scenario.getInstance().messageGeneral._afficherMessage(message);
				}
			}
		}
		
		private function updateAgenda(event:Event)
		{
			// y
			maintenant.y = maintenant.y + 5;
			// test sur journée
			if (maintenant.y > NB_HEURES * HAUTEUR_HEURE)
			{
				idJourCourant++;
				maintenant.y = 0;
				maintenant.x = idJourCourant * LARGEUR_JOUR;
			}
			// affichage
			dateCourante = DateFromPosXY(maintenant.x, maintenant.y);
			
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
				isOpen = false;
				this.gotoAndStop(5);
				demasqueElements();
			}
			else
			{
				textDebug.text = "";
				isOpen = true;
				this.gotoAndStop(1);
				masqueElements();
			}
		}
		public function masqueElements():void
		{
			fond.visible = false;
			boutonAjoutCreneau.visible = false;
			radioButtonsDuration.visible = false;
			cbPatients.visible = false;
			container.visible = false;
			textDebug.visible = false;
			maintenant.visible = false;
		}
		public function demasqueElements():void
		{
			fond.visible = true;
			boutonAjoutCreneau.visible = true;
			radioButtonsDuration.visible = true;
			cbPatients.visible = true;
			container.visible = true;
			textDebug.visible = true;
			maintenant.visible = true;
		}
		function radioHandler(event:MouseEvent):void
		{
			selectedDuration = event.target.value;
			textDebug.appendText("\ndurée : " + selectedDuration);
		}

		public function buttonAddSlot(e:MouseEvent):void
		{
			// remove all focus
			removeAllFocus();
			// Launched by click on "add slot button")
			var durationS:Number = Number(selectedDuration);
			// duration, position x, position y, patient id
			addSlot(durationS, e.currentTarget.x, e.currentTarget.y);
		}

		public function addSlot(durationS:Number, positionX:Number, positionY:Number, idPatient:Number=0):void
		{
			textDebug.appendText("\nslot: duration : " + durationS.toString());
			// adding slot on scene;
			var slot:Creneau = new Creneau;
			slot.etat = Creneau.FUTUR;
			slot.duration = 1 / durationS; // en nombre d'heures
			slot.idPatient = idPatient;
			slot.x = positionX;
			slot.y = positionY;
			slot.slotBackground.height = slot.slotBackground.height / durationS;
			slot.focus.height = slot.focus.height / durationS;
			// delete button
			slot.deleteButton.visible = false;
			slot.deleteButton.addEventListener(MouseEvent.CLICK,deleteSlot);
			// drag;
			slot.addEventListener(MouseEvent.MOUSE_DOWN,dragSlot);
			slot.addEventListener(MouseEvent.MOUSE_UP,stopSlot);
			// add to stage
			container.addChild(slot);
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
			// drag
			e.currentTarget.startDrag(false,rect);
		}

		private function stopSlot(e:MouseEvent):void
		{
			displayProperties(selectedSlot);
			selectedSlot.stopDrag();
			positionSlot();
		}

		private function deleteSlot(e:MouseEvent):void
		{
			// delete slot
			container.removeChild(selectedSlot);
			selectedSlot = null;
			// cb invisible
			cbPatients.visible = false;
		}

		private function positionSlot():void
		{
			// accurately position slot (grid LARGEUR_JOUR px x HAUTEUR_HEURE/4 px)
			var gridX:Number = LARGEUR_JOUR;
			var gridY:Number = HAUTEUR_HEURE / 4;
			var xPosition:Number = Math.floor(selectedSlot.x / gridX) * gridX;
			var yPosition:Number = Math.floor(selectedSlot.y / gridY) * gridY;
			selectedSlot.x = xPosition;
			selectedSlot.y = yPosition;
			// comprendre l'ajustement "- HAUTEUR_HEURE" réalisée dans la ligne suivante
			selectedSlot.date = DateFromPosXY(selectedSlot.x, selectedSlot.y - HAUTEUR_HEURE);
			if (selectedSlot.idPatient > 0) {
				PatientAgenda.getPatientParId(selectedSlot.idPatient).trieListeCreneaux();
			}
		}
		private function initRectangle(largeur:Number,hauteur:Number):void
		{
			rect = new Rectangle(0, HAUTEUR_HEURE, largeur - LARGEUR_JOUR, hauteur);
		}

		private function removeAllFocus():void
		{
			for (var i:uint = 0; i < container.numChildren; i++)
			{
				var currentSlot = container.getChildAt(i);
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