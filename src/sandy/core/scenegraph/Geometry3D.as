
package sandy.core.scenegraph 
{
	//import flash.utils.Dictionary;
	
	import flash.utils.Dictionary;
	
	import sandy.core.data.Edge3D;
	import sandy.core.data.Point3D;
	import sandy.core.data.UVCoord;
	import sandy.core.data.Vertex;
	
	
	/**
	 * 	The Geometry3D class holds a complete description of the geometry of a Shape3D.
	 *
	 * 	It contains points, faces, normals and uv coordinates.
	 * 	
	 * 	NOTE: 	For best performance, Geometry should be created in offline mode,
	 * 		especially all faces, as createFace() validates all points 
	 * 		if these points exist in points array.
	 * 
	 * 	NOTE: 	This object is going to work well _ONLY_ if arrays 
	 * 		wont be changed directlly [ie. push()] but _ONLY_ via accessor methods:
	 * 		createFace, createFaceByIds, addFace, addFaces.
	 * 		In the future we can make these Arrays PRIVATE but then the only 
	 * 		way to make them safe is to deliver additionall accessors like 
	 * 		getPoint(index:int), getFace(index:int) what could potentially slow 
	 * 		affect performance of this structure (well, we need to test it, and 
	 * 		if there is no problem, make arrays private and provide accessors for 
	 * 		_SINGLE_ array's elements to make them safe ). 
	 *
	 * <p>[<b>ToDo</b>: Revise this and adopt tp ASDoc]</p>
	 * 
	 * @author	Mirek Mencel
	 * @author	Thomas PFEIFFER
	 * @version		3.1
	 * @date	07.04.2007
	 */
	public final class Geometry3D
	{	
	// ______
	// PUBLIC________________________________________________________	
		
		private var EDGES_DICO:Dictionary = new Dictionary(true);
		
		
		/** Array of vertices */
		public var aVertex:Array = new Array();
		/** Array of faces composed from vertices */
		public var aFacesVertexID:Array = new Array();
		public var aFacesUVCoordsID:Array = new Array();
		/** Array ov normals */
		public var aFacesNormals:Array = new Array();
		public var aVertexNormals:Array = new Array();
		public var aEdges:Array = new Array();
		// Array of face edges
		public var aFaceEdges:Array = new Array();
		/** UV Coords for faces */
		public var aUVCoords:Array = new Array();
		private var m_nLastVertexId:int = 0;
		private var m_nLastNormalId:int = 0;
		private var m_nLastFaceId:int = 0;
		private var m_nLastFaceUVId:int = 0;
		private var m_nLastUVId:int = 0;
		private var m_nLastVertexNormalId:int = 0;
		private var m_aVertexFaces:Array = new Array();
	// ___________
	// CONSTRUCTOR___________________________________________________
		
		/**
		 * Creates a 3D geometry.
		 * 
		 * @param p_points	Not used in this version
		 */
		public function Geometry3D(p_points:Array=null)
		{
			init();
		}
		/**
		* Not used in this version.
		*/
		public function init():void
		{
			;
		}
		
		/**
		 * Adds new point at the specified index of the vertex list.
		 * 
		 * @param p_nVertexID	Index at which to save the vertex
		 * @param p_nX		x coordinate of the vertex
		 * @param p_nY		y coordinate of the vertex
		 * @param p_nZ		z coordinate of the vertex
		 * @return 		The next free index or -1 it the index is already occupied		 
		 */
		public function setVertex( p_nVertexID:int, p_nX:Number, p_nY:Number, p_nZ:Number ):int
		{
			if( aVertex[p_nVertexID] )
				return -1;
			else
			{ 
				aVertex[p_nVertexID] = new Vertex(p_nX, p_nY, p_nZ); 
				return ++m_nLastVertexId - 1;  
			}
		}
		
		/**
		 * Returns the next unused vertex id.
		 *
		 * <p>this is the next free index in the verex list, and used by setVertex</p>
		 *
		 * @return 	The vertex id
		 */
		public function getNextVertexID():int
		{
			return m_nLastVertexId;
		}	
	
		/**
		 * Adds new normal at the specified index of the face normal list.
		 * 
		 * @param p_nNormalID	Index at which to save the normal
		 * @param p_nX		The x component of the normal
		 * @param p_nY		The y component of the normal
		 * @param p_nZ		The z component of the normal
		 * @return 		The next free index or -1 it the index is already occupied		 
		 */
		public function setFaceNormal( p_nNormalID:int, p_nX:Number, p_nY:Number, p_nZ:Number ):int
		{
			if( aFacesNormals[p_nNormalID] )
				return -1;
			else
			{ 
				aFacesNormals[p_nNormalID] = new Vertex(p_nX, p_nY, p_nZ); 
				return ++m_nLastNormalId - 1; 
			}
		}
	
		/**
		 * Returns the next unused normal id.
		 *
		 * <p>This is the next free index in the normal list, and used by setFaceNormal</p>
		 *
		 * @return 	The normal id
		 */
		public function getNextFaceNormalID():int
		{
			return m_nLastNormalId;
		}
			
		/**
		 * Add new point the specified index of the vertex normal list.
		 * 
		 * @param p_nNormalID	Index at which to save the vertex normal
		 * @param p_nX		x coordinate of the vertex normal
		 * @param p_nY		y coordinate of the vertex normal
		 * @param p_nZ		z coordinate of the vertex normal
		 * @return 		The next free index or -1 it the index is already occupied
		 */
		public function setVertexNormal( p_nNormalID:int, p_nX:Number, p_nY:Number, p_nZ:Number ):int
		{
			if( aVertexNormals[p_nNormalID] )
				return -1;
			else
			{ 
				aVertexNormals[p_nNormalID] = new Vertex(p_nX, p_nY, p_nZ); 
				return ++m_nLastVertexNormalId - 1;  
			}
		}
		
		/**
		 * Returns the next unused vertex normal id.
		 *
		 * <p>This is the next free index in the vertex normal list, and used by setVertexNormal</p>
		 *
		 * @return 	The vertex normal id
		 */
		public function getNextVertexNormalID():int
		{
			return m_nLastVertexNormalId;
		}
		
		/**
		 * Sets the ID's of the face vertices.
		 * 
		 * @param p_nFaceID	Id of the face
		 * @param...rest 	An array of data containing the ID's of the vertex list for the face
		 * @return 		The next free index or -1 it the index is already occupied
		 */
		public function setFaceVertexIds( p_nFaceID:int, ... arguments ):int
		{
			if( aFacesVertexID[p_nFaceID] )
			{
				return -1;
			}
			else
			{
				var rest:Array = (arguments[0] is Array)? arguments[0]: arguments.splice(0);
				aFacesVertexID[p_nFaceID] = rest;
				
				// Time to check if edges allready exist or if we shall create them
				for( var lId:uint = 0; lId < rest.length; lId++ )
				{
					var lId1:uint = rest[lId];
					var lId2:uint = rest[ (lId+1)%rest.length ];
					var lEdgeID:uint;
					var lString:String;
					// --
					if( isEdgeExist( lId1, lId2 ) == false )
					{
						lEdgeID = aEdges.push( new Edge3D( lId1, lId2 ) ) - 1;
						// --
						if( lId1 < lId2 ) lString = lId1+"_"+lId2;
						else lString = lId2+"_"+lId1;
						// --
						EDGES_DICO[lString] = lEdgeID;
					}
					else
					{
						if( lId1 < lId2 ) lString = lId1+"_"+lId2;
						else lString = lId2+"_"+lId1;
						lEdgeID = EDGES_DICO[lString];
					}
					
					if( null == aFaceEdges[p_nFaceID] ) aFaceEdges[p_nFaceID] = new Array();
						( aFaceEdges[p_nFaceID] as Array ).push( lEdgeID );
				}
				
				return ++m_nLastFaceId - 1; 
			}
		}
		
		private function isEdgeExist( p_nVertexId1:uint, p_nVertexId2:uint ):Boolean
		{
			var lString:String;
			// --
			if( p_nVertexId1 < p_nVertexId2 ) lString = p_nVertexId1+"_"+p_nVertexId2;
			else lString = p_nVertexId2+"_"+p_nVertexId1;
			// --
			if( EDGES_DICO[lString] == null ) return false;
			else return true;
		}
		
		/**
		 * Returns the next unused face id.
		 *
		 * <p>This is the next free index in the faces list, and used by setFaceVertexIds</p>
		 *
		 * @return 	The index
		 */
		public function getNextFaceID():int
		{
			return m_nLastFaceId;
		}
		
		/**
		 * Set the ID's of face UV coordinates.
		 *
		 * @param p_nFaceID	The id of the face
		 * @param ...rest 	An array of data containing the ID's of the UV coords list for the face
		 * @return 		The next free index or -1 it the index is already occupied
		 */
		public function setFaceUVCoordsIds( p_nFaceID:int, ... arguments /* Arguments */ ):int
		{
			if( aFacesUVCoordsID[p_nFaceID] )
			{
				return -1;
			}
			else
			{
				var rest:Array = (arguments[0] is Array)? arguments[0]: arguments.splice(0);
				aFacesUVCoordsID[p_nFaceID] = rest;
				return ++m_nLastFaceUVId - 1; 
			}
		}
			
		/**
		 * Returns the next unused face UV coordinates id.
		 *
		 * <p>This is the next free index in the UV coordinate id list, and used by setFaceUVCoords</p>
		 *
		 * @return 	The index
		 */
		public function getNextFaceUVCoordID():int
		{
			return m_nLastFaceUVId;
		}
			
		/**
		 * Returns the index of a specified point in the vertex list.
		 *
		 * @return 	The index
		 */
		public function getVertexId( p_point:Vertex ):int
		{
			/*var j:Number = 0;
			for(j=0; j<aVertex.length && !(aVertex[j] == p_point); 	j++);
			
			return j == aVertex.length ? -1: j;*/
			return aVertex.indexOf (p_point);
		}
		
		/**
		 * Adds UV coordinates for single face.
		 * 
		 * [<b>ToDo</b>: Explain this ]
		 * @param p_nID		The id of the face
		 * @param p_UValue	The u component of the UV coordinate
		 * @param p_nVValue	The v component of the UV coordinate
		 * @return 		The next free index or -1 it the index is already occupied
		 */
		public function setUVCoords( p_nID:int, p_UValue:Number, p_nVValue:Number ):int
		{
			if ( aUVCoords[p_nID] )
			{
				return -1;
			}
			else
			{
				aUVCoords[p_nID] = new UVCoord( p_UValue, p_nVValue );
				return ++m_nLastUVId - 1; 
			}
		}
	
		/**
		 * Returns the next unused UV coordinates id.
		 * 
		 * <p>This is the next free index in the UV coordinates list, and used by setUVCoords</p>
		 *
		 * @return 	The index
		 */
		public function getNextUVCoordID():int
		{
			return m_nLastUVId;
		}
		
		
		public function generateFaceNormals():void
		{
			if( aFacesNormals.length > 0 )  return;
			else
			{
				for each( var a:Array in aFacesVertexID )
				{
					// If face is linear, as Line3D, no face normal to process
					if( a.length < 3 ) continue;
					// --
					var lA:Vertex, lB:Vertex, lC:Vertex;
					lA = aVertex[a[0]];
					lB = aVertex[a[1]];
					lC = aVertex[a[2]];
					// --
					var lV:Point3D = new Point3D( lB.wx - lA.wx, lB.wy - lA.wy, lB.wz - lA.wz );
					var lW:Point3D = new Point3D( lB.wx - lC.wx, lB.wy - lC.wy, lB.wz - lC.wz );
					// we compute de cross product
					var lNormal:Point3D = lV.cross( lW );
					// we normalize the resulting Point3D
					lNormal.normalize();
					// --
					setFaceNormal( getNextFaceNormalID(), lNormal.x, lNormal.y, lNormal.z );
				}
			}
		}


		public function generateVertexNormals():void
		{
			if( aVertexNormals.length > 0 )  return;
			else
			{
				var lId:uint = 0;
				for( lId = 0; lId < aFacesVertexID.length; lId++ )
				{
					var l_aList:Array = aFacesVertexID[ lId ];
					// -- get the normal of that face
					var l_oNormal:Vertex = aFacesNormals[ lId ];
					// for some reason, no normal has been set up here. 
					if( l_oNormal == null )
						continue;
					// -- add it to the corresponding vertex normals
					if( null == aVertexNormals[l_aList[0]] )
					{
						m_nLastVertexNormalId++;
						aVertexNormals[l_aList[0]] = new Vertex();
					}
					Vertex( aVertexNormals[l_aList[0]] ).add( l_oNormal );
					
					if( null == aVertexNormals[l_aList[1]] )
					{
						m_nLastVertexNormalId++;
						aVertexNormals[l_aList[1]] = new Vertex();
					}
					Vertex( aVertexNormals[l_aList[1]] ).add( l_oNormal );
					
					if( null == aVertexNormals[l_aList[2]] )
					{
						m_nLastVertexNormalId++;
						aVertexNormals[l_aList[2]] = new Vertex();
					}
					Vertex( aVertexNormals[l_aList[2]] ).add( l_oNormal );
					
					// -- We update the number of faces these vertex belongs to
					if( (aVertex[l_aList[0]] as Vertex).aFaces.indexOf( lId ) == 0 )
						(aVertex[l_aList[0]] as Vertex).aFaces.push( lId );
					
					if( (aVertex[l_aList[1]] as Vertex).aFaces.indexOf( lId ) == 0 )
						(aVertex[l_aList[1]] as Vertex).aFaces.push( lId );
					
					if( (aVertex[l_aList[2]] as Vertex).aFaces.indexOf( lId ) == 0 )
						(aVertex[l_aList[2]] as Vertex).aFaces.push( lId );
						
					aVertex[l_aList[0]].nbFaces++;
					aVertex[l_aList[1]].nbFaces++;
					aVertex[l_aList[2]].nbFaces++;
				}
				
				for( lId = 0; lId < aVertexNormals.length; lId++ )
				{
					var l_oVertex:Vertex = aVertex[ lId ];
					if( l_oVertex.nbFaces ) Vertex( aVertexNormals[ lId ] ).scale( 1 / l_oVertex.nbFaces );
				}
			}
		}
				
		/**
		* Returns a clone of this Geometry3D.
		* 	
		* <p>NOTE: Because polygons also stores instance-specific data like Appearance
		* on the Geometry level, we are considering it only as a set of connections between points, 
		* so only coordinates and normals are copied in the clone process.
		* 
		* @return A copy of this geometry
		*/
		public function clone():Geometry3D
		{
			var l_result:Geometry3D = new Geometry3D();
			var i:uint = 0, l_oVertex:Vertex;
			// Points
			for each( l_oVertex in aVertex )
			{
				l_result.aVertex[i] = l_oVertex.clone();
				i++;
			}
			
			// Faces
			i = 0;
			for each( var a:Array in aFacesVertexID )
			{
				l_result.aFacesVertexID[i] = a.concat();
				i++;
			}
			
			// Normals
			i = 0;
			for each( l_oVertex in aFacesNormals )
			{
				l_result.aFacesNormals[i] = l_oVertex.clone();
				i++;
			}
			
			// Normals
			i = 0;
			for each( l_oVertex in aVertexNormals )
			{
				l_result.aVertexNormals[i] = l_oVertex.clone();
				i++;
			}
			
			// UVs face
			i = 0;
			for each( var b:Array in aFacesUVCoordsID )
			{
				l_result.aFacesUVCoordsID[i] = b.concat();
				i++;
			}
			
			// UVs coords
			i = 0;
			for each( var u:UVCoord in aUVCoords )
			{
				l_result.aUVCoords[i] = u.clone();
				i++;
			}
			
			i=0;
			for each( var l_oEdge:Edge3D in aEdges )
			{
				l_result.aEdges[i] = l_oEdge.clone();
				i++;
			}
			
			i = 0;
			for each( var l_oEdges:Array in aFaceEdges )
			{
				l_result.aFaceEdges[i] = l_oEdges.concat();
				i++;
			}
			
			return l_result;
		}
		
		
		/**
		 * Dispose all the geometry ressources.
		 * Arrays data is removed, arrays are set to null value to make garbage collection possible
		 */
		public function dispose():void
		{
			var a:Array, l_oVertex:Vertex;
			var l:int;
			var u:UVCoord;
			// Points
			l = aVertex.length;
			while( l_oVertex =  aVertex[--l] )
			{
				l_oVertex.aFaces = null;
				l_oVertex = null;
			}
			aVertex = null;
			// Faces
			l = aFacesVertexID.length;
			while( a =  aFacesVertexID[--l] )
			{
				a = null;
			}
			aFacesVertexID = null;
			// Normals
			l = aFacesNormals.length;
			while( l_oVertex =  aFacesNormals[--l] )
			{
				l_oVertex.aFaces = null;
				l_oVertex = null;
			}
			aFacesNormals = null;
			// Normals
			l = aVertexNormals.length;
			while( l_oVertex =  aVertexNormals[--l] )
			{
				l_oVertex.aFaces = null;
				l_oVertex = null;
			}
			aVertexNormals = null;
			// UVs face
			l = aFacesUVCoordsID.length;
			while( a =  aFacesUVCoordsID[--l] )
			{
				a = null;
			}
			aFacesUVCoordsID = null;
			// UVs coords
			l = aUVCoords.length;
			while( u =  aUVCoords[--l] )
			{
				u = null;
			}	
			aUVCoords = null;	
			// Edges
			for( var l_sEdgeName:String in EDGES_DICO )
			{
				delete EDGES_DICO[l_sEdgeName];
			}	
			EDGES_DICO = null;
		}
		
		/**
		 * Returns a string representation of this geometry.
		 *
		 * <p>The string contins the lengths of the arrays of data defining this geometry.</p>
		 * <p>[<b>ToDo</b>: Decide if this is the best representation ]</p>
		 *
		 * @return The string representation
		 */
		public function toString():String
		{
			return "[Geometry: " + 	aFacesVertexID.length + " faces, " + 
					aVertex.length + " points, " + 
					aFacesNormals.length + " normals, " +
					aUVCoords.length + " uv coords]";
		}
		
		/*public function debug():void
		{
			trace("Faces: [" + faces.length + "] " + faces);
			trace("Points: [" + points.length + "] " + points);
			trace("Unique directions: [" + uniqueDirections.length + "] " + uniqueDirections);
			trace("Normals: [" + normals.length + "] " + normals);
			trace("UVs: [" + uv.length + "] " + uv);
		}*/
		
	}
}
