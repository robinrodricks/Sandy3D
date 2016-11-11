
package sandy.bounds 
{
	import sandy.core.data.Matrix4;	import sandy.core.data.Point3D;	import sandy.core.data.Vertex;	
	/**
	 * The BSphere class is used to quickly and easily clip an object in a 3D scene.
	 * <p>It creates a bounding sphere that contains the whole object</p>
	 * 
	 * @example 	This example is taken from the Shape3D class. It is used in
	 * 				the <code>updateBoundingVolumes()</code> method:
 	 *
 	 * <listing version="3.1">
 	 *     _oBSphere = BSphere.create( m_oGeometry.aVertex );
 	 *  </listing>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		22.03.2006
	 */
	public final class BSphere
	{
		/**
		 * Specifies if this object's boundaries are up to date with the object it is enclosing.
		 * If <code>false</code>, this object's <code>transform()</code> method must be called to get its updated boundaries in the current frame.
		 */
		public var uptodate:Boolean = false;
		
		/**
		 * A Point3D representing the center of the bounding sphere.
		 */
		public var center:Point3D = new Point3D();
		
		/**
		 * The radius of the bounding sphere.
		 */
		public var radius:Number = 1;
		// -----------------------------
		//    [TRANSFORMED]  -----------
		public var position:Point3D = new Point3D();
		
		/**
		 * Creates a bounding sphere that encloses a 3D from an Array of the object's vertices.
		 * 
		 * @param p_aVertices		The vertices of the 3D object the bounding sphere will contain.
		 * @return 					The BSphere instance.
		 */	
		public static function create( p_aVertices:Array ):BSphere
		{
		    var l_sphere:BSphere = new BSphere();
		    l_sphere.compute( p_aVertices );
			return l_sphere;
		}
				
		/**
		 * Creates a new BSphere instance.</p>
		 */ 	
		public function BSphere()
		{
			;
		}
		
		public function resetFromBox(box:BBox):void 
		{
			this.center.copy( box.getCenter() );
			this.radius = Math.sqrt(((box.maxEdge.x - this.center.x) * (box.maxEdge.x - this.center.x)) + ((box.maxEdge.y - this.center.y) * (box.maxEdge.y - this.center.y)) + ((box.maxEdge.z - this.center.z) * (box.maxEdge.z - this.center.z)));
		}
		
		/**
		 * Reset the current bounding box to an empoty box with 0,0,0 as max and min values
		 */
		public function reset():void
		{
			center.reset();
			radius = 0;
			position.reset();
			uptodate = false;
		}
		
		
		/**
	     * Applies a transformation to the bounding sphere.
	     * 
	     * @param p_oMatrix		The transformation matrix.
	     */	
	    public function transform( p_oMatrix:Matrix4 ):void
	    {
	        position.copy( center );
	        p_oMatrix.transform( position );
	        uptodate = true;
	    }
	    
		/**
		 * Returns a string representation of this object.
		 *
		 * @return	The fully qualified name of this object.
		 */
		public function toString():String
		{
			return "sandy.bounds.BSphere (center : "+center+", radius : "+radius + ")";
		}
		
		/**
		 * Computes of the bounding sphere's center and radius.
		 * 
		 * @param p_aVertices		The vertices of the 3D object the bounding sphere will contain.
		 */		
		public function compute( p_aVertices:Array ):void
		{
			if(p_aVertices.length == 0) return;
			var x:Number, y:Number, z:Number, d:Number, i:int = 0, j:int = 0, l:int = p_aVertices.length;
			var p1:Vertex = p_aVertices[0].clone();
			var p2:Vertex = p_aVertices[0].clone();
			// find the farthest couple of points
			var dmax:Number = 0;			
			var pA:Vertex, pB:Vertex;
			while( i < l )
			{
				j = i + 1;
				while( j < l )
				{
					pA = p_aVertices[int(i)];
					pB = p_aVertices[int(j)];
					x = pB.x - pA.x;
					y = pB.y - pA.y;
					z = pB.z - pA.z;
					d = x * x + y * y + z * z;
					if(d > dmax)
					{
						dmax = d;
						p1.copy( pA );
						p2.copy( pB );
					}
					j += 1;
				}
				i += 1;
			}
			// --
			center = new Point3D((p1.x + p2.x) / 2, (p1.y + p2.y) / 2, (p1.z + p2.z) / 2);
			radius = Math.sqrt(dmax) / 2;
		}
	  
	  
		/**
		 * Return the positions of the array of Position p that are outside the BoundingSphere.
		 * 
		 * @param 	An array containing the points to test
	 	 * @return 	An array of points containing those that are outside. The array has a length 
	 	 * 			of 0 if all the points are inside or on the surface.
		 */
		private function pointsOutofSphere(p_aPoints:Array):Array
		{
			var r:Array = new Array();
			var i:int, l:int = p_aPoints.length;
			
			while( i < l ) 
			{
				if(distance(p_aPoints[int(i)]) > 0) 
				{
					r.push( p_aPoints[int(i)] );
				}
				
				i++;
			}
			return r;
		}
	  
		/**
		 * Returns the distance of a Point3D from the surface of the bounding sphere.
		 * The number returned will be positive if the Point3D is outside the sphere,
		 * negative if inside, or <code>0</code> if on the surface of the sphere.
		 * 
		 * @return The distance from the bounding sphere to the Point3D.
		 */
		public function distance(p_oPoint:Point3D):Number
		{
			var x:Number = p_oPoint.x - center.x;
			var y:Number = p_oPoint.y - center.y;
			var z:Number = p_oPoint.z - center.z;
			return  Math.sqrt(x * x + y * y + z * z) - radius;
		}
		
		/**
		 * Computes the bounding sphere's radius.
		 * 
		 * @param p_aPoints		An Array containing the bounding sphere's points.
		 *
		 * @return The bounding sphere's radius.
		 */		
		private function computeRadius(p_aPoints:Array):Number
		{
			var x:Number, y:Number, z:Number, d:Number, dmax:Number = 0;
			var i:int, l:int = p_aPoints.length;
			while( i < l ) 
			{
				x = p_aPoints[int(i)].x - center.x;
				y = p_aPoints[int(i)].x - center.x;
				z = p_aPoints[int(i)].x - center.x;
				d = x * x + y * y + z * z;
				if(d > dmax) dmax = d;
				i++;
			}
			return Math.sqrt(dmax);
		}
	}
}