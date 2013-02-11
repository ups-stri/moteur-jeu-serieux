package scenariofactory.widgets
{

	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class Carte extends Widget
	{

		public var numero:String;
		public var container:Sprite;
		public var joueur:String;
		public var image:String;
		public var xOri:Number;
		public var yOri:Number;

		private var swfTimeline:MovieClip;
		// composant IULoader "loader" sur la scène de Carte

		// constructeur
		public function Carte(numeroC:String,joueurC:String,imageC:String,containerC:Sprite)
		{
			this.numero = numeroC;
			this.joueur = joueurC;
			this.image = imageC;
			this.container = containerC;
			this.scaleX = 0.1;
			this.scaleY = 0.1;
			trace("   > occurence de Carte "+this.image);
			if (this.joueur == "J1" || this.joueur == "C")
			{
				afficheImage();
			}
			addEventListener(MouseEvent.MOUSE_OVER, zoomIn);
			addEventListener(MouseEvent.MOUSE_OUT, zoomOut);
		}
		public function zoomIn(e:MouseEvent):void
		{
			trace("zoomIn / carte "+e.currentTarget.name);
			xOri = this.x;
			yOri = this.y;
			this.scaleX = 0.4;
			this.scaleY = 0.4;
			this.x = this.x - 200;
			this.y = this.y - 200;
			// changement de niveau
			this.container.setChildIndex(this.container.getChildByName(e.currentTarget.name), (this.container.numChildren - 1));
		}
		public function zoomOut(e:MouseEvent):void
		{
			this.scaleX = 0.1;
			this.scaleY = 0.1;
			this.x = xOri;
			this.y = yOri;
		}


		public function afficheImage():void
		{
			trace("   > afficheImage image "+"./actifs/cartes/"+this.image+".png");
			var request:URLRequest = new URLRequest("./actifs/cartes/" + this.image + ".png");
			this.loader.scaleContent = false;
			this.loader.addEventListener(Event.COMPLETE,loadComplete);
			this.loader.addEventListener(ProgressEvent.PROGRESS,loadProgress);
			this.loader.load(request);
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