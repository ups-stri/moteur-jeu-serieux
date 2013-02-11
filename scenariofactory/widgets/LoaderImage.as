﻿package scenariofactory.widgets
{

	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.display.MovieClip;
	import fl.containers.UILoader;

	public class LoaderImage extends Widget
	{
		// déclaration manuelle des occurrences de symboles placées sur la scène
		public var loader:UILoader;

		private var image:String;
		private var swfTimeline:MovieClip;
		// composant IULoader "loader" sur la scène de LoaderImage

		// constructeur
		public function LoaderImage()
		{
			trace("occurence de LoaderImage : "+this.name);
			this.visible = false;
		}

		public function afficher(liste:Array):void
		{
			trace("affichage de l'image "+liste[0]);
			this.image = liste[0];
			var request:URLRequest = new URLRequest(liste[0]);
			this.loader.scaleContent = false;
			this.loader.addEventListener(Event.COMPLETE,loadComplete);
			this.loader.addEventListener(ProgressEvent.PROGRESS,loadProgress);
			this.loader.load(request);
			this.visible = true;
		}

		public function aFini():Boolean
		{
			this.swfTimeline = this.loader.content as MovieClip;
			trace("aFini de l'image "+this.image+", totalFrames="+this.swfTimeline.totalFrames);
			var resultat:Boolean = false;
			
			if (this.swfTimeline.currentFrame == this.swfTimeline.totalFrames)
			{
				//this.swfTimeline.stop();
				resultat = true;
			}
			else
			{
				resultat = false;
			}
			return resultat;

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