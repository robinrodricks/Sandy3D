
package sandy.core.data
{
	import sandy.util.NumberUtil;

	/**
	 * A 3D coordinate.
	 *
	 * <p>A representation of a position in a 3D space.</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @author		Mirek Mencel
	 * @author		Tabin Cédric - thecaptain
	 * @author		Nicolas Coevoet - [ NikO ]
	 * @author		Bruce Epstein - zeusprod - truncated toString output to 2 decimals
	 * @since		0.1
	 * @version		3.1
	 * @date 		24.08.2007
	 */
	public final class Point3D
	{
		/**
		 * The x coordinate.
		 */
		public var x:Number;
		/**
		 * The y coordinate.
		 */
		public var y:Number;
		/**
		 * The z coordinate.
		 */
		public var z:Number;

		/**
		* Creates a new Point3D.
		*
		* @param p_nX	The x coordinate.
		* @param p_nY	The y coordinate.
		* @param p_nZ	The z coordinate.
		*/
		public function Point3D(p_nX:Number=0, p_nY:Number=0, p_nZ:Number=0)
		{
			x = p_nX;
			y = p_nY;
			z = p_nZ;
		}

		/**
		 * Sets the <code>x</code>, <code>y</code>, and <code>z</code> properties to <code>0</code>.
		 */
		public function reset( px:Number=0, py:Number=0, pz:Number=0):void
		{
			x = px; y = py; z = pz;
		}
		
		/**
		 * Sets the <code>x</code>, <code>y</code>, and <code>z</code> properties to lowest value Flash can handle (<code>Number.NEGATIVE_INFINITY</code>).
		 */
		public function resetToNegativeInfinity():void
		{
			x = y = z = Number.NEGATIVE_INFINITY;
		}

		/**
		 * Sets the <code>x</code>, <code>y</code>, and <code>z</code> properties to highest value Flash can handle (<code>Number.POSITIVE_INFINITY</code>).
		 */
		public function resetToPositiveInfinity():void
		{
			x = y = z = Number.POSITIVE_INFINITY;
		}
		
		/**
		 * Returns a new Point3D object that is a clone of the original instance. 
		 * 
		 * @return A new Point3D object that is identical to the original. 
		 */	
		public final function clone():Point3D
		{
		    var l_oV:Point3D = new Point3D( x, y, z );
		    return l_oV;
		}

		/**
		 * Makes this Point3D a copy of the specified Point3D.
		 *
		 * <p>All components of the specified Point3D are copied to this Point3D.</p>
		 *
		 * @param p_oPoint3D	The Point3D to copy.
		 */
		public final function copy( p_oPoint3D:Point3D ):void
		{
			x = p_oPoint3D.x;
			y = p_oPoint3D.y;
			z = p_oPoint3D.z;
		}

		/**
		 * Returns the norm of this Point3D.
		 *
		 * <p>The norm is calculated by <code>Math.sqrt( x*x + y*y + z*z )</code>.</p>
		 *
		 * @return 	The norm.
		 */
		public final function getNorm():Number
		{
			return Math.sqrt( x*x + y*y + z*z );
		}

		/**
		 * Returns the inverse of this Point3D, will all properties as their negative values.
		 *
		 * @return 	The inverse of the Point3D.
		 */
		public final function negate( /*v:Point3D*/ ): Point3D
		{
			// Commented out the argument as it is never used - Petit
			return new Point3D( - x, - y, - z );
		}

		/**
		 * Adds the specified Point3D to this Point3D.
		 *
		 * @param v 	The Point3D to add.
		 */
		public final function add( v:Point3D ):void
		{
			x += v.x;
			y += v.y;
			z += v.z;
		}

		/**
		 * Substracts the specified Point3D from this Point3D.
		 *
		 * @param v		The Point3D to subtract.
		 */
		public final function sub( v:Point3D ):void
		{
			x -= v.x;
			y -= v.y;
			z -= v.z;
		}

		/**
		 * Raises the Point3D to the specified power.
		 *
		 * <p>All components of the vertex are raised to the specified power.</p>
		 *
		 * @param pow The power to raise the Point3D to.
		 */
		public final function pow( pow:Number ):void
		{
			x = Math.pow( x, pow );
	        y = Math.pow( y, pow );
	        z = Math.pow( z, pow );
		}
		
		/**
		 * Multiplies this Point3D by the specified number.
		 *
		 * <p>All components of the Point3D are multiplied by the specified number.</p>
		 *
		 * @param n 	The number to multiply the Point3D with.
		 */
		public final function scale( n:Number ):void
		{
			x *= n;
			y *= n;
			z *= n;
		}

		/**
		 * Returns the dot product between this Point3D and the specified Point3D.
		 *
		 * @param w 	The Point3D to make a dot product with.
		 *
		 * @return The dot product.
		 */
		public final function dot( w: Point3D):Number
		{
			return ( x * w.x + y * w.y + z * w.z );
		}

		/**
		 * Returns the cross product between this Point3D and the specified Point3D.
		 *
		 * @param v 	The Point3D to make a cross product with (right side).
		 *
		 * @return The resulting Point3D of the cross product.
		 */
		public final function cross( v:Point3D):Point3D
		{
			// cross product Point3D that will be returned
			return new Point3D(
								(y * v.z) - (z * v.y) ,
			                 	(z * v.x) - (x * v.z) ,
			               		(x * v.y) - (y * v.x)
	                           );
		}

		/**
		 * Crosses this Point3D with the specified Point3D.
		 *
		 * @param v 	The Point3D to make the cross product with (right side).
		 */
		public final function crossWith( v:Point3D):void
		{
			const cx:Number = (y * v.z) - (z * v.y);
			const cy:Number = (z * v.x) - (x * v.z);
			const cz:Number = (x * v.y) - (y * v.x);
			x = cx; y = cy; z = cz;
		}

		/**
		 * Normalizes this Point3D.
		 *
		 * <p>A Point3D is normalized when its components are divided by its norm.
		 * The norm is calculated by <code>Math.sqrt( x*x + y*y + z*z )</code>. After normalizing
		 * the Point3D, the direction is the same, but the length is <code>1</code>.</p>
		 */
		public final function normalize():void
		{
			// -- We get the norm of the Point3D
			var norm:Number = getNorm();
			// -- We escape the process is norm is null or equal to 1
			if( norm == 0 || norm == 1) return;
			x /= norm;
			y /= norm;
			z /= norm;
		}

		/**
		 * Gives the biggest component of the current Point3D.
		 * <listing version="3.1">
		 *     var lMax:Number = new Point3D(5, 6.7, -4).getMaxComponent(); //returns 6.7
		 *  </listing>
		 * 
		 * @return The biggest component value of the Point3D
		 */
		public final function getMaxComponent():Number
		{
			return Math.max( x, Math.max( y, z ) );
		}
		
		/**
		 * Gives the smallest component of the current Point3D.
		 * <listing version="3.1">
		 *     var lMin:Number = new Point3D(5, 6.7, -4).getMinComponent(); //returns -4
		 *  </listing>
		 * 
		 * @return The smallest component value of the Point3D
		 */
		public final function getMinComponent():Number
		{
			return Math.min( x, Math.min( y, z ) );
		}
		
		/**
		 * Returns the angle between this Point3D and the specified Point3D.
		 *
		 * @param w		The Point3D making an angle with this one.
		 *
		 * @return The angle in radians.
		 */
		public final function getAngle ( w:Point3D ):Number
		{
			var n1:Number = getNorm();
			var n2:Number =  w.getNorm();
			var denom:Number = n1 * n2;
			if( denom  == 0 ) 
			{
				return 0;
			}
			else
			{
				var ncos:Number = dot( w ) / ( denom );
				var sin2:Number = 1 - (ncos * ncos);
				if ( sin2 < 0 )
				{
					trace(" wrong "+ncos);
					sin2 = 0;
				}
				//I took long time to find this bug. Who can guess that (1-cos*cos) is negative ?!
				//sqrt returns a NaN for a negative value !
				return  Math.atan2( Math.sqrt(sin2), ncos );
			}
		}


		/**
		 * Returns a string representation of this object.
		 *
		 * @param decPlaces	The number of decimal places to round the Point3D's components off to.
		 *
		 * @return	The fully qualified name of this object.
		 */
		public final function toString(decPlaces:Number=0):String
		{
			
			// Round display to the specified number of decimals places
			// Returns "{x, y, z}"
			return "{" + serialize(Math.pow (10, -decPlaces)) + "}";
		}
		
		// Useful for XML output
		public function serialize(decPlaces:Number=0.1):String
		{
			//returns x,y,x
			return  (NumberUtil.roundTo(x, decPlaces) + "," + 
					 NumberUtil.roundTo(y, decPlaces) + "," + 
					 NumberUtil.roundTo(z, decPlaces));
		}
		
		// Useful for XML input
		public static function deserialize(convertFrom:String):Point3D
		{
			var tmp:Array = convertFrom.split(",");
			if (tmp.length != 3) {
				trace ("Unexpected length of string to deserialize into a Point3D " + convertFrom);
			}
			for (var i:Number = 0; i < tmp.length; i++) {
				tmp[i] = Number(tmp[i]);
			}
			return new Point3D (tmp[0], tmp[1], tmp[2]);
		}

		/**
		 * Determines if this Point3D is equal to the specified Point3D.
		 *
		 * <p>This all properties of this Point3D is compared to the properties of the specified Point3D.
		 * If all properties of the two Point3Ds are equal, a value of <code>true</code> is returned.</p>
		 *
		 * @return Whether the two Point3Ds are equal.
		 */
		public final function equals(p_Point3D:Point3D):Boolean
		{
			return (p_Point3D.x == x && p_Point3D.y == y && p_Point3D.z == z);
		}
		

	}
}
