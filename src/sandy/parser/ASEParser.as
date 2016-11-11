
package sandy.parser
{
	import flash.events.Event;
	import flash.utils.unescapeMultiByte;

	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;

	/**
	 * Transforms an ASE file into Sandy geometries.
	 * <p>Creates a Group as rootnode which appends all geometries it finds.
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		1.0
	 * @version		3.1
	 * @date 		26.07.2007
	 *
	 * @example To parse an ASE file at runtime:
	 *
	 * <listing version="3.1">
	 *     var parser:IParser = Parser.create( "/path/to/my/asefile.ase", Parser.ASE );
	 * </listing>
	 *
	 * @example To parse an embedded ASE object:
	 *
	 * <listing version="3.1">
	 *     [Embed( source="/path/to/my/asefile.ase", mimeType="application/octet-stream" )]
	 *     private var MyASE:Class;
	 *
	 *     ...
	 *
	 *     var parser:IParser = Parser.create( new MyASE(), Parser.ASE );
	 * </listing>
	 */

	public final class ASEParser extends AParser implements IParser
	{
		/**
		 * Creates a new ASEParser instance
		 *
		 * @param p_sUrl		This can be either a String containing an URL or a
		 * 						an embedded object
		 * @param p_nScale		The scale factor
		 * @param p_sTextureExtension	Overrides texture extension. You might want to use it for models that
		 * specify PSD or TGA textures.
		 */
		public function ASEParser( p_sUrl:*, p_nScale:Number = 1, p_sTextureExtension:String = null )
		{
			super( p_sUrl, p_nScale, p_sTextureExtension );
		}

		/**
		 * @private
		 * Starts the parsing process
		 *
		 * @param e				The Event object
		 */
		protected override function parseData( e:Event=null ):void
		{
			super.parseData( e );
			// --
			var lines:Array = unescapeMultiByte( String( m_oFile ) ).split( '\n' );
			var lineLength:uint = lines.length;
			var id:uint;
			// -- local vars
			var line:String;
			var content:String;
			var chunk:String;
			var l_oAppearance:Appearance = null;
			var l_oGeometry:Geometry3D = null;
			var l_oShape:Shape3D = null;
			var l_sLastNodeName:String = null;
			var l_aPolySubmatId:Array;
			var l_aPolySubmatIds:Array = [];
			// --
			var recToGet2:Array = [];
			var m_textureNames:Array = [];
			var m_subMaterials:Array = [];
			var currentMatId:int;
			// --
			while( lines.length )
			{
				var event:ParserEvent = new ParserEvent( ParserEvent.PARSING );
				event.percent = ( 100 - ( lines.length * 100 / lineLength ) );
				dispatchEvent( event );
				//-- parsing
				line = String(lines.shift());
				//-- clear white space from begin
				line = line.substr( line.indexOf( '*' ) + 1 );
				//-- clear closing brackets
				if( line.indexOf( '}' ) >= 0 ) line = '';
				//-- get chunk description
				chunk = line.substr( 0, line.indexOf( ' ' ) );
				//--
				switch( chunk )
				{
					case 'MATERIAL':
					{
						// get material ID from "MATERIAL 0 {"
						var matIdReg:RegExp = /MATERIAL[^\d]+(\d+)[^\d]+/
						currentMatId = parseInt (line.replace (matIdReg, "$1"));

						// start submaterials list
						m_subMaterials [currentMatId] = []; break;
					}
					case 'SUBMATERIAL':
					{
						// found submaterial, push empty string to the list
						m_subMaterials [currentMatId].push (""); break;
					}
					case 'BITMAP':
					{
						// ideally, we need to load these only from *MAP_DIFFUSE { ... }

						// *BITMAP "f:\models\mapobjects\kt_barge\kt_barge_grey.tga"
						// *BITMAP "F:\my_stuff\3d\studentCap\workfiles\textures\studentCap_color_002.psd"
						var texReg:RegExp = /BITMAP.+[\"\\]([^\"\\]+)\"\s*/
						if ((m_subMaterials [currentMatId].length > 0) && (m_subMaterials [currentMatId] [m_subMaterials [currentMatId].length -1] == ""))
						{
							// this is submaterial
							m_subMaterials [currentMatId] [m_subMaterials [currentMatId].length -1] = line.replace (texReg, "$1");
						}
						else
						{
							// material has no submaterials
							m_textureNames [currentMatId] = line.replace (texReg, "$1");
						}
						break;
					}

					case 'GEOMOBJECT':
					{
						// we need to catch this before NODE_NAME
						if( l_oGeometry )
						{
							l_oShape = new Shape3D( l_sLastNodeName, l_oGeometry, m_oStandardAppearance );
							m_oGroup.addChild( l_oShape ); l_aPolySubmatIds.push (l_aPolySubmatId);
						}
						// -
						l_oGeometry = new Geometry3D();
						break;
					}
					case 'NODE_NAME':
					{
						// TODO: NODE_NAME is repeated in NODE_TM - find out why (if there can be multiple nodes, this code will break :)
						l_sLastNodeName = line.split( '"' )[1];
						break;
					}
/*					case 'MESH_NUMFACES':
					{
						//var num: Number =  Number(line.split( ' ' )[1]);
						break;
					}*/
					case 'MESH_VERTEX_LIST':
					{
						while( ( content = (lines.shift() as String )).indexOf( '}' ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );
							var vertexReg:RegExp = /MESH_VERTEX\s*(\d+)\s*([\d-\.]+)\s*([\d-\.]+)\s*([\d-\.]+)/
							id = uint(content.replace(vertexReg, "$1"));
							var v1:Number = Number(content.replace(vertexReg, "$2"));
							var v2:Number = Number(content.replace(vertexReg, "$4"));
							var v3:Number = Number(content.replace(vertexReg, "$3"));

							l_oGeometry.setVertex(id, v1*m_nScale, v2*m_nScale, v3*m_nScale );
						}
						break;
					}
					case 'MESH_FACE_LIST':
					{
						l_aPolySubmatId = [];
						while( ( content = (lines.shift() as String )).indexOf( '}'  ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );
							//"MESH_FACE    0:    A:    777 B:    221 C:    122 AB:    1 BC:    1 CA:    1 *MESH_SMOOTHING 1   *MESH_MTLID 0"
							//"MESH_FACE   10: A:  325 B:  155 C:  327	 *MESH_SMOOTHING 0 	*MESH_MTLID 0"
							var faceReg:RegExp = /MESH_FACE\s*(\d+):\s*A:\s*(\d+)\s*B:\s*(\d+)\s*C:\s*(\d+)[^\d]+.*/
							id = uint(content.replace(faceReg, "$1"));
							var p1:uint = uint(content.replace(faceReg, "$2"));
							var p2:uint = uint(content.replace(faceReg, "$3"));
							var p3:uint = uint(content.replace(faceReg, "$4"));

							// additionally parse submaterial IDs
							// thanks darknet for bringing this to attention
							var MatReg:RegExp = /.*\*MESH_MTLID\s*(\d+)[^\d]*/
							l_aPolySubmatId [id] = parseInt(content.replace(MatReg, "$1"));

							l_oGeometry.setFaceVertexIds(id, p1, p2, p3 );
						}
						break;
					}
					case 'MESH_TVERTLIST':
					{
						while( ( content = (lines.shift() as String )).indexOf( '}' ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );
							vertexReg = /MESH_TVERT\s*(\d+)\s*([\d-.]+)\s*([\d-\.]+)\s*([\d-\.]+)/
							id = uint(content.replace(vertexReg, "$1"));
							v1 = Number(content.replace(vertexReg, "$2"));
							v2 = Number(content.replace(vertexReg, "$3"));
							//var v3 = (content.replace(vertexReg, "$2"));
							l_oGeometry.setUVCoords(id, v1, 1-v2 );
						}
						break;
					}
					//TODO: there are ASE file without MESH_TFACELIST, what then
					case 'MESH_TFACELIST':
					{
						while( ( content = (lines.shift() as String)).indexOf( '}' ) < 0 )
						{
							content = content.substr( content.indexOf( '*' ) + 1 );
							faceReg = /MESH_TFACE\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)/
							id = uint(content.replace(faceReg, "$1"));
							var f1:uint = uint(content.replace(faceReg, "$2"));
							var f2:uint = uint(content.replace(faceReg, "$3"));
							var f3:uint = uint(content.replace(faceReg, "$4"));
							l_oGeometry.setFaceUVCoordsIds( id, f1, f2, f3 );
						}
						break;
					}

					case 'MATERIAL_REF':
					{
						// *MATERIAL_REF 0
						var refReg:RegExp = /MATERIAL_REF\s+(\d+)\s*/
						recToGet2.push (parseInt (line.replace (refReg, "$1")));
						
						break;
					}
				}
			}
			// --
			l_oShape = new Shape3D( l_sLastNodeName, l_oGeometry, m_oStandardAppearance );
			m_oGroup.addChild( l_oShape ); l_aPolySubmatIds.push (l_aPolySubmatId);

			for(var i:int = 0; i<m_oGroup.children.length; i++)
			{
				var s:Shape3D = Shape3D (m_oGroup.children[i]);
				currentMatId = recToGet2 [i];
				// have any submaterials?
				if( m_subMaterials [currentMatId] )
				{
					if (m_subMaterials [currentMatId].length > 0)
					{
						l_aPolySubmatId = l_aPolySubmatIds [i];
						for (var j:int = 0; j < s.aPolygons.length; j++)
						{
							//trace ("shape " + i + " mat " + currentMatId + " poly " + j +
							// " submat id " + l_aPolySubmatId [j] + " bitmap " + m_subMaterials [currentMatId] [l_aPolySubmatId [j]]);
							applyTextureToShape (s.aPolygons [j],
								m_subMaterials [currentMatId] [l_aPolySubmatId [j]] );
						}
					}
				}
				else
				{
					applyTextureToShape (s, m_textureNames [currentMatId]);
				}
			}

			// -- Parsing is finished
			dispatchInitEvent ();
		}
	}// -- end AseParser
}
