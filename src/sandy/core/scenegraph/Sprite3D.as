
package sandy.core.scenegraph
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Matrix4;	

	/**
	 * The Sprite3D class is used to create a 3D sprite.
	 *
	 * <p>A Sprite3D can be seen as a special Sprite2D.<br/>
	 * It has an appearance that is a movie clip containing 360 frames (as maximum!) with texture.</p>
	 *
	 * <p>Depending on the camera position, a different frame of the clip is shown, givin a 3D effect.<p/>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		20.05.2006
	 **/
	public class Sprite3D extends Sprite2D
	{
		// FIXME Create a Sprite as the spriteD container,
		// and offer a method to attach a visual content as a child of the sprite
		public var offset:uint = 0;
		
		 /**
	 	 * Creates a Sprite3D
		 *
		 * @param p_sName 	A string identifier for this object
		 * @param p_oContent	The Movieclip containing the pre-rendered textures
		 * @param p_nScale 	A number used to change the scale of the displayed object.
		 * 			In case that the object projected dimension
		 *			isn't adapted to your needs.
		 *			Default value is 1.0 which means unchanged.
		 * 			A value of 2.0 will double object size.
		 * 			A value of 0 will force original graphics size independent of distance.
		 *
		 * @param p_nOffset 	A number between [0-360] to give angle offset into the clip.
		 */
		public function Sprite3D( p_sName:String = "", p_oContent:MovieClip = null, p_nScale:Number=1, p_nOffset:Number=0 )
		{
			super(p_sName, p_oContent, p_nScale);
			// -- set the offset
			offset = p_nOffset;
		}

		/**
		 * The MovieClip that will used as content of this Sprite2D. 
		 * If this MovieClip has already a scree position, it will be reseted to 0,0.
		 * 
		 * @param p_content The MovieClip to attach to the Sprite3D#container. 
		 */
		override public function set content( p_content:DisplayObject ):void
		{
			if (p_content as MovieClip)
			{
				super.content = p_content;
				// --
				m_nAutoOffset = (m_oContent as MovieClip).totalFrames / 360;
			}
		}
		
		override public function display( p_oContainer:Sprite = null ):void
		{
			(m_oContent as MovieClip).gotoAndStop( __frameFromAngle( Math.atan2( viewMatrix.n13, viewMatrix.n33 ) ) );
			super.display( p_oContainer );
		}

		// Returns the frame to show at the current camera angle
		private function __frameFromAngle(a:Number):uint
		{
			// to degree
			a *= 57.295779513082321; // *= 180 / Math.PI
			// correction to simply use uint ()
			a += 0.5 / m_nAutoOffset;
			// force 0...360 range
			a = (( a + offset )+360) % 360;
			// convert corrected angle to frame number
			return 1 + uint (a * m_nAutoOffset);
		}

		// -- frames offset
		private var m_nAutoOffset:Number;
	}
}