
package sandy.core.data
{
	import sandy.util.NumberUtil;

	/**
	 * A vertex is the point of intersection of edges the of a polygon.
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		1.0
	 * @version		3.1
	 * @date 		24.08.2007
	 *
	 * @see sandy.core.data.Polygon
	 */
	public final class Vertex
	{
		private static var ID:uint = 0;
		
		/**
		 * Vertex flags that can be SandyFlags.VERTEX_WORLD, SandyFlags.VERTEX_CAMERA or SandyFlags.VERTEX_PROJECTED
		 * Need to avoid unecessary computations
		 */
		public var flags:int = 0;
		
		public var projected:Boolean = false;
		public var transformed:Boolean = false;
		
		/**
		* The unique identifier for the vertex.
		*/
		public const id:uint = ID ++;

		/**
		* The x coordinate in the scene.
		*/
		public var x:Number;
		
		/**
		* The y coordinate in the scene.
		*/
		public var y:Number;
		
		/**
		* The z coordinate in the scene.
		*/
		public var z:Number;

		/**
		* The transformed x coordinate in the scene.
		*/
		public var wx:Number;
		
		/**
		* The transformed y coordinate in the scene.
		*/
		public var wy:Number;
		
		/**
		* The transformed z coordinate in the scene.
		*/
		public var wz:Number;

		/**
		* The transformed x coordinate on the screen.
		*/
		public var sx:Number;
		
		/**
		* The transformed y coordinate on the screen.
		*/
		public var sy:Number;

		/**
		 * The number of polygons the vertex belongs to.
		 */
		public var nbFaces:uint = 0;

		/**
		 * An array of polygons that use the vertex</p>
		 */
		public var aFaces:Array = new Array();

		/**
		* Creates a new vertex.
		*
		* @param p_nx		The x position.
		* @param p_ny		The y position.
		* @param p_nz		The z position.
		* @param ...rest	Optional values for the <code>wx</code>, <code>wy</code>, and <code>wz</code> properties.
		*/
		public function Vertex( p_nx:Number=0, p_ny:Number=0, p_nz:Number=0, ...rest )
		{
			x = p_nx;
			y = p_ny;
			z = p_nz;
			// --
			wx = (rest[0])?rest[0]:x;
			wy = (rest[1])?rest[1]:y;
			wz = (rest[2])?rest[2]:z;
			// --
			sy = sx = 0;
		}
		
		/**
		 * Reset the values of that vertex.
		 * This allows to change all the values of that vertex in one method call instead of acessing to each public property.
		 *  @param p_nX Value for x and wx properties
		 *  @param p_nY Value for y and wy properties
		 *  @param p_nZ Value for z and wz properties
		 */
		public function reset( p_nX:Number, p_nY:Number, p_nZ:Number ):void
		{
			x = p_nX;
			y = p_nY;
			z = p_nZ;
			wx = x;
			wy = y;
			wz = z;
		}
		
		/**
		 * Returns the 2D position of this vertex.  The function returns a Point3D with the x and y coordinates of the
		 * vertex and the depth as the <code>z</code> property.
		 *
		 * @return The 2D position of this vertex once projected.
		 */
		public function getScreenPoint():Point3D
		{
			return new Point3D( sx, sy, wz );
		}

		/**
		* Returns a Point3D of the transformed vertex.
		*
		* @return A Point3D of the transformed vertex.
		*/
		public final function getCameraPoint3D():Point3D
		{
			m_oCamera.x = wx;
			m_oCamera.y = wy;
			m_oCamera.z = wz;
			return m_oCamera;
		}

		/**
		 * Returns a Point3D representing the original x, y, z coordinates.
		 *
		 * @return A Point3D representing the original x, y, z coordinates.
		 */
		public final function getPoint3D():Point3D
		{
			m_oLocal.x = x;
			m_oLocal.y = y;
			m_oLocal.z = z;
			return m_oLocal;
		}

		/**
		 * Returns a new Vertex object that is a clone of the original instance. 
		 * 
		 * @return A new Vertex object that is identical to the original. 
		 */		
		public final function clone():Vertex
		{
		    var l_oV:Vertex = new Vertex( x, y, z );
		    l_oV.wx = wx;    l_oV.sx = sx;
		    l_oV.wy = wy;    l_oV.sy = sy;
		    l_oV.wz = wz;
		    l_oV.nbFaces = nbFaces;
		    l_oV.aFaces = aFaces.concat();
		    return l_oV;
		}

		/**
		 * Returns a new vertex build on the transformed values of this vertex.
		 *
		 * <p>Returns a new Vertex object that is created with the vertex's transformed coordinates as the new vertex's start position.
		 * The <code>x</code>, y</code>, and z</code> properties of the new vertex would be the <code>wx</code>, <code>wy</code>, <code>wz</code> properties of this vertex.</p>
		 * <p>[<strong>ToDo</strong>: What can this one be used for? - Explain! ]</p>
		 *
		 * @return 	The new Vertex object.
		 */
		public final function clone2():Vertex
		{
		    return new Vertex( wx, wy, wz );
		}

		/**
		 * Creates and returns a new vertex from the specified Point3D.
		 *
		 * @param p_v	The vertex's position Point3D.
		 *
		 * @return 	The new vertex.
		 */
		static public function createFromPoint3D( p_v:Point3D ):Vertex
		{
		    return new Vertex( p_v.x, p_v.y, p_v.z );
		}

		/**
		 * Determines if this vertex is equal to the specified vertex.
		 *
		 * <p>This all properties of this vertex is compared to the properties of the specified vertex.
		 * If all properties of the two vertices are equal, a value of <code>true</code> is returned.</p>
		 *
		 * @return Whether the two verticies are equal.
		 */
	 	public final function equals(p_vertex:Vertex):Boolean
		{
			return Boolean( p_vertex.x  ==  x && p_vertex.y  ==  y && p_vertex.z  ==  z &&
					p_vertex.wx == wx && p_vertex.wy == wy && p_vertex.wz == wz &&
					p_vertex.sx == wx && p_vertex.sy == sy);
		}

		/**
		 * Makes this vertex a copy of the specified vertex.
		 *
		 * <p>All components of the specified vertex are copied to this vertex.</p>
		 *
		 * @param p_oPoint3D	The vertex to copy.
		 */
		public final function copy( p_oPoint3D:Vertex ):void
		{
			x = p_oPoint3D.x;
			y = p_oPoint3D.y;
			z = p_oPoint3D.z;
			wx = p_oPoint3D.wx;
			wy = p_oPoint3D.wy;
			wz = p_oPoint3D.wz;
			sx = p_oPoint3D.sx;
			sy = p_oPoint3D.sy;
		}

		/**
		 * Returns the norm of this vertex.
		 *
		 * <p>The norm of the vertex is calculated as the length of its position Point3D.
		 * The norm is calculated by <code>Math.sqrt( x*x + y*y + z*z )</code>.</p>
		 *
		 * @return 	The norm.
		 */
		public final function getNorm():Number
		{
			return Math.sqrt( x*x + y*y + z*z );
		}

		/**
		 * Inverts the vertex.  All properties of the vertex become their nagative values.
		 */
		public final function negate( /*v:Vertex*/ ): void
		{
			// The argument is commented out, as it is not used - Petit
			x = -x;
			y = -y;
			z = -z;
			wx = -wx;
			wy = -wy;
			wz = -wz;
			//return new Vertex( -x, -y, -z, -wx, -wy, -wz);
		}

		/**
		 * Adds the specified vertex to this vertex.
		 *
		 * @param v 	The vertex to add to this vertex.
		 */
		public final function add( v:Vertex ):void
		{
			x += v.x;
			y += v.y;
			z += v.z;

			wx += v.wx;
			wy += v.wy;
			wz += v.wz;
		}

		/**
		 * Substracts the specified vertex from this vertex.
		 *
		 * @param v 	The vertex to subtract from this vertex.
		 */
		public function sub( v:Vertex ):void
		{
			x -= v.x;
			y -= v.y;
			z -= v.z;
			wx -= v.wx;
			wy -= v.wy;
			wz -= v.wz;
		}

		/**
		 * Raises the vertex to the specified power.
		 *
		 * <p>All components of the vertex are raised to the specified power.</p>
		 *
		 * @param pow The power to raise the vertex to.
		 */
		public final function pow( pow:Number ):void
		{
			x = Math.pow( x, pow );
        	y = Math.pow( y, pow );
        	z = Math.pow( z, pow );
        	wx = Math.pow( wx, pow );
        	wy = Math.pow( wy, pow );
        	wz = Math.pow( wz, pow );
		}

		/**
		 * Multiplies this vertex by the specified number.
		 *
		 * <p>All components of the vertex are multiplied by the specified number.</p>
		 *
		 * @param n 	The number to multiply the vertex with.
		 */
		public final function scale( n:Number ):void
		{
			x *= n;
			y *= n;
			z *= n;
			wx *= n;
			wy *= n;
			wz *= n;
		}

		/**
		 * Returns the dot product between this vertex and the specified vertex.
		 *
		 * <p>Only the original positions values are used for this dot product.</p>
		 *
		 * @param w 	The vertex to make a dot product with.
		 *
		 * @return The dot product.
		 */
		public final function dot( w: Vertex):Number
		{
			return ( x * w.x + y * w.y + z * w.z );
		}

		/**
		 * Returns the cross product between this vertex and the specified vertex.
		 *
		 * <p>Only the original positions values are used for this cross product.</p>
		 *
		 * @param v 	The vertex to make a cross product with.
		 *
		 * @return The resulting vertex of the cross product.
		 */
		public final function cross( v:Vertex):Vertex
		{
			// cross product Point3D that will be returned
	        	// calculate the components of the cross product
			return new Vertex( 	(y * v.z) - (z * v.y) ,
	                            (z * v.x) - (x * v.z) ,
	                            (x * v.y) - (y * v.x) );
		}

		/**
		 * Normalizes this vertex.
		 *
		 * <p>A vertex is normalized when its components are divided by its norm.
		 * The norm is calculated by <code>Math.sqrt( x*x + y*y + z*z )</code>, which is the length of the position Point3D.</p>
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

			wx /= norm;
			wy /= norm;
			wz /= norm;
		}

		/**
		 * Returns the angle between this vertex and the specified vertex.
		 *
		 * @param w	The vertex making an angle with this one.
		 *
		 * @return 	The angle in radians.
		 */
		public final function getAngle ( w:Vertex ):Number
		{
			var ncos:Number = dot( w ) / ( getNorm() * w.getNorm() );
			var sin2:Number = 1 - ncos * ncos;
			if (sin2<0)
			{
				trace(" wrong "+ncos);
				sin2 = 0;
			}
			//I took long time to find this bug. Who can guess that (1-cos*cos) is negative ?!
			//sqrt returns a NaN for a negative value !
			return  Math.atan2( Math.sqrt(sin2), ncos );
		}


		/**
		 * Returns a string representation of this object.
		 *
		 * @param decPlaces	The number of decimal places to round the vertex's components off to.
		 *
		 * @return	The fully qualified name of this object.
		 */
		public final function toString(decPlaces:Number=0):String
		{
			if (decPlaces == 0)
			{
				decPlaces = 0.01;
			}
			// Round display to two decimals places
			// Returns "{x, y, z}"
			return "{" + 	NumberUtil.roundTo(x, decPlaces) + ", " +
					NumberUtil.roundTo(y, decPlaces) + ", " +
					NumberUtil.roundTo(z, decPlaces) + ", " +
					NumberUtil.roundTo(wx, decPlaces) + ", " +
					NumberUtil.roundTo(wy, decPlaces) + ", " +
					NumberUtil.roundTo(wz, decPlaces) + ", " +
					NumberUtil.roundTo(sx, decPlaces) + ", " +
					NumberUtil.roundTo(sy, decPlaces) + "}";
		}


		// Useful for XML output
		/**
		 * Returns a string representation of this vertex with rounded values.
		 *
		 * <p>[<strong>ToDo</strong>: Explain why this is good for XML output! ]</p>
		 *
		 * @param decPlaces	Number of decimals.
		 * @return 		The specific serialize string.
		 */
		public final function serialize(decPlaces:Number=0):String
		{
			if (decPlaces == 0)
			{
				decPlaces = .01;
			}
			//returns x,y,x
			return  (NumberUtil.roundTo(x, decPlaces) + "," +
					 NumberUtil.roundTo(y, decPlaces) + "," +
					 NumberUtil.roundTo(z, decPlaces) + "," +
					 NumberUtil.roundTo(wx, decPlaces) + "," +
					 NumberUtil.roundTo(wy, decPlaces) + "," +
					 NumberUtil.roundTo(wz, decPlaces) + "," +
					 NumberUtil.roundTo(sx, decPlaces) + "," +
					 NumberUtil.roundTo(sy, decPlaces));
		}

		// Useful for XML output
		/**
		 * Sets the elements of this vertex from a string representation.
		 *
		 * <p>[<strong>ToDo</strong>: Explain why this is good for XML intput! ]</p>
		 *
		 * @param 	A string representing the vertex ( specific serialize format ).
		 */
		public final function deserialize(convertFrom:String):void
		{
			var tmp:Array = convertFrom.split(",");
			if (tmp.length != 9)
			{
				trace ("Unexpected length of string to deserialize into a Point3D " + convertFrom);
			}

			x = tmp[0];
			y = tmp[1];
			z = tmp[2];

			wx = tmp[3];
			wy = tmp[4];
			wz = tmp[5];

			sx = tmp[6];
			sy = tmp[7];
		}
		
		private const m_oCamera:Point3D = new Point3D();
		private const m_oLocal:Point3D = new Point3D();
	}
}