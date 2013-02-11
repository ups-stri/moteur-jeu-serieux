package scenariofactory
{
	// package non précisé car .as dans répertoire

	public class Regle
	{

		public static var listeRegles:Array = [];
		public static var nbRegles:Number = 0;

		public var nom:String;
		public var active:Boolean;
		public var listeConditions:Array;
		public var listeEvenements:Array;
		public var id:Number;
		public var detruite:Boolean = false;

		// constructeur
		public function Regle(nom:String, listeConditions:Array, listeEvenements:Array, active:Boolean)
		{
			this.nom = nom;
			this.listeConditions = listeConditions;
			this.listeEvenements = listeEvenements;
			// toutes les règles sont inactives au départ
			this.active = active;
			trace("Nouvelle règle : "+this.nom+", active="+this.active);
			this.id = nbRegles;
			listeRegles[nbRegles] = this;
			nbRegles++;
		}
		public function rendreInactive():void
		{
			trace("dans rendreInactive() : règle "+this.nom);
			this.active = false;
		}
		public function rendreActive():void
		{
			trace("dans rendreActive() : règle "+this.nom);
			this.active = true;
		}
		public function detruire():void
		{
			Scenario.getInstance().supprimerRegle(this)
		}
		static public function detruireRegle(regleADetruire:Regle):void
		{
			/*
			trace("                      > destruction de la règle "+regleADetruire.nom);
			for (var regle:String in listeRegles)
			{
				if(regle == regleADetruire.nom)
			}listeRegles[regle.id] = null;
			regle = null;
			*/
		}

	}
}