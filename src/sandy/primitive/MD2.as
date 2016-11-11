package sandy.primitive
{
	import sandy.core.data.*;
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;
	import sandy.primitive.Primitive3D;
	import sandy.view.CullingState;
	import sandy.view.Frustum;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;	

	/**
	* MD2 primitive.
	* 
	* @author Philippe Ajoux (philippe.ajoux@gmail.com)
	*/
	public class MD2 extends Shape3D implements Primitive3D
	{
		/**
		* Creates MD2 primitive.
		*
		* @param p_sName Shape instance name.
		* @param data MD2 binary data.
		* @param scale Adjusts model scale.
		*/
		public function MD2 ( p_sName:String, data:ByteArray, scale:Number = 1 )
		{
			m_oBinaryData = data;
			super (p_sName); scaling = scale; geometry = generate (data);
		}

		public override function clone(  p_sName:String="", p_bKeepTransform:Boolean = false ):Shape3D
		{
			var l_oCopy:MD2 = new MD2(p_sName, m_oBinaryData, scaling);
			if( p_bKeepTransform == true ) l_oCopy.matrix = this.matrix;
			l_oCopy.useSingleContainer = this.useSingleContainer;
			l_oCopy.appearance = this.appearance;
			return l_oCopy;			
		}
		
		private var m_oBinaryData:ByteArray;

		/**
		* Generates the geometry for MD2. Sandy never actually calls this method,
		* but we still implement it according to Primitive3D, just in case :)
		*
		* @return The geometry object.
		*/
		public function generate (... arguments):Geometry3D
		{
			var i:int, j:int, char:int;
			var uvs:Array = [];
			var mesh:Geometry3D = new Geometry3D ();

			// okay, let's read out header 1st
			var data:ByteArray = ByteArray (arguments [0]);
			data.endian = Endian.LITTLE_ENDIAN;
			data.position = 0;
			ident = data.readInt();
			version = data.readInt();

			if (ident != 844121161 || version != 8)
				throw new Error("Error loading MD2 file: Not a valid MD2 file/bad version");

			skinwidth = data.readInt();
			skinheight = data.readInt();
			framesize = data.readInt();
			num_skins = data.readInt();
			num_vertices = data.readInt();
			num_st = data.readInt();
			num_tris = data.readInt();
			num_glcmds = data.readInt();
			num_frames = data.readInt();
			offset_skins = data.readInt();
			offset_st = data.readInt();
			offset_tris = data.readInt();
			offset_frames = data.readInt();
			offset_glcmds = data.readInt();
			offset_end = data.readInt();

			// texture name
			data.position = offset_skins;
			texture = "";
			if (num_skins > 0)
			for (i = 0; i < 64; i++)
			{
				char = data.readUnsignedByte ();
				if (char == 0) break; else texture += String.fromCharCode (char);
			}

			// UV coordinates
			data.position = offset_st;
			for (i = 0; i < num_st; i++)
				uvs.push (new UVCoord (data.readShort() / skinwidth, data.readShort() / skinheight ));

			// Faces
			data.position = offset_tris;
			for (i = 0, j = 0; i < num_tris; i++, j+=3)
			{
				var a:int = data.readUnsignedShort();
				var b:int = data.readUnsignedShort();
				var c:int = data.readUnsignedShort();
				var ta:int = data.readUnsignedShort();
				var tb:int = data.readUnsignedShort();
				var tc:int = data.readUnsignedShort();

				// create placeholder vertices (actual coordinates are set later)
				mesh.setVertex (a, 1, 0, 0);
				mesh.setVertex (b, 0, 1, 0);
				mesh.setVertex (c, 0, 0, 1);

				mesh.setUVCoords (j, uvs [ta].u, uvs [ta].v);
				mesh.setUVCoords (j + 1, uvs [tb].u, uvs [tb].v);
				mesh.setUVCoords (j + 2, uvs [tc].u, uvs [tc].v);

				mesh.setFaceVertexIds (i, a, b, c);
				mesh.setFaceUVCoordsIds (i, j, j + 1, j + 2);
			}

			// Frame animation data
			for (i = 0; i < num_frames; i++)
			{
				var sx:Number = data.readFloat();
				var sy:Number = data.readFloat();
				var sz:Number = data.readFloat();
				
				var tx:Number = data.readFloat();
				var ty:Number = data.readFloat();
				var tz:Number = data.readFloat();

				// store frame names as pointers to frame numbers
				var name:String = "", wasNotZero:Boolean = true;
				for (j = 0; j < 16; j++)
				{
					char = data.readUnsignedByte ();
					wasNotZero &&= (char != 0);
					if (wasNotZero)
						name += String.fromCharCode (char);
				}
				frames [name] = i;

				// store vertices for every frame
				var vi:Array = [];
				vertices [i] = vi;
				for (j = 0; j < num_vertices; j++)
				{
					var vec:Point3D = new Point3D ();

					// order of assignment is important here because of data reads...
					vec.x = ((sx * data.readUnsignedByte()) + tx) * scaling;
					vec.z = ((sy * data.readUnsignedByte()) + ty) * scaling;
					vec.y = ((sz * data.readUnsignedByte()) + tz) * scaling;

					vi [j] = vec;

					// ignore "vertex normal index"
					data.readUnsignedByte ();
				}
			}

			// init vertices here so that updateBoundingVolumes() call has valid data to work with
			t_old = -1; t = 0; var vs0:Array = vertices [0];
			for (i = 0; i < num_vertices; i++) {
				var v0:Vertex = Vertex (mesh.aVertex [i]);
				v0.reset (vs0 [i].x, vs0 [i].y, vs0 [i].z);
			}

			return mesh;
		}

		/**
		* Frames map. This maps frame names to frame numbers.
		*/
		public var frames:Array = [];

		/**
		* Frame number. You can tween this value to play MD2 animation.
		*/
		public function get frame ():Number { return t; }

		/**
		* @private (setter)
		*/
		public function set frame (value:Number):void { t = value; changed = true; }

		/**
		 * @inheritDoc
		 */
		override public function cull(p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean):void {
			super.cull (p_oFrustum, p_oViewMatrix, p_bChanged);

			if ((t != t_old) && (culled != CullingState.OUTSIDE) && (appearance != null)) {
				// it does make sense to do this only when we're on display list
				t_old = t;

				// interpolation frames
				var f1:Array = vertices [int (t) % num_frames];
				var f2:Array = vertices [(int (t) + 1) % num_frames];

				// interpolation coef-s
				var c2:Number = t - int (t), c1:Number = 1 - c2;

				// loop through vertices
				for (var i:int = 0; i < num_vertices; i++)
				{
					var v0:Vertex = Vertex (geometry.aVertex [i]);
					var v1:Point3D = Point3D (f1 [i]);
					var v2:Point3D = Point3D (f2 [i]);

					// interpolate
					v0.x = v1.x * c1 + v2.x * c2; v0.wx = v0.x;
					v0.y = v1.y * c1 + v2.y * c2; v0.wy = v0.y;
					v0.z = v1.z * c1 + v2.z * c2; v0.wz = v0.z;
				}

				// update face normals, if not animated all the time
				if (!animated) for each (var l_oPoly:Polygon in aPolygons) l_oPoly.updateNormal ();
			}
		}

		/**
		* Appends frame copy to animation.
		* You can use this to rearrange an animation at runtime, create transitions, etc.
		*
		* @return number of created frame.
		*/
		public function appendFrameCopy (sourceFrame:int):int
		{
			var f:Array = vertices [sourceFrame] as Array;
			if (f == null) {
				return -1;
			} else {
				num_frames++;
				return vertices.push (f.slice ()) -1;
			}
		}

		/**
		* Replaces specified frame with other key or interpolated frame.
		*/
		public function replaceFrame (destFrame:int, sourceFrame:Number):void
		{
			var f0:Array = [];

			// interpolation frames
			var f1:Array = vertices [int (sourceFrame) % num_frames];
			var f2:Array = vertices [(int (sourceFrame) + 1) % num_frames];

			// interpolation coef-s
			var c2:Number = sourceFrame - int (sourceFrame), c1:Number = 1 - c2;

			// loop through vertices
			for (var i:int = 0; i < num_vertices; i++)
			{
				var v0:Point3D = new Point3D;
				var v1:Point3D = Point3D (f1 [i]);
				var v2:Point3D = Point3D (f2 [i]);

				// interpolate
				v0.x = v1.x * c1 + v2.x * c2;
				v0.y = v1.y * c1 + v2.y * c2;
				v0.z = v1.z * c1 + v2.z * c2;

				// save
				f0 [i] = v0;
			}

			vertices [destFrame] = f0;
			num_frames = vertices.length;
		}

		// animation "time" (frame number)
		private var t:Number, t_old:Number;

		// vertices list for every frame
		private var vertices:Array = [];

		// original Philippe vars
		private var ident:int;
		private var version:int;
		private var skinwidth:int;
		private var skinheight:int;
		private var framesize:int;
		private var num_skins:int;
		private var num_vertices:int;
		private var num_st:int;
		private var num_tris:int;
		private var num_glcmds:int;
		private var num_frames:int;
		private var offset_skins:int;
		private var offset_st:int;
		private var offset_tris:int;
		private var offset_frames:int;
		private var offset_glcmds:int;
		private var offset_end:int;
		private var scaling:Number;

		private var texture:String;

		/**
		 * Number of frames in MD2.
		 */
		public function get nFrames():Number { return num_frames }

		/**
		* Texture file name.
		*/
		public function get textureFileName():String { return texture; }
	}
}