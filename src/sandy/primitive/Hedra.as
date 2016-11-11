
package sandy.primitive
{
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;

	/**
	* The Hedra class is used for creating a hedra. A hedra can be seen as two pyramids joined at their bases.
	*
	* @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	* @date 		26.07.2007
	*
	* @example To create a hedra with ( y, x, z ) dimensions ( 100, 60, 80 ),
	* use the following statement:
	*
	* <listing version="3.1">
	*     var myHedra:Hedra = new Hedra( "theObj", 100, 60, 80 );
	*  </listing>
	*/
	public class Hedra extends Shape3D implements Primitive3D
	{
		//////////////////
		///PRIVATE VARS///
		//////////////////
		private var _h:Number;
		private var _lg:Number;
		private var _radius:Number ;

		/**
		* Creates a Hedra primitive.
		*
		* <p>The Hedra is created centered at the origin of the world coordinate system
		* with its edges parallel to world coordinate axes.</p>
		*
		* @param p_sName	A string identifier for this object.
		* @param p_nHeight	Height of the hedra (along the y-axis).
		* @param p_nWidth	Width of the hedra (along the x-axis).
		* @param p_nDepth	Depth of the hedra (along the z-axis).
		*/
		public function Hedra ( p_sName:String=null, p_nHeight : Number = 100, p_nWidth : Number = 100, p_nDepth : Number = 100 )
		{
			super (p_sName);
			setConvexFlag (true);
			_radius = (p_nDepth)?p_nDepth:100;
			_h = (p_nHeight)?p_nHeight:100 ;
			_lg = (p_nWidth)?p_nWidth:100;
			geometry = generate ();
		}

		/**
		* Generates the geometry for the hedra.
		*
		* @return The geometry object for the hedra.
		*
		* @see sandy.core.scenegraph.Geometry3D
		*/
		public function generate (... arguments):Geometry3D
		{
			var l_oGeometry3D:Geometry3D = new Geometry3D();
			//Creation des points
			_h = -_h;
			var r2:Number = _radius / 2;
			var l2:Number = _lg / 2;
			var h2:Number = _h / 2;
			/*
			3-----2
			 \ 4&5 \
			  0-----1
			*/
			l_oGeometry3D.setVertex(0, -r2 , 0  , l2 );
			l_oGeometry3D.setVertex(1,r2 , 0  , l2 );
			l_oGeometry3D.setVertex(2, r2 , 0  , -l2 );
			l_oGeometry3D.setVertex(3,-r2 , 0  , -l2 );
			l_oGeometry3D.setVertex(4, 0 , h2  , 0 );
			l_oGeometry3D.setVertex(5, 0 , -h2  , 0 );

			l_oGeometry3D.setUVCoords(0, 0, 0.5);//0
			l_oGeometry3D.setUVCoords(1, 0.33, 0.5);//1
			l_oGeometry3D.setUVCoords(2, 0.66, 0.5);//2
			l_oGeometry3D.setUVCoords(3, 1, 0.5);//3
			l_oGeometry3D.setUVCoords(4, 1, 1);
			l_oGeometry3D.setUVCoords(5, 0, 0);

			//Creation des faces
			//Face avant
			l_oGeometry3D.setFaceVertexIds( 0, 0, 1, 4 );
			l_oGeometry3D.setFaceUVCoordsIds(0, 0, 1, 4 );

			//Face derriere
			l_oGeometry3D.setFaceVertexIds( 1, 3, 4, 2 );
			l_oGeometry3D.setFaceUVCoordsIds( 1, 3, 4, 2 );

			l_oGeometry3D.setFaceVertexIds( 2, 1, 5, 2 );
			l_oGeometry3D.setFaceUVCoordsIds( 2, 1, 5, 2 );
			//Face gauche
			l_oGeometry3D.setFaceVertexIds( 3, 4, 3, 0 );
			l_oGeometry3D.setFaceUVCoordsIds( 3, 4, 3, 0 );
			//Face droite
			l_oGeometry3D.setFaceVertexIds( 4, 4, 1, 2 );
			l_oGeometry3D.setFaceUVCoordsIds( 4, 4, 1, 2 );

			l_oGeometry3D.setFaceVertexIds( 5, 0, 5, 1 );
			l_oGeometry3D.setFaceUVCoordsIds( 5, 0, 5, 1 );

			l_oGeometry3D.setFaceVertexIds( 6, 3, 2, 5 );
			l_oGeometry3D.setFaceUVCoordsIds( 6, 3, 2, 5 );

			l_oGeometry3D.setFaceVertexIds( 7, 0, 3, 5 );
			l_oGeometry3D.setFaceUVCoordsIds( 7, 0, 3, 5 );


			return l_oGeometry3D;
		}

		/**
		* @private
		*/
		public override function toString():String
		{
			return "sandy.primitive.Hedra";
		}
	}
}