
package sandy.events
{
	import flash.events.Event;
	import flash.events.EventDispatcher;		
	/**
	 * The event broadcaster of Sandy.
	 *
	 * @version		3.1
	 */
	public class EventBroadcaster extends EventDispatcher
	{
		public function EventBroadcaster()
		{
			super();
		}

		override public function dispatchEvent(evt:Event):Boolean 
		{
			if (hasEventListener(evt.type) || evt.bubbles) 
			{
				return super.dispatchEvent(evt);
			}
			return true;
		}
	}
}