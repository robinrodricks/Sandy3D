package sandy.events
{
	import flash.events.Event;
	import sandy.core.scenegraph.Shape3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.UVCoord;
	import sandy.core.data.Point3D;

	/**
	 * This class represents the type of events broadcasted by shapes objects.
	 * It gives some useful information about the clicked object such as the polygon clicked, and real 3D position of the point under mouse, the UV coordinate under mouse.
	 * It allows some advanced interaction with the object and its texture.
	 *
	 * @version		3.1
	 *
	 * @see sandy.core.scenegraph.Shape3D
	 */
	public class Shape3DEvent extends BubbleEvent
	{
		/**
		 * A reference to the object which has been clicked.
		 *
	     * @see sandy.core.scenegraph.Scene3D
		 */
		public var shape:Shape3D;

		/**
		 * Polygon that has been clicked.
		 *
	     * @see sandy.core.data.Polygon
		 */
		public var polygon:Polygon;

		/**
		 * Real UV coordinate of the point under the mouse click position.
		 *
	     * @see sandy.core.data.UVCoord
		 */
		public var uv:UVCoord;

		/**
		 * Real 3D position of the point under mouse click position.
		 *
	     * @see sandy.core.data.Point3D
		 */
		public var point:Point3D;

		/**
		 * Original Flash event instance.
		 */
		public var event:Event;
		
		/**
		 * Constructs a new Shape3DEvent instance.
		 *
		 * <p>Example
		 * <code>
		 *   var e:Shape3DEvent = new Shape3DEvent(MyClass.onSomething, theShapeReference, thePolygonReference, theUVCoord, theReal3DIntersectionPoint);
		 * </code>
		 *
		 * @param e				A name for the event.
		 * @param p_oShape		The Shape3D object reference
		 * @param p_oPolygon	The Polygon object reference
		 * @param p_oUV			The UVCoord object which corresponds to the UVCoord under mouse position
		 * @param p_oPoint3d	The Point3D object which is the real 3D position under the mouse position
		 * @param p_oEvent		The original Flash event instance
		 *
	     * @see sandy.core.scenegraph.Scene3D
	     * @see sandy.core.data.Polygon
	     * @see sandy.core.data.UVCoord
	     * @see sandy.core.data.Point3D
		 */
		public function Shape3DEvent(e:String, p_oShape:Shape3D, p_oPolygon:Polygon, p_oUV:UVCoord, p_oPoint3d:Point3D, p_oEvent:Event )
		{
			super(e, p_oShape);
			shape = p_oShape;
			polygon = p_oPolygon;
			uv = p_oUV;
			point = p_oPoint3d;
			event = p_oEvent;
		}
	}
}
