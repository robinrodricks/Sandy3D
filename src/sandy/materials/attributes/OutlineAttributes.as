
package sandy.materials.attributes
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Edge3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vertex;
	import sandy.core.scenegraph.Sprite2D;
	import sandy.materials.Material;
	
	/**
	 * Holds all outline attributes data for a material.
	 *
	 * <p>Each material can have an outline attribute to outline the whole 3D shape.<br/>
	 * The OutlineAttributes class stores all the information to draw this outline shape</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		09.09.2007
	 */
	public final class OutlineAttributes extends AAttributes
	{
		private const SHAPE_MAP:Dictionary = new Dictionary(true);
		// --
		private var m_nThickness:Number;
		private var m_nColor:Number;
		private var m_nAlpha:Number;
		// --
		private var m_nAngleThreshold:Number = 181;
		// --
		/**
		 * Whether the attribute has been modified since it's last render.
		 */
		public var modified:Boolean;
		
		/**
		 * Creates a new OutlineAttributes object.
		 *
		 * @param p_nThickness	The line thickness.
		 * @param p_nColor		The line color.
		 * @param p_nAlpha		The alpha transparency value of the material.
		 */
		public function OutlineAttributes( p_nThickness:uint = 1, p_nColor:uint = 0, p_nAlpha:Number = 1 )
		{
			m_nThickness = p_nThickness;
			m_nAlpha = p_nAlpha;
			m_nColor = p_nColor;
			// --
			modified = true;
		}
		
		/**
		 * Indicates the alpha transparency value of the outline. Valid values are 0 (fully transparent) to 1 (fully opaque).
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
		 * The angle threshold. Attribute will additionally draw edges between faces that form greater angle than this value.
		 */	
		public function get angleThreshold():Number
		{
			return m_nAngleThreshold;
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
		public function set angleThreshold(p_nValue:Number):void
		{
			m_nAngleThreshold = p_nValue;
		}

		/**
		 * @private
		 */
		override public function init( p_oPolygon:Polygon ):void
		{
			;// to keep reference to the shapes/polygons that use this attribute
			// -- attempt to create the neighboors relation between polygons
			if( SHAPE_MAP[p_oPolygon.shape.id] == null )
			{
				// if this shape hasn't been registered yet, we compute its polygon relation to be able
				// to draw the outline.
				var l_aPoly:Array = p_oPolygon.shape.aPolygons;
				var a:int = l_aPoly.length, lCount:uint = 0, i:int, j:int;
				var lP1:Polygon, lP2:Polygon;
				var l_aEdges:Array;
				// if any of polygons of this shape have neighbour information, do not re-calculate it
				var l_bNoInfo:Boolean = true;
				for( i = 0; i < a; i++ )
				{
					if ( l_aPoly[i].aNeighboors.length > 0 )
						l_bNoInfo = false;
				}
				if ( l_bNoInfo )
				{
					for( i = 0; i < a-1; i+=1 )
					{
						lP1 = l_aPoly[int(i)];
						for( j=i+1; j < a; j+=1 )
						{
							lP2 = l_aPoly[int(j)];
							l_aEdges = lP2.aEdges;
							// --
							lCount = 0;
							// -- check if they share at least 2 vertices
							for each( var l_oEdge:Edge3D in lP1.aEdges )
								if( l_aEdges.indexOf( l_oEdge ) > -1 ) lCount += 1;
							// --
							if( lCount > 0 )
							{
								lP1.aNeighboors.push( lP2 );
								lP2.aNeighboors.push( lP1 );
							}
						}
					}
				}
				// --
				SHAPE_MAP[p_oPolygon.shape.id] = true;
			}
		}
	
		/**
		 * @private
		 */
		override public function unlink( p_oPolygon:Polygon ):void
		{
			;// to remove reference to the shapes/polygons that use this attribute
			// TODO : can we free the memory of SHAPE_MAP ? Don't think so, and would it be really necessary? not sure either.
		}
		
		/**
		 * @private
		 */
		override public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			var l_oEdge:Edge3D;
			var l_oPolygon:Polygon;
			var l_bFound:Boolean;
			var l_bVisible:Boolean = p_oPolygon.visible;
			// --
			var l_oNormal:Vertex;
			var l_nDotThreshold:Number;
			if (m_nAngleThreshold < 180)
			{
				l_oNormal = p_oPolygon.normal;
				l_nDotThreshold = Math.cos (m_nAngleThreshold * 0.017453292519943295769236907684886 /* Math.PI / 180 */ );
			}
			// --
			p_oGraphics.lineStyle( m_nThickness, m_nColor, m_nAlpha );
			p_oGraphics.beginFill(0);
			// --
			for each( l_oEdge in p_oPolygon.aEdges )
			{
				l_bFound = false;
				// --
				for each( l_oPolygon in p_oPolygon.aNeighboors )
				{
					// aNeighboor not visible, does it share an edge?
					// if so, we draw it
					if( l_oPolygon.aEdges.indexOf( l_oEdge ) > -1 )
					{
						if(( l_oPolygon.visible != l_bVisible ) ||
							((m_nAngleThreshold < 180) && (l_oNormal.dot (l_oPolygon.normal) < l_nDotThreshold )) )
						{
							p_oGraphics.moveTo( l_oEdge.vertex1.sx, l_oEdge.vertex1.sy );
							p_oGraphics.lineTo( l_oEdge.vertex2.sx, l_oEdge.vertex2.sy );
						}
						l_bFound = true;
					}
				}
				// -- if not shared with any neighboor, it is an extremity edge that shall be drawn
				if( l_bFound == false )
				{
					p_oGraphics.moveTo( l_oEdge.vertex1.sx, l_oEdge.vertex1.sy );
					p_oGraphics.lineTo( l_oEdge.vertex2.sx, l_oEdge.vertex2.sy );
				}
			}
			
			p_oGraphics.endFill();
		}

		/**
		 * @private
		 */
		override public function drawOnSprite( p_oSprite:Sprite2D, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			const g:Graphics = p_oSprite.container.graphics; g.clear ();
			const r:Rectangle = p_oSprite.container.getBounds (p_oSprite.container);
			g.lineStyle (m_nThickness, m_nColor, m_nAlpha); g.drawRect (r.x, r.y, r.width, r.height);
		}
	}
}
