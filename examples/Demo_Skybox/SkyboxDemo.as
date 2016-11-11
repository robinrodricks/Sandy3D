package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.events.QueueEvent;
	import sandy.events.SandyEvent;
	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.primitive.SkyBox;
	import sandy.util.LoaderQueue;
	import sandy.util.NumberUtil;
	import sandy.view.BasicView;
	import sandy.materials.Material;

	public class SkyboxDemo extends BasicView
	{
		public function SkyboxDemo():void
		{
			super();
			init( 600, 600 );
			camera.setPosition( 0, 0, 0 );
			camera.fov = 60;
			planeNames = [ "side2" , "side3", "side4", "side5", "side6", "side1" ];
			loadImages();
		}
		
		private var shape:SkyBox;
		private var planeNames:Array;
		private var polygons:Array;
		private var textures:Array;	
		private var running:Boolean = false;
		private var keyPressed:Array = new Array();
		private var queue:LoaderQueue = new LoaderQueue();
		
		
		public function __onKeyDown(e:KeyboardEvent):void
		{
            keyPressed[e.keyCode] = true;
            if( e.keyCode == Keyboard.SPACE )
            	stage.displayState = StageDisplayState.FULL_SCREEN;
        }

        public function __onKeyUp(e:KeyboardEvent):void
        {
           keyPressed[e.keyCode] = false;
        }
		
		private function clickHandler( p_oEvt:Event ):void
		{
			if( p_oEvt.type == MouseEvent.MOUSE_DOWN )
			{
				lastPanAngle = panangle;
				lastTiltAngle = tiltangle;
				lastMouseX = stage.mouseX;
				lastMouseY = stage.mouseY;
				running = true;
			}
			else
			{
				running = false;
			}
		}
		
		//  -- Loading images
		private function loadImages():void
		{
			textures = new Array( planeNames.length );
			// --
			for ( var i:int = 0; i < 6; i++)
			{
				queue.add( planeNames[i], new URLRequest("skybox/sky2/"+planeNames[i]+".png") );
			}
			// --
			queue.addEventListener(SandyEvent.QUEUE_COMPLETE, loadComplete );
			queue.start();
		}
		
		private function getMaterial( p_nId:uint ):Material
		{
			var l_nPrecision:uint = 10;
			var l_oMat:BitmapMaterial = new BitmapMaterial( queue.data[planeNames[p_nId]].bitmapData, null, l_nPrecision );
			l_oMat.repeat = true;
			l_oMat.maxRecurssionDepth = 6;
			return l_oMat;
		}
		
		private function loadComplete( event:QueueEvent ):void 
		{			
			createScene();
			// --
			shape.front.appearance = new Appearance( getMaterial(0) );
			shape.back.appearance = new Appearance( getMaterial(2) );
			shape.left.appearance = new Appearance( getMaterial(3) );
			shape.right.appearance = new Appearance( getMaterial(1) );
			shape.top.appearance = new Appearance( getMaterial(4) );
			shape.bottom.appearance = new Appearance(  getMaterial(5) );				
			// --
			shape.front.enableClipping = true;
			shape.back.enableClipping = true;
			shape.left.enableClipping = true;
			shape.right.enableClipping = true;
			shape.top.enableClipping = true;
			shape.bottom.enableClipping = true;
			// --
			stage.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, clickHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			// --
			render();
		}
		
		// Create the root Group and the object tree 
		private function createScene():void
		{
			shape = new SkyBox( "pano", 300, 1, 1 );
			rootNode.addChild( shape );
		}

		private var panangle:Number = 0;
		private var tiltangle:Number = 0;
		private var lastPanAngle:Number = 0;
		private var lastTiltAngle:Number = 0;
		private var lastMouseX:Number = 0;
		private var lastMouseY:Number = 0;
		private const toRADIANS:Number = Math.PI/180;
		
		override public function simpleRender( event : Event = null ) : void
		{
			if( running )
			{
				panangle 	=  0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				tiltangle 	= -0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
					
				if (tiltangle > 85)
					tiltangle = 85;
				if (tiltangle < -85)
					tiltangle = -85;
				camera.rotateY = panangle;
				camera.tilt = tiltangle;
				/*
				camera.lookAt(	100 * Math.sin(panangle * toRADIANS) * Math.cos(tiltangle * toRADIANS),// + camera.x,
								100 * Math.cos(panangle * toRADIANS) * Math.cos(tiltangle * toRADIANS),// + camera.z,
								100 * Math.sin(tiltangle * toRADIANS)// + camera.y
							);
				*/
			}
			
			super.simpleRender( event );
		}
	}
}