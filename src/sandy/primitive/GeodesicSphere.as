
package sandy.primitive
{
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;
	
	/**
	* GeodesicSphere implements octahedron-based geodesic sphere.
	*
	* <p>Compared to regular sphere, this primitive produces geometry with more
	* evenly distributed triangles (code ported from Away3D mostly as is, with
	* the exception of U/V mapping).</p>
	*
	* @author		makc
	 * @version		3.1
	* @date 		10.04.2008
	*
	* @see http://en.wikipedia.org/wiki/Geodesic_dome
	* @see http://en.wikipedia.org/wiki/Octahedron
	*/
	public class GeodesicSphere extends Shape3D implements Primitive3D {
		 
		private var radius_in:Number;
        private var fractures_in:int;
		
		/**
		* Creates a GeodesicSphere primitive.
		*
		* @param p_sName	A string identifier for this object.
		* @param p_nRadius	Sphere radius.
		* @param p_nFractures	Tesselation quality.
		*/
		public function GeodesicSphere ( p_sName:String=null, p_nRadius : Number = 100, p_nFractures : Number = 2)
        {
            super (p_sName);
		setConvexFlag (true);

			radius_in = p_nRadius;
            fractures_in = Math.max (2, p_nFractures);
			 
			geometry = generate ();
		}
		
		/**
		* @private
		*/
		public function generate (... arguments):Geometry3D
		{
			var l_oGeometry3D:Geometry3D = new Geometry3D();

			// Set up variables for keeping track of the vertices, faces, and texture coords.
			var nVertices:int = 0, nFaces:int = 0;
			var aPacificFaces:Array = [], aVertexNormals:Array = [];
			
			// Set up variables for keeping track of the number of iterations and the angles
			var iVerts:uint = fractures_in + 1, jVerts:uint;
			var j:uint, Theta:Number=0, Phi:Number=0, ThetaDel:Number, PhiDel:Number;
			var cosTheta:Number, sinTheta:Number, cosPhi:Number, sinPhi:Number;

			// Although original code used quite clever diamond projection, let's change it to
			// equirectangular just to see how it performs compared to standard Sphere - makc

			var Pd4:Number = Math.PI / 4, cosPd4:Number = Math.cos(Pd4), sinPd4:Number = Math.sin(Pd4), PIInv:Number = 1/Math.PI;
			var R_00:Number = cosPd4, R_01:Number = -sinPd4, R_10:Number = sinPd4, R_11:Number = cosPd4;

			PhiDel = Math.PI / ( 2 * iVerts);

			Phi += PhiDel;

			// Build vertices for the sphere progressing in rings around the sphere
			var i:int, q:int, aI:Array = [];
			for (q = 1; q <= iVerts; q++) aI.push (q);
			for (q = iVerts -1; q > 0; q--) aI.push (q);

			for (q = 0; q < aI.length; q++) {
				i = aI[q]; j = 0; jVerts = i*4;
				Theta = 0;
				ThetaDel = 2* Math.PI / jVerts;
				cosPhi = Math.cos( Phi );
				sinPhi = Math.sin( Phi );
				for( j; j < jVerts; j++ )
				{
					cosTheta = Math.cos( Theta );
					sinTheta = Math.sin( Theta );

					l_oGeometry3D.setVertex (nVertices, cosTheta * sinPhi * radius_in, cosPhi * radius_in, sinTheta * sinPhi * radius_in);
					l_oGeometry3D.setVertexNormal (nVertices, cosTheta * sinPhi, cosPhi, sinTheta * sinPhi);
					l_oGeometry3D.setUVCoords (nVertices, Theta * PIInv * 0.5, Phi * PIInv); nVertices++;

					Theta += ThetaDel;
				}
				Phi += PhiDel;
			}
			
			// Four triangles meet at every pole, so we make 8 polar vertices to reduce polar distortions
			for (i = 0; i < 8; i++)
			{
				l_oGeometry3D.setVertex (nVertices + i, 0, (i < 4) ? radius_in : -radius_in, 0);
				l_oGeometry3D.setVertexNormal (nVertices + i, 0, (i < 4) ? 1 : -1, 0);
				l_oGeometry3D.setUVCoords (nVertices + i, 0.25 * (i%4 + 0.5), (i < 4) ? 0 : 1);
			}

			// Build the faces for the sphere
			// Build the upper four sections
			var k:uint, L_Ind_s:uint, U_Ind_s:uint, U_Ind_e:uint, L_Ind_e:uint, L_Ind:uint, U_Ind:uint;
			var isUpTri:Boolean, Pt0:uint, Pt1:uint, Pt2:uint, tPt:uint, triInd:uint, tris:uint;
			tris = 1;
			L_Ind_s = 0; L_Ind_e = 0;
			for( i = 0; i < iVerts; i++ ){
				U_Ind_s = L_Ind_s;
				U_Ind_e = L_Ind_e;
				if( i == 0 ) L_Ind_s++;
				L_Ind_s += 4*i;
				L_Ind_e += 4*(i+1);
				U_Ind = U_Ind_s;
				L_Ind = L_Ind_s;
				for( k = 0; k < 4; k++ ){
					isUpTri = true;
					for( triInd = 0; triInd < tris; triInd++ ){
						if( isUpTri ){
							Pt0 = U_Ind;
							Pt1 = L_Ind;
							L_Ind++;
							if( L_Ind > L_Ind_e ) L_Ind = L_Ind_s;
							Pt2 = L_Ind;
							isUpTri = false;
						} else {
							Pt0 = L_Ind;
							Pt2 = U_Ind;
							U_Ind++;
							if( U_Ind > U_Ind_e ) {
								// pacific problem - correct vertex does not exist
								aPacificFaces.push (
									(Pt2 % 2 == 0) ?
									[ Pt2 -1, Pt0 -1, U_Ind_s -1 ] :
									[ Pt0 -1, Pt2 -1, U_Ind_s -1 ]);
								continue;
							}
							Pt1 = U_Ind;
							isUpTri = true;
						}

						// use extra vertices for pole
						if (Pt0 == 0)
						{
							Pt0 = Pt1 + nVertices;
							if (Pt1 == 4) {
								// pacific problem at North pole
								aPacificFaces.push ([ Pt0 -1, Pt1 -1, Pt2 -1 ]);
								continue;
							}
						}

						l_oGeometry3D.setFaceVertexIds (nFaces, Pt0 -1, Pt1 -1, Pt2 -1);
						l_oGeometry3D.setFaceUVCoordsIds (nFaces, Pt0 -1, Pt1 -1, Pt2 -1); nFaces++;
					}
				}
				tris += 2;
			}
			U_Ind_s = L_Ind_s; U_Ind_e = L_Ind_e;
			// Build the lower four sections
			 
			for( i = iVerts-1; i >= 0; i-- ){
				L_Ind_s = U_Ind_s; L_Ind_e = U_Ind_e; U_Ind_s = L_Ind_s + 4*(i+1); U_Ind_e = L_Ind_e + 4*i;
				if( i == 0 ) U_Ind_e++;
				tris -= 2;
				U_Ind = U_Ind_s;
				L_Ind = L_Ind_s;
				for( k = 0; k < 4; k++ ){
					isUpTri = true;
					for( triInd = 0; triInd < tris; triInd++ ){
						if( isUpTri ){
							Pt0 = U_Ind;
							Pt1 = L_Ind;
							L_Ind++;
							if( L_Ind > L_Ind_e ) L_Ind = L_Ind_s;
							Pt2 = L_Ind;
							isUpTri = false;
						} else {
							Pt0 = L_Ind;
							Pt2 = U_Ind;
							U_Ind++;
							if( U_Ind > U_Ind_e ) {
								if (Pt2 %2 == 0)
									aPacificFaces.push ([ Pt0 -1, Pt2 -1, U_Ind_s -1 ]);
								else
									aPacificFaces.push ([ Pt0 -1, U_Ind_s -1, L_Ind_s -1 ]);
								continue;
							}
							Pt1 = U_Ind;
							isUpTri = true;
						}

						// use extra vertices for pole
						if (Pt0 == nVertices +1)
						{
							Pt0 = Pt1 + 8;
							if (Pt1 == nVertices) {
								// pacific problem at South pole
								aPacificFaces.push ([ Pt0 -1, Pt2 -1, Pt1 -1 ]);
								continue;
							}
						}

						l_oGeometry3D.setFaceVertexIds (nFaces, Pt0 -1, Pt2 -1, Pt1 -1);
						l_oGeometry3D.setFaceUVCoordsIds (nFaces, Pt0 -1, Pt2 -1, Pt1 -1); nFaces++;
					}
				}
			}
			
			// only now we can fix pacific problem
			// (because doing so in any other way would break Gabriel code ;)
			nVertices = l_oGeometry3D.aVertex.length;
			for (i = 0; i < aPacificFaces.length; i++)
			{
				for (k = 0; k < 3; k++)
				{
					var p:int = aPacificFaces [i][k];
					if (l_oGeometry3D.aUVCoords [p].u == 0)
					{
						l_oGeometry3D.setVertex (nVertices,
							l_oGeometry3D.aVertex [p].x,
							l_oGeometry3D.aVertex [p].y,
							l_oGeometry3D.aVertex [p].z);
						l_oGeometry3D.setVertexNormal (nVertices,
							l_oGeometry3D.aVertexNormals [p].x,
							l_oGeometry3D.aVertexNormals [p].y,
							l_oGeometry3D.aVertexNormals [p].z);
						l_oGeometry3D.setUVCoords (nVertices, 1,
							l_oGeometry3D.aUVCoords [p].v);
						aPacificFaces [i][k] = nVertices;
						nVertices++;
					}
				}

				l_oGeometry3D.setFaceVertexIds (nFaces, aPacificFaces [i][0], aPacificFaces [i][1], aPacificFaces [i][2]);
				l_oGeometry3D.setFaceUVCoordsIds (nFaces, aPacificFaces [i][0], aPacificFaces [i][1], aPacificFaces [i][2]);

				nFaces++;
			}

			return l_oGeometry3D;
		}
	}
}