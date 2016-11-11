package
{
	import flash.filters.*

	import sandy.core.*
	import sandy.core.data.*
	import sandy.core.scenegraph.*
	import sandy.math.*

	public class Galaxy
	{
		public function Galaxy ()
		{
			// generate 4500 stars in nice spiral pattern
			sf = new StarField ();
			generate1500 (); generate1500 (); generate1500 ();
			sf.container.filters = [ new GlowFilter (clr2[c], 1, 20, 20, 6) ];
			sf.container.blendMode = "add";
			sf.fadeFrom = 0;
			sf.fadeTo = 1e6;
			c++; c%=3;
			
			// init physics
			var i:int;
			M = 5;
			C = new Point3D (0, 0, 0); // zero
			var dC:Point3D = new Point3D ();
			for (i=0; i<sf.stars.length; i++)
			{
				dC.copy (sf.stars[i].getPoint3D ()); dC.scale (1.0 / sf.stars.length); C.add (dC);
			}
			V = new Point3D (0.1, 0, 0); // Point3DMath.sphrand (0.1, 0.3);
			var R:Point3D = new Point3D ();
			for (i=0; i<sf.stars.length; i++)
			{
				R.copy (sf.stars[i].getPoint3D ()); R.sub (C);
				var r:Number = R.getNorm ();
				var v:Number = Math.sqrt (G * M / r) * (1 - 0.2 * Math.random () + 0.1 * Math.random ());
				starV[i] = new Point3D (R.y, -R.x, R.z);
				starV[i].normalize (); starV[i].scale (v); starV[i].add (V);
			}

			// apply random rotation and translation
			var ref:Point3D = Point3DMath.sphrand (20, 50);
			var axis:Point3D = Point3DMath.sphrand (1, 2); axis.normalize ();
			var pAngle:Number = 360 * Math.random ();
			var m:Matrix4 = Matrix4Math.axisRotationPoint3D (axis, pAngle);
			C.copy (Matrix4Math.transform (m, C)); C.add (ref);
			V.copy (Matrix4Math.transform (m, V));
			for (i=0; i<sf.stars.length; i++)
			{
				var tmp:Point3D = Matrix4Math.transform (m, sf.stars[i].getPoint3D ()); tmp.add (ref);
				sf.stars[i].x = tmp.x; sf.stars[i].y = tmp.y; sf.stars[i].z = tmp.z;
				starV[i].copy (Matrix4Math.transform (m, starV[i]));
			}
		}

		// Physics-related stuff
		public var G:Number = 1;
		public var M:Number; // center mass
		public var C:Point3D; // center coordinates
		public var V:Point3D; // center velocity
		public var starV:Array = []; // stars velocities
		

		// Appearance-related stuff
		private static var c:int = 0;
		private var clr:Array = [
			// 1st galaxy is in chades of blue
			[0x0080FF, 0x8080E4, 0xB0B0FF],
			// 2nd galaxy is in shades of gold
			[0xFF8000, 0xE48080, 0xFFB0B0],
			// 3rd galaxy is in shades of green
			[0x40FF40, 0x80E480, 0xB0FFB0]
		];
		private var clr2:Array = [
			0x007fff, // blue
			0xff7f00, // gold
			0x3fff3f // green
		];

		// I wrote this code back in late '90s in TurboPascal
		// By now, I have no idea how it works, and what those magic numbers are :)
		private function generate1500 ()
		{
			var I:Number, J:Number, K:Number,
			s:Number, L:Number, d:Number, R:Number,
			dX:Number, dY:Number, dZ:Number,
			c2:Number;
			var Rm:Number = 20, A:Number = 0.3;
			
			for (I = 0; I < 101; I++)
			{
				A = A + 0.03;
				R = A * Rm;
				for (J = 0; J < 5 - Math.floor(I / 20); J++)
				{
					for (K = 0; K < 5; K++)
					{
						L = clr[c][(R > 3 * Rm * Math.random()) ? 0 : 1];
						c2 = (R > 2 * Rm * Math.random()) ? 1 : 2;
						if (A < 0.6) L = clr[c][2];
						s = Math.max (2, Rm - R / 3);

						dX = R * Math.cos(A + K * 2 * Math.PI / 5) + 0.2 * ((100 - I) * Math.random() + I / 2);
						dY = R * Math.sin(A + K * 2 * Math.PI / 5) + 0.2 * ((100 - I) * Math.random() + I / 2);
						dZ = s * (Math.random() - Math.random());

						sf.stars.push (new Vertex (dX, dY, dZ));
						sf.starColors.push (0x1000000 * /* alpha */ (255 - 120 * c2) + /* color */ L);
					}
				}
			}
		}

		public var sf:StarField;
	}
}