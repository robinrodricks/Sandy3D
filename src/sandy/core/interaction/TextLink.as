
package sandy.core.interaction 
{
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Dictionary;

	public class TextLink 
	{
		
		
		public static var textLinks : Dictionary;
		
		public var x 				: Number;
		public var y 				: Number;
		public var height			: Number;
		public var width			: Number;
		
		private var __sHRef			: String;
		private var __sTarget		: String;
		private var __iOpenIndex	: int;
		private var __iCloseIndex	: int;
		private var __tfOwner		: TextField;
		private var __rBounds		: Rectangle;
		
		public function TextLink() 
		{
			x = 0;
			y = 0;
			height = 0;
			width = 0;
		}
		
	/* ****************************************************************************
	* PUBLIC FUNCTIONS
	**************************************************************************** */		
		/**
		 * Return an array of textlinks
		 * @param	t
		 * @return
		 */
		public static function getTextLinks( t : TextField, force : Boolean = false ) : Array
		{
			if ( !t.htmlText ) return null;
			if ( !textLinks ) textLinks = new Dictionary();
			if ( textLinks[t] && !force ) return textLinks[t];
			
			textLinks[t] = new Array();
			
			var rawText 	: String = t.htmlText;
			
			var reHRef		: RegExp = /href=['"].*?['"]/i;
			var reTarget	: RegExp = /target=['"].*?['"]/i;
			var reLink		: RegExp = /<A.*?A>/i;
			var openA		: RegExp = /<A.*?\>/i;
			var closeA		: RegExp = /<\/A>/i;
			
		//	replace html tag with empty string
			var reHTMLTag	: RegExp = /<[^A][^\/A].*?>/gi;
			rawText = rawText.replace( reHTMLTag, "" );
			
			var linkText : Object = reLink.exec( rawText );
			while ( linkText != null )
			{
				var link : TextLink = new TextLink();
				link.owner = t;
				textLinks[t].push( link );
			
				var h : String = linkText[0].match( reHRef);
				link.href = h.substring( 6, h.length-1 );
			
				var tg : String = linkText[0].match( reTarget );
				link.target = tg.substring( 8, tg.length-1 );
			
			//	remove <a ... >
				link.openIndex = rawText.search( openA );
				rawText = rawText.replace( openA, "" );
					
			//	delete closing tag
				link.closeIndex =  rawText.search( closeA );
				rawText = rawText.replace( closeA, "" );
				
				link._init();
				
				linkText = reLink.exec( rawText );
			}
			
			return textLinks[t];
		}
		
		public function getBounds() : Rectangle
		{
			return __rBounds;
		}

		
	/* ****************************************************************************
	* GETTER && SETTER
	**************************************************************************** */
		public function get owner() : TextField
		{
			return __tfOwner;
		}
		public function set owner( tf : TextField ) : void
		{
			__tfOwner = tf;
		}	
	
		public function get target() : String
		{
			return __sTarget;
		}
		public function set target( s : String ) : void
		{
			__sTarget = s;
		}
		
		public function get href() : String
		{
			return __sHRef;
		}
		public function set href( s : String ) : void
		{
			__sHRef = s;
		}
		
		public function get openIndex() : int
		{
			return __iOpenIndex;
		}
		public function set openIndex( i : int ) : void
		{
			__iOpenIndex = i;
		}
		
		public function get closeIndex() : int
		{
			return __iCloseIndex;
		}
		public function set closeIndex( i : int ) : void
		{
			__iCloseIndex = i;
		}
		
		
	/* ****************************************************************************
	* PRIVATE FUNCTIONS
	**************************************************************************** */
		protected function _init() : void
		{	
			for ( var j : Number = 0; j < __iCloseIndex - __iOpenIndex; ++j )
			{
				var rectB : Rectangle = __tfOwner.getCharBoundaries( openIndex + j);
				if ( j == 0 ) {
					x = rectB.x;
					y = rectB.y;
				}
				width += rectB.width;
				height = height < rectB.height ? rectB.height : height ;
			}
			
			__rBounds = new Rectangle();
			__rBounds.x = x;
			__rBounds.y = y;
			__rBounds.height = height;
			__rBounds.width = width;
		}
		
	}
	
}
