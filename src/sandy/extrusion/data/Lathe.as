package sandy.extrusion.data 
{
	import sandy.core.data.Point3D;	

	/**
	 * Circular, spiral or helix arc.
	 * @author makc
	 */
	public class Lathe extends Curve3D 
	{

		/**
		 * Generates circular, spiral or helix arc.
		 * @param	center Arc center.
		 * @param	axis Axis of revolution.
		 * @param	reference A Point3D that specifies direction to count angle from. Must be non-collinear to axis.
		 * @param	angle0 Start angle.
		 * @param	angle1 End angle.
		 * @param	step Angle step.
		 * @param	radius0 Start radius.
		 * @param	radius1 End radius.
		 * @param	height0 Start height.
		 * @param	height1 End height.
		 * @param	scale0 Start scale.
		 * @param	scale1 End scale.
		 */
		public function Lathe(center:Point3D, axis:Point3D, reference:Point3D, angle0:Number = 0, angle1:Number = Math.PI, step:Number = 0.3, radius0:Number = 100, radius1:Number = 100, height0:Number = 0, height1:Number = 0, scale0:Number = 1, scale1:Number = 1)
		{
			super();

			// compute local coordinates
			var x:Point3D = orthogonalize(axis, reference);
			if (x.getNorm() > 0) 
				x.normalize(); 
			else 
				x.x = +1;
				
			var y:Point3D = axis.clone();
			if (y.getNorm() > 0) 
				y.normalize(); 
			else
				y.y = +1;
				
			var z:Point3D = x.cross(y);

			// compute dot bases
			var basex:Point3D = new Point3D(x.x, y.x, z.x);
			var basey:Point3D = new Point3D(x.y, y.y, z.y);
			var basez:Point3D = new Point3D(x.z, y.z, z.z);

			// generate curve
			var a:Number = angle0;
			while (((angle0 <= angle1) && (a <= angle1)) || ((angle0 > angle1) && (a >= angle1))) 
			{
				var ca:Number = Math.cos(a), sa:Number = Math.sin(a);

				var r:Number = radius0;
				if (angle1 != angle0) r = (a - angle0) * (radius1 - radius0) / (angle1 - angle0) + radius0;

				var h:Number = height0;
				if (angle1 != angle0) h = (a - angle0) * (height1 - height0) / (angle1 - angle0) + height0;

				// point x = r cos a, z = r sin a, y = h
				var vector:Point3D = new Point3D(r * ca, h, r * sa);
				v.push(new Point3D(basex.dot(vector), basey.dot(vector), basez.dot(vector)));

				// tangent (thank to mathcad for this solution :)
				var tangent:Point3D = new Point3D(-r * sa, 0, r * ca);
				if (angle1 != angle0) 
				{
					tangent.x += ca * (radius1 - radius0) / (angle1 - angle0);
					tangent.y += (height1 - height0) / (angle1 - angle0);
					tangent.z += sa * (radius1 - radius0) / (angle1 - angle0);
				}
				if (tangent.getNorm() > 0) tangent.normalize(); else tangent.z = +1;
				t.push(new Point3D(basex.dot(tangent), basey.dot(tangent), basez.dot(tangent)));

				// normal (too lazy to solve this; but should be close to x = -cos a, z = -sin a, y = 0)
				var normal:Point3D = orthogonalize(tangent, new Point3D(-ca, 0, -sa));
				if (normal.getNorm() > 0) normal.normalize(); else normal.y = +1;
				n.push(new Point3D(basex.dot(normal), basey.dot(normal), basez.dot(normal)));

				// scale
				var scale:Number = scale0;
				if (angle1 != angle0) scale = (a - angle0) * (scale1 - scale0) / (angle1 - angle0) + scale0;
				s.push(scale);

				// next angle
				a += step;
			}
		}
	}
}