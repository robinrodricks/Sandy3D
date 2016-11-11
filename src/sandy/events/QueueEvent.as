package sandy.events
{
	import flash.events.Event;

	/**
	 * Conatains events use for loading resources.
	 *
	 * @version		3.1
	 *
	 * @see sandy.util.LoaderQueue
	 * @see BubbleEventBroadcaster
	 */
	public class QueueEvent extends Event
	{
		private var _loaders:Object;

	    /**
		 * Defines the value of the <code>type</code> property of a <code>queueComplete</code> event object.
	     *
	     * @eventType queueComplete
	     */
		public static const QUEUE_COMPLETE:String = "queueComplete";

	    /**
		 * Defines the value of the <code>type</code> property of a <code>queueResourceLoaded</code> event object.
	     *
	     * @eventType queueResourceLoaded
	     */
		public static const QUEUE_RESOURCE_LOADED:String = "queueResourceLoaded";

	    /**
		 * Defines the value of the <code>type</code> property of a <code>queueLoaderError</code> event object.
	     *
	     * @eventType queueLoaderError
	     */
		public static const QUEUE_LOADER_ERROR:String = "queueLoaderError";

	 	/**
		 * Constructor.
		 *
		 * @param type The event type; indicates the action that caused the event.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
	     */
		public function QueueEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_loaders = loaders;
		}

	    /**
	     * Someone care to explain?
	     */
		public function get loaders():Object
		{
			return _loaders;
		}

		/**
		 * @private
		 */
		public function set loaders(loaderObject:Object):void
		{
			_loaders = loaderObject;
		}

		/**
		 * @private
		 */
		override public function clone():Event
	    {
	    	var e:QueueEvent = new QueueEvent(type, bubbles, cancelable);
	    	e.loaders = _loaders;
	        return e;
	    }
	}
}