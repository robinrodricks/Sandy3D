package 
{
	import flash.display.*;
	import flash.events.*;

	import sandy.core.*;
	import sandy.core.data.*;
	import sandy.events.*;
	import sandy.core.scenegraph.*;
	import sandy.primitive.*;
	import sandy.materials.*;
	import sandy.view.*;

	public class MaterialDispose extends BasicView
	{
		public var mat:BitmapMaterial;

		public function MaterialDispose ()
		{
			super ();
			init (465, 465);

			var b:BitmapData = new BitmapData(1000,1000,false,0xFFCC00);
			var s:Sphere = addSphere();
			s.appearance = makeBitmapAppearance(b);
			mat = BitmapMaterial(s.appearance.frontMaterial);
			
			s.enableEvents = true;
			s.addEventListener( MouseEvent.CLICK, disposeMaterialHandler );
			
			render();
		}
		
		private function disposeMaterialHandler( pEvt:Shape3DEvent ):void
		{
			var s:Shape3D = pEvt.shape;
			s.appearance.dispose();
		}
	}
}