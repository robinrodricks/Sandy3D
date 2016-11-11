
package sandy.core.data
{
	import sandy.util.BezierUtil;

	/**
	 * A 3D Bézier path.
	 *
	 * <p>The Bézier path is built form an array of 3D points, by using Bézier equations<br />
	 * With two points the path is degenereated to a straight line. To get a curved line, you need
	 * at least three points. The mid point is used as a control point which gives the curvature.<br />
	 * After that you will have to add three point segments</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		1.0
	 * @version		3.1
	 * @date 		24.08.2007
	 */
	public class BezierPath
	{
		/**
		 * Creates a new Bézier path.
		 */
		public function BezierPath( /*pbBoucle:Boolean*/ )
		{
			_aContainer = new Array();
			_aSegments = new Array();
			_nCrtSegment = 0;
			_bBoucle = false;
			_bCompiled = false;
		}

		/**
		 * Returns a segment of this path identified by its sequence number.
		 *
		 * <p>The Bézier path is made up of a sequence of segments which are internally numbered.
		 * This method returns the n:th segment, where n is the passed in number.</p>
		 *
		 * @param p_nId	The index of the desired segment in the segments array.
		 *
		 * @return An array containing the Bézier curve points [startPoint, controlPoint, endPoint]
		 */
		public function getSegment( p_nId:uint ):Array
		{
			if( p_nId >= 0 && p_nId < _nNbSegments )
			{
				return _aSegments[ int(p_nId) ];
			}
			else
			{
				return null;
			}
		}

		/**
		 * Returns the position in the 3D space at a specific portion of this path.
		 *
		 * If length of the path is regarded as <code>1.0</code> (100%) and the position at 10% of the path is desired
		 * <code>0.1</code> is passed as the.
		 *
		 * @param p_nP	The position of the path length as a percentage ( 0 - 1 ).
		 *
		 * @return The 3D position on the path at the desired position.
		 */
		public function getPosition( p_nP:Number ):Point3D
		{
			var id:Number = Math.floor(p_nP/_nRatio);
			if( id == _nNbSegments )
			{
				id --;
				p_nP = 1.0;
			}
			var seg:Array = getSegment( id );
			return BezierUtil.getPointsOnQuadCurve( (p_nP-id*_nRatio)/_nRatio, seg[0], seg[1], seg[2] );
		}


		/**
		 * Adds a 3D point to this path.
		 *
		 * <p>At least three points are required for a a curved segment. The first point added must be the control point,
		 * followed by segments added in sets of two points.
		 *
		 * <p><strong>Note:</strong> You can't add a point to the path once it has been compiled.</p>
		 *
		 * @param p_nX	The x coordinate of the 3D point.
		 * @param p_nY	The y coordinate of the 3D point.
		 * @param p_nZ	The z coordinate of the 3D point.
		 *
		 * @return Whether the point was added.
		 */
		public function addPoint( p_nX:Number, p_nY:Number, p_nZ:Number ):Boolean
		{
			if( _bCompiled )
			{
				return false;
			}
			else
			{
				_aContainer.push( new Point3D( p_nX, p_nY, p_nZ ) );
				return true;
			}
		}

		/**
		 * Computes the control points for this path.
		 *
		 * <p>Must be called after all segments have been added and before the scene is rendered.</p>
		 */
		public function compile():void
		{
			_nNbPoints = _aContainer.length;
			if( _nNbPoints >= 3 &&  _nNbPoints%2 == 1 )
			{
				trace('sandy.core.data.BezierPath ERROR: Number of points incompatible');
				return;
			}
			_bCompiled = true;
			_nNbSegments = 0;
			var a:Point3D, b:Point3D, c:Point3D;
			for (var i:Number = 0; i <= _nNbPoints-2; i+=2 )
			{
				a = _aContainer[int(i)];
				b = _aContainer[int(i+1)];
				c = _aContainer[int(i+2)];
				_aSegments.push( [ a, b, c ] );
			}
			if( _bBoucle )
			{
				_aSegments.push([
								_aContainer[ int(_nNbPoints) ],
								BezierUtil.getQuadControlPoints(_aContainer[ int(_nNbPoints) ],_aContainer[ 0 ],_aContainer[ 1 ]),
								_aContainer[ 0 ]
								]);
			}
			// --
			_nNbSegments = _aSegments.length;
			_nRatio = 1 / _nNbSegments;
		}

		/**
		 * Returns the number of segments for this path.
		 *
		 * @return The number of segments in this path.
		 */
		public function getNumberOfSegments():uint
		{
			return _nNbSegments;
		}

		/**
		 * Returns a string representation of this object.
		 *
		 * @return	The fully qualified name of this object.
		 */
		public function toString():String
		{
			return "sandy.core.data.BezierPath";
		}

		/**
		 * Transformed coordinates in the local frame of the object.
		 */
		private var _aContainer:Array;

		/**
		 * Array of segments.
		 */
		private var _aSegments:Array;


		/**
		 * Current segment id.
		 */
		private var _nCrtSegment:uint;

		/**
		 * Number of segments of this path.
		 */
		private var _nNbSegments:uint;

		/**
		 * Number of points of this path.
		 */
		private var _nNbPoints:uint;

		/**
		 * Should this path be closed? True if it should false otherwise, default - false
		 */
		private var _bBoucle:Boolean;

		/**
		 * Is this path compiled? True if it is, false otherwise.
		 */
		private var _bCompiled:Boolean;

		private var _nRatio:Number;

	}
}