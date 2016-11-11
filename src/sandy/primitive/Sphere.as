
package sandy.primitive
{
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;

	/**
	* The Sphere class is used for creating a sphere primitive
	*
	* @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	* @date 		26.07.2007
	*
	* @example To create a sphere with radius 150 and with default settings
	* for the number of horizontal and vertical segments, use the following statement:
	*
	* <listing version="3.1">
	*     var mySphere:Sphere = new Sphere( "theSphere", 150);
	*  </listing>
	*/
	public class Sphere extends Shape3D implements Primitive3D
	{
		private var radius:Number;

		/**
		* The number of horizontal segments.
		*/
		public var segmentsW :Number;

		/**
		* The number of vertical segments.
		*/
		public var segmentsH :Number;

		/**
		* The default radius for a sphere.
		*/
		static public const DEFAULT_RADIUS :Number = 100;

		/**
		* The default scale for a sphere texture.
		*/
		static public const DEFAULT_SCALE :Number = 1;

		/**
		* The default number of horizontal segments for a sphere.
		*/
		static public const DEFAULT_SEGMENTSW :Number = 8;

		/**
		* The default number of vertical segments for a sphere.
		*/
		static public const DEFAULT_SEGMENTSH :Number = 6;

		/**
		* The minimum number of horizontal segments for a sphere.
		*/
		static public const MIN_SEGMENTSW :Number = 3;

		/**
		* The minimum number of vertical segments for a sphere.
		*/
		static public const MIN_SEGMENTSH :Number = 2;

		/**
		* Creates a Sphere primitive.
		*
		* <p>The sphere is created centered at the origin of the world coordinate system,
		* with its poles on the y axis</p>
		*
		* @param p_sName 		A string identifier for this object.
		* @param p_nRadius		Radius of the sphere.
		* @param p_nSegmentsW	Number of horizontal segments.
		* @param p_nSegmentsH	Number of vertical segments.
		*/
		function Sphere( p_sName:String=null , p_nRadius:Number=100, p_nSegmentsW:Number=8, p_nSegmentsH:Number=6 )
		{
			super( p_sName );
			setConvexFlag (true);
			// --
			this.segmentsW = Math.max( MIN_SEGMENTSW, p_nSegmentsW || DEFAULT_SEGMENTSW); // Defaults to 8
			this.segmentsH = Math.max( MIN_SEGMENTSH, p_nSegmentsH || DEFAULT_SEGMENTSH); // Defaults to 6
			radius = (p_nRadius != 0) ? p_nRadius : DEFAULT_RADIUS; // Defaults to 100
			// --
			var scale :Number = DEFAULT_SCALE;
			// --
			geometry = generate();
		}

		/**
		* Generates the geometry for the sphere.
		*
		* @return The geometry object for the sphere.
		*
		* @see sandy.core.scenegraph.Geometry3D
		*/
		public function generate(... arguments):Geometry3D
		{
			var l_oGeometry:Geometry3D = new Geometry3D();
			// --
			var i:Number, j:Number, k:Number;
			var iHor:Number = Math.max(3,this.segmentsW);
			var iVer:Number = Math.max(2,this.segmentsH);
			// --
			var aVtc:Array = new Array();
			for ( j=0; j<(iVer+1) ;j++ )
			{ // vertical
				var fRad1:Number = Number(j/iVer);
				var fZ:Number = -radius*Math.cos(fRad1*Math.PI);
				var fRds:Number = radius*Math.sin(fRad1*Math.PI);
				var aRow:Array = new Array();
				var oVtx:Number;
				for ( i=0; i<iHor ; i++ )
				{ // horizontal
					var fRad2:Number = Number(2*i/iHor);
					var fX:Number = fRds*Math.sin(fRad2*Math.PI);
					var fY:Number = fRds*Math.cos(fRad2*Math.PI);
					if (!((j==0||j==iVer)&&i>0))
					{ // top||bottom = 1 vertex
						oVtx = l_oGeometry.setVertex( l_oGeometry.getNextVertexID(), fY, fZ, fX );//fY, -fZ, fX );
					}
					aRow.push(oVtx);
				}
				aVtc.push(aRow);
			}
			// --
			var iVerNum:Number = aVtc.length;
			for ( j=0; j<iVerNum; j++ )
			{
				var iHorNum:Number = aVtc[j].length;
				if (j>0)
				{ // &&i>=0
					for ( i=0; i<iHorNum; i++ )
					{
						// select vertices
						var bEnd:Boolean = i==(iHorNum-0);
						// --
						var l_nP1:Number = aVtc[j][bEnd?0:i];
						var l_nP2:Number = aVtc[j][(i==0?iHorNum:i)-1];
						var l_nP3:Number = aVtc[j-1][(i==0?iHorNum:i)-1];
						var l_nP4:Number = aVtc[j-1][bEnd?0:i];
						// uv
						var fJ0:Number = j		/ (iVerNum-1);
						var fJ1:Number = (j-1)	/ (iVerNum-1);
						var fI0:Number = (i+1)	/ iHorNum;
						var fI1:Number = i		/ iHorNum;

						var l_nUV4:Number = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), fI0, 1-fJ1 );
						var l_nUV1:Number = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), fI0, 1-fJ0 );
						var l_nUV2:Number = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), fI1, 1-fJ0 );
						var l_nUV3:Number = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), fI1, 1-fJ1 );
						var l_nF:Number;

						// 2 faces
						if (j<(aVtc.length-1))
						{
							l_nF = l_oGeometry.setFaceVertexIds( l_oGeometry.getNextFaceID(), l_nP1, l_nP2, l_nP3 );
							l_oGeometry.setFaceUVCoordsIds( l_nF, l_nUV1, l_nUV2, l_nUV3 );
							//aFace.push( new Face3D(new Array(aP1,aP2,aP3),new Array(aP1uv,aP2uv,aP3uv)) );
						}
						if (j>1)
						{
							l_nF = l_oGeometry.setFaceVertexIds( l_oGeometry.getNextFaceID(), l_nP1, l_nP3, l_nP4 );
							l_oGeometry.setFaceUVCoordsIds( l_nF, l_nUV1, l_nUV3, l_nUV4 );
							//aFace.push( new Face3D(new Array(aP1,aP3,aP4), new Array(aP1uv,aP3uv,aP4uv)) );
						}

					}
				}
			}
			// --
			return l_oGeometry;
		}

		/**
		* @private
		*/
		public override function toString():String
		{
			return "sandy.primitive.Sphere";
		}
	}
}