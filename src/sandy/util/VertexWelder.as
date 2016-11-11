package sandy.util{
	import sandy.core.scenegraph.*;
	import sandy.core.data.*;
	import flash.utils.Dictionary;

	/**
	 * The VertexWelder class is a static class that is able to weld duplicate
	 * vertices in a geometry.
	 *
	 * <p>It can faithfully transfer all UV data in a non-destructive manner,
	 * and automatically smooth all vertex normal data by averaging
	 * all the normals of duplicate vertices in the geometry.</p>
	 *
	 * @see sandy.core.scenegraph.Geometry3D
	 * @see sandy.core.data.UVCoord
	 * @see sandy.core.data.Vertex
	 *
	 * @author	Gregorius Soedharmo
	 * @version	3.1.1
	 * @date	11.15.2009
	 */

	public class VertexWelder {
		/**
		*
		* Cached result of the previous call to <code>weld</code>.
		*
		* @default null
		*
		*/
		public static var geometry:Geometry3D = null;

		/**
		 *
		 * Throw an error if the user tried to instantiate the class.
		 *
		 * @private
		 *
		 */
		public function VertexWelder():void
		{
			throw new Error("VertexWelder is a static only class and can not be instantiated.");
		}

		/**
		 * Create a clone of a geometry, deletes all redundant data, and welds
		 * all duplicate vertex found in the former geometry.
		 *
		 * @param p_oGeom The geometry input to be processed
		 * @param p_iPrecision The precision threshold of vertex welding.
		 * @return The welded geometry clone of <code>p_oGeom</code>
		 *
		 * @example <listing version="3.0">
		 * VertexWelder( myShape3D.geometry, 4); // This will weld myShape3D geometry with 0.0001 welding threshold.
		 * </listing>
		 */
		public static function weld(p_oGeom:Geometry3D, p_iPrecision:int = 2):Geometry3D {
			var precision:int = Math.pow(10, p_iPrecision);
			var _geometry:Geometry3D = new Geometry3D();

			var refGeom:Geometry3D =p_oGeom;
			var aVertex:Array = refGeom.aVertex;
			var aUVCoords:Array = refGeom.aUVCoords;
			var aFacesNormals:Array = refGeom.aFacesNormals;
			var aVertexNormals:Array =refGeom.aVertexNormals;

			var vertexCache:Dictionary = new Dictionary();
			var vertexMap:Array = new Array();
			var uvCache:Dictionary = new Dictionary();
			var uvMap:Array = new Array();

			/**
			 *
			 * Copy over all the UV coordinate datas, deleting duplicates
			 * with duplicates defined as the same ID obtained when
			 * the string Us + "_" + Vs equals each other where
			 * Us and Vs defines as the floor of U and V values
			 * after being multiplied by a million.
			 *
			 * Rationale: 1/1000000 is a good enough precision considering that
			 * Flash player can only handle a maximum bitmap size of 4096 x 4096.
			 *
			 * Create a many to one mapping array so we can move the old data
			 * to the newly optimized UV list data when we rebuild the geometry.
			 *
			 */
			var len:int=aUVCoords.length;
			var mapID:int;
			for (var i:int=0; i<len; i++) {
				var uv:UVCoord=aUVCoords[i];
				if( null == uv ) continue;	// aUVCoords array can be sparse
				var uvID:String=int(uv.u*1000000)+"_"+int(uv.v*1000000);
				if (null==uvCache[uvID]) {
					mapID=_geometry.setUVCoords(_geometry.getNextUVCoordID(),uv.u,uv.v);
					uvCache[uvID]=mapID;
				} else {
					mapID=uvCache[uvID];
				}
				uvMap[i]=mapID;
			}

			/**
			 *
			 * Now we do the same with the vertices, except that this time,
			 * the precision is left to the user to decide, and the ID is set
			 * to Xs + "_" + Ys + "_" + Zs.
			 *
			 * If multiple vertices were found, get their normals and average them.
			 * We will temporarily use the Vertex.flag of the normal to store
			 * the duplicate count of vertices found.
			 *
			 */
			len=aVertex.length;
			for (i=0; i<len; i++) {
				var v:Vertex=aVertex[i];
				if( null == v ) continue;	// aVertex array can be sparse
				var vID:String=int(v.x*precision)+"_"+int(v.y*precision)+"_"+int(v.z*precision);
				if (null==vertexCache[vID]) {
					mapID=_geometry.setVertex(_geometry.getNextVertexID(),v.x,v.y,v.z);
					vertexCache[vID]=mapID;

					var nRef:Vertex=aVertexNormals[i];
					if( null != nRef ){		// Vertex normal might not exist for "virgin" geometries from parsers.
						_geometry.setVertexNormal(mapID, nRef.x, nRef.y, nRef.z);
						var nNew:Vertex=_geometry.aVertexNormals[mapID];
						nNew.flags=1;
					}
				} else {
					mapID=vertexCache[vID];

					nRef=aVertexNormals[i];
					if( null != nRef ){		// Vertex normal might not exist for "virgin" geometries from parsers.
						nNew=_geometry.aVertexNormals[mapID];
						nNew.add(nRef);
						nNew.flags++;
					}
				}
				vertexMap[i]=mapID;
			}

			/**
			 *
			 * Average the normals, normalize, and reset the flag to 0.
			 *
			 */
			len=_geometry.aVertexNormals.length;
			for (i=0; i<len; i++) {
				nNew=_geometry.aVertexNormals[i];
				if( null != nNew){		// Vertex normal might not exist for "virgin" geometries from parsers.
					nNew.scale(1/nNew.flags);
					nNew.normalize();
					nNew.flags=0;
				}
			}

			/**
			 *
			 * Rebuild the geometry faces and copy the face normal data
			 * and the UV data.
			 *
			 * Make sure the data exists before we try to rebuild it.
			 *
			 */
			var facesVtx:Array=refGeom.aFacesVertexID;
			var facesUV:Array=refGeom.aFacesUVCoordsID;
			var facesNorm:Array=refGeom.aFacesNormals;
			len=facesVtx.length;
			for (i=0; i<len; i++) {
				var faceVtx:Array=facesVtx[i].slice();
				var faceUV:Array=facesUV[i].slice();
				for (var j:int=0; j<faceVtx.length; j++) {
					if(faceVtx) faceVtx[j]=vertexMap[faceVtx[j]];
					if(faceUV) faceUV[j]=uvMap[faceUV[j]];
				}
				if(faceVtx) _geometry.setFaceVertexIds(i, faceVtx);
				if(faceUV) _geometry.setFaceUVCoordsIds(i, faceUV);

				nRef=facesNorm[i];
				if(nRef) _geometry.setFaceNormal(i, nRef.x, nRef.y, nRef.z);
			}

			/**
			 *
			 * DONE! Clean-up time!
			 *
			 */
			aVertex=null;
			aUVCoords=null;
			aFacesNormals=null;
			aVertexNormals=null;
			vertexMap.length = 0;
			vertexMap=null;
			uvMap.length = 0;
			uvMap=null;
			refGeom=null;

			var prop:String;
			for (prop in vertexCache) {
				delete vertexCache[prop];
			}

			for (prop in uvCache) {
				delete uvCache[prop];
			}

			geometry = _geometry;
			return _geometry;
		}
	}

}