package scenariofactory.widgets {
 	import flash.display.MovieClip;
	import flash.text.TextField;

	public class Creneau extends MovieClip {
		// déclaration manuelle des occurrences de symboles placées sur la scène
		public var textPatient:TextField;
		public var focus:MovieClip;
		public var deleteButton:MovieClip;
		public var slotBackground:MovieClip;

		// différents états d'un créneau de consultation dans le temps
		public static const CRENEAU_PASSE:int		= 0;
		public static const CRENEAU_EN_COURS:int	= 1;
		public static const CRENEAU_FUTUR:int		= 2;
		// état actuel		
		public var etat:int;
		
		// date de début du créneau
		public var date:Date;
		
		// durée du créneau en heure (résolution : 0.25 : 1/4 h)
		public var duration:Number;
		
		public var idPatient:int;	// pour lequel ce créneau a été pris
		
		function Creneau(){
		
		}

		override public function toString():String {
			return this.date.toString() + " [" + this.etat + "]";
		}

		// fonctions permettant d'appliquer la méthode "filter" sur les vecteurs de AGEND_Slot
		// suivant les différents états des créneaux que l'on désire garder
		public static function creneauEstPasse(creneau:Creneau, indiceCrenau:int, listeCreneaux:Vector.<Creneau>):Boolean {
			return (creneau.etat == CRENEAU_PASSE);
		}
		public static function creneauEstPasPasse(creneau:Creneau, indiceCrenau:int, listeCreneaux:Vector.<Creneau>):Boolean {
			return (creneau.etat != CRENEAU_PASSE);
		}
		public static function creneauEstEnCours(creneau:Creneau, indiceCrenau:int, listeCreneaux:Vector.<Creneau>):Boolean {
			return (creneau.etat == CRENEAU_EN_COURS);
		}
		public static function creneauEstFutur(creneau:Creneau, indiceCrenau:int, listeCreneaux:Vector.<Creneau>):Boolean {
			return (creneau.etat == CRENEAU_FUTUR);
		}
		
		public function compareDateACreneau(d:Date) {
			return d.getTime() - this.date.getTime();
		}

		
		public function compareCreneau(c:Creneau) {
			return this.date.getTime() - c.date.getTime();
		}

		public static function compareCreneaux(c1:Creneau, c2:Creneau) {
			return c1.date.getTime() - c2.date.getTime();
		}

		public static function trieListeCreneaux(listeCreneaux:Vector.<Creneau>) {
			listeCreneaux.sort(compareCreneaux);
		}

		public static function traceListeCreneaux(listeCreneaux:Vector.<Creneau>) {
			for each (var creneau:Creneau in listeCreneaux) {
				trace("- " + creneau.toString());
			}
		}

	}
}