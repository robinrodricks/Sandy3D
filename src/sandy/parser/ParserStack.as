
package sandy.parser
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import sandy.core.scenegraph.Group;
	import sandy.parser.AParser;
	import sandy.parser.IParser;
	import sandy.parser.ParserEvent;
	
	/**
	* Dispatched when data is received as the parsing progresses.
	*
	* @eventType sandy.parser.ParserStack.PROGRESS
	*/
	[Event(name="parserstack_progress", type="sandy.parser.ParserStack")]
	
	/**
	* Dispatched when an error occurs in the parsing process.
	*
	* @eventType sandy.parser.ParserStack.ERROR
	*/
	[Event(name="parserstack_error", type="sandy.parser.ParserStack")]
	
	/**
	* Dispatched when the parsing process is complete.
	*
	* @eventType sandy.parser.ParserStack.COMPLETE
	*/
	[Event(name="parserstack_complete", type="sandy.parser.ParserStack")]
	
	 /**
     * ParserStack utility class.
     * <p>An utility class that acts as a parser stack. You can a set of parser objects, and it process to the loading/parsing automatially and sequentially.</p>
     *
     * @author      Thomas Pfeiffer - kiroukou
     * @since       3.0
	 * @version		3.1
     * @date        12.02.2008
     */
	public class ParserStack extends EventDispatcher
	{
		/**
		 * Defines the value of the <code>type</code> property of a <code>parserstack_progress</code> event object.
	     *
	     * @eventType parserstack_progress
		 */
		public static const PROGRESS:String = "parserstack_progress";
		
		/**
		 * Defines the value of the <code>type</code> property of a <code>parserstack_error</code> event object.
	     *
	     * @eventType parserstack_error
		 */
		public static const ERROR:String = "parserstack_error";
		
		/**
		 * Defines the value of the <code>type</code> property of a <code>parserstack_complete</code> event object.
	     *
	     * @eventType parserstack_complete
		 */
		public static const COMPLETE:String = "parserstack_complete";
		
		private var m_oMap:Dictionary = new Dictionary(true);
		private var m_oNameMap:Dictionary = new Dictionary(true);
		private var m_oGroupMap:Dictionary = new Dictionary(true);
		private var m_oParser:AParser;
		private var m_nId:int = 0;
		private var m_aList:Array = new Array();
		
		/**
		 * Constructor.
		 */
		public function ParserStack()
		{
			super();
		}
		
		/**
		 * Clears the stack.
		 */
		public function clear():void
		{
			m_aList.splice(0);
			for( var elt:* in m_oMap )
			{
				m_oMap[elt] = null;
			}
		}
		
		/**
		 * Retrieve the parser you stored by the associated name.
		 * If no parser with that name is found, null is returned
		 */
		public function getParserByName( p_sName:String ):IParser
		{
			return m_oMap[ p_sName ];
		}
		
		/**
		 * Get the parser group object associated with the parser name.
		 * Returns null if no parser is associated with that name
		 */
		public function getGroupByName( p_sName:String ):Group
		{
			return m_oGroupMap[ p_sName ];
		}
		/**
		 * Add a parser to the list.
		 * @param p_sName the parser name to reference with
		 * @param p_oParser The parser instance
		 */
		public function add(  p_sName:String, p_oParser:IParser  ):void
		{
			m_aList.push( p_oParser );
			m_oMap[ p_sName ] = p_oParser;
			m_oNameMap[p_oParser] = p_sName;
		}
		
		/**
		 * Launch the loading/parsing process.
		 */
		public function start():void
		{
			m_nId = 0;
			goNext();
		}
		
		private function goNext( pEvt:ParserEvent = null ):void
		{
			if( m_aList.length == m_nId )
			{
				m_oGroupMap[ m_oNameMap[ m_oParser ] ] = pEvt.group;
				m_oParser.removeEventListener( ParserEvent.PROGRESS, onProgress );
				m_oParser.removeEventListener( ParserEvent.FAIL, onFail );
				m_oParser.removeEventListener( ParserEvent.INIT, goNext );//END
				
				onFinish( pEvt );
			}
			else
			{
				if( m_oParser )
				{
					m_oGroupMap[ m_oNameMap[ m_oParser ] ] = pEvt.group;
					m_oParser.removeEventListener( ParserEvent.PROGRESS, onProgress );
					m_oParser.removeEventListener( ParserEvent.FAIL, onFail );
					m_oParser.removeEventListener( ParserEvent.INIT, goNext );
				}
				m_oParser = m_aList[ m_nId ];
				m_oParser.addEventListener( ParserEvent.PROGRESS, onProgress );
				m_oParser.addEventListener( ParserEvent.FAIL, onFail );
				m_oParser.addEventListener( ParserEvent.INIT, goNext );
				m_nId++;
				m_oParser.parse();
			}
		}
	
		private function onProgress( p_oEvent:ParserEvent ):void
		{
			progress = (m_nId/(m_aList.length-1))*100 + p_oEvent.percent;
			dispatchEvent( new Event( PROGRESS ) );
		}
		
		private function onFail( p_oEvent:ParserEvent ):void
		{
			dispatchEvent( new Event( ERROR ) );
		}
		
		private function onFinish( p_oEvent:ParserEvent ):void
		{
			dispatchEvent( new Event( COMPLETE ) );
		}
		
		/**
		 * The percent of the loading that is complete.
		 */
		public var progress:Number = 0;
	}
}