
package sandy.materials.attributes
{
	import sandy.core.Scene3D;
	import sandy.core.data.Point3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vertex;
	import sandy.core.scenegraph.Shape3D;
	import sandy.core.scenegraph.Sprite2D;
	import sandy.materials.Material;
	import sandy.math.ColorMath;
	import sandy.math.VertexMath;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;	

	/**
	 * This attribute provides very basic simulation of partially opaque medium.
	 * You can use this attribute to achieve wide range of effects (e.g., fog, Rayleigh scattering, light attached to camera, etc).
	 * 
	 * @author		makc
	 * @version		3.1
	 * @date 		01.12.2007
	 */
	public final class MediumAttributes extends AAttributes
	{
		/**
		 * @private
		 */
		public function set color (p_nColor:uint):void
		{
			_c = p_nColor & 0xFFFFFF;
			_a = (p_nColor - _c) / 0x1000000 / 255.0;
		}
		
		/**
		 * Medium color (32-bit value) at the point given by fadeFrom + fadeTo.
		 * If this value is transparent, color gradient will be extrapolated beyond that point.
		 */
		public function get color ():uint
		{
			return _c + Math.floor (0xFF * _a) * 0x1000000;
		}

		/**
		 * @private
		 */
		public function set fadeTo (p_oW:Point3D):void
		{
			_fadeTo = p_oW;
			_fadeToN2 = p_oW.getNorm (); _fadeToN2 *= _fadeToN2;
		}
		
		/**
		 * Attenuation Point3D. This is the Point3D from transparent point to opaque point.
		 *
		 * @see sandy.core.data.Point3D
		 */
		public function get fadeTo ():Point3D
		{
			return _fadeTo;
		}

		/**
		 * Transparent point in wx, wy and wz coordinates.
		 *
		 * @see sandy.core.data.Point3D
		 */
		public var fadeFrom:Point3D;

		/**
		 * Maximum amount of blur to add. <b>Warning:</b> this feature is very expensive when shape useSingleContainer is false.
		 */
		public var blurAmount:Number;

		/**
		 * Creates a new MediumAttributes object.
		 *
		 * @param p_nColor		Medium color
		 * @param p_oFadeTo		Attenuation Point3D (500 pixels beyond the screen by default).
		 * @param p_oFadeFrom	Transparent point (at the screen by default).
		 * @param p_nBlurAmount	Maximum amount of blur to add
		 *
		 * @see sandy.core.data.Point3D
		 */
		public function MediumAttributes (p_nColor:uint = 0xFFFFFFFF, p_oFadeFrom:Point3D = null, p_oFadeTo:Point3D = null, p_nBlurAmount:Number = 0)
		{
			if (p_oFadeFrom == null)
				p_oFadeFrom = new Point3D (0, 0, 0);
			if (p_oFadeTo == null)
				p_oFadeTo = new Point3D (0, 0, 500);
			// --
			color = p_nColor; fadeTo = p_oFadeTo; fadeFrom = p_oFadeFrom; blurAmount = p_nBlurAmount;
		}

		/**
		 * @private
		 */
		override public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			const l_points:Array = ((p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices);
			const n:int = l_points.length; if (n < 3) return;

			const l_ratios:Array = new Array (n);
			for (var i:int = 0; i < n; i++) l_ratios[i] = ratioFromWorldPoint3D (Vertex(l_points[i]).getCameraPoint3D ());

			const zIndices:Array = l_ratios.sort (Array.NUMERIC | Array.RETURNINDEXEDARRAY);

			const v0: Vertex = l_points[zIndices[0]];
			const v1: Vertex = l_points[zIndices[1]];
			const v2: Vertex = l_points[zIndices[2]];

			const r0: Number = l_ratios[zIndices[0]], ar0:Number = _a * r0;
			const r1: Number = l_ratios[zIndices[1]];
			const r2: Number = l_ratios[zIndices[2]], ar2:Number = _a * r2;

			if (ar2 > 0)
			{
				if (ar0 < 1)
				{
					// gradient matrix
					VertexMath.linearGradientMatrix (v0, v1, v2, r0, r1, r2, _m);

					p_oGraphics.beginGradientFill ("linear", [_c, _c], [ar0, ar2], [0, 0xFF], _m);
				}

				else
				{
					p_oGraphics.beginFill (_c, 1);
				}

				// --
				p_oGraphics.moveTo (l_points[0].sx, l_points[0].sy);
				for each (var l_oVertex:Vertex in l_points)
				{
					p_oGraphics.lineTo (l_oVertex.sx, l_oVertex.sy);
				}
				p_oGraphics.endFill();
			}

			blurDisplayObjectBy (
				p_oPolygon.shape.useSingleContainer ? p_oPolygon.shape.container : p_oPolygon.container,
				prepareBlurAmount (blurAmount * r0)
			);
		}

		/**
		 * @private
		 */
		override public function drawOnSprite( p_oSprite:Sprite2D, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			const l_ratio:Number = Math.max (0, Math.min (1, ratioFromWorldPoint3D (p_oSprite.getPosition ("camera")) * _a));
			const l_color:Object = ColorMath.hex2rgb (_c);
			const l_coltr:ColorTransform = p_oSprite.container.transform.colorTransform;
			// --
			l_coltr.redOffset = Math.round (l_color.r * l_ratio);
			l_coltr.greenOffset = Math.round (l_color.g * l_ratio);
			l_coltr.blueOffset = Math.round (l_color.b * l_ratio);
			l_coltr.redMultiplier = l_coltr.greenMultiplier = l_coltr.blueMultiplier = 1 - l_ratio;
			// --
			p_oSprite.container.transform.colorTransform = l_coltr;

			blurDisplayObjectBy (
				p_oSprite.container,
				prepareBlurAmount (blurAmount * l_ratio)
			);
		}

		// --
		private function ratioFromWorldPoint3D (p_oW:Point3D):Number
		{
			p_oW.sub (fadeFrom); return p_oW.dot (_fadeTo) / _fadeToN2;
		}

		private function prepareBlurAmount (p_nBlurAmount:Number):Number
		{
			// a) constrain blur amount according to filter specs
			// b) quantize blur amount to make filter reuse more effective
			return Math.round (10 * Math.min (255, Math.max (0, p_nBlurAmount)) ) * 0.1;
		}

		private var m_bWasNotBlurred:Boolean = true;
		private function blurDisplayObjectBy (p_oDisplayObject:DisplayObject, p_nBlurAmount:Number):void
		{
			if (m_bWasNotBlurred && (p_nBlurAmount == 0)) return;

			var fs:Array = [], changed:Boolean = false;

			for (var i:int = p_oDisplayObject.filters.length -1; i > -1; i--)
			{
				if (!changed && (p_oDisplayObject.filters[i] is BlurFilter) && (p_oDisplayObject.filters[i].quality == 1))
				{
					var bf:BlurFilter = p_oDisplayObject.filters[i];

					// hopefully, this check will save some cpu
					if ((bf.blurX == p_nBlurAmount) &&
					    (bf.blurY == p_nBlurAmount)) return;

					// assume this is our filter and change it
					bf.blurX = bf.blurY = p_nBlurAmount; fs[i] = bf; changed = true;
				}
				else
				{
					// copy the filter
					fs[i] = p_oDisplayObject.filters[i];
				}
			}
			// if filter was not found, add new
			if (!changed)
			{
				fs.push (new BlurFilter (p_nBlurAmount, p_nBlurAmount, 1));
				// once we added blur we have to track it all the time
				m_bWasNotBlurred = false;
			}
			// re-apply all filters
			p_oDisplayObject.filters = fs;
		}

		// --
		private var _m:Matrix = new Matrix();
		private var _c:uint;
		private var _a:Number;
		private var _fadeTo:Point3D;
		private var _fadeToN2:Number;
	}
}
