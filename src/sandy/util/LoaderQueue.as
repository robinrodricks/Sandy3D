
package sandy.util
{
	import sandy.events.QueueEvent;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;	

	/**
	* Dispatched when all resources have been loaded.
	*
	* @eventType sandy.events.QueueEvent.QUEUE_COMPLETE
	*/
	[Event(name="queueComplete", type="sandy.events.QueueEvent")]

	/**
	* Dispatched when a resource has been loaded.
	*
	* @eventType sandy.events.QueueEvent.QUEUE_RESOURCE_LOADED
	*/
	[Event(name="queueResourceLoaded", type="sandy.events.QueueEvent")]

	/**
	* Dispatched when an error is encountered while loading a resource.
	*
	* @eventType sandy.events.QueueEvent.QUEUE_LOADER_ERROR
	*/
	[Event(name="queueLoaderError", type="sandy.events.QueueEvent")]

    /**
	 * Utility class for loading resources.
	 *
	 * <p>A LoaderQueue allows you to queue up requests for loading external resources.</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou /Max Pellizzaro 
	 * @version		3.1
	 * @date 		07.16.2008
	 */
	public class LoaderQueue extends EventDispatcher
	{
		
		/**
		* Specifies the Image type of object to load
		*/
		public static const IMG:String = "IMG";
		/**
		* Specifies the SWF type of object to load
		*/
		public static const SWF:String = "SWF";
		/**
		* Specifies the Binary type of object to load
		*/
		public static const BIN:String = "BIN";
		
		private var m_oLoaders : Object;
		private var m_nLoaders : int;
		private var m_oQueueCompleteEvent : QueueEvent;
		private var m_oQueueResourceLoadedEvent : QueueEvent;
		private var m_oQueueLoaderError : QueueEvent;
		
		/**
		 * A list of all resources indexed by their names.
		 */
		public var data:Dictionary = new Dictionary( true );
		public var clips:Dictionary = new Dictionary( true );
		
		/**
		 * Creates a new loader queue.
		 */
		public function LoaderQueue()
		{
			m_oLoaders = new Object();
			m_oQueueCompleteEvent 		= new QueueEvent ( QueueEvent.QUEUE_COMPLETE );
			m_oQueueResourceLoadedEvent = new QueueEvent ( QueueEvent.QUEUE_RESOURCE_LOADED );
			m_oQueueLoaderError 		= new QueueEvent ( QueueEvent.QUEUE_LOADER_ERROR );
		}
		
		/**
		 * Adds a new request to this loader queue.
		 *
		 * <p>The request is given its own loader and is added to a loader queue<br/>
		 * The loading is postponed until the start method of the queue is called.</p>
		 * 
		 * @param p_sID		A string identifier for this request
		 * @param p_oURLRequest	The request
		 */
		public function add( p_sID : String, p_oURLRequest : URLRequest, type:String = "IMG" ) : void
		{
			if(type == "BIN")
			{
				var tmpLoader:URLLoader = new URLLoader ();
			    tmpLoader.dataFormat = URLLoaderDataFormat.BINARY;
			    m_oLoaders[ p_sID ] = new QueueElement( p_sID, null, tmpLoader, p_oURLRequest );
			} 
			else 
			{
			 	m_oLoaders[ p_sID ] = new QueueElement( p_sID, new Loader(), null, p_oURLRequest );
			}
			// --
			m_nLoaders++;
		}
		
		private function getIDFromLoader( p_oLoader:Loader):String
		{
			for each( var l_oElement:QueueElement in m_oLoaders )
			{
				 if( p_oLoader == l_oElement.loader)
				 {
				  return l_oElement.name;
				 }
			}
			return null;
		}
		
		private function getIDFromURLLoader( p_oLoader:URLLoader ):String
		{
			for each( var l_oElement:QueueElement in m_oLoaders )
			{
				if( p_oLoader == l_oElement.urlLoader )
				{
					return l_oElement.name;
				}
			}
			return null;
		}
		
		/**
		 * Starts the loading of all resources in the queue.
		 *
		 * <p>All loaders in the queue are started and IOErrorEvent and the COMPLETE event are subscribed too.</p>
		 */
		public function start() : void
		{
			var noLoaders:Boolean = true;
			for each( var l_oLoader:QueueElement in m_oLoaders )
			{
				noLoaders = false;
				if (l_oLoader.loader != null) 
				{
					l_oLoader.loader.load( l_oLoader.urlRequest );
					l_oLoader.loader.contentLoaderInfo.addEventListener( Event.COMPLETE, completeHandler );
	            	l_oLoader.loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				} 
				else 
				{
					l_oLoader.urlLoader.load( l_oLoader.urlRequest );	
					l_oLoader.urlLoader.addEventListener( Event.COMPLETE, completeHandler );
	            	l_oLoader.urlLoader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				}
			}

			if (noLoaders)
			{
				// still need to dispatch complete event
				m_oQueueCompleteEvent.loaders = m_oLoaders;
				dispatchEvent( m_oQueueCompleteEvent );
			}
		}
		
		/**
		 * Fires a QUEUE_RESOURCE_LOADED, for each resources that is loaded.
		 * Fires a single QUEUE_COMPLETE, after the last resources is loaded.
		 * Type QUEUE_COMPLETE
		 */
		private function completeHandler( p_oEvent:Event ) : void
		{		
			var l_sName:String;
			var l_oLoaderInfos:LoaderInfo = p_oEvent.target as LoaderInfo;
			
			// Fire an event to indicate that a single resource loading was completed (needs to be enhanced to provide more info)
			dispatchEvent( m_oQueueResourceLoadedEvent ); 
			
			if (getQualifiedClassName(p_oEvent.target) == "flash.net::URLLoader")
			{
				var l_oLoader:URLLoader = URLLoader(p_oEvent.target);
				l_sName = getIDFromURLLoader(l_oLoader );
				data[ l_sName ] = l_oLoader.data;
				clips[ l_sName ] = l_oLoaderInfos;
		    } 
		    else
		    {
				var l_oLoader01:Loader = l_oLoaderInfos.loader;
				l_sName = getIDFromLoader( l_oLoader01 );
				data[ l_sName ] = l_oLoaderInfos.content;
				clips[ l_sName ] = l_oLoaderInfos;
		    }
			m_nLoaders--;
			// --
			if( m_nLoaders == 0 ) 
			{
				m_oQueueCompleteEvent.loaders = m_oLoaders;
				dispatchEvent( m_oQueueCompleteEvent );
			}
			
		}
		
		/**
		 * Fires an error event if any of the loaders didn't succeed
		 *
		 */
		private function ioErrorHandler( p_oEvent : IOErrorEvent ) : void
		{	
			trace( "LoaderQueue can't access a file: " + p_oEvent.text );
			// Fire an event to indicate that a single resource loading failed (needs to be enhanced to provide more info)
			dispatchEvent( m_oQueueLoaderError );
			m_nLoaders--;
			if( m_nLoaders == 0 ) 
			{
				m_oQueueCompleteEvent.loaders = m_oLoaders;
				dispatchEvent( m_oQueueCompleteEvent );
			}
		}

		public function getBytesLoaded():int {
			var bytes:int=0;
			for each (var l_oLoader:QueueElement in m_oLoaders) {
				if (l_oLoader.loader!=null){
					bytes+=l_oLoader.loader.contentLoaderInfo.bytesLoaded;
				} else {
					bytes+=l_oLoader.urlLoader.bytesLoaded;
				}
			}
			return bytes;
		}

		public function getBytesTotal():int{
			var bytes:int=0;
			for each (var l_oLoader:QueueElement in m_oLoaders) {
				if (l_oLoader.loader!=null){
					bytes+=l_oLoader.loader.contentLoaderInfo.bytesTotal;
				} else {
					bytes+=l_oLoader.urlLoader.bytesTotal;
				}
			}
			return bytes;
		}
	}
}

import flash.display.Loader;
import flash.net.URLLoader;
import flash.net.URLRequest;

internal class QueueElement
{
	public var name:String;
	public var loader:Loader;
	public var urlLoader:URLLoader;
	public var urlRequest:URLRequest;
	// --
	public function QueueElement( p_sName:String, p_oLoader:Loader, u_oLoader:URLLoader ,p_oURLRequest : URLRequest )
	{
		name = p_sName;
		loader = p_oLoader;
		urlRequest = p_oURLRequest;
		urlLoader = u_oLoader;
	}
}
