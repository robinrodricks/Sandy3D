
package sandy.materials
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.math.ColorMath;
	import sandy.util.NumberUtil;

	/**
	 * Displays a MovieClip on the faces of a 3D shape.
	 *
	 * <p>Based on the AS2 class VideoSkin made by kiroukou and zeusprod</p>
	 *
	 * @author		Xavier Martin - zeflasher
	 * @author		Thomas PFEIFFER - kiroukou
	 * @since		1.0
	 * @version		3.1
	 * 				this should be add directly in the bitmap material I reckon
	 * @date 		11.11.2007
	 */
	public class MovieMaterial extends BitmapMaterial
	{
		/**
		 * Default color used to draw the bitmapdata content.
		 * In case you need a specific color, change this value at your application initialization.
		 */
		public static const DEFAULT_FILL_COLOR:uint = 0;

		private var m_oTimer:Timer;
		private var m_oMovie:Sprite;
		private var m_bUpdate:Boolean;
		private var m_oAlpha:ColorTransform;

		/**
		 * Creates a new MovieMaterial.
		 *
		 * <p>The MovieClip used for the material may contain animation.<br/>
		 * It is converted to a bitmap to give it a perspective distortion.<br/>
		 * To see the animation the bitmap has to be recreated from the MovieClip on a regular basis.</p>
		 *
		 * @param p_oMovie		The Movieclip to be shown by this material.
		 * @param p_nUpdateMS	The update interval.
		 * @param p_oAttr		The material attributes.
		 * @param p_bRemoveTransparentBorder	Remove the transparent border.
		 * @param p_nWidth		Desired width ( chunk the movieclip )
		 * @param p_nHeight		Desired height ( chunk the movieclip )
		 *
		 * @see sandy.materials.attributes.MaterialAttributes
		 */
		public function MovieMaterial( p_oMovie:Sprite, p_nUpdateMS:uint = 40, p_oAttr:MaterialAttributes = null, p_bRemoveTransparentBorder:Boolean = false, p_nHeight:Number=0, p_nWidth:Number=0 )
		{
			var w : Number;
			var h : Number;

			m_oAlpha = new ColorTransform ();

			if ( p_bRemoveTransparentBorder )
			{
				var tmpBmp : BitmapData = new BitmapData(  p_oMovie.width, p_oMovie.height, true, 0 );
				tmpBmp.draw( p_oMovie );
				var rect : Rectangle = tmpBmp.getColorBoundsRect( 0xFF000000, 0x00000000, false );
				w = rect.width;
				h = rect.height;
			}
			else
			{
				w = p_nWidth ? p_nWidth :  p_oMovie.width;
				h = p_nHeight ? p_nHeight : p_oMovie.height;
			}

			super( new BitmapData( w, h, true, DEFAULT_FILL_COLOR), p_oAttr );
			m_oMovie = p_oMovie;
			m_oType = MaterialType.MOVIE;
			// --
			m_bUpdate = true;
			m_oTimer = new Timer( p_nUpdateMS );
			m_oTimer.addEventListener(TimerEvent.TIMER, update );
			m_oTimer.start();

			if( tmpBmp ) 
			{
				tmpBmp.dispose();
				tmpBmp = null;
			}
			rect = null;
			w = undefined;
			h = undefined;
		}
		
		override public function dispose():void
		{
			super.dispose();
			stop();
			m_oTimer = null;
			m_oMovie = null;
		}

		/**
		 * @private
		 */
		public override function renderPolygon ( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ) : void
		{
			m_bUpdate = true;
			super.renderPolygon( p_oScene, p_oPolygon, p_mcContainer );
		}

		/**
		 * @private
		 */
		public override function setTransparency( p_nValue:Number ):void
		{
			m_oAlpha.alphaMultiplier = NumberUtil.constrain( p_nValue, 0, 1 );
		}


		/**
		 * Updates this material each internal timer cycle.
		 */
		public function update( p_eEvent:Event = null ):void
		{
			if ( m_bUpdate || forceUpdate )
			{
				m_oTexture.fillRect( m_oTexture.rect,
					ColorMath.applyAlpha( DEFAULT_FILL_COLOR, m_oAlpha.alphaMultiplier) );
				// --
				m_oTexture.draw( m_oMovie, null, m_oAlpha, null, null, smooth );
				m_bModified = true;
			}
			m_bUpdate = false;
		}

		/**
		 * Call this method when you want to start the material update.
		 * This is automatically called at the material creation so basically it is used only when the MovieMaterial::stop() method has been called
		 */
		public function start():void
		{
			m_oTimer.start();
		}

		/**
		 * Call this method is case you would like to stop the automatic MovieMaterial texture update.
		 */
		public function stop():void
		{
			if(m_oTimer!=null)m_oTimer.stop();
		}

		/**
		 * Get the sprite used for the material.
		 */
		public function get movie() : Sprite
		{
			return m_oMovie;
		}
	}
}
