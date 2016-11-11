package sandy.events
{
	import sandy.core.scenegraph.StarField;
	
	import flash.display.BitmapData;	

	/**
	 * This class represents the type of events broadcasted by StarField objects.
	 * It gives you some additional control over StarField rendering process.
	 *
	 * @version		3.1
	 *
	 * @see sandy.core.scenegraph.StarField
	 */
	public class StarFieldRenderEvent extends BubbleEvent
	{
		/**
		 * Constructs a new StarFieldRenderEvent instance.
		 *
		 * @param e				A name for the event.
		 * @param p_oStarField		The StarField object reference.
		 * @param p_oBitmapData		The BitmapData object reference.
		 * @param p_bClear		Clearing flag.
		 *
		 * @see sandy.core.scenegraph.StarField
		 */
		public function StarFieldRenderEvent(e:String, p_oStarField:StarField, p_oBitmapData:BitmapData, p_bClear:Boolean )
		{
			super(e, p_oStarField);
			bitmapData = p_oBitmapData;
			clear = p_bClear;
		}

		/**
		 * The BitmapData object reference.
		 */
		public var bitmapData:BitmapData = null;

		/**
		 * A flag indicating if BitmapData should be cleared by StarField after event.
		 * Setting this to false in BEFORE_RENDER event will force StarField to keep last frame image.
		 */
		public var clear:Boolean;

		/**
		 * Defines the value of the <code>type</code> property of a <code>beforeRender</code> event object.
		 *
		 * @eventType beforeRender
		 *
		 * @see sandy.core.scenegraph.StarField
		 */
		public static const BEFORE_RENDER:String = "beforeRender";

		/**
		 * Defines the value of the <code>type</code> property of a <code>afterRender</code> event object.
		 *
		 * @eventType afterRender
		 *
		 * @see sandy.core.scenegraph.StarField
		 */
		public static const AFTER_RENDER:String = "afterRender";
	}
}