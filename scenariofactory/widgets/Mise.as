﻿package scenariofactory.widgets
{

	public class Mise
	{
		public var itemM:String;
		public var joueur:String;
		public var bq:String;

		public function Mise(itemA:String, joueurA:String, bqA:String)
		{
			this.itemM = itemA;
			this.joueur = joueurA;
			this.bq = bqA;
		}

		public function toString():String
		{
			return " mise : " + joueur + ":" + bq;
		}
	}

}