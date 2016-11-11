
package sandy.primitive
{
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;

	/**
	* The Line3D class is used for creating a line in 3D space.
	*
	* <p>The line is created by passing a comma delimited argument list containing Point3Ds.<br/>
	* A Line3D object can only use the WireFrameMaterial[?]</p>
	*
	* @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	* @date 		26.07.2007
	*
	* @example To create a line between ( x0, y0, z0 ), ( x1, y1, z1 ), ( x2, y2, z3 ),
	* use the following statement:
	*
	* <listing version="3.1">
	*     var myLine:Line3D = new Line3D( "aLine", new Point3D(x0, y0, z0), new Point3D( x1, y1, z1 ), new Point3D( x2, y2, z3 ));
	*  </listing>
	*/
	public class Line3D extends Shape3D implements Primitive3D
	{
		/**
		* Creates a Line3D primitive.
		*
		* <p>A line is drawn between Point3Ds in the order they are passed. A minimum of two Point3Ds must be passed.</p>
		*
		* @param p_sName	A string identifier for this object.
		* @param ...rest 	A comma delimited list of Point3Ds.
		*
		* @see sandy.core.data.Point3D
		*/
		public function Line3D ( p_sName:String=null, ...rest )
		{
			super ( p_sName );
			// "rest" can be a two-or-more-element array of Point3Ds. Or the first element can itself be an array
			if (rest.length == 1 && rest[0] is Array) {
				rest = rest[0];
			}
			
			if( rest.length < 2)
			{
				trace('Line3D::Too few arguments');
				// Should throw an exception, frankly
			}
			else
			{
				geometry = generate( rest );
				enableBackFaceCulling = false;
			}
		}

		/**
		* Generates the geometry for the line.
		*
		* @return The geometry object for the line.
		*
		* @see sandy.core.scenegraph.Geometry3D
		*/
		public function generate ( ... arguments ) : Geometry3D
		{
			var l_oGeometry:Geometry3D = new Geometry3D();
			var l_aPoints:Array = arguments[0];
			// --
			var i:int;
			var l:int = l_aPoints.length;
			// --
			while( i < l )
			{
				l_oGeometry.setVertex( i, l_aPoints[int(i)].x, l_aPoints[int(i)].y, l_aPoints[int(i)].z );
				i++;
			}
			// -- initialisation
			i = 0;
			while( i < l-1 )
			{
				l_oGeometry.setFaceVertexIds( i, i, i+1 );
				i++;
			}
			// --
			return l_oGeometry;
		}

		/**
		* @private
		*/
		public override function toString():String
		{
			return "sandy.primitive.Line3D";
		}
	}
}
