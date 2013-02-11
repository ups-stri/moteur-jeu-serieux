package scenariofactory {
	// package non précisé car .as dans répertoire

	public class Evenement {

		public var nom:String;
		public var listeEffets:Array;
		public var enCours:Number;

		// constructeur
		public function Evenement(nom:String, listeEffets:Array) {
			this.nom = nom;
			this.listeEffets = listeEffets;
			this.enCours = 0;

			var stringTrace:String = "Nouvel événement : "+this.nom;
		}

	}
}