package sandy.core
{
	import sandy.core.data.Point3D;
	import sandy.core.data.Pool;
	import sandy.core.light.Light3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.events.SandyEvent;

	import flash.display.Sprite;
	import flash.events.EventDispatcher;

	/**
	* Dispatched when a light is added to the scene.
	*
	* @eventType sandy.events.SandyEvent.LIGHT_ADDED
	*/
	[Event(name="lightAdded", type="sandy.events.SandyEvent")]

	/**
	* Dispatched when the scene is rendered.
	*
	* @eventType sandy.events.SandyEvent.SCENE_RENDER
	*/
	[Event(name="scene_render", type="sandy.events.SandyEvent")]

	/**
	* Dispatched when the scene has finished its rendering process
	*
	* @eventType sandy.events.SandyEvent.SCENE_RENDER_FINISH
	*/
	[Event(name="scene_render_finish", type="sandy.events.SandyEvent")]

	/**
	* Dispatched when the scene is culled.
	*
	* @eventType sandy.events.SandyEvent.SCENE_CULL
	*/
	[Event(name="scene_cull", type="sandy.events.SandyEvent")]

	/**
	* Dispatched when the scene is updated.
	*
	* @eventType sandy.events.SandyEvent.SCENE_UPDATE
	*/
	[Event(name="scene_update", type="sandy.events.SandyEvent")]

	/**
	* Dispatched when the display list is rendered.
	*
	* @eventType sandy.events.SandyEvent.SCENE_RENDER_DISPLAYLIST
	*/
	[Event(name="scene_render_display_list", type="sandy.events.SandyEvent")]

	/**
	 * The Sandy 3D scene.
	 *
	 * <p>Supercedes deprecated World3D class.</p>
	 *
	 * <p>The Scene3D object is the central point of a Sandy scene.<br/>
	 * You can have multiple scenes.<br/>
	 * A scene contains the object tree with groups, a camera, a light source and a canvas to draw on</p>
	 *
	 * @example	To create the scene, you invoke the Scene3D constructor, passing it the base movie clip, the camera, and the root group for the scene.<br/>
	 * The rendering of the scene is driven by a "heart beat", which may be a Timer or the Event.ENTER_FRAME event.
	 *
	 * The following pseudo-code approximates the necessary steps. It is very approximate and not meant as a working example:
	 * <listing version="3.0.3">
	 * 		var cam:Camera = new Camera3D(600, 450, 45, 0, 2000); // camera viewport height,width, fov, near plane, and far plane
	 *		var mc:MovieClip = someSceneHoldingMovieClip;  // Programmer must ensure it is a valid movie clip.
	 *		var rootGroup = new Group("world_root_group");
	 *		// Add some child objects to the world (not shown), perhaps as follows
	 *		//rootGroup.addChild(someChild);
	 *		// Create the scene and render it
	 *     	var myScene:Scene3D = new Scene3D("scene_name", mc, cam, rootGroup);
	 *		myScene.render();
	 *	//The enterFrameHandler presumably calls the myScene.render() method to render the scene for each frame.
	 *	yourMovieRoot.addEventListener( Event.ENTER_FRAME, enterFrameHandler );
	 *  </listing>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		25.08.2008
	 */
	public class Scene3D extends EventDispatcher
	{
		/**
		 * The camera looking at this scene.
		 *
	     * @see sandy.core.scenegraph.Camera3D
		 */
		public var camera:Camera3D;

		/**
		 * The container that stores all displayable objects for this scene.
		 */
		public var container:Sprite;

		/**
		 * The renerer choosed for render this scene.
		 * In the future, the actual renderer will implement an interface that developers could use to create their own
		 * rendering process.
		 */
		public var renderer:Renderer = new Renderer();


		/**
		 * Creates a new 3D scene.
		 *
		 * <p>Each scene is automatically registered with the SceneLocator and must be given
		 * a unique name to make proper use of the SceneLocator registry.</p>
		 *
		 * @param p_sName		A unique name for this scene.
		 * @param p_oContainer 	The container where the scene will be drawn.
		 * @param p_oCamera		The camera for this scene.
		 * @param p_oRootNode	The root group of the scene's object tree.
		 *
	     * @see sandy.core.scenegraph.Camera3D
	     * @see sandy.core.scenegraph.Group
		 */
		public function Scene3D(p_sName:String, p_oContainer:Sprite, p_oCamera:Camera3D = null, p_oRootNode:Group = null)
		{
			if (p_sName != null)
			{
				if (SceneLocator.getInstance().registerScene(p_sName, this))
				{
					container = p_oContainer;
					camera = p_oCamera;
					root = p_oRootNode;

					if (root != null && camera != null)
					{
						if( !camera.hasParent() )
							root.addChild(camera);
					}
				}
				m_sName = p_sName;
			}
			// --
			_light = new Light3D(new Point3D(0, 0, 1), 100);
		}

		/**
		 * Renders the scene in its container.
		 * Several events are dispatched by the scene to allows you to control the rendering pipeline
		 * SandyEvent.SCENE_UPDATE is broadcasted before the update phasis of the scenegraph. During this phasis each node updates its information and creates its local matrix if any
		 * SandyEvent.SCENE_CULL is bradcasted before the scene cull phasis. This phasis corresponds to the frustum vs nodes bounding objects visibility test. Nodes that aren't in the camera field of view, are removed from the render phasis.
		 * SandyEvent.SCENE_RENDER process the render call of the visible nodes. During this process, visible polygons/sprites are registering for the camera display to the screen.
		 * SandyEvent.SCENE_RENDER_DISPLAYLIST render the visible polygons to the screen
		 *
		 * @param p_bUseCache Boolean default true, use the cache system
		 *
	     * @see sandy.events.SandyEvent
		 */
		public function render(p_bUseCache:Boolean = true):void
		{
			if (root && camera && container)
			{
				Pool.getInstance().init();
				renderer.init();
				// --
				dispatchEvent(new SandyEvent(SandyEvent.SCENE_UPDATE));
				root.update(null, false);
				// --
				dispatchEvent(new SandyEvent( SandyEvent.SCENE_CULL));
				root.cull(camera.frustrum, camera.invModelMatrix, camera.changed);
				// --
				dispatchEvent(new SandyEvent(SandyEvent.SCENE_RENDER));
				var l_bNeedDraw:Boolean = renderer.render( this, p_bUseCache );
				// -- clear the polygon's container and the projection vertices list
				frameCount++;
				dispatchEvent(new SandyEvent(SandyEvent.SCENE_RENDER_DISPLAYLIST));
				if( l_bNeedDraw || _light.changed )
				{
	            	renderer.renderDisplayList( this );
	            	_light.changed = false;
	            }
	            dispatchEvent(new SandyEvent(SandyEvent.SCENE_RENDER_FINISH));
			}
		} // end method

		/**
		 * @private
		 */
		public var frameCount:int = 0;


		/**
		 * The root of the scene graph for this scene.
		 *
	     * @see sandy.core.scenegraph.Group
		 */
		public function set root(p_oGroup:Group):void
		{
			if( m_oRoot )
			{
				m_oRoot.scene = null;
				m_oRoot = null;
			}
			if( p_oGroup )
			{
				m_oRoot = p_oGroup;
				m_oRoot.scene = this;
				if( !camera.hasParent() )
					root.addChild(camera);
			}
		}

		public function get root():Group
		{
			return m_oRoot;
		}


		protected var m_oRoot:Group;

		/**
		 * Disposes of all the scene's resources.
		 *
		 * <p>This method is used to clear memory and will free up all resources of the scene and unregister it from SceneLocator.</p>
		 */
		public function dispose():Boolean
		{
			SceneLocator.getInstance().unregisterScene(m_sName);
			// --
			if (root)
			{
				root.destroy();
				root = null;
			}
			if (camera)
			{
				camera = null;
			}
			if (_light)
			{
				_light = null;
			}

			return true;
		}

		/**
		 * The Light3D object associated with this this scene.
		 *
		 * @see sandy.core.light.Light3D
		 */
		public function get light():Light3D
		{
			return _light;
		}

		/**
		 * @private
		 */
		public function set light(l:Light3D):void
		{
			if (_light)
			{
				_light.destroy();
			}
			// --
			_light = l;
			dispatchEvent(new SandyEvent(SandyEvent.LIGHT_ADDED));
		}

		/**
		 * Enable this property to perfectly clip your 3D scene to the viewport's dimensions with a 2D clipping
		 * If set to <code>true</code>, nothing will be drawn outside the viewport's dimensions.
		 *
		 * @default false
		 */
		public function get rectClipping():Boolean
		{
			return m_bRectClipped;
		}

		/**
		 * @private
		 */
		public function set rectClipping(p_bEnableClipping:Boolean):void
		{
			m_bRectClipped = p_bEnableClipping;
			// -- we force the new state of the rectClipping property to be applied
			if (camera)
			{
				camera.viewport.hasChanged = true;
			}
		}

		/**
		 * The name of this scene.
		 * This value can't be changed.
		 */
		public function get name():String
		{
			return m_sName;
		}

		/**
		 * Returns a version string ("3.1"), useful for conditional code
		 */
		public static function getVersion( ) : String
		{
			return _version;
		}

		/**
	     * @private
		 */
		protected var m_sName:String;
		private var m_bRectClipped:Boolean = false;
		private var _light:Light3D; 	//the unique light instance of the world
		private static var _version:String = "3.1";
	}
}