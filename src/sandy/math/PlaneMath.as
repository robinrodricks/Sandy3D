
package sandy.math 
{
	import sandy.core.data.Plane;
	import sandy.core.data.Point3D;	

	/**
	 * Math functions for planes.
	 *  
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		0.3
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public class PlaneMath
	{
		/**
		 * Specifies a negative distance from a Point3D to a plane.
		 */
		public static const NEGATIVE:int = -1;
		
		/**
		 * Specifies a Point3D is on a plane.
		 */
		public static const ON_PLANE:int = 0;
		
		/**
		 * Specifies a positive distance from a Point3D to a plane.
		 */
		public static const POSITIVE:int = 1;
		
		/**
		 * Normalizes the plane. 
		 * 
		 * <p>Often before making some calculations with a plane you have to normalize it.</p>
		 *
		 * @param p_oPlane 	The plane to normalize.
		 */
		public static function normalizePlane( p_oPlane:Plane ):void
		{
			var mag:Number;
			mag = Math.sqrt( p_oPlane.a * p_oPlane.a + p_oPlane.b * p_oPlane.b + p_oPlane.c * p_oPlane.c );
			p_oPlane.a = p_oPlane.a / mag;
			p_oPlane.b = p_oPlane.b / mag;
			p_oPlane.c = p_oPlane.c / mag;
			p_oPlane.d = p_oPlane.d / mag;
		}
		
		/**
		 * Computes the distance between a plane and a Point3D.
		 *
		 * @param p_oPlane	The plane.
		 * @param p_oPoint3D	The Point3D.
		 *
		 * @return 	The distance between the Point3D and the plane.
		 */
		public static function distanceToPoint( p_oPlane:Plane, p_oPoint3D:Point3D ):Number
		{
			return p_oPlane.a * p_oPoint3D.x + p_oPlane.b * p_oPoint3D.y + p_oPlane.c * p_oPoint3D.z + p_oPlane.d ;
		}
		
		/**
		 * Returns a classification constant depending on a Point3D's position relative to a plane.
		 * 
		 * <p>The classification is one of PlaneMath.NEGATIVE, PlaneMath.POSITIVE, and PlaneMath.ON_PLANE.</p>
		 *
		 * @param p_oPlane	The reference plane.
		 * @param p_oPoint3D	The Point3D we want to classify.
		 *
		 * @return The classification of the Point3D.
		 */
		public static function classifyPoint( p_oPlane:Plane, p_oPoint3D:Point3D ):Number
		{
			var d:Number;
			d = PlaneMath.distanceToPoint( p_oPlane, p_oPoint3D );
			
			if (d < 0)
			{
				return PlaneMath.NEGATIVE;
			}
			if (d > 0)
			{
				return PlaneMath.POSITIVE;
			}
			
			return PlaneMath.ON_PLANE;
		}
		
		/**
		 * Computes a plane from three Point3Ds.
		 *
		 * @param p_oPoint3DA	The first Point3D.
		 * @param p_oPoint3DB	The second Point3D.
		 * @param p_oPoint3DC	The third Point3D.
		 *
		 * @return 	The computed plane.
		 */
		public static function computePlaneFromPoints( p_oPoint3DA:Point3D, p_oPoint3DB:Point3D, p_oPoint3DC:Point3D ):Plane
		{
			var n:Point3D = Point3DMath.cross( Point3DMath.sub( p_oPoint3DA, p_oPoint3DB), Point3DMath.sub( p_oPoint3DA, p_oPoint3DC) );
			Point3DMath.normalize( n );
			var d:Number = Point3DMath.dot( p_oPoint3DA, n);
			// --
			return new Plane( n.x, n.y, n.z, d);
		}
		
		/**
		 * Computes a plane from a normal Point3D and a specified point.
		 *
		 * @param p_oNormal	The normal Point3D.
		 * @param p_oPoint	The point.
		 *
		 * @return 	The computed plane.
		 */
		public static function createFromNormalAndPoint( p_oNormal:Point3D, p_oPoint:Point3D ):Plane
		{
			var p:Plane = new Plane();
			p.a = p_oNormal.x;
			p.b = p_oNormal.y;
			p.c = p_oNormal.z;
			p.d = p_oNormal.dot (p_oPoint) * -1;
			PlaneMath.normalizePlane( p );
			return p;
		}
		
	}
}