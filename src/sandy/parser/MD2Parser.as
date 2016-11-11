
package sandy.parser
{
	import sandy.primitive.MD2;
	
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;	

	/**
	 * Transforms an MD2 file into Sandy MD2 primitive.
	 * <p>Creates a Group as rootnode with MD2 primitive as its only child.
	 *
	 * @author		makc
	 * @version		3.1
	 * @date 		03.06.2008
	 *
	 * @example To parse an MD2 file at runtime:
	 *
	 * <listing version="3.1">
	 *     var parser:IParser = Parser.create( "/path/to/my/md2file.md2", Parser.MD2 );
	 * </listing>
	 *
	 * @example To parse an embedded MD2 object:
	 *
	 * <listing version="3.1">
	 *     [Embed( source="/path/to/my/md2file.md2", mimeType="application/octet-stream" )]
	 *     private var MyMD2:Class;
	 *
	 *     ...
	 *
	 *     var parser:IParser = Parser.create( new MyMD2(), Parser.MD2 );
	 * </listing>
	 */

	public final class MD2Parser extends AParser implements IParser
	{
		/**
		 * Creates a new MD2Parser instance
		 *
		 * @param p_sUrl		This can be either a String containing an URL or a
		 * 						an embedded object
		 * @param p_nScale		The scale factor
		 * @param p_sTextureExtension	Overrides texture extension. You might want to use it for models that
		 * specify PCX textures.
		 */
		public function MD2Parser( p_sUrl:*, p_nScale:Number = 1, p_sTextureExtension:String = null )
		{
			super( p_sUrl, p_nScale, p_sTextureExtension );
			m_sDataFormat = URLLoaderDataFormat.BINARY;
		}

		/**
		 * @private
		 * Starts the parsing process
		 *
		 * @param e				The Event object
		 */
		protected override function parseData( e:Event=null ):void
		{
			super.parseData( e );
			// make MD2 object
			var md2:MD2 = new MD2 ( "animation", ByteArray( m_oFile ), m_nScale );
			// we are not quite done yet, so we dispatch less than 100% :)
			var event:ParserEvent = new ParserEvent( ParserEvent.PARSING ); event.percent = 80; dispatchEvent( event );
			// --
			md2.appearance = m_oStandardAppearance; m_oGroup.addChild( md2 );
			// -- Parsing is finished
			applyTextureToShape (md2, md2.textureFileName);
			dispatchInitEvent ();
		}
	}
}
