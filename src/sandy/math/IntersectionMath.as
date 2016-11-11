
package sandy.math
{
	import sandy.bounds.BSphere;
	import sandy.core.data.Point3D;
	import sandy.util.NumberUtil;
	
	import flash.geom.Point;	

	/**
	 * An util class with static method which provides useful functions related to intersection.
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		18.10.2007
	 */
	public final class IntersectionMath
	{
		/**
		 * Determines whether two bounding spheres intersect.
		 *
		 * @param p_oBSphereA	The first bounding sphere.
		 * @param p_oBSphereB	The second bounding sphere.
		 *
		 * @return Whether the two spheres intersect.
		 */
		public static function intersectionBSphere( p_oBSphereA:BSphere, p_oBSphereB:BSphere ):Boolean
		{
    		var l_oVec:Point3D = p_oBSphereA.position.clone();
    		l_oVec.sub( p_oBSphereB.position );
    		var l_nDist:Number = p_oBSphereA.radius + p_oBSphereB.radius;
     		// --
    		var l_nNorm:Number = l_oVec.getNorm();
   			return (l_nNorm <= l_nDist);
		}
		
		
		/**
		 * Computes the smallest distance between two 3D lines.
		 * <p>As 3D lines cannot intersect, we compute two points, first owning to the first 3D line, and the second point owning to the second 3D line.</p>
		 * <p>The two points define a segment which length represents the shortest distance between these two lines.</p>
		 *
		 * @param p_oPointA	A Point3D of the first 3D line.
		 * @param p_oPointB	Another Point3D of the first 3D line.
		 * @param p_oPointC	A Point3D of the second 3D line.
		 * @param p_oPointD	Another Point3D of the second 3D line.
		 *
		 * @return An array containing the Point3Ds of the segment connecting the two 3D lines.
		 */
		public static function intersectionLine3D( p_oPointA:Point3D, p_oPointB:Point3D, p_oPointC:Point3D, p_oPointD:Point3D ):Array
		{
            var res:Array = [
                new Point3D (0.5 * (p_oPointA.x + p_oPointB.x), 0.5 * (p_oPointA.y + p_oPointB.y), 0.5 * (p_oPointA.z + p_oPointB.z)),
                new Point3D (0.5 * (p_oPointC.x + p_oPointD.x), 0.5 * (p_oPointC.y + p_oPointD.y), 0.5 * ( p_oPointC.z + p_oPointD.z))
            ];

            var p13_x:Number = p_oPointA.x - p_oPointC.x;
            var p13_y:Number = p_oPointA.y - p_oPointC.y;
            var p13_z:Number = p_oPointA.z - p_oPointC.z;

            var p43_x:Number = p_oPointD.x - p_oPointC.x;
            var p43_y:Number = p_oPointD.y - p_oPointC.y;
            var p43_z:Number = p_oPointD.z - p_oPointC.z;

            if (NumberUtil.isZero (p43_x) && NumberUtil.isZero (p43_y) && NumberUtil.isZero (p43_z))
                return res;

            var p21_x:Number = p_oPointB.x - p_oPointA.x;
            var p21_y:Number = p_oPointB.y - p_oPointA.y;
            var p21_z:Number = p_oPointB.z - p_oPointA.z;

            if (NumberUtil.isZero (p21_x) && NumberUtil.isZero (p21_y) && NumberUtil.isZero (p21_z))
                return res;

            var d1343:Number = p13_x * p43_x + p13_y * p43_y + p13_z * p43_z;
            var d4321:Number = p43_x * p21_x + p43_y * p21_y + p43_z * p21_z;
            var d1321:Number = p13_x * p21_x + p13_y * p21_y + p13_z * p21_z;
            var d4343:Number = p43_x * p43_x + p43_y * p43_y + p43_z * p43_z;
            var d2121:Number = p21_x * p21_x + p21_y * p21_y + p21_z * p21_z;

            var denom:Number = d2121 * d4343 - d4321 * d4321;

            if (NumberUtil.isZero (denom))
                return res;

            var mua:Number = (d1343 * d4321 - d1321 * d4343) / denom;
            var mub:Number = (d1343 + d4321 * mua) / d4343;

            return [
                new Point3D (p_oPointA.x + mua * p21_x, p_oPointA.y + mua * p21_y, p_oPointA.z + mua * p21_z),
                new Point3D (p_oPointC.x + mub * p43_x, p_oPointC.y + mub * p43_y, p_oPointC.z + mub * p43_z)
            ];
		}
		
		/**
		 * Finds the intersection point of two 2D lines.
		 *
		 * @param p_oPointA	A point of the first line.
		 * @param p_oPointB	Another point of the first line.
		 * @param p_oPointC	A point of the second line.
		 * @param p_oPointD	Another point of the second line.
		 *
		 * @return The point where the two lines intersect. Returns null if lines are coincident or parallel.
		 */
		public static function intersectionLine2D( p_oPointA:Point, p_oPointB:Point, p_oPointC:Point, p_oPointD:Point ):Point
		{
			const 	xA:Number = p_oPointA.x, yA:Number = p_oPointA.y,
					xB:Number = p_oPointB.x, yB:Number = p_oPointB.y,
					xC:Number = p_oPointC.x, yC:Number = p_oPointC.y,
					xD:Number = p_oPointD.x, yD:Number = p_oPointD.y;
			
			var denom:Number = ( ( yD - yC )*( xB - xA ) - ( xD - xC )*( yB - yA ) );
			// -- if lines are parallel
			if( denom == 0 ) return null;
			
			var uA:Number =  ( ( xD - xC )*( yA - yC ) - ( yD - yC )*( xA - xC ) );
			uA /= denom;
			
			// we shall compute uB and test uA == uB == 0 to test coincidence
			/*
			uB =  ( ( xB - xA )*( yA - yC ) - ( yB - yA )*( xA - xC ) );
			uB /= denom;
			*/
			return new Point( xA + uA * ( xB - xA ), yA + uA*( yB - yA ) );
		}
		
		/**
		 * Determines if a point is within a triangle.
		 *
		 * @param p_oPoint	The point to find in the triangle.
		 * @param p_oA		The first point of the triangle.
		 * @param p_oB		The second point of the triangle.
		 * @param p_oC		The third point of the triangle.
		 *
		 * @return Whether the point is inside the triangle.
		 */
		/*
      	** From http://www.blackpawn.com/texts/pointinpoly/default.html
      	** Points right on the perimeter are NOT treated as in.
      	** AS3 implementation : tcorbet
      	*/
		public static function isPointInTriangle2D ( p_oPoint:Point, p_oA:Point, p_oB:Point, p_oC:Point ):Boolean
	    {
		    var oneOverDenom:Number = (1 /
		        (((p_oA.y - p_oC.y) * (p_oB.x - p_oC.x)) +
		        ((p_oB.y - p_oC.y) * (p_oC.x - p_oA.x))));
		    var b1:Number = (oneOverDenom *
		        (((p_oPoint.y - p_oC.y) * (p_oB.x - p_oC.x)) +
		        ((p_oB.y - p_oC.y) * (p_oC.x - p_oPoint.x))));
		    var b2:Number = (oneOverDenom *
		        (((p_oPoint.y - p_oA.y) * (p_oC.x - p_oA.x)) +
		        ((p_oC.y - p_oA.y) * (p_oA.x - p_oPoint.x))));
		    var b3:Number = (oneOverDenom *
		        (((p_oPoint.y - p_oB.y) * (p_oA.x - p_oB.x)) +
		        ((p_oA.y - p_oB.y) * (p_oB.x - p_oPoint.x))));
		 
		    return ((b1 > 0) && (b2 > 0) && (b3 > 0));      
	    }
	}
}