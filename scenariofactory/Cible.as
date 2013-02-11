﻿package scenariofactory {
	// package non précisé car .as dans répertoire

	public class Cible {

		public var nom:String;
		public var listeMethodes:Array;

		// constructeur
		public function Cible(nom:String, listeMethodes:Array) {
			//trace("cible");
			this.nom = nom;
			this.listeMethodes = listeMethodes;
		}

	}
}