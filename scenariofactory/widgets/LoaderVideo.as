﻿package scenariofactory.widgets
{

	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import fl.video.*;

	public class LoaderVideo extends Widget
	{

		// composant FLVPlayback "loader" sur la scène de LoaderImageMenu
		var finVideo:Boolean = false;

		// constructeur
		public function LoaderVideo()
		{
			trace("occurence de LoaderImageMenu : "+this.name);
			this.visible = false;
		}

		public function afficher(liste:Array):void
		{
			finVideo = false;
			loader.source = liste[0];
			trace("affichage de la vidéo "+liste[0]);
			this.visible = true;
			loader.addEventListener(VideoEvent.COMPLETE, completePlay);
		}
		
		public function completePlay(e:VideoEvent):void {
			trace("fin de la vidéo");
			finVideo = true;
		}

		public function aFini():Boolean
		{
			trace("test de fin...");
			return finVideo;
		}

		public function setFinVideo():void
		{
			trace("setFinVideo");
			finVideo = true;
		}

		private function loadProgress(e:ProgressEvent):void
		{
			//this.loader.uiLoaderLabel.text = String(e.target.percentLoaded);
		}
		private function loadComplete(e:Event):void
		{
			//this.loader.uiLoaderLabel.text = "Load Complete";
		}

	}
}