package sandy.core.scenegraph.mode7{
	import sandy.core.scenegraph.Camera3D;	
	/**	 * CameraMode7 behaves like Camera3D, but with some constraints:	 * - rotations are available only by the rotateY and tilt methods (other are desactivated)	 * - the lookAt method is overrided to respect the available rotations	 * @author Cedric Jules	 */	public class CameraMode7 extends Camera3D
	{		private var _horizon : Number;
		private const PI : Number = Math.PI;
		private const PIon180 : Number = PI / 180;
		private const sin : Function = Math.sin;
		private const cos : Function = Math.cos;
		private const aTan2 : Function = Math.atan2;
		public function CameraMode7(p_nWidth : Number, p_nHeight : Number, p_nFov : Number = 45, p_nNear : Number = 50, p_nFar : Number = 10000	)
		{
			super(p_nWidth, p_nHeight, p_nFov, p_nNear, p_nFar);
		}
		public function get horizon() : Number				{					return _horizon;				}
		public function set horizon(value : Number) : void				{					_horizon = value;				}
		// desactivation of some setters methods

		/**
		 * @private
		 */
		public override function set rotateX(p_nAngle : Number) : void 		{			;		}
		/**		 * @private		 */		public override function set rotateZ(p_nAngle : Number) : void 		{			;		}
		/**		 * @private		 */		public override function set pan(p_nAngle : Number) : void 		{			;		}
		/**		 * @private		 */		public override function set roll(p_nAngle : Number) : void 		{			;		}
		/**		 * @private		 */		public override function rotateAxis(p_nX : Number, p_nY : Number, p_nZ : Number, p_nAngle : Number) : void 		{			;		}
		/**		 * @inheritDoc		 */		public override function lookAt(p_nX : Number, p_nY : Number, p_nZ : Number) : void
		{			_xTarget = p_nX - x;
			_yTarget = p_nY - y;
			_zTarget = p_nZ - z;
			
			_yAngle = -aTan2(_xTarget, _zTarget);
			rotateY = _yAngle / PIon180;
			
			_zTargetBis = _xTarget * sin(-_yAngle) + _zTarget * cos(-_yAngle);
			_tiltAngle = -aTan2(_yTarget, _zTargetBis);
			tilt = _tiltAngle / PIon180;
		}
		// some useful variables to make some computations
		private var _xTarget : Number;
		private var _yTarget : Number;
		private var _zTarget : Number;
		private var _yAngle : Number;
		private var _zTargetBis : Number;
		private var _tiltAngle : Number;
	}
}