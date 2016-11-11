package sandy.extrusion.data 
{
	import sandy.core.data.Matrix4;
	import sandy.core.data.Point3D;

	/**
	 * Specifies a curve in 3D space.
	 * @author makc
	 */
	public class Curve3D 
	{
		/**
		 * Array of points that curve passes through.
		 */
		public var v:Array;

		/**
		 * Array of tangent unit Point3Ds at curve points.
		 */
		public var t:Array;

		/**
		 * Array of normal unit Point3Ds at curve points.
		 */
		public var n:Array;

		/**
		 * Array of binormal unit Point3Ds at curve points. Set to null in order to re-calculate it from t and n.
		 * @see http://en.wikipedia.org/wiki/Frenet-Serret_frame
		 */
		public function get b():Array 
		{
			if (_b == null) b = null; 
			return _b;
		}

		public function set b(arg:Array):void 
		{
			if (arg != null) 
			{
				_b = arg;
			} 
			else if ((t != null) && (n != null)) 
			{
				_b = []; 
				var i:int, N:int = Math.min(t.length, n.length);
				for (i = 0;i < N; i++) 
				{
					_b[i] = Point3D(t[i]).cross(Point3D(n[i]));
				}
			}
		}

		private var _b:Array;

		/**
		 * Array of scalar values at curve points. toSections method uses
		 * these values to scale crossections.
		 */
		public var s:Array;

		/**
		 * Computes matrices to use this curve as extrusion path.
		 * @param stabilize whether to flip normals after inflection points.
		 * @return array of Matrix4 objects.
		 * @see Extrusion
		 */
		public function toSections(stabilize:Boolean = true):Array 
		{
			if ((t == null) || (n == null)) return null;

			var sections:Array = [], i:int, N:int = Math.min(t.length, n.length), m1:Matrix4, m2:Matrix4 = new Matrix4;
			var normal:Point3D = new Point3D, binormal:Point3D = new Point3D;
			for (i = 0;i < N; i++) 
			{
				normal.copy(n[i]); 
				binormal.copy(b[i]);
				if (stabilize && (i > 0)) 
				{
					if (Point3D(n[i - 1]).dot(normal) * Point3D(t[i - 1]).dot(t[i]) < 0) 
					{
						normal.scale(-1); 
						binormal.scale(-1);
					}
				}
				m1 = new Matrix4; 
				m1.fromPoint3Ds(normal, binormal, t[i], v[i]);
				m2.scale(s[i], s[i], s[i]); 
				m1.multiply(m2);
				sections[i] = m1;
			}
			return sections;
		}

		/**
		 * Return Point3D perpendicular to Point3D and as close to hint as possible.
		 * @param	Point3D
		 * @param	hint
		 * @return
		 */
		protected function orthogonalize(p_oPoint:Point3D, hint:Point3D):Point3D 
		{
			var w:Point3D = p_oPoint.cross(hint); 
			w.crossWith(p_oPoint); 
			return w;
		}

		/**
		 * Creates empty Curve3D object.
		 */
		public function Curve3D()
		{
			v = []; 
			t = []; 
			n = []; 
			s = [];
		}
	}
}