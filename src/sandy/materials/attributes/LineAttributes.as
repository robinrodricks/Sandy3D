
package sandy.materials.attributes
{
	import flash.display.Graphics;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vertex;
	import sandy.materials.Material;
	
	/**
	 * Holds all line attribute data for a material.
	 *
	 * <p>Some materials have line attributes to outline the faces of a 3D shape.<br/>
	 * In these cases a LineAttributes object holds all line attribute data</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public class LineAttributes extends AAttributes
	{
		private var m_nThickness:Number;
		private var m_nColor:Number;
		private var m_nAlpha:Number;
		// --
		/**
		 * Whether the attribute has been modified since it's last render.
		 */
		public var modified:Boolean;
		
		/**
		 * Creates a new LineAttributes object.
		 *
		 * @param p_nThickness	The line thickness.
		 * @param p_nColor		The line color.
		 * @param p_nAlpha		The alpha transparency value of the material.
		 */
		public function LineAttributes( p_nThickness:uint = 1, p_nColor:uint = 0, p_nAlpha:Number = 1 )
		{
			m_nThickness = p_nThickness;
			m_nAlpha = p_nAlpha;
			m_nColor = p_nColor;
			// --
			modified = true;
		}
		
		/**
		 * Indicates the alpha transparency value of the line. Valid values are 0 (fully transparent) to 1 (fully opaque).
		 *
		 * @default 1.0
		 */
		public function get alpha():Number
		{
			return m_nAlpha;
		}
		
		/**
		 * The line color.
		 */
		public function get color():Number
		{
			return m_nColor;
		}
		
		/**
		 * The line thickness.
		 */	
		public function get thickness():Number
		{
			return m_nThickness;
		}
		
		/**
		 * @private
		 */
		public function set alpha(p_nValue:Number):void
		{
			m_nAlpha = p_nValue; 
			modified = true;
		}
		
		/**
		 * @private
		 */
		public function set color(p_nValue:Number):void
		{
			m_nColor = p_nValue; 
			modified = true;
		}

		/**
		 * @private
		 */
		public function set thickness(p_nValue:Number):void
		{
			m_nThickness = p_nValue; 
			modified = true;
		}
	
		/**
		* @private
		*/
		override public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			var l_aPoints:Array = (p_oPolygon.isClipped)?p_oPolygon.cvertices : p_oPolygon.vertices;
			var l_oVertex:Vertex;
			p_oGraphics.lineStyle( m_nThickness, m_nColor, m_nAlpha );
			// --
			p_oGraphics.moveTo( l_aPoints[0].sx, l_aPoints[0].sy );
			var lId:int = l_aPoints.length;
			while( l_oVertex = l_aPoints[ --lId ] )
				p_oGraphics.lineTo( l_oVertex.sx, l_oVertex.sy );
		}
	}
}