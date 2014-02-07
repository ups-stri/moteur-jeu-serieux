package scenariofactory.widgets
{

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.controls.TextArea;

	public class MessageSimple extends Widget
	{
		// déclaration manuelle des occurrences de symboles placées sur la scène
		public var texteMessage:TextArea;

		// constructeur
		public function MessageSimple()
		{
			trace("occurrence de MessageSimple : "+this.name);
			texteMessage.text = "";
		}

		// affiche un message dans le widget de message permettant de dialoguer
		// avec l'utilisateur
		public function _afficherMessage(texte:String)
		{
			// si la barre de défilement verticale est déjà positionnée tout en bas,
			// on va veiller à l'y remettre après affichage du message
			var scrollbarIsDown:Boolean =
				texteMessage.verticalScrollPosition == texteMessage.maxVerticalScrollPosition;  
			trace("   message : "+texte);
			texteMessage.text = texteMessage.text + texte + "\n";
			if (scrollbarIsDown) {
				texteMessage.verticalScrollPosition = texteMessage.maxVerticalScrollPosition;
			}
		}
		

		public function afficherMessage(liste:Array)
		{
			_afficherMessage(liste[1]);
		}
		
		//definir la hauteur du textarea
		override public function setHeight(liste:Array)
		{
			this.texteMessage.height = Number(liste[1]);
		}
		
		//definir la largeur du textarea
		override public function setWidth(liste:Array)
		{
			this.texteMessage.width = Number(liste[1]);
		}
	}
}