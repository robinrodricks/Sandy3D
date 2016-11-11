
package sandy.core.scenegraph 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vertex;
	import sandy.events.BubbleEvent;
	import sandy.events.SandyEvent;
	import sandy.materials.Material;
	import sandy.view.CullingState;
	import sandy.view.Frustum;

	/**
	 * The Sprite2D class is used to create a 2D sprite.
	 *
	 * <p>A Sprite2D object is used to display a static or dynamic texture in the Sandy world.<br/>
	 * The sprite always shows the same side to the camera. This is useful when you want to show more
	 * or less complex images, without heavy calculations of perspective distortion.</p>
	 * <p>The Sprite2D has a fixed bounding sphere radius, set by default to 30.<br />
	 * In case your sprite is bigger, you can adjust it to avoid any frustum culling issue</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public class Sprite2D extends ATransformable implements IDisplayable
	{	
		// FIXME Create a Sprite as the spriteD container, 
		//and offer a method to attach a visual content as a child of the sprite
		
		/**
		 * Set this to true if you want this sprite to rotate with camera.
		 */
		public var fixedAngle:Boolean = false;

		/**
		 * When enabled, the sprite will be displayed at its graphical center.
		 * Otherwise the sprite positioning is controlled by floorCenter property.
		 */
		public var autoCenter:Boolean = true;

		/**
		 * When enabled, the sprite will be displayed at its bottom line.
		 * Otherwise it is positioned at its registration point (usually top left corner).
		 * This property has no effect when autoCenter is enabled.
		 */
		public var floorCenter:Boolean = false;
		
		/**
		 * @private
		 */
		public var v:Vertex;
		/**
		 * @private
		 */
		public var vx:Vertex;
		/**
		 * @private
		 */
		public var vy:Vertex;
		
		/**
		 * Creates a Sprite2D.
		 *
		 * @param p_sName	A string identifier for this object
		 * @param p_oContent	The container containing all the pre-rendered picture
		 * @param p_nScale 	A number used to change the scale of the displayed object.
		 * 			In case that the object projected dimension
		 *			isn't adapted to your needs. 
		 *			Default value is 1.0 which means unchanged. 
		 * 			A value of 2.0 will double object size.
		 * 			A value of 0 will force original graphics size independent of distance.
		 */	
		public function Sprite2D( p_sName:String = "", p_oContent:DisplayObject = null, p_nScale:Number=1) 
		{
			super(p_sName);
			m_oContainer = new Sprite();
			// --
			v = new Vertex(); vx = new Vertex(); vy = new Vertex();
	        // --
			_nScale = p_nScale;
			// --
			if ( p_oContent ) {
				content = p_oContent;
				setBoundingSphereRadius( Math.max (30, Math.abs (_nScale) * Math.max (content.width, content.height)) );
			}
		}

		/**
		 * The DisplayObject that will used as content of this Sprite2D. 
		 * If this DisplayObject has already a screen position, it will be reseted to 0,0.
		 * If the DisplayObject has allready a parent, it will be unrelated from it automatically. (its transform matrix property is resetted to identity too).
		 * @param p_content The DisplayObject to attach to the Sprite2D#container. 
		 */
		public function set content( p_content:DisplayObject ):void
		{
			p_content.transform.matrix.identity();
			if( m_oContent ) m_oContainer.removeChild( m_oContent );
			m_oContent = p_content;
			m_oContainer.addChildAt( m_oContent, 0 );
			m_oContent.x = 0;
			m_oContent.y = 0;
			m_nW2 = m_oContainer.width / 2;
			m_nH2 = m_oContainer.height / 2;
			changed = true;
		}
		
		/**
		 * Gives access to your content reference.
		 * The content is the exact visual object you passed to the constructor.
		 * In comparison with the container which is the container of the content (in Sandy's architecture, the container must be a Sprite),
		 * but the content can be any kind of visual object AS3 offers (MovieClip, Bitmap, Sprite etc.)
		 * WARNNIG: Be careful when manipulating the content object to not break any link with the sandy container (content.parent).
		 */
		public function get content():DisplayObject
		{
			return m_oContent;
		}
		
		
		override public function set scene(p_oScene:Scene3D):void
		{
			if( p_oScene == null ) return;
			if( scene )
			{
				scene.removeEventListener(SandyEvent.SCENE_RENDER_FINISH, _finishMaterial );
				scene.removeEventListener(SandyEvent.SCENE_RENDER_DISPLAYLIST, _beginMaterial );
			}
			super.scene = p_oScene;
			// --
			scene.addEventListener(SandyEvent.SCENE_RENDER_FINISH, _finishMaterial );
			scene.addEventListener(SandyEvent.SCENE_RENDER_DISPLAYLIST, _beginMaterial );
		}
		
		private function _finishMaterial( pEvt:SandyEvent ):void
		{
			if( !m_oMaterial ) return;
			if( !visible ) return;
			// --
			m_oMaterial.finish( scene );
		}
		
		private function _beginMaterial( pEvt:SandyEvent ):void
		{
			if( !m_oMaterial ) return;
			if( !visible ) return;
			// --
			m_oMaterial.begin( scene );
		}

		
		/**
		 * The container of this sprite ( canvas )
		 */
		public function get container():Sprite
		{
			return m_oContainer;
		}

		/**
		 * Sets the radius of bounding sphere for this sprite.
		 *
		 * @param p_nRadius	The radius
		 */
		public function setBoundingSphereRadius( p_nRadius:Number ):void
		{
			//boundingBox.maxEdge.reset( p_nRadius/2, p_nRadius/2, p_nRadius/2 );
			//boundingBox.minEdge.reset(-p_nRadius/2,-p_nRadius/2,-p_nRadius/2 );
			boundingSphere.radius = p_nRadius;
			//updateBoundingVolumes();
		}

		/**
		 * The scale of this sprite.
		 *
		 * <p>Using scale, you can change the dimension of the sprite rapidly.</p>
		 */
		public function get scale():Number
		{ 
			return _nScale; 
		}
	
		/**
		 * @private
		 */
		public function set scale( n:Number ):void
		{
			if( n )	_nScale = n; 
			changed = true;
		}
		
		/**
		 * The depth to draw this sprite at.
		 * <p>[<b>ToDo</b>: Explain ]</p>
		 */
		public function get depth():Number
		{
			return m_nDepth;
		}
		
		/**
		 * @private
		 */
		public function set depth( p_nDepth:Number ):void
		{m_nDepth = p_nDepth; changed = true;}
		  
		/**
		 * Tests this node against the camera frustum to get its visibility.
		 *
		 * <p>If this node and its children are not within the frustum, 
		 * the node is set to cull and it would not be displayed.<p/>
		 * <p>The method also updates the bounding volumes to make the more accurate culling system possible.<br/>
		 * First the bounding sphere is updated, and if intersecting, 
		 * the bounding box is updated to perform the more precise culling.</p>
		 * <p><b>[MANDATORY] The update method must be called first!</b></p>
		 *
		 * @param p_oScene The current scene
		 * @param p_oFrustum	The frustum of the current camera
		 * @param p_oViewMatrix	The view martix of the curren camera
		 * @param p_bChanged
		 */
		public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			super.cull( p_oFrustum, p_oViewMatrix, p_bChanged );			
			if( visible == false )
			{
				container.visible = visible;
				return;
			}
			// --
			if( viewMatrix )
			{
				/////////////////////////
		        //// BOUNDING SPHERE ////
		        /////////////////////////
		        boundingSphere.transform( viewMatrix );
		        culled = p_oFrustum.sphereInFrustum( boundingSphere );
			}
			// --
			if( culled == CullingState.OUTSIDE )
			{ 	
				container.visible = false;
			}
			else 
			{
				if( culled == CullingState.INTERSECT ) 
				{
					if( boundingSphere.position.z <= scene.camera.near )
					{
						container.visible = false;
					}
					else 
					{
						container.visible = true;
						// --
						scene.renderer.addToDisplayList( this ); 
					}
				}
				else
				{
					container.visible = true;
					// --
					scene.renderer.addToDisplayList( this ); 
				}
			}
		}
		
		/**
		 * Clears the graphics object of this object's container.
		 *
		 * <p>The the graphics that were drawn on the Graphics object is erased, 
		 * and the fill and line style settings are reset.</p>
		 */	
		public function clear():void
		{
			;//m_oContainer.visible = false;
		}
		
		
		/**
		 * Provide the classical remove behaviour, plus remove the container to the display list.
		 */
		public override function remove():void
		{
			if( m_oContainer.parent ) m_oContainer.parent.removeChild( m_oContainer );
			m_oContainer.graphics.clear();
			enableEvents = false;
			
			if( scene )
			{
				scene.removeEventListener(SandyEvent.SCENE_RENDER_FINISH, _finishMaterial );
				scene.removeEventListener(SandyEvent.SCENE_RENDER_DISPLAYLIST, _beginMaterial );
			}
			
			super.remove();
		}

		/**
		 * @inheritDoc
		 */
		public override function destroy():void
		{
			remove (); 
			super.destroy ();
		}

		/**
		 * Displays this sprite.
		 *
		 * <p>display the object onto the scene.
		 * If the object has autocenter enabled, sprite center is set at screen position.
		 * Otherwise the sprite top left corner will be at that position.</p>
		 *
		 * @param p_oScene The current scene
		 * @param p_oContainer	The container to draw on
		 */
		public function display( p_oContainer:Sprite = null  ):void
		{
			m_nPerspScaleX = (_nScale == 0) ? 1 : _nScale * (vx.sx - v.sx);
			m_nPerspScaleY = (_nScale == 0) ? 1 : _nScale * (v.sy - vy.sy);
			m_nRotation = Math.atan2( viewMatrix.n12, viewMatrix.n22 );
			// --
			m_oContainer.scaleX = m_nPerspScaleX;
			m_oContainer.scaleY = m_nPerspScaleY;
			m_oContainer.x = v.sx - (autoCenter ? m_oContainer.width/2 : 0);
			m_oContainer.y = v.sy - (autoCenter ? m_oContainer.height/2 : (floorCenter ? m_oContainer.height : 0) );
			// --
			if (fixedAngle) m_oContainer.rotation = m_nRotation * 180 / Math.PI;
			// --
			if (m_oMaterial) m_oMaterial.renderSprite( this, m_oMaterial, scene );
		}

		/**
		 * Material that the sprite will be dressed in. Use it to apply some attributes
		 * to sprite, such as light attributes.
		 */
		public function get material():Material
		{
			return m_oMaterial;
		}

		/**
		 * @private
		 */
		public function set material( p_oMaterial:Material ):void
		{
			m_oMaterial = p_oMaterial;
			changed = true;
		}

		/**
		 * Should forced depth be enable for this object?.
		 *
		 * <p>If true it is possible to force this object to be drawn at a specific depth,<br/>
		 * if false the normal Z-sorting algorithm is applied.</p>
		 * <p>When correctly used, this feature allows you to avoid some Z-sorting problems.</p>
		 */
		public var enableForcedDepth:Boolean = false;
		
		/**
		 * The forced depth for this object.
		 *
		 * <p>To make this feature work, you must enable the ForcedDepth system too.<br/>
		 * The higher the depth is, the sooner the more far the object will be represented.</p>
		 */
		public var forcedDepth:Number = 0;

		public function get enableEvents():Boolean
		{
			return m_bEv;
		}
		
		override public function set enableEvents( b:Boolean ):void
		{
			if( b &&!m_bEv )
			{
				m_oContainer.addEventListener(MouseEvent.CLICK, _onInteraction);
		    	m_oContainer.addEventListener(MouseEvent.MOUSE_UP, _onInteraction);
		    	m_oContainer.addEventListener(MouseEvent.MOUSE_DOWN, _onInteraction);
	    		m_oContainer.addEventListener(MouseEvent.ROLL_OVER, _onInteraction);
	    		m_oContainer.addEventListener(MouseEvent.ROLL_OUT, _onInteraction);
	    		
				m_oContainer.addEventListener(MouseEvent.DOUBLE_CLICK, _onInteraction);
				m_oContainer.addEventListener(MouseEvent.MOUSE_MOVE, _onInteraction);
				m_oContainer.addEventListener(MouseEvent.MOUSE_OVER, _onInteraction);
				m_oContainer.addEventListener(MouseEvent.MOUSE_OUT, _onInteraction);
				m_oContainer.addEventListener(MouseEvent.MOUSE_WHEEL, _onInteraction);
			}
			else if( !b && m_bEv )
			{
				m_oContainer.removeEventListener(MouseEvent.CLICK, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.MOUSE_UP, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.MOUSE_DOWN, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.ROLL_OVER, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.ROLL_OUT, _onInteraction);
				
				m_oContainer.removeEventListener(MouseEvent.DOUBLE_CLICK, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.MOUSE_MOVE, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.MOUSE_OVER, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.MOUSE_OUT, _onInteraction);
				m_oContainer.removeEventListener(MouseEvent.MOUSE_WHEEL, _onInteraction);
			}
		}
		
		protected function _onInteraction( p_oEvt:Event ):void
		{
			m_oEB.dispatchEvent( new BubbleEvent( p_oEvt.type, this ) );
		}
		
		override public function toString():String
		{
			return "sandy.core.scenegraph.Sprite2D, container:"+m_oContainer;
		}
		
		private var m_bEv:Boolean = false; // The event system state (enable or not)
		
		private var m_nW2:Number=0;
		private var m_nH2:Number=0;
		private var m_oContainer:Sprite;
		protected var m_nPerspScaleX:Number=0, m_nPerspScaleY:Number=0;
		protected var m_nRotation:Number = 0;
		protected var m_nDepth:Number;
		protected var _nScale:Number;
		protected var m_oContent:DisplayObject;
		protected var m_oMaterial:Material;
	}
}