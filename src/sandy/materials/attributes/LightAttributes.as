
package sandy.materials.attributes
{
	import flash.display.Graphics;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Point3D;
	import sandy.core.data.Vertex;
	import sandy.materials.Material;
	
	/**
	 * Realize a flat shading effect when associated to a material.
	 *
	 * <p>To make this material attribute use by the Material object, the material must have :myMAterial.lightingEnable = true.<br />
	 * This attributes contains some parameters</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public final class LightAttributes extends ALightAttributes
	{
		/**
		 * Flag for lighting mode.
		 * <p>If true, the lit objects use full light range from black to white. If false (the default) they range from black to their normal appearance.</p>
		 */
		public var useBright:Boolean = false;
		
		/**
		 * Creates a new LightAttributes object.
		 *
		 * @param p_bBright		The brightness (value for useBright).
		 * @param p_nAmbient	The ambient light value. A value between O and 1 is expected.
		 */
		public function LightAttributes( p_bBright:Boolean = false, p_nAmbient:Number = 0.3 )
		{
			useBright = p_bBright;
			ambient = Math.min (Math.max (p_nAmbient, 0), 1);
		}
		
		/**
		* @private
		*/
		override public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			super.draw (p_oGraphics, p_oPolygon, p_oMaterial, p_oScene);

			if( p_oMaterial.lightingEnable )
			{	
				var l_aPoints:Array = (p_oPolygon.isClipped)?p_oPolygon.cvertices : p_oPolygon.vertices;
				var l_oNormal:Point3D = p_oPolygon.normal.getPoint3D();
				// --
				var lightStrength:Number = calculate (l_oNormal, p_oPolygon.visible);
				if (lightStrength > 1) lightStrength = 1; else if (lightStrength < ambient) lightStrength = ambient;
				// --
				p_oGraphics.lineStyle();
				if( useBright) 
					p_oGraphics.beginFill( (lightStrength < 0.5) ? 0 : 0xFFFFFF, (lightStrength < 0.5) ? (1-2 * lightStrength) : (2 * lightStrength - 1) );
				else 
					p_oGraphics.beginFill( 0, 1-lightStrength );
				// --
				p_oGraphics.moveTo( Vertex(l_aPoints[0]).sx, Vertex(l_aPoints[0]).sy );
				for each( var l_oVertex:Vertex in l_aPoints )
				{
					p_oGraphics.lineTo( l_oVertex.sx, l_oVertex.sy );
				}
				p_oGraphics.endFill();
				// --
				l_oNormal = null;
				l_oVertex = null;
			}
		}
	}
}
