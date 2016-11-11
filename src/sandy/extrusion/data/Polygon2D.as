package sandy.extrusion.data
{
	import flash.geom.Point;
	import flash.geom.Rectangle;	

	/**
	 * 2D polygon class.
	 *
	 * @author makc
	 * @date 13.03.2008
	 */
	public class Polygon2D
	{
		/**
		 * Ordered array of Point objects.
		 */
		public var vertices:Array;

		/**
		 * Creates Polygon2D instance.
		 * @param points array to copy to vertices property.
		 * @see #vertices
		 */
		public function Polygon2D(points:Array = null)
		{
			// points need to be copied here
			// to set reference use vertices
			if (points != null) this.vertices = points.slice();
		}

		/**
		 * Calculates Polygon2D oriented area.
		 * @see http://local.wasp.uwa.edu.au/~pbourke/geometry/clockwise/
		 */
		public function area():Number
		{
			var a:Number = 0, n:int = vertices.length;
			for (var i:int = 0;i < n; i++)
				a += vertices[i].x * vertices[(i + 1) % n].y - vertices[(i + 1) % n].x * vertices[i].y;
			return 0.5 * a;
		}

		/**
		 * Returns array of edges.
		 * @param reorient If true, vertices in edges are ordered.
		 * @return Array of vertice pairs.
		 */
		public function edges(reorient:Boolean = false):Array
		{
			var n:int = vertices.length;
			var r:Array = [];
			for (var i:int = 0;i < n; i++)
			{
				r[i] = [];
				r[i][0] = vertices[i].clone();
				r[i][1] = vertices[(i + 1) % n].clone();
				if (reorient && ((r[i][0].y > r[i][1].y) || ((r[i][0].y == r[i][1].y) && (r[i][0].x > r[i][1].x))))
							r[i].reverse();
			}
			return r;
		}

		/**
		 * Tests if point is inside or not.
		 * At first, I thought this will be needed for tesselation, so here you have it :)
		 * @param point Point to test.
		 * @param includeVertices if false, vertices are not considered to be inside.
		 * @return True if point is inside.
		 */
		public function hitTest(point:Point, includeVertices:Boolean = true):Boolean
		{
			// first, loop through all vertices
			var i:int, n:int = vertices.length;
			for (i = 0;i < n; i++)
				if (Point.distance(vertices[i], point) == 0)
					return includeVertices;

			// due to some topology theorem, if the ray intersects shape
			// perimeter odd number of times, the point is inside

			// shorter and faster code thanks to Alluvian
			// http://board.flashkit.com/board/showpost.php?p=4037392&postcount=5

			var V:Array = vertices.slice(); 
			V.push(V[0]);

			var crossing:int = 0; 
			n = V.length - 1;
			for (i = 0;i < n; i++) 
			{
				if (((V[i].y <= point.y) && (V[i + 1].y > point.y)) || ((V[i].y > point.y) && (V[i + 1].y <= point.y))) 
				{
					var vt:Number = (point.y - V[i].y) / (V[i + 1].y - V[i].y);
					if (point.x < V[i].x + vt * (V[i + 1].x - V[i].x)) 
					{
						crossing++;
					}
				}
			}

			return (crossing % 2 != 0);
		}

		/**
		 * Checks for edge intersection.
		 * @return True if edges intersect in X pattern.
		 * @see http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
		 */
		private function edge2edge(edge1:Array, edge2:Array):Boolean
		{
			var x1:Number = edge1[0].x, y1:Number = edge1[0].y,
				x2:Number = edge1[1].x, y2:Number = edge1[1].y,
				x3:Number = edge2[0].x, y3:Number = edge2[0].y,
				x4:Number = edge2[1].x, y4:Number = edge2[1].y;

			// work around bug caused by floating point imprecision
			if (((x1 == x3) && (y1 == y3)) || ((x2 == x4) && (y2 == y4)) ||
				((x1 == x4) && (y1 == y4)) || ((x2 == x3) && (y2 == y3))) return false;

			var a:Number = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);
			var b:Number = (x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3);
			var d:Number = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);

			return (d != 0) && (0 < a / d) && (a / d < 1) && (0 < b / d) && (b / d < 1);
		}

		/**
		 * Removes links that no longer link to anything.
		 */
		private function removeOrphanLinks():void
		{
			var ok:Boolean, i:int, n:int;
			do
			{
				ok = true;
				n = vertices.length;
				for (i = 0;i < n; i++)
				{
					if (Point.distance(vertices[(i + n - 1) % n], vertices[(i + 1) % n]) == 0)
					{
						vertices.splice(((i + 1) % n == 0) ? 0 : i, 2); 
						i = n; 
						ok = false;
					}
				}
			}
			while (!ok);
		}

		/**
		 * Simple polygon tesselator.
		 * <p>This handles both concave and convex non-selfintersecting polygons.</p>
		 * @return Array of Polygon2D objects.
		 */
		public function triangles():Array
		{
			var mesh:Array = [], edges1:Array, edges2:Array = edges();
			var rest:Polygon2D = new Polygon2D(vertices);
			var o:Number = area();
			var i:int = 0, j:int, k:int, n:int, m:int;
			var ok:Boolean;

			while (rest.vertices.length > 2)
			{
				n = rest.vertices.length;
				var tri:Polygon2D = new Polygon2D([rest.vertices[(i + n - 1) % n], rest.vertices[i], rest.vertices[(i + 1) % n]]);

				// a triangle goes into mesh, if:
				// 1) it has same orientation with the polygon
				// 2) none of other vertices fall inside of triangle
				// 3) it has no open intersections with polygon edges
				ok = false;
				if (tri.area() * o > 0)
				{
					edges1 = tri.edges();

					ok = true;
					m = vertices.length;
					for (k = 0;k < m; k++)
					if (tri.hitTest(vertices[k], false))
					{
						ok = false; 
						k = m;
					}
					
					if (ok)
					{
						for (j = 0;j < 3; j++)
						for (k = 0;k < m; k++)
						if (edge2edge(edges1[j], edges2[k]))
						{
							ok = false; 
							j = 3; 
							k = m;
						}
					}
				}

				// ok, so...
				if (ok)
				{
					mesh.push(tri);
					rest.vertices.splice(i, 1);
					// if we have orphan link left, remove it
					rest.removeOrphanLinks();
					// start all over
					i = 0;
				}
				else
				{
					i++;
					if (i > n - 1)
						// whatever is left, cannot be handled
						// either because this tesselator sucks, or because vertices list is malformed
						return mesh;
				}
			}
			return mesh;
		}

		/**
		 * Bounding box.
		 */
		public function bbox():Rectangle
		{
			var xmin:Number = 1e99, xmax:Number = -1e99, ymin:Number = xmin, ymax:Number = xmax;
			for each (var p:Point in vertices)
			{
				if (p.x < xmin) xmin = p.x;
				if (p.x > xmax) xmax = p.x;
				if (p.y < ymin) ymin = p.y;
				if (p.y > ymax) ymax = p.y;
			}
			return new Rectangle(xmin, ymin, xmax - xmin, ymax - ymin);
		}

		/**
		 * Convex hull.
		 */
		public function convexHull():Polygon2D
		{
			// code derived from http://notejot.com/2008/11/convex-hull-in-2d-andrews-algorithm/
			var pointsHolder:Array = [];//vertices.slice ();

			// need to filter out duplicates 1st
			var i:int, j:int;
			for (i = 0;i < vertices.length; i++) 
			{
				var d:Number = 1;
				for (j = 0;(d > 0) && (j < pointsHolder.length); j++) 
				{
					d *= Point.distance(vertices[i], pointsHolder[j]);
				}
				if (d > 0) 
				{
					pointsHolder.push(vertices[i]);
				}
			}

			var topHull:Array = [];
			var bottomHull:Array = [];

			// triangles are always convex
			if (pointsHolder.length < 4)
				return new Polygon2D(pointsHolder);

			// lexicographic sort
			pointsHolder.sortOn(["x", "y"], Array.NUMERIC);

			// compute top part of hull
			topHull.push(0);
			topHull.push(1);				
 
			for (i = 2;i < pointsHolder.length; i++) 
			{
				if(towardsLeft(pointsHolder[topHull[topHull.length - 2]], pointsHolder[topHull[topHull.length - 1]], pointsHolder[i])) 
				{
					topHull.pop();

					while (topHull.length >= 2) 
					{
						if(towardsLeft(pointsHolder[topHull[topHull.length - 2]], pointsHolder[topHull[topHull.length - 1]], pointsHolder[i])) 
						{
							topHull.pop();
						} 
						else 
						{
							topHull.push(i);
							break;
						}
					}
					if (topHull.length == 1)
						topHull.push(i);
				} 
				else 
				{
					topHull.push(i);
				}
			}

			// compute bottom part of hull
			bottomHull.push(0);
			bottomHull.push(1);				
 
			for (i = 2;i < pointsHolder.length; i++) 
			{

				if (!towardsLeft(pointsHolder[bottomHull[bottomHull.length - 2]], pointsHolder[bottomHull[bottomHull.length - 1]], pointsHolder[i])) 
				{
					bottomHull.pop();

					while (bottomHull.length >= 2) 
					{
						if (!towardsLeft(pointsHolder[bottomHull[bottomHull.length - 2]], pointsHolder[bottomHull[bottomHull.length - 1]], pointsHolder[i])) 
						{
							bottomHull.pop();
						} 
						else 
						{
							bottomHull.push(i);
							break;
						}
					}
					if (bottomHull.length == 1)
						bottomHull.push(i);
				} 
				else 
				{
					bottomHull.push(i);
				}
			}

			bottomHull.reverse();
			bottomHull.shift();

			// convert to Polygon2D format
			var ix:Array = topHull.concat(bottomHull);
			var vs:Array = [];
			for (i = 0;i < ix.length - 1; i++)
				vs.push(pointsHolder[ix[i]]);

			return new Polygon2D(vs);
		}

		/**
		 * Used by convexHull() code.
		 */
		private function towardsLeft(origin:Point, p1:Point, p2:Point):Boolean 
		{
			// funny thing is that convexHull() works regardless if either < or > is used here
			return (new Polygon2D([origin, p1, p2]).area() < 0);
		}
	}
}
