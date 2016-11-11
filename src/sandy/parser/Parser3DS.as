
package sandy.parser
{
	import sandy.core.data.Matrix4;
	import sandy.core.data.Point3D;
	import sandy.core.data.Quaternion;
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;
	
	import flash.events.*;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	import flash.utils.Endian;	

	/**
	 * Transforms a 3DS file into Sandy geometries.
	 * <p>Creates a Group as rootnode which appends all geometries it finds.
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		1.0
	 * @version		3.1
	 * @date 		26.07.2007
	 *
	 * @example To parse a 3DS file at runtime:
	 *
	 * <listing version="3.1">
	 *     var parser:IParser = Parser.create( "/path/to/my/3dsfile.3ds", Parser.MAX_3DS );
	 * </listing>
	 *
	 */

	public final class Parser3DS extends AParser implements IParser
	{
		private var _rot_m:Array;
		private var currentObjectName:String;
		private var data:ByteArray;
		private var _animation:Array;
		private var startFrame:uint;
		private var endFrame:uint;
		private var lastRotation:Quaternion;

		private var textureFileNames:Array;
		private var currentMaterialName:String;
		private var currentMeshMaterialName:String;
		private var currentMeshMaterialsMap:Array;

		/**
		 * Creates a new Parser3DS instance.
		 *
		 * @param p_sUrl		A String pointing to the location of the 3DS file
		 * @param p_nScale		The scale factor
		 * @param p_sTextureExtension	Overrides texture extension. You might want to use it for models that
		 * specify BMP textures.
		 */
		public function Parser3DS( p_sUrl:String, p_nScale:Number = 1, p_sTextureExtension:String = null )
		{
			super( p_sUrl, p_nScale, p_sTextureExtension );
			m_sDataFormat = URLLoaderDataFormat.BINARY; textureFileNames = [];
		}

		/**
		 * @private
		 *
		 * Starts the parsing process
		 * @param e				The Event object
		 */
	   protected override function parseData( e:Event=null ):void
		{
			super.parseData( e );
			// --
			currentMeshMaterialsMap = [];
			data = (m_oFileLoader.data as ByteArray );
			data.endian = Endian.LITTLE_ENDIAN;
			// --
			var currentObjectName:String = null;
			var _rot_m:Array = new Array();
			var ad:Array = new Array();
			var pi180:Number = 180 / Math.PI;
			// --
			var l_oAppearance:Appearance = m_oStandardAppearance;
			var l_oGeometry:Geometry3D = null;
			var l_oShape:Shape3D = null;
			var l_oMatrix:Matrix4;
			// --
			var x:Number, y:Number, z:Number;
			var l_qty:uint;
			// --
			while( data.bytesAvailable > 0 )
			{
				var id:uint = data.readUnsignedShort();
				//trace("chunk id: " + id);
				//trace("bytesAvailable: " + data.bytesAvailable);
				var l_chunk_length:uint = data.readUnsignedInt();
				//trace("chunk length: " + l_chunk_length);
				//trace("bytesAvailable: " + data.bytesAvailable);

				switch( id )
				{
					case Parser3DSChunkTypes.MAIN3DS:

						//trace("0x4d4d MAIN3DS");
				        break;

				    case Parser3DSChunkTypes.EDIT3DS:

				    	//trace("0x3d3d EDIT3DS");
				        break;

				   	case Parser3DSChunkTypes.KEYF3DS:
				   		//trace("0xB000 KEYF3DS");
				   		break;

					case Parser3DSChunkTypes.EDIT_MATERIAL:
						// wait for Parser3DSChunkTypes.MAT_TEXMAP
						break;
					case Parser3DSChunkTypes.MAT_TEXMAP:
						// wait for Parser3DSChunkTypes.MAT_TEXFLNM
						break;
					case Parser3DSChunkTypes.MAT_NAME:
						// material name
						currentMaterialName = readString ();
//trace ("currentMaterialName <- " + currentMaterialName);
						break;
					case Parser3DSChunkTypes.MAT_TEXFLNM:
						// texture file name
						textureFileNames [currentMaterialName] = readString ();
//trace ("texture (currentMaterialName = " + currentMaterialName + ") " + textureFileNames [currentMaterialName]);
						break;

					case Parser3DSChunkTypes.TRI_MATERIAL:
						// what material to use
						currentMeshMaterialName = readString ();
//trace ("currentMeshMaterialName <- " + currentMeshMaterialName);
						// this chunk has face list
						var faceList:Array = [ currentMeshMaterialName ];
						var numFaces:int = data.readUnsignedShort();
						for (var f:int = 0; f < numFaces; f++) {
							faceList.push (data.readUnsignedShort());
						}
						currentMeshMaterialsMap.push (faceList);

						break;

				    case Parser3DSChunkTypes.EDIT_OBJECT:

				    	//trace("0x4000");
				    	if( l_oGeometry )
						{
					        l_oShape = new Shape3D( currentObjectName, l_oGeometry, l_oAppearance );
					        if( l_oMatrix ) _applyMatrixToShape( l_oShape, l_oMatrix );
							m_oGroup.addChild( l_oShape );
						// untested, may not work... but should
//trace ("making shape (1), currentMeshMaterialName = " + currentMeshMaterialName);
						if (currentMeshMaterialsMap.length < 2) {
							// 1 or less materials
							if (textureFileNames [currentMeshMaterialName])
								applyTextureToShape (l_oShape, textureFileNames [currentMeshMaterialName]);
						} else {
							// multiple materials per shape
							for each (var faceList1:Array in currentMeshMaterialsMap) {
								if (textureFileNames [faceList1 [0]]) {
									for (var p1:int = 1; p1 < faceList1.length; p1++) {
										applyTextureToShape (l_oShape.aPolygons [faceList1 [p1]], textureFileNames [faceList1 [0]]);
									}
								}
							}
						}
						currentMeshMaterialsMap = [];
					    }
					    // --
					    var str:String = readString();
					    currentObjectName = str;
					    l_oGeometry = new Geometry3D();
					    l_oAppearance = l_oAppearance;
			         	break;

					case Parser3DSChunkTypes.OBJ_TRIMESH:

						//trace("0x4100");
	         			break;

	         		 case Parser3DSChunkTypes.TRI_VERTEXL:        //vertices

	         		 	//trace("0x4110 vertices");
			            l_qty = data.readUnsignedShort();
			            for (var i:int=0; i<l_qty; i++)
			            {
			            	x = data.readFloat();
			            	z = data.readFloat();
			            	y = data.readFloat();
			            	l_oGeometry.setVertex( i, x*m_nScale, y*m_nScale, z*m_nScale );
			            }
			            break;

			         case Parser3DSChunkTypes.TRI_TEXCOORD:		// texture coords

				      //  trace("0x4140  texture coords");
			            l_qty = data.readUnsignedShort();
			            for (i=0; i<l_qty; i++)
			            {
			            	var u:Number = data.readFloat();
			            	var v:Number = data.readFloat();
			            	l_oGeometry.setUVCoords( i, u, 1-v );
			            }
			         	break;

			         case Parser3DSChunkTypes.TRI_FACEL1:		// faces

						//trace("0x4120  faces");
			            l_qty = data.readUnsignedShort();
			            for (i = 0; i<l_qty; i++)
			            {
			            	var vertex_a:int = data.readUnsignedShort();
			            	var vertex_b:int = data.readUnsignedShort();
			            	var vertex_c:int = data.readUnsignedShort();

					// should we ignore invisible faces?
			            	var visible:Boolean = data.readUnsignedShort() as Boolean;

			            	l_oGeometry.setFaceVertexIds(i, vertex_a, vertex_b, vertex_c );
			            	l_oGeometry.setFaceUVCoordsIds(i, vertex_a, vertex_b, vertex_c );
			            }
			         	break;

			         case Parser3DSChunkTypes.TRI_LOCAL:		//ParseLocalCoordinateSystem
			         	//trace("0x4160 TRI_LOCAL");

			         	var localX:Point3D = readPoint3D();
			         	var localZ:Point3D = readPoint3D();
			         	var localY:Point3D = readPoint3D();
			         	var origin:Point3D = readPoint3D();

			         	/*
			         	l_oMatrix = new Matrix4
			         	(
			         		localX.x, localZ.x, localY.x, origin.x,
			         		localX.z, localZ.z, localY.z, origin.z,
			         		localX.y, localZ.y, localX.y, origin.y,
			         		0, 0, 0, 1
			         	);
			         	*/

			         	/*
			         	l_oMatrix = new Matrix4
			         	(
			         		localX.x, localX.z, localX.y, origin.x,
			         		localY.x, localY.z, localY.y, origin.z,
			         		localZ.x, localZ.z, localZ.y, origin.y,
			         		0, 0, 0, 1
			         	);
			         	*/

			         	/*
			         	l_oMatrix = new Matrix4
			         	(
			         		1, 0, 0, origin.x,
			         		0, 1, 0, origin.y,
			         		0, 0, 1, origin.z,
			         		0, 0, 0, 1
			         	);*/



			         	l_oMatrix = new Matrix4(	localX.x, localX.y, localX.z, origin.x,
			         								localY.x, localY.y, localY.z, origin.y,
			         								localZ.x, localZ.y, localZ.z, origin.z,
									         		0,0,0,1 );



						//if( l_oShape )   _applyMatrixToShape( l_oShape, l_oMatrix );

						//l_oShape.setPosition(origin.x, -origin.y, origin.z );
						//l_oShape.transform.matrix = init_m;
						//l_oShape.setPosition( origin.x, -origin.y, origin.z );
						/* _rot_m[currentObjectName] = init_m;

			         	var originVertex:Vertex = origin.toVertex();
			         	var len:int = o.aPoints.length;
			         	for (i = 0; i<l_qty; i++)
			            {
			            	o.aPoints[i] = VertexMath.sub(  o.aPoints[i], originVertex );
			            }
			            */
			         	break;

			         case Parser3DSChunkTypes.OBJ_LIGHT:		//Lights
			         	//trace("0x4600 Light");
			            //var light:Point3D = readPoint3D();
			         	break;

			         case Parser3DSChunkTypes.LIT_SPOT:			//Light Spot
			         	/*
			         	var tx:Number = data.readFloat();
			            var ty:Number = data.readFloat();
			            var tz:Number = data.readFloat();
			            var hotspot:Number = data.readFloat();
			            var falloff:Number = data.readFloat();
			            */
			         	break;

			         case Parser3DSChunkTypes.COL_TRU:			//RGB color
			         	/*
			         	var r:Number = data.readFloat();
			            y = data.readFloat();
			            z = data.readFloat();
			            l_oAppearance.frontMaterial = new ColorMaterial( ColorMath.rgb2hex( r, y, z ) );
			            */
			         	break;

			         case Parser3DSChunkTypes.COL_RGB:			//RGB color
			         	/*
			         	x = data.readByte();
			            y = data.readByte();
			            z = data.readByte();
			            l_oAppearance.frontMaterial = new ColorMaterial( ColorMath.rgb2hex( x, y, z ) );
			            */
			         	break;

			         case Parser3DSChunkTypes.OBJ_CAMERA:		//Cameras
			         	//trace("0x4700 Cameras");
			         	/*
			         	x = data.readFloat();
			            y = data.readFloat();
			            z = data.readFloat();

			            tx = data.readFloat();
			            ty = data.readFloat();
			            tz = data.readFloat();

			            var angle:Number = data.readFloat();
			            var fov:Number = data.readFloat();
			            */
			         	break;

			         // animation
			         case Parser3DSChunkTypes.KEYF_FRAMES:
			         	//trace("0xB008 KEYF_FRAMES");
			         	//startFrame = data.readInt();
			         	//endFrame = data.readInt();
			         	break;

			         case Parser3DSChunkTypes.KEYF_OBJDES:
			         	//trace("0xB002 KEYF_OBJDES");
			         	//startFrame = data.readInt();
			         	//endFrame = data.readInt();
			         	break;

			         case Parser3DSChunkTypes.NODE_ID:
			         	//trace("0xB030 NODE_ID");

			         	//var node_id:uint = data.readUnsignedShort();
			         	/*
			         	var keyframer:Keyframer = new Keyframer();

			         	keyframer.startFrame = startFrame;
			         	keyframer.endFrame = endFrame;

			         	lastRotation = null;
			         	//ad.push(keyframer.);
			         	*/
			         	break;

			         case Parser3DSChunkTypes.NODE_HDR:
			         	//trace("0xB010 NODE_HDR");
			         	/*
			         	var name:String = readString();
			         	var flag1:uint = data.readUnsignedShort();
			         	var flag2:uint = data.readUnsignedShort();
			         	var parent:int = data.readShort();

			         	keyframer.name = name;

			         	_animation[name] = keyframer;

			         	keyframer.flag1 = flag1;
			         	keyframer.flag2 = flag2;
			         	keyframer.parent = parent;
			         	//var endFrame:uint = data.readInt();
			         	*/
			         	break;

			         case Parser3DSChunkTypes.PIVOT:
			         	//trace("0xB013 PIVOTR");
			         	/*
			         	x = data.readFloat();
			            y = data.readFloat();
			            z = data.readFloat();
			            */
			            //keyframer.pivot = new Point3D(x,z,y);
			            //trace("PIVOT: " + keyframer.pivot);
			         	//var endFrame:uint = data.readInt();
			         	break;

			         case Parser3DSChunkTypes.POS_TRACK_TAG:
			         	//trace("0xB020 POS_TRACK_TAG");
			         	/*
			         	var flag1:uint = data.readUnsignedShort();
			         	for (var j:int=0; j<8; j++)
			         	{
			         		var unknown:Number = data.readByte();
			         	}
			            var keys:uint = data.readInt();
			            */
			            /*
			           	var frame0pos:Point3D;
			            keyframer.track_data.pos_track_keys = keys;

			            for (j = 0; j<keys; j++)
			         	{
			         		var posObj:Object = keyframer.getPositionObject();

			         		var key:uint = data.readInt();
			            	var acc:int = data.readShort();
				            //position
				            var rx:Number = data.readFloat();
				            var ry:Number = data.readFloat();
				            var rz:Number = data.readFloat();

				            posObj.key = key;
				            posObj.acc = acc;

				            posObj.position = new Point3D(rx,rz,ry);

//							trace("keyframer ["+keyframer.name+"] pos => " + posObj.position);
				         }
				         */
			         	break;

			         case Parser3DSChunkTypes.ROT_TRACK_TAG:
			         	//trace("0xB021 ROT_TRACK_TAG");
			         	/*
			         	flag1 = data.readUnsignedShort();
			         	for (j = 0; j<8; j++)
			         	{
			         		unknown = data.readByte();
			         	}
			            keys = data.readInt();
			            */
			            /*
			            keyframer.track_data.rot_track_keys = keys;
			            //keyframer.track_data.rot_track_data = new Array();

			            for (j = 0; j<keys; j++)
			         	{
			         		var rotObj:Object = keyframer.getRotationObject();
			         		key = data.readInt();
			            	acc = data.readShort();

				            var AnimAngle:Number = data.readFloat();
				            //axis
				            rx = data.readFloat();
				            ry = data.readFloat();
				            rz = data.readFloat();

				            rotObj.key = key;
				            rotObj.acc = acc;

				            var rotation:Quaternion = QuaternionMath.setAxisAngle(new Point3D(rx,-rz,-ry), AnimAngle);
//				            trace("keyframer ["+keyframer.name+"] lastRotation1 => " + rotation);
				            if (lastRotation != null)
				            {
				            	lastRotation = QuaternionMath.multiply(lastRotation, rotation);

				            }
				            else
				            {
				            	lastRotation = QuaternionMath.setByMatrix(_rot_m[keyframer.name]);
				            	lastRotation = QuaternionMath.multiply(lastRotation, rotation);
				            	//lastRotation = QuaternionMath.clone(rotation);
				            }
				            if (key > 60)
				            {
								trace("keyframer ["+keyframer.name+"] lastRotation2["+key+"] => " + QuaternionMath.toEuler(lastRotation));
				            }
							rotObj.axis = lastRotation;
				        }
				        */
			         	break;

			         case Parser3DSChunkTypes.SCL_TRACK_TAG:
			         	//trace("0xB022 SCL_TRACK_TAG");
			         	/*
			         	flag1 = data.readUnsignedShort();
			         	for (j=0; j<8; j++)
			         	{
			         		unknown = data.readByte();
			         	}
			            keys = data.readInt();
			            */
			            /*
			            keyframer.track_data.scl_track_keys = keys;

			            // ATTENTION:
			            // The rotation is relative to last frame to avoid the gimbal lock problem.
			            //So if you want the "global" rotation, you need to concatenate them with quaterinion multiplication.
			            for (j = 0; j<keys; j++)
			         	{
			         		var sclObj:Object = keyframer.getScaleObject();

			         		key = data.readInt();
				            acc = data.readShort();
				            //size
				            rx = data.readFloat();
				            ry = data.readFloat();
				            rz = data.readFloat();

				            sclObj.key = key;
				            sclObj.acc = acc;
				            sclObj.size = new Point3D(rx,rz,ry);

							//trace("keyframer ["+keyframer.name+"] scl => " + sclObj.size);
				        }
				        */
			         	break;
			         default:
				        //trace("default");
			            data.position += l_chunk_length-6;
					// if this points backwards, we have some parsing error :(
					// if we're lucky, some valid geometry may be already parsed
					if (l_chunk_length-6 < 0) {
						data.position += data.bytesAvailable;
						trace ("Parser3DS.parseData(): WARNING! There were errors parsing your file.");
					}
			 	}
			}
			// occasionally parser creates empty shapes here
			if (l_oGeometry.aFacesVertexID.length > 0) {
				l_oShape = new Shape3D( currentObjectName, l_oGeometry, l_oAppearance);
				if( l_oMatrix ) _applyMatrixToShape( l_oShape, l_oMatrix );
				m_oGroup.addChild( l_oShape );
//trace ("making shape (2), currentMeshMaterialName = " + currentMeshMaterialName);
				if (currentMeshMaterialsMap.length < 2) {
					// 1 or less materials
					if (textureFileNames [currentMeshMaterialName])
						applyTextureToShape (l_oShape, textureFileNames [currentMeshMaterialName]);
				} else {
					// multiple materials per shape
					for each (var faceList2:Array in currentMeshMaterialsMap) {
						if (textureFileNames [faceList2 [0]]) {
							for (var p2:int = 1; p2 < faceList2.length; p2++) {
								applyTextureToShape (l_oShape.aPolygons [faceList2 [p2]], textureFileNames [faceList2 [0]]);
							}
						}
					}
				}
				currentMeshMaterialsMap = [];
			}
			// -- Parsing is finished
			dispatchInitEvent ();
		}

		private function _applyMatrixToShape( p_oShape:Shape3D, p_oMatrix:Matrix4 ):void
		{
			/*
			p_oShape.setBasis(	new Point3D( p_oMatrix.n11, p_oMatrix.n12, p_oMatrix.n13 ),
								new Point3D( p_oMatrix.n21, p_oMatrix.n22, p_oMatrix.n23 ),
								new Point3D( p_oMatrix.n31, p_oMatrix.n32, p_oMatrix.n33 ) );
			p_oShape.setPosition( p_oMatrix.n14, p_oMatrix.n24, p_oMatrix.n34 );
			*/
			p_oShape.matrix = p_oMatrix;
		}

		/**
		 * Reads a Point3D from a ByteArray
		 *
		 * @return	A Point3D containing the x, y, z values
		 */
		private function readPoint3D():Point3D
		{
			var x:Number = data.readFloat();
			var y:Number = data.readFloat();
			var z:Number = data.readFloat();
			return new Point3D(x, z, y);
		}

		/**
		 * Reads a byte from a ByteArray
		 *
		 * @return 	A byte
		 */
		private function readByte():int
		{
			return data.readByte();
		}

		/**
		 * Reads a character (unsigned byte) from a ByteArray
		 *
		 * @return A character
		 */
		private function readChar():uint
		{
			return data.readUnsignedByte();
		}

		/**
		 * Reads an integer from a ByteArray
		 *
		 * @return	An integer
		 */
		private function readInt():uint
		{
 			var temp:uint = readChar();
 			return ( temp | (readChar() << 8));
		}

		/**
		 * Reads a string from a ByteArray
		 *
		 * @return 	A String
		 */
		private function readString():String
		{
 			var name:String = "";
 			var ch:uint;
 			while(ch = readChar())
 			{
 				if (ch == 0)
 				{
 					break;
 				}
 				name += String.fromCharCode(ch);
 			}
 			return name
		}
	}
}