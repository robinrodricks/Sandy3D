
package sandy.util
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;

	import sandy.core.scenegraph.Shape3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Polygon;
	import sandy.core.data.Point3D;
	import sandy.core.data.Vertex;
	import sandy.core.data.UVCoord;
	import sandy.core.Scene3D;

	/**
	 * Utility class for Bitmap calculations.
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public class BitmapUtil
	{
		/**
		 * Converts a sprite to a bitmap respecting the sprite position.
		 *
		 * <p>The simple BitmapData.draw method doesn't take care of the negative part of the sprite during the draw.<br />
		 * This method does.</p>
		 *
		 * @param p_oSprite 		The sprite or other DisplayObject to convert to BitmapData. (DisplayObject allows support for AVM1Movie)
		 * @param p_bTransparent	Whether to allow transparency.
		 * @param p_nColor			Background color (32 bit).
		 *
		 * @return 			The converted bitmap.
		 */
		//public static function movieToBitmap( p_oSprite:Sprite, p_bTransparent:Boolean=true, p_nColor:Number=0x00FF00CC /* a random color, needed by the bitmapData constructor to apply transparency */ ):BitmapData
		public static function movieToBitmap( p_oSprite:DisplayObject, p_bTransparent:Boolean=true, p_nColor:Number=0x00FF00CC /* a random color, needed by the bitmapData constructor to apply transparency */ ):BitmapData
		{
			var bmp:BitmapData;
			// --
			bmp = new BitmapData( p_oSprite.width, p_oSprite.height, p_bTransparent, p_nColor );
			bmp.draw( p_oSprite );
			// --
			return bmp;
		}


		/**
		 * Returns a scaled version of a bitmap.
		 *
		 * <p>The method takes a bitmap as input, and returns a scaled copy.<br/>
		 * The original is not changed.</p>
		 *
		 * @param p_oBitmap	The bitmap to scale.
		 * @param p_nScalex	The x-scale.
		 * @param p_nScaley	The y-scale.
		 *
		 * @return 		The scaled bitmap data.
		 */
		public static function getScaledBitmap( p_oBitmap:BitmapData, p_nScalex:Number, p_nScaley:Number=0 ):BitmapData
		{
			//scaley = (undefined == scaley) ? scalex : scaley;
			var tex:BitmapData = new BitmapData( p_nScalex * p_oBitmap.width, p_nScaley * p_oBitmap.height);
			tex.draw( p_oBitmap, new Matrix( p_nScalex, 0, 0, p_nScaley ) );
			return tex;
		}

		/**
		 * Returns a concatenation of two bitmap matrices.
		 *
		 * <p>[<strong>ToDo</strong>: Explain what matrices are handled here ]</p>
		 *
		 * @param p_oM1	The matrix of the first bitmap.
		 * @param p_oM2	The matrix of the second bitmap.
		 *
		 * @return 	The resulting matrix.
		 */
		public static function concatBitmapMatrix( p_oM1:Object, p_oM2:Object ):Object
		{
			var r:Object = new Object();
			// --
			r.a = p_oM1.a * p_oM2.a;
			r.d = p_oM1.d * p_oM2.d;
			r.b = r.c = 0;
			r.ty = p_oM1.ty * p_oM2.d + p_oM2.ty;
			r.tx = p_oM1.tx * p_oM2.a + p_oM2.tx;
			// --
			if( p_oM1.b != 0 || p_oM1.c !=0 || p_oM2.b != 0 || p_oM2.c != 0 )
			{
				r.a  += p_oM1.b * p_oM2.c;
				r.d  += p_oM1.c * p_oM2.b;
				r.b  += p_oM1.a * p_oM2.b + p_oM1.b * p_oM2.d;
				r.c  += p_oM1.c * p_oM2.a + p_oM1.d * p_oM2.c;
				r.tx += p_oM1.ty * p_oM2.c;
				r.ty += p_oM1.tx * p_oM2.b;
			}
			// --
			return r;
		}

		/**
		 * Creates shape texture map template. This is useful for 3rd party models texturing :)
		 *
		 * @param obj	Shape to rip texture template from.
		 * @param size	Template size (will be size x size pixels).
		 *
		 * @return 		Sprite with texture map template drawn in.
		 */
		public static function ripShapeTexture (obj:Shape3D, size:Number = 256):Sprite {
			var tex:Sprite = new Sprite ();
			tex.graphics.beginFill (0); tex.graphics.drawRect (0, 0, size, size); tex.graphics.endFill ();
			tex.graphics.lineStyle (1, 0xFF0000);
			for each (var p:Polygon in obj.aPolygons) {
				var i:int = p.vertices.length -1;
				tex.graphics.moveTo (size * p.aUVCoord [i].u, size * p.aUVCoord [i].v);
				for (i = 0; i < p.vertices.length; i++)
					tex.graphics.lineTo (size * p.aUVCoord [i].u, size * p.aUVCoord [i].v);
			}
			return tex;
		}

		/**
		 * Computes shape texture map pre-lit with Phong directional light source. Shape must be made of triangles.
		 *
		 * @param obj	Shape for texture to be applied to.
		 * @param light	Scene you are going to render shape in.
		 * @param srcTexture	Source texture.
		 * @param dstTexture	Destination texture.
		 * @param ambient	Ambient reflection factor.
		 * @param diffuse	Diffuse reflection factor.
		 * @param specular	Specular reflection factor.
		 * @param gloss	Specular exponent.
		 *
		 * @return 		Pre-lit texture map.
		 * @example The following CS3 code does sphere per-pixel lighting: <listing version="3.1" >
import sandy.core.Scene3D;
import sandy.core.scenegraph.*;
import sandy.primitive.*;
import sandy.materials.*;
import sandy.util.*;

var tex:BitmapData = new Texture (0, 0); // tex.fillRect (tex.rect, 0xFFFFFF00);

// code from "simplest sandy tutorial"
var scene:Scene3D = new Scene3D( "myScene", this, new Camera3D( 550, 400 ), new Group("root") );
var sphere:Sphere = new Sphere("mySphere");
var mat:BitmapMaterial = new BitmapMaterial( tex.clone () ); mat.smooth = true;
sphere.appearance = new Appearance( mat );
scene.root.addChild( sphere );
scene.render();

// apply lighting
function click (e:*) {
	scene.light.setDirection(stage.stageWidth / 2 - stage.mouseX, stage.mouseY - stage.stageHeight / 2, 100);
	BitmapUtil.burnShapeTexture (sphere, scene, tex, mat.texture, 0.3, 1.0, 2, 15.0);
}

stage.addEventListener ("click", click);
</listing>
		 */
		public static function burnShapeTexture (obj:Shape3D, scene:Scene3D, srcTexture:BitmapData, dstTexture:BitmapData, ambient:Number = 0.3, diffuse:Number = 1.0, specular:Number = 0.0, gloss:Number = 5.0):void {
			var m1:Matrix= new Matrix;
			var vn:Point3D= new Point3D;
			// get light data (code borrowed from ALightAttributes)
			var m_nI:Number = scene.light.getNormalizedPower ();
			var m_oL:Point3D = scene.light.getDirectionPoint3D ();
			var m_oV:Point3D = scene.camera.getPosition ("absolute"); m_oV.scale (-1); m_oV.normalize ();
			var m_oH:Point3D = new Point3D(); m_oH.copy( m_oL ); m_oH.add (m_oV); m_oH.normalize ();
			// FIXME: currently shape needs to be rendered in order to have invModelMatrix calculated
			const invModelMatrix:Matrix4 = obj.invModelMatrix;
			var m_oCurrentL:Point3D = new Point3D (); m_oCurrentL.copy (m_oL); invModelMatrix.transform3x3 (m_oCurrentL);
			var m_oCurrentV:Point3D = new Point3D (); m_oCurrentV.copy (m_oV); invModelMatrix.transform3x3 (m_oCurrentV);
			var m_oCurrentH:Point3D = new Point3D (); m_oCurrentH.copy (m_oH); invModelMatrix.transform3x3 (m_oCurrentH);
			// compute color factors as in ALightAttributes.applyColorToDisplayObject with b = 1 argument
			var c:Number = scene.light.color; if (c < 1) c = 0xFFFFFF;
			var r:Number = (0xFF0000 & c) >> 16;
			var g:Number = (0x00FF00 & c) >> 8;
			var b:Number = (0x0000FF & c);
			const bY:Number = 255 * 1.7321 /*Math.sqrt (3)*/ / Math.sqrt (r * r + g * g + b * b);
			r *= bY; g *= bY; b *= bY;
			// lock destination texture
			dstTexture.lock ();
			// loop through every destination texture pixel
			for (var i:int = 0; i < dstTexture.width;  i++)
			for (var j:int = 0; j < dstTexture.height; j++) {
				var u:Number = i / dstTexture.width;
				var v:Number = j / dstTexture.width;
				// loop through every polygon
				for each (var p:Polygon in obj.aPolygons) {
/*					// see if we're inside
					// http://board.flashkit.com/board/showpost.php?p=4037392&postcount=5
					var crossing:int = 0;
					for (var k:int = 0; k < p.aUVCoord.length; k++) {
						var Vi:UVCoord = UVCoord (p.aUVCoord [k]);
						var Vi1:UVCoord = (k + 1 < p.aUVCoord.length) ? UVCoord (p.aUVCoord [k + 1]) : UVCoord (p.aUVCoord [0]);
						if (((Vi.v <= v) && (Vi1.v > v)) || ((Vi.v > v) && (Vi1.v <= v))) {
							var vt:Number = (v - Vi.v) / (Vi1.v - Vi.v);
							if (u < Vi.u + vt * (Vi1.u - Vi.u)) {
								crossing++;
							}
						}
					}
					if (crossing % 2) {
						// we're inside
					}*/
					var uv0:UVCoord = UVCoord (p.aUVCoord[0]);
					var uv1:UVCoord = UVCoord (p.aUVCoord[1]);
					var uv2:UVCoord = UVCoord (p.aUVCoord[2]);
					m1.a = uv1.u - uv0.u;
					m1.b = uv2.u - uv0.u;
					m1.c = uv1.v - uv0.v;
					m1.d = uv2.v - uv0.v;
					m1.tx = 0; m1.ty = 0;
					m1.invert ();
					var A:Number = m1.a * (u - uv0.u) + m1.b * (v - uv0.v);
					var B:Number = m1.c * (u - uv0.u) + m1.d * (v - uv0.v);
					if ((A >= 0) && (B >= 0) && (A + B <= 1)) {
						// we're inside
						// interpolate normal Point3D from vertex normals
						var vn0:Vertex = Vertex (p.vertexNormals[0]);
						var vn1:Vertex = Vertex (p.vertexNormals[1]);
						var vn2:Vertex = Vertex (p.vertexNormals[2]);
						vn.x = vn0.x + A * (vn1.x - vn0.x) + B * (vn2.x - vn0.x);
						vn.y = vn0.y + A * (vn1.y - vn0.y) + B * (vn2.y - vn0.y);
						vn.z = vn0.z + A * (vn1.z - vn0.z) + B * (vn2.z - vn0.z);
						// calculate lighting as in ALightAttributes.calculate
						var l_n:Number = -1;
						var l_k:Number = l_n * m_oCurrentL.dot (vn); if (l_k < 0) l_k = 0; l_k = ambient + diffuse * l_k;
						if (specular > 0) {
							var l_s:Number = l_n * m_oCurrentH.dot (vn); if (l_s < 0) l_s = 0;
							l_k += specular * Math.pow (l_s, gloss);
						}
						l_k *= m_nI; if (l_k > 1) l_k = 1;
						// set resulting pixel and break out of polygon loop
						dstTexture.setPixel (i, j,
							int (r * l_k) * 65536 +
							int (g * l_k) * 256 +
							int (b * l_k)
						);
						break;
					}
				}
			}
			// unlock destination texture
			dstTexture.unlock ();
			// overlay by source texture
			dstTexture.draw (srcTexture, null, null, "overlay");
		}
	}
}
