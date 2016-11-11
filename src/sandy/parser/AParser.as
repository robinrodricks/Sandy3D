
package sandy.parser
{
	import sandy.core.scenegraph.Group;
	import sandy.events.QueueEvent;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.ColorMaterial;
	import sandy.materials.attributes.*;
	import sandy.util.LoaderQueue;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;	

	/**
	 * ABSTRACT CLASS - super class for all parser objects.
	 *
	 * <p>This class should not be directly instatiated, but sub classed.<br/>
	 * The AParser class is responsible for creating the root Group, loading files
	 * and handling the corresponding events.</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		1.0
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public class AParser extends EventDispatcher implements IParser
	{
		//protected static var m_eProgress:ParserEvent = new ParserEvent( ParserEvent.PROGRESS );
		/**
		 * @private
		 */
		protected const m_oLoader:URLLoader = new URLLoader();

		/**
		 * @private
		 */
		protected var m_oGroup:Group;

		/**
		 * @private
		 */
		protected var m_oFile:Object;

		/**
		 * @private
		 */
		protected var m_oFileLoader:URLLoader;

		/**
		 * @private
		 */
		protected var m_sDataFormat:String;

		/**
		 * @private
		 */
		protected var m_nScale:Number;

		/**
		 * @private
		 */
		protected var m_oStandardAppearance:Appearance;

		private var m_sUrl:String;

		/**
		 * Creates a parser object. Creates a root Group, default appearance
		 * and sets up an URLLoader.
		 *
		 * @param p_sFile		Must be either a text string containing the location
		 * 						to a file or an embedded object.
		 * @param p_nScale		The scale amount.
		 * @param p_sTextureExtension	Overrides texture extension.
		 */
		public function AParser( p_sFile:*, p_nScale:Number = 1, p_sTextureExtension:String = null )
		{
			super(this);
			m_oGroup = new Group('parser');
			m_nScale = p_nScale;
			m_sTextureExtension = p_sTextureExtension;
			if( p_sFile is String )
			{
				m_sUrl = p_sFile;
				m_oFileLoader = new URLLoader();
				m_sDataFormat = URLLoaderDataFormat.TEXT;

				// assume that textures are in same folder with model itself
				if (m_sUrl.match(/[\/\\]/))
					RELATIVE_TEXTURE_PATH = m_sUrl.replace(/(.*)[\/\\][^\/\\]+/, "$1");
			}
			else
			{
				m_oFile = p_sFile;
			}

			standardAppearance = new Appearance(new ColorMaterial(0xFF, 100, new MaterialAttributes(new LineAttributes())));
		}

		/**
		 * Set the standard appearance for all the parsed objects.
		 *
		 * @param p_oAppearance		The standard appearance.
		 */
		public function set standardAppearance( p_oAppearance:Appearance ):void
		{
			m_oStandardAppearance = p_oAppearance;
		}

		/**
		 * Called when an I/O error occurs.
		 *
		 * @param	e	The error event.
		 */
		private function _io_error( e:IOErrorEvent ):void
		{
			dispatchEvent(new ParserEvent(ParserEvent.FAIL));
		}

		/**
		 * @private
		 *
		 * This method is called when all files are loaded and initialized.
		 *
		 * @param e		The event object.
		 */
		protected function parseData( e:Event = null ):void
		{
			if( e != null )
			{
				m_oFileLoader = URLLoader(e.target);
				m_oFile = m_oFileLoader.data;
			}
		}

		/**
		 * @private
		 */
		protected function onProgress( p_oEvt:ProgressEvent ):void
		{
			var event:ParserEvent = new ParserEvent(ParserEvent.PROGRESS);
			event.percent = 100 * p_oEvt.bytesLoaded / p_oEvt.bytesTotal;
			dispatchEvent(event);
		}

		/**
		 * @private
		 */
		protected function dispatchInitEvent():void
		{
			// -- load textures, if any
			if (m_aTextures != null) 
			{
				m_oQueue = new LoaderQueue();
				for (var i:int = 0;i < m_aTextures.length; i++) 
				{
					m_oQueue.add(i.toString(), new URLRequest(RELATIVE_TEXTURE_PATH + "/" + m_aTextures[i]));
				}
				m_oQueue.addEventListener(QueueEvent.QUEUE_COMPLETE, onTexturesloadComplete);
				m_oQueue.addEventListener(QueueEvent.QUEUE_LOADER_ERROR, onTexturesloadError);
				m_oQueue.start();
			} 
			else 
			{
				var l_eOnInit:ParserEvent = new ParserEvent(ParserEvent.INIT);
				l_eOnInit.group = m_oGroup;
				dispatchEvent(l_eOnInit);
			}
		}

		private function onTexturesloadError(e:Event=null):void
		{
			trace("Parser can't load automatically the texture(s), check RELATIVE_TEXTURE_PATH property in documentation");
		}
		
		private function onTexturesloadComplete(e:QueueEvent):void
		{			
			for (var i:int = 0;i < m_aShapes.length; i++) 
			{
				// set successfully loaded materials
				if (m_oQueue.data[i.toString()]) 
				{
					var shapes:Array = m_aShapes[i.toString()];
					var mat:Appearance = new Appearance(new BitmapMaterial(m_oQueue.data[i].bitmapData));
					for (var j:int = 0;j < shapes.length; j++) 
					{
						// whatever is in m_aShapes must have appearance property or be dynamic class
						Object(shapes[j]).appearance = mat;
					}
				}
			}

			m_oQueue.removeEventListener(QueueEvent.QUEUE_COMPLETE, onTexturesloadComplete);

			// this is called even if there were errors loading textures... perfect!
			m_aShapes = m_aTextures = null; 
			dispatchInitEvent();
		}

		/**
		 * @private used internally to load textures
		 */
		protected function applyTextureToShape(shape:Object, texture:String):void
		{
			var texName:String = changeExt(texture);
			var texId:int = -1;

			if (m_aTextures == null) 
			{
				// there was no textures enqueued so far
				m_aTextures = []; 
				m_aShapes = [];
			} 
			else 
			{
				// look up texture, maybe we have it enqueued
				texId = m_aTextures.indexOf(texName);
			}

			if (texId < 0) 
			{
				// this texture is not enqueued yet
				m_aTextures.push(texName);
				m_aShapes.push([shape]);
			} 
			else 
			{
				// this texture is enqueued, just add shape to the list
				m_aShapes[texId].push(shape);
			}
		}

		/**
		 * @private Collada parser already loads textures on its own, so it needs this protected
		 */
		protected function changeExt(s:String):String
		{
			if (m_sTextureExtension != null) 
			{
				var tmp:Array = s.split(".");
				if (tmp.length > 1) 
				{
					tmp[tmp.length - 1] = m_sTextureExtension;
					s = tmp.join(".");
				} 
				else 
				{
					// leave as is?
					s += "." + m_sTextureExtension;
				}
			}
			return s;
		}

		private var m_sTextureExtension:String;
		private var m_aShapes:Array;
		private var m_aTextures:Array;
		private var m_oQueue:LoaderQueue;

		/**
		 * Default path for images.
		 */
		public var RELATIVE_TEXTURE_PATH:String = ".";

		
		/**
		 * Load the file that needs to be parsed. When done, call the parseData method.
		 */
		public function parse():void
		{
			if( m_sUrl is String )
			{
				// Construction d'un objet URLRequest qui encapsule le chemin d'acces
				var urlRequest:URLRequest = new URLRequest(m_sUrl);
				// Ecoute de l'evennement COMPLETE
				m_oFileLoader.addEventListener(Event.COMPLETE, parseData);
				m_oFileLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
				m_oFileLoader.addEventListener(IOErrorEvent.IO_ERROR, _io_error);
				// Lancer le chargement
				m_oFileLoader.dataFormat = m_sDataFormat;
				m_oFileLoader.load(urlRequest);
			}
			else
			{
				parseData();
			}
		}
	}
}
