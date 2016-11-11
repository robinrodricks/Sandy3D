
package sandy.core.data
{
	/**
	 * A plane in 3D space.
	 *
	 * <p>This class is used primarily to represent the frustrum planes of the camera.</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		0.1
	 * @version		3.1
	 * @date 		24.08.2007
	 *
	 * @see sandy.view.Frustum
	 */
	final public class Plane
	{
		/**
		* The coordinate of the first plane.
		*/
		public var a:Number;
		
		/**
		* The coordinate of the second plane.
		*/
		public var b:Number;
		
		/**
		* The coordinate of the third plane.
		*/
		public var c:Number;
		
		/**
		* The coordinate of the fourth plane.
		*/
		public var d:Number;

		/**
		* Creates a new Plane instance.
		*
		* @param p_nA	The coordinate of the first plane.
		* @param p_nB	The coordinate of the second plane.
		* @param p_nC	The coordinate of the third plane.
		* @param p_nd	The coordinate of the forth plane.
		*/
		public function Plane( p_nA:Number=0, p_nB:Number=0, p_nC:Number=0, p_nd:Number=0 )
		{
			this.a = p_nA;
			this.b = p_nB;
			this.c = p_nC;
			this.d = p_nd;
		}

		/**
		 * Returns a string representation of this object.
		 *
		 * @return	The fully qualified name of this object.
		 */
		public function toString():String
		{
			return "sandy.core.data.Plane" + "(a:"+a+", b:"+b+", c:"+c+", d:"+d+")";
		}
	}
}