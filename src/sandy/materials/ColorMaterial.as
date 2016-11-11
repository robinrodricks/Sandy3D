
package sandy.materials
{
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vertex;
	import sandy.materials.attributes.MaterialAttributes;
	
	import flash.display.Graphics;
	import flash.display.Sprite;	

	/**
	 * Displays a color with on the faces of a 3D shape.
	 *
	 * <p>Used to show colored faces, possibly with lines at the edges of the faces.</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public final class ColorMaterial extends Material implements IAlphaMaterial
	{
		private var m_nColor:Number;
		private var m_nAlpha:Number;

		/**
		 * Creates a new ColorMaterial.
		 *
		 * @param p_nColor 	The color for this material in hexadecimal notation.
		 * @param p_nAlpha	The alpha transparency value of the material.
		 * @param p_oAttr	The attributes for this material.
		 *
		 * @see sandy.materials.attributes.MaterialAttributes
		 */
		public function ColorMaterial( p_nColor:uint = 0x00, p_nAlpha:Number = 1, p_oAttr:MaterialAttributes = null )
		{
			super(p_oAttr);
			// --
			m_oType = MaterialType.COLOR;
			// --
			m_nColor = p_nColor;
			m_nAlpha = p_nAlpha;
		}

		/**
		 * @private
		 */
		public override function renderPolygon( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ):void
		{
			const l_points:Array = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
			if( !l_points.length ) return;
			var l_oVertex:Vertex;
			var lId:int = l_points.length;
			var l_graphics:Graphics = p_mcContainer.graphics;
			// --
			l_graphics.lineStyle();
			l_graphics.beginFill( m_nColor, m_nAlpha );
			l_graphics.moveTo( l_points[0].sx, l_points[0].sy );
			while( l_oVertex = l_points[ --lId ] )
				l_graphics.lineTo( l_oVertex.sx, l_oVertex.sy );
			l_graphics.endFill();
			// --
			super.renderPolygon( p_oScene, p_oPolygon, p_mcContainer );
			//if( attributes )  attributes.draw( l_graphics, p_oPolygon, this, p_oScene ) ;

		}

		/**
		 * Indicates the alpha transparency value of the material. Valid values are 0 (fully transparent) to 1 (fully opaque).
		 *
		 * @default 1.0
		 */
		public function get alpha():Number
		{
			return m_nAlpha;
		}

		/**
		 * The color of this material.
		 *
		 * @default 0x00
		 */
		public function get color():Number
		{
			return m_nColor;
		}

		/**
		 * @private
		 */
		public function set alpha(p_nValue:Number):void
		{
			m_nAlpha = p_nValue;
			m_bModified = true;
		}

		/**
		 * @private
		 */
		public function set color(p_nValue:Number):void
		{
			m_nColor = p_nValue;
			m_bModified = true;
		}

	}
}
