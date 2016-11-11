
package sandy.materials.attributes
{
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vertex;
	import sandy.materials.Material;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;	

	/**
	 * Realize a Gouraud shading on a material.
	 *
	 * <p>To make this material attribute use by the Material object, the material must have :myMAterial.lighteningEnable = true.<br />
	 * This attributes contains some parameters</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @author		Makc for effect improvment 
	 * @version		3.1
	 * @date 		13.11.2007
	 */
	public final class GouraudAttributes extends ALightAttributes
	{
		/**
		 * Flag for lightening mode.
		 * <p>If true, the lit objects use full light range from black to white. If false (the default) they just range from black to their normal appearance.</p>
		 */
		public function get useBright ():Boolean
		{
			return _useBright;
		}
		
		/**
		 * @private
		 */
		public function set useBright (p_bUseBright:Boolean):void
		{
			_useBright = p_bUseBright; makeLightMap ();
		}

		private function makeLightMap ():void
		{
			m_aColors = _useBright ? [0, 0, 0xFFFFFF, 0xFFFFFF] : [0, 0];
			m_aAlphas = _useBright ? [1, 0, 0, 1] : [1, 0];
			m_aRatios = _useBright ? [0, 127, 127, 255] : [0, 255];
		}

		/**
		 * Create the GouraudAttribute object.
		 * @param p_bBright The brightness (value for useBright).
		 * @param p_nAmbient The ambient light value. A value between O and 1 is expected.
		 */
		public function GouraudAttributes( p_bBright:Boolean = false, p_nAmbient:Number = 0.0 )
		{
			useBright = p_bBright;
			ambient = Math.min (Math.max (p_nAmbient, 0), 1);
		}

		private var v0L:Number, v1L:Number, v2L:Number;
		private var m1:Matrix = new Matrix();
		private var m2:Matrix = new Matrix();
		private var m_oVertex:Vertex;

		/**
		* @private
		*/
		override public function draw(p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D):void
		{
			super.draw (p_oGraphics, p_oPolygon, p_oMaterial, p_oScene);

			if( !p_oMaterial.lightingEnable ) return;
			
			// get vertices
			const l_aPoints:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
			// calculate light per vertex
			const l_bVisible:Boolean = p_oPolygon.visible;
			const l_nAmbient:Number = ambient;

			var v0L:Number = calculate (Vertex(p_oPolygon.vertexNormals[0]).getPoint3D(), l_bVisible); if (v0L < l_nAmbient) v0L = l_nAmbient; else if (v0L > 1)v0L = 1;
			var v1L:Number = calculate (Vertex(p_oPolygon.vertexNormals[1]).getPoint3D(), l_bVisible); if (v1L < l_nAmbient) v1L = l_nAmbient; else if (v1L > 1)v1L = 1;
			var v2L:Number = calculate (Vertex(p_oPolygon.vertexNormals[2]).getPoint3D(), l_bVisible); if (v2L < l_nAmbient) v2L = l_nAmbient; else if (v2L > 1)v2L = 1;
			// affine mapping
			var v0:Number, v1:Number, v2:Number,
				u0:Number, u1:Number, u2:Number, tmp:Number;

			v0 = -100; v1 = 0; v2 = 100;

			u0 = (v0L - 0.5) * (32768 * 0.05);
			u1 = (v1L - 0.5) * (32768 * 0.05);
			u2 = (v2L - 0.5) * (32768 * 0.05);

			m2.tx = Vertex(l_aPoints[0]).sx; m2.ty = Vertex(l_aPoints[0]).sy;

			// we have 3276.8 pixels per 256 colors (~0.07 colors per pixel)
			if ( (int (u0 * 0.1) == int (u1 * 0.1)) && (int (u1 * 0.1) == int (u2 * 0.1)) )
			{
				// this is solid color case - so fill accordingly
				p_oGraphics.lineStyle();
				if (_useBright) 
					p_oGraphics.beginFill( (v0L < 0.5) ? 0 : 0xFFFFFF, (v0L < 0.5) ? (1 - 2 * v0L) : (2 * v0L - 1) );
				else
					p_oGraphics.beginFill( 0, 1 - v0L );
				p_oGraphics.moveTo( m2.tx, m2.ty );
				for each( m_oVertex in l_aPoints )
				{
					p_oGraphics.lineTo( m_oVertex.sx, m_oVertex.sy );
				}
				p_oGraphics.endFill();
				return;
			}
				
			// in one line?
			if ((u2 - u1) * (u1 - u0) > 0)
			{
				tmp = v1; v1 = v2; v2 = tmp;
			}

			// prepare matrix
			m1.a = u1 - u0; m1.b = v1 - v0;
			m1.c = u2 - u0; m1.d = v2 - v0;
			m1.tx = u0; m1.ty = v0;
			m1.invert ();

			m2.a = Vertex(l_aPoints[1]).sx - m2.tx; m2.b = Vertex(l_aPoints[1]).sy - m2.ty;
			m2.c = Vertex(l_aPoints[2]).sx - m2.tx; m2.d = Vertex(l_aPoints[2]).sy - m2.ty;
			m1.concat (m2);
			// draw the map
			p_oGraphics.lineStyle();
			/*if (p_oPolygon.id == 259)
				p_oGraphics.lineStyle(1, 0xFF0000);*/
			p_oGraphics.beginGradientFill ("linear", m_aColors, m_aAlphas, m_aRatios, m1);
			p_oGraphics.moveTo( m2.tx, m2.ty );
			for each( m_oVertex in l_aPoints )
			{
				p_oGraphics.lineTo( m_oVertex.sx, m_oVertex.sy );
			}
			p_oGraphics.endFill();
		}

		private var _useBright:Boolean = true;

		private var m_aColors:Array;
		private var m_aAlphas:Array;
		private var m_aRatios:Array;
	}
}