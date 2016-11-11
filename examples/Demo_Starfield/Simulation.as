package
{
	import flash.display.*;
	import flash.events.*

	import sandy.core.*;
	import sandy.core.data.*;
	import sandy.core.scenegraph.*;

	public class Simulation extends Sprite
	{
		private var scene:Scene3D = new Scene3D ("myScene", this as Sprite, new Camera3D (550, 400), new Group ("root"));
		private var tg:TransformGroup = new TransformGroup ();

		public function Simulation ()
		{
			reset (null);
			gc0 = new Sprite2D ("gc0", new GalacticCenter ()); tg.addChild (gc0);
			gc1 = new Sprite2D ("gc1", new GalacticCenter ()); tg.addChild (gc1);
			scene.root.addChild (tg);
			stage.addEventListener (MouseEvent.CLICK, reset);
			stage.addEventListener (Event.ENTER_FRAME, render);
		}

		// add more elements to this array to have more galaxies
		private var g:Array = [null, null];

		// sprites to track centers of two galaxies
		private var gc0:Sprite2D, gc1:Sprite2D;

		private function reset (e:MouseEvent):void
		{
			for (var i:int = 0; i < g.length; i++)
			{
				if (g[i] != null)
					g[i].sf.remove ();
				g[i] = new Galaxy ();
				tg.addChild (g[i].sf);
			}
		}

		private function render (e:Event):void
		{
			simulate ();
			gc0.x = g[0].C.x; gc0.y = g[0].C.y; gc0.z = g[0].C.z;
			gc1.x = g[1].C.x; gc1.y = g[1].C.y; gc1.z = g[1].C.z;
			tg.rotateY = mouseX; tg.tilt = mouseY;
			scene.render ();
		}

		private var G:Number = 1;
		private function simulate ()
		{
			// run simulation cycle
			var i:int, j:int, k:int, m:int, n:int;
			// --
			m = g.length;
			// --
			var r:Point3D = new Point3D ();
			var a:Point3D = new Point3D ();
			var d:Number;
			// update velocities of galactic centers
			for (i = 0; i < m; i++)
			for (j = 0; j < m; j++)
			if (i != j)
			{
				// distance from i-th to j-th center
				r.copy (g[j].C); r.sub (g[i].C); d = Math.max (4, r.getNorm ());
	
				// acceleration of i-th towards j-th center
				a.copy (r); a.scale (G * g[j].M / (d * d * d) + Math.exp(1e-6 * d) -1);
	
				// update i-th velocity
				g[i].V.add (a);
			}
			// now move centers
			for (i = 0; i < m; i++)
			{
				g[i].C.add (g[i].V);
			}
			// stars
			for (i = 0; i < m; i++)
			{
				n = g[i].sf.stars.length;
				for (j = 0; j < n; j++)
				{
					var s:Vertex = g[i].sf.stars[j] as Vertex;
					var v:Point3D = g[i].starV[j] as Point3D;

					for (k = 0; k < m; k++)
					{
						// distance Point3D from j-th star to k-th galaxy center
						r.copy (g[k].C); r.sub (s.getPoint3D ()); d = Math.max (2, r.getNorm ());

						// acceleration of j-th star towards k-th center
						a.copy (r); a.scale (G * g[k].M / (d * d * d) + Math.exp(1e-7 * d) -1);

						// update star velocities
						v.add (a);
					}

					// move stars
					s.x += v.x; s.y += v.y; s.z += v.z;
				}
			}
		}
	}
}