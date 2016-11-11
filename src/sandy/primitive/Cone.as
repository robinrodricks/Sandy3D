
package sandy.primitive
{
	/**
	* The Cone class is used for creating a cone primitive.
	*
	* <p>This class is a special case of the Cylinder class, with an top radius of 0.</p>
	*
	* <p>All credits go to Tim Knipt from suite75.net who created the AS2 implementation.
	* Original sources available at : http://www.suite75.net/svn/papervision3d/tim/as2/org/papervision3d/objects/Cone.as</p>
	*
	* @author		Thomas Pfeiffer ( adaption for Sandy )
	* @author		Tim Knipt
	 * @version		3.1
	* @date 		26.07.2007
	*
	* @example To create a cone with a base radius of 150 and a height of 300,
	* with default number of segments, use the following statement:
	*
	* <listing version="3.1">
	*     var myCone:Cone = new Cone( "theCone", 150, 300 );
	*  </listing>
	*/
	public class Cone extends Cylinder implements Primitive3D
	{
		/**
		* Creates a Cone primitive.
		*
		* <p>The cone is created at the origin of the world coordinate system with its vertical axis
		* along the y axis (pointing upwards).</p>
		*
		* @param p_sName 		A string identifier for this object.
		* @param p_nRadius		Radius of the cone.
		* @param p_nHeight		Height of the cone.
		* @param p_nSegmentsW	Number of horizontal segments.
		* @param p_nSegmentsH	Number of vertical segments.
		*/
		public function Cone(p_sName : String = null, p_nRadius:Number=100, p_nHeight:Number=100, p_nSegmentsW:Number=8, p_nSegmentsH:Number=6)
		{
			super(p_sName, p_nRadius, p_nHeight, p_nSegmentsW, p_nSegmentsH, 0 );
			setConvexFlag (true);
		}

		/**
		* @private
		*/
		public override function toString():String
		{
			return "sandy.primitive.Cone";
		}
	}
}