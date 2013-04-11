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
		// (INVALIDE indique un créneau qui était consacré à la première
		//  séance d'un cas, et pour lequel la liste d'actions de vérification
		//  proposée a été incorrecte, obligeant le joueur à replanifier la séance) 
		public static const INVALIDE:int	= -1;
		public static const PASSE:int		= 0;
		public static const EN_COURS:int	= 1;
		public static const FUTUR:int		= 2;
		// n° d'images respectives du clip Flash représentant ce créneau
		public static const IMAGE_FUTUR:int =    1; 
		public static const IMAGE_PASSE:int =    2; 
		public static const IMAGE_EN_COURS:int = 3; 
		public static const IMAGE_INVALIDE:int = 4; 
		// état actuel		
		private var _etat:int;
		
		// date de début du créneau
		public var date:Date;
		
		// durée du créneau en heure (résolution : 0.25 : 1/4 h)
		public var duration:Number;
		
		public var idPatient:int;	// pour lequel ce créneau a été pris
		
		function Creneau() {
		
		}

		override public function toString():String {
			return this.date.toString() + " [" + this.etat + "]";
		}

		// fonctions permettant d'appliquer la méthode "filter" sur les vecteurs de creneau
		// suivant les différents états des créneaux que l'on désire garder
		// (la mise de valeurs par défaut aux 2e et 3e arguments
		//  permet un appel manuel et plus classique de chaque méthode)
		public static function estPasse(creneau:Creneau, indiceCrenau:int = -1, listeCreneaux:Vector.<Creneau> = null):Boolean {
			return (creneau.etat == PASSE);
		}
		public static function estPasPasse(creneau:Creneau, indiceCrenau:int = -1, listeCreneaux:Vector.<Creneau> = null):Boolean {
			// on ne retient pas les créneaux invalides
			return (creneau.etat != PASSE && creneau.etat != INVALIDE);
		}
		public static function estEnCours(creneau:Creneau, indiceCrenau:int = -1, listeCreneaux:Vector.<Creneau> = null):Boolean {
			return (creneau.etat == EN_COURS);
		}
		public static function estFutur(creneau:Creneau, indiceCrenau:int = -1, listeCreneaux:Vector.<Creneau> = null):Boolean {
			return (creneau.etat == FUTUR);
		}
		
		public function get etat():int {
			return _etat;	
		}
		
		// fonction indiquant le nouvel état du créneau
		public function set etat(etatNew:int) {
			_etat = etatNew;
			var imageEtat:int;
			switch (etatNew) {
				case FUTUR:
					imageEtat = IMAGE_FUTUR;
					this.alpha = 0.8;
					break;
				case PASSE:
					imageEtat = IMAGE_PASSE;
					this.alpha = 0.5;
					break;
				case EN_COURS:
					imageEtat = IMAGE_EN_COURS;
					this.alpha = 1.0;
					break;
				case INVALIDE:
					imageEtat = IMAGE_INVALIDE;
					this.alpha = 0.3;
					break;
			}
			this.gotoAndPlay(imageEtat);		
			trace("créneau > set etat : " + etatNew + " / " + imageEtat + " > " + this.currentFrame);	
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