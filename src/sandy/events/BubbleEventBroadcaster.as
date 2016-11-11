

package sandy.events
{
	import flash.events.Event;

	/**
	 * BubbleEventBroadcaster defines a custom event broadcaster to work with.
	 *
	 * @author	Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 */
	public final class BubbleEventBroadcaster extends EventBroadcaster
	{
		private var m_oParent:BubbleEventBroadcaster = null;

		private var m_oTarget:Object;
		
	 	/**
		 * Constructor.
	     */
		public function BubbleEventBroadcaster( p_oTarget:Object )
		{
			super();
			m_oTarget = p_oTarget;
		}

		public function get target():Object
		{
			return m_oTarget;
		}
		
		/**
		 * Starts receiving bubble events from specified child.
		 *
		 * @param child	A BubbleEventBroadcaster instance that will send bubble events.
		 */
		public function addChild(child:BubbleEventBroadcaster):void
		{
			child.parent = this;
		}

		/**
		 * Stops receiving bubble events from specified child.
		 * <p>[<strong>ToDo</strong>: This method has very bad implementation and disabled for the moment. ]</p>
		 *
		 * @param child	A BubbleEventBroadcaster instance that will stop sending bubble events.
		 */
		public function removeChild(child:BubbleEventBroadcaster):void
		{
			//child.parent = null;
		}

	 	/**
		 * The parent of this broadcaster.
	     */
		public function get parent():BubbleEventBroadcaster
		{
			return m_oParent;
		}

		/**
		 * @private
		 */
		public function set parent(pEB:BubbleEventBroadcaster):void
		{
			m_oParent = pEB;
		}

		/**
		 * @private
		 */
		override public function dispatchEvent(e:Event):Boolean
		{
			if (e is BubbleEvent)
			{
				super.dispatchEvent(e);

				if (parent)
				{
					parent.dispatchEvent(e);
				}
			}
			else
			{
				// why parent?
				//parent.dispatchEvent(e); // used for regular event dispatching
				super.dispatchEvent(e);
			}
			return true;
		}

	}
}