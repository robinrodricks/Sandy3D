package 
{

	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.BitmapData;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageQuality;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import sandy.core.scenegraph.mode7.CameraMode7;
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.Shape3D;
	import sandy.core.scenegraph.mode7.Mode7;

	import sandy.materials.Appearance;
	import sandy.materials.BitmapMaterial;
	import sandy.primitive.Sphere;

	public class SandyMode7 extends Sprite
	{
		private const _framerate:int = 30;
		private const _surfaceWidth:int = 800;
		private const _surfaceHeight:int = 400;
		private var _mainSurface:Sprite;
		private var _3dSurface:Sprite;
		private var _rootScene:Group;
		private var _3dScene:Scene3D;
		private var _camera:CameraMode7;
		private var _mode7Surface:Shape;
		private var _mode7:Mode7;
		
		// keys and buttons pressed
		private var _upPush:int;
		private var _downPush:int;
		private var _leftPush:int;
		private var _rightPush:int;
		

		public function SandyMode7 ()
		{
			// stage init
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = Math.round(_framerate * 1.3);
			stage.quality = StageQuality.HIGH;

			// main surface
			_mainSurface = new Sprite();
			addChild (_mainSurface);
			_mainSurface.scrollRect = new Rectangle(0,0,_surfaceWidth,_surfaceHeight);

			////// we init the 3D
			_3dSurface = new Sprite();
			_mainSurface.addChild (_3dSurface);
			_rootScene = new Group("root");
			// note the special mode7 camera
			_camera = new CameraMode7(_surfaceWidth,_surfaceHeight);
			_camera.x = 0;
			_camera.y = 100;
			_camera.z = 0;
			_camera.tilt = 20;
			_3dScene = new Scene3D("scene",_3dSurface,_camera,_rootScene);
			_rootScene.addChild (_camera);
			_mode7 = new Mode7();
			var l_oTexture:BitmapData = new GroundTextureMap (0, 0);
			_mode7.setBitmap ( l_oTexture );
			_mode7.setHorizon (true, 0x000000, 1);
			_mode7.setNearFar (true);
			_rootScene.addChild( _mode7 );
			_mode7.repeatMap = false;

			var s:Sphere = new Sphere ("sphere", 50);
			s.appearance = new Appearance ( new BitmapMaterial (l_oTexture) );
			_rootScene.addChild( s ); s.y =  50;
			//////
			// init some variables
			_upPush = 0;
			_downPush = 0;
			_leftPush = 0;
			_rightPush = 0;

			// add listeners
			stage.addEventListener (Event.RESIZE, onResize);
			stage.addEventListener (Event.ENTER_FRAME, onEnterFrameHandler);

			stage.addEventListener (KeyboardEvent.KEY_DOWN, onKey);
			stage.addEventListener (KeyboardEvent.KEY_UP, onKey);

			// ask for a resize
			onResize (null);

		}

		// private functions //

		// events callbacks //

		private function onResize (evt:Event):void
		{
			_mainSurface.x = Math.round((stage.stageWidth - _surfaceWidth) / 2);
			_mainSurface.y = Math.round((stage.stageHeight - _surfaceHeight) / 2);
		}

		private function onEnterFrameHandler (evt:Event):void
		{
			(_3dScene.root.getChildByName("sphere") as Shape3D).rotateY ++;
			_camera.rotateY += (_leftPush - _rightPush) * 2;
			var rotationRadian:Number=Math.PI*_camera.rotateY/180;
			_camera.x += Math.sin(- rotationRadian) * (_upPush - _downPush) * 8;
			_camera.z += Math.cos(- rotationRadian) * (_upPush - _downPush) * 8;
			_3dScene.render ();
		}

		private function onKey (kEvt:KeyboardEvent):void
		{
			if (kEvt.type==KeyboardEvent.KEY_DOWN)
			{
				if (kEvt.keyCode==Keyboard.UP)
				{
					_upPush=1;
				}
				else if (kEvt.keyCode == Keyboard.DOWN)
				{
					_downPush=1;
				}
				else if (kEvt.keyCode == Keyboard.LEFT)
				{
					_leftPush=1;
				}
				else if (kEvt.keyCode == Keyboard.RIGHT)
				{
					_rightPush=1;
				}
			}
			else if (kEvt.type == KeyboardEvent.KEY_UP)
			{
				if (kEvt.keyCode==Keyboard.UP)
				{
					_upPush=0;
				}
				else if (kEvt.keyCode == Keyboard.DOWN)
				{
					_downPush=0;
				}
				else if (kEvt.keyCode == Keyboard.LEFT)
				{
					_leftPush=0;
				}
				else if (kEvt.keyCode == Keyboard.RIGHT)
				{
					_rightPush=0;
				}
			}
		}
	}
}