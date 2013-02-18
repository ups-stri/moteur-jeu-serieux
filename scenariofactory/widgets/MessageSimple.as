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

		public function afficherMessage(texte:String)
		{
			trace("   message : "+texte);
			texteMessage.text = texteMessage.text+texte+"\n";
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