
package sandy.core.scenegraph
{
	import sandy.core.data.Matrix4;
	import sandy.core.data.Point3D;	

	/**
	 * ABSTRACT CLASS - super class for all movable objects in the object tree.
	 *
	 * <p> This class should not be directly instatiated, but sub classed.<br/>
	 * The Atransformable class is resposible for scaling, rotation and translation of objects in 3D space.</p>
	 *
	 * <p>Rotations and translations are performed in one of three coordinate systems or reference frames:<br/>
	 * - The local frame which is the objects own coordinate system<br />
	 * - The parent frame which is the coordinate system of the object's parent, normally a TransformGroup<br/>
	 * - The world frame which is the coordinate system of the world, the global system.</p>
	 * <p>Positions, directions, translations and rotations of an ATransformable object are performed in its parent frame.<br />
	 * Tilt, pan and roll, are rotations around the local axes, and moveForward, moveUpwards and moveSideways are translations along local axes.</p>
	 *
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		16.03.2007
	 **/
	public class ATransformable extends Node
	{
		/**
		 * Disable the local transformations applied to this Node if set to false.
		 * They will be applied back once et back to true.
		 */
		public var disable:Boolean = false;
		
		/**
		 * <p>Inverse of the model matrix
		 * The matrix is inverted in comparison of the real model matrix.<br/>
		 * For example, this allows replacement of the objects in the correct camera frame before projection</p>
		 */
		public var invModelMatrix:Matrix4 = new Matrix4 ();
		
		/**
		 * Creates a transformable node in the object tree of the world.
		 *
		 * <p>This constructor should normally not be called directly, but from a sub class.</p>
		 *
		 * @param p_sName	A string identifier for this object
		 */
		public function ATransformable ( p_sName:String="" )
		{
			super( p_sName );
			resetCoords();
		}
		
		/**
		 * Resets the coordinate system for this object. Useful for returning to known state.
		 */
		public function resetCoords (): void 
		{
			// --
			initFrame();
			// --
			_p 		= new Point3D();
			_oScale = new Point3D( 1, 1, 1 );
			_vRotation = new Point3D(0,0,0);
			// --
			_vLookatDown = new Point3D(0.00000000001, -1, 0);// value to avoid some colinearity problems.;
			// --
			_nRoll 	= 0;
			_nTilt 	= 0;
			_nYaw  	= 0;
			// --
			m_tmpMt = new Matrix4();
			m_oMatrix = new Matrix4();
			// --
			changed = true;
		}
		
		/**
		 * Initiates the local coordinate system for this object.
		 *
		 * <p>The local coordinate system for this object is set parallell the parent system.</p>
		 */
		public function initFrame():void
		{
			_vSide 	= new Point3D( 1, 0, 0 );
			_vUp 	= new Point3D( 0, 1 ,0 );
			_vOut 	= new Point3D( 0, 0, 1 );
			_vRotation = new Point3D(0,0,0);
			changed = true;
		}

		public function get matrix():Matrix4
		{
		    	return m_oMatrix;
		}

		/**
		 * This property allows you to directly set the matrix you want to a transformable object.
		 * But be careful with its use. It modifies the rotation AND the position.
		 * WARNING : Please remove any scale from this matrix. This is not managed yet.
		 * WARNING : Please think about call initFrame before changing this frame. Without calling this method first, the frame will stay local, and the transformation will be applied
		 * locally.
		 * @param p_oMatrix The new local matrix for this node
		 */
		public function set matrix( p_oMatrix:Matrix4 ):void
		{
			m_oMatrix = p_oMatrix;
		    // --
		    m_oMatrix.transform3x3(_vSide);
		    m_oMatrix.transform3x3(_vUp);
		    m_oMatrix.transform3x3(_vOut);
		    // --
		    _vSide.normalize();
		    _vUp.normalize();
		    _vOut.normalize();
		    // --
		    _p.x = p_oMatrix.n14;
		    _p.y = p_oMatrix.n24;
		    _p.z = p_oMatrix.n34;
		    // --
		    changed = true;
		}
		

		/**
		 * @private
		 */
		public function set x( p_nX:Number ):void
		{
			if( p_nX == _p.x ) return;
			_p.x = p_nX;
			changed = true;
		}
		/**
		 * x position of this object in its parent frame.
		 */
		public function get x():Number
		{
			return _p.x;
		}

		/**
		 * @private
		 */
		public function set y( p_nY:Number ):void
		{
			if( p_nY == _p.y ) return;
			_p.y = p_nY;
			changed = true;
		}

		/**
		 * y position of this object in its parent frame.
		 */
		public function get y():Number
		{
			return _p.y;
		}

		/**
		 * @private
		 */
		public function set z( p_nZ:Number ):void
		{
			if( p_nZ == _p.z ) return;
			_p.z = p_nZ;
			changed = true;
		}

		/**
		 * z position of the node in its parent frame.
		 */
		public function get z():Number
		{
			return _p.z;
		}

		/**
		 * getLookAt - obtain last value set via lookAt() method; may not be valid if other camera movement has occurred since then.
		 */
		public function getLookAt():Point3D
		{
			return _vLookAt;
		}
		/**
		 * Forward direction ( local z ) in parent coordinates.
		 */
		public function get out():Point3D
		{
			return _vOut;
		}

		/**
		 * Side direction ( local x ) in parent coordinates.
		 */
		public function get side():Point3D
		{
			return _vSide;
		}

		/**
		 * Up direction ( local y ) in parent coordinates.
		 */
		public function get up():Point3D
		{
			return _vUp;
		}

		/**
		 * @private
		 */
		public function set scaleX( p_nScaleX:Number ):void
		{
			if( _oScale.x == p_nScaleX ) return;
			_oScale.x = p_nScaleX;
			changed = true;
		}

		/**
		 * x scale of this object.
		 *
		 * <p>A value of 1 scales to the original x scale, a value of 2 doubles the x scale.<br/>
		 * NOTE : This value does not affect the camera object.</p>
		 */
		public function get scaleX():Number
		{
			return _oScale.x;
		}

		/**
		 * @private
		 */
		public function set scaleY( p_nScaleY:Number ):void
		{
			if( _oScale.y == p_nScaleY ) return;
			_oScale.y = p_nScaleY;
			changed = true;
		}

		/**
		 * y scale of this object.
		 *
		 * <p>A value of 1 scales to the original y scale, a value of 2 doubles the y scale.<br/>
		 * NOTE : This value does not affect the camera object.</p>
		 */
		public function get scaleY():Number
		{
			return _oScale.y;
		}

		/**
		 * @private
		 */
		public function set scaleZ( p_nScaleZ:Number ):void
		{
			if( _oScale.z == p_nScaleZ ) return;
			_oScale.z = p_nScaleZ;
			changed = true;
		}

		/**
		 * z scale of this object.
		 *
		 * <p>A value of 1 scales to the original z scale, a value of 2 doubles the z scale.<br/>
		 * NOTE : This value does not affect the camera object.</p>
		 */
		public function get scaleZ():Number
		{
			return _oScale.z;
		}

		/**
		 * Translates this object along its side Point3D ( local x ) in the parent frame.
		 *
		 * <p>If you imagine yourself in the world, it would be a step to your right or to your left</p>
		 *
		 * @param p_nD	How far to move
		 */
		public function moveSideways( p_nD : Number ) : void
		{
			changed = true;
			_p.x += _vSide.x * p_nD;
			_p.y += _vSide.y * p_nD;
			_p.z += _vSide.z * p_nD;
		}

		/**
		 * Translates this object along its up Point3D ( local y ) in the parent frame.
		 *
		 * <p>If you imagine yourself in the world, it would be a step up or down<br/>
		 * in the direction of your body, not always vertically!</p>
		 *
		 * @param p_nD	How far to move
		 */
		public function moveUpwards( p_nD : Number ) : void
		{
			changed = true;
			_p.x += _vUp.x * p_nD;
			_p.y += _vUp.y * p_nD;
			_p.z += _vUp.z * p_nD;
		}

		/**
		 * Translates this object along its forward Point3D ( local z ) in the parent frame.
		 *
		 * <p>If you imagine yourself in the world, it would be a step forward<br/>
		 * in the direction you look, not always horizontally!</p>
		 *
		 * @param p_nD	How far to move
		 */
		public function moveForward( p_nD : Number ) : void
		{
			changed = true;
			_p.x += _vOut.x * p_nD;
			_p.y += _vOut.y * p_nD;
			_p.z += _vOut.z * p_nD;
		}

		/**
		 * Translates this object parallel to its parent zx plane and in its forward direction.
		 *
		 * <p>If you imagine yourself in the world, it would be a step in the forward direction,
		 * but without changing your altitude ( constant global z ).</p>
		 *
		 * @param p_nD	How far to move
		 */
		public function moveHorizontally( p_nD:Number ) : void
		{
			changed = true;
			_p.x += _vOut.x * p_nD;
			_p.z += _vOut.z * p_nD;
		}

		/**
		 * Translates this object vertically in ots parent frame.
		 *
		 * <p>If you imagine yourself in the world, it would be a strictly vertical step,
		 * ( in the global y direction )</p>
		 *
		 * @param p_nD	How far to move
		 */
		public function moveVertically( p_nD:Number ) : void
		{
			changed = true;
			_p.y += p_nD;
		}

		/**
		 * Translates this object laterally in its parent frame.
		 *
		 * <p>This is a translation in the parent's x direction.</p>
		 *
		 * @param p_nD	How far to move
		 */
		public function moveLateraly( p_nD:Number ) : void
		{
			changed = true;
			_p.x += p_nD;
		}

		/**
		 * Translate this object from it's current position with the specified offsets.
		 *
		 * @param p_nX 	Offset that will be added to the x coordinate of the object
		 * @param p_nY 	Offset that will be added to the y coordinate of the object
		 * @param p_nZ 	Offset that will be added to the z coordinate of the object
		 */
		public function translate( p_nX:Number, p_nY:Number, p_nZ:Number ) : void
		{
			changed = true;
			_p.x += p_nX;
			_p.y += p_nY;
			_p.z += p_nZ;
		}


		/**
		 * Rotate this object around the specified axis in the parent frame by the specified angle.
		 *
		 * <p>NOTE : The axis will be normalized automatically.</p>
		 *
		 * @param p_nX		The x coordinate of the axis
		 * @param p_nY		The y coordinate of the axis
		 * @param p_nZ		The z coordinate of the axis
		 * @param p_nAngle	The angle of rotation in degrees.
		 */
		public function rotateAxis( p_nX : Number, p_nY : Number, p_nZ : Number, p_nAngle : Number ):void
		{
			changed = true;
			p_nAngle = (p_nAngle + 360)%360;
			var n:Number = Math.sqrt( p_nX*p_nX + p_nY*p_nY + p_nZ*p_nZ );
			// --
			m_tmpMt.axisRotation( p_nX/n, p_nY/n, p_nZ/n, p_nAngle );
			// --
			m_tmpMt.transform3x3(_vSide);
			m_tmpMt.transform3x3(_vUp);
			m_tmpMt.transform3x3(_vOut);
		}

		/**
		 * The position in the parent frame this object should "look at".
		 *
		 * <p>Useful for following a moving object or a static object while this object is moving.<br/>
		 * Normally used when this object is a camera</p>
		 */
		public function lookAtPoint( p_oTarget:Point3D ):void
		{
			lookAt( p_oTarget.x, p_oTarget.y, p_oTarget.z) ;
		}

		/**
		 * Makes this object "look at" the specified position in the parent frame.
		 *
		 * <p>Useful for following a moving object or a static object while this object is moving.<br/>
		 * Normally used when this object is a camera</p>
		 *
		 * @param	p_nX	Number	The x position to look at
		 * @param	p_nY	Number	The y position to look at
		 * @param	p_nZ	Number	The z position to look at
		 */
		public function lookAt( p_nX:Number, p_nY:Number, p_nZ:Number ):void
		{
			changed = true;
			_vLookAt = new Point3D (p_nX, p_nY, p_nZ);
			
			//
			_vOut.x = p_nX; _vOut.y = p_nY; _vOut.z = p_nZ;
			//
			_vOut.sub( _p );
			_vOut.normalize();
			// -- the vOut Point3D should not be colinear with the reference down Point3D!
			_vSide = null;
			_vSide = _vOut.cross( _vLookatDown );
			_vSide.normalize();
			//
			_vUp = null;
			_vUp = _vOut.cross(_vSide );
			_vUp.normalize();
		}

		/**
		 * Rotates this object around an axis parallel to the parent's x axis.
		 *
		 * <p>The object rotates a specified angle ( degrees ) around an axis through the
		 * objects reference point, paralell to the x axis of the parent frame.</p>
		 */
		public function set rotateX ( p_nAngle:Number ):void
		{
			var l_nAngle:Number = (p_nAngle - _vRotation.x);
			if(l_nAngle == 0 ) return;
			changed = true;
			// --
			m_tmpMt.rotationX( l_nAngle );
			m_tmpMt.transform3x3(_vSide);
			m_tmpMt.transform3x3(_vUp);
			m_tmpMt.transform3x3(_vOut);
			// --
			_vRotation.x = p_nAngle;
		}

		/**
		 * @private
		 */
		public function get rotateX():Number
		{
			return _vRotation.x;
		}

		/**
		 * Rotates this object around an axis parallel to the parent's y axis.
		 *
		 * <p>The object rotates a specified angle ( degrees ) around an axis through the
		 * objects reference point, parallel to the y axis of the parent frame.</p>
		 */
		public function set rotateY ( p_nAngle:Number ):void
		{
			var l_nAngle:Number = (p_nAngle - _vRotation.y);
			if(l_nAngle == 0 ) return;
			changed = true;
			// --
			m_tmpMt.rotationY( l_nAngle );
			m_tmpMt.transform3x3(_vSide);
			m_tmpMt.transform3x3(_vUp);
			m_tmpMt.transform3x3(_vOut);
			// --
			_vRotation.y = p_nAngle;
		}

		/**
		 * @private
		 */
		public function get rotateY():Number
		{
			return _vRotation.y;
		}

		/**
		 * Rotates this object around an axis paralell to the parent's z axis.
		 *
		 * <p>The object rotates a specified angle ( degrees ) around an axis through the
		 * objects reference point, paralell to the z axis of the parent frame.</p>
		 */
		public function set rotateZ ( p_nAngle:Number ):void
		{
			var l_nAngle:Number = (p_nAngle - _vRotation.z );
			if(l_nAngle == 0 ) return;
			changed = true;
			// --
			m_tmpMt.rotationZ( l_nAngle );
			m_tmpMt.transform3x3(_vSide);
			m_tmpMt.transform3x3(_vUp);
			m_tmpMt.transform3x3(_vOut);
			// --
			_vRotation.z = p_nAngle;
		}

		/**
		 * @private
		 */
		public function get rotateZ():Number
		{
			return _vRotation.z;
		}

		/**
		 * Rolls this object around the local z axis.
		 *
		 * <p>The roll angle interval is -180 to +180 degrees<br/>
		 * At 0 degrees the local x axis is aligned with the horizon of its parent<br/>
		 * Full roll right = 180 and full roll left = -180 degrees ( upside down ).</p>
		 *
		 * @param p_nAngle 	The roll angle in degrees.
		 */
		public function set roll ( p_nAngle:Number ):void
		{
			var l_nAngle:Number = (p_nAngle - _nRoll);
			if(l_nAngle == 0 ) return;
			changed = true;
			// --
			m_tmpMt.axisRotation ( _vOut.x, _vOut.y, _vOut.z, l_nAngle );
			m_tmpMt.transform3x3(_vSide);
			m_tmpMt.transform3x3(_vUp);
			// --
			_nRoll = p_nAngle;
		}

		/**
		 * @private
		 */
		public function get roll():Number
		{
			return _nRoll;
		}

		/**
		 * Tilts this object around the local x axis.
		 *
		 * <p>The tilt angle interval is -90 to +90 degrees<br/>
		 * At 0 degrees the local z axis is paralell to the zx plane of its parent coordinate system.<br/>
		 * Straight up = +90 and stright down = -90 degrees.</p>
		 *
		 * @param p_nAngle 	The tilt angle in degrees.
		 */
		public function set tilt ( p_nAngle:Number ):void
		{
			var l_nAngle:Number = (p_nAngle - _nTilt);
			if(l_nAngle == 0 ) return;
			changed = true;
			// --
			m_tmpMt.axisRotation ( _vSide.x, _vSide.y, _vSide.z, l_nAngle );
			m_tmpMt.transform3x3(_vOut);
			m_tmpMt.transform3x3(_vUp);
			// --
			_nTilt = p_nAngle;
		}

		/**
		 * Getter for the tilt value
		 */
		public function get tilt():Number
		{
			return _nTilt;
		}

		/**
		 * Pans this object around the local y axis.
		 *
		 * <p>The pan angle interval is 0 to 360 degrees<br/>
		 * Directions within the parent frame are: North = 0, East = 90, South = 180 nad West = 270 degrees.</p>
		 *
		 * @param p_nAngle 	The pan angle in degrees.
		 */
		public function set pan ( p_nAngle:Number ):void
		{
			var l_nAngle:Number = (p_nAngle - _nYaw);
			if(l_nAngle == 0 ) return;
			changed = true;
			// --
			m_tmpMt.axisRotation ( _vUp.x, _vUp.y, _vUp.z, l_nAngle );
			m_tmpMt.transform3x3(_vOut);
			m_tmpMt.transform3x3(_vSide);
			// --
			_nYaw = p_nAngle;
		}

		/**
		 * @private
		 */
		public function get pan():Number
		{
			return _nYaw;
		}

		/**
		 * Sets the position of this object in coordinates of its parent frame.
		 *
		 * @param p_nX 	The x coordinate
		 * @param p_nY 	The y coordiante
		 * @param p_nZ 	The z coordiante
		 */
		public function setPosition( p_nX:Number, p_nY:Number, p_nZ:Number ):void
		{
			changed = true;
			// we must consider the screen y-axis inversion
			_p.x = p_nX;
			_p.y = p_nY;
			_p.z = p_nZ;
		}
		
		/**
		 * Updates this node or object.
		 *
		 * <p>For node's with transformation, this method updates the transformation taking into account the matrix cache system.<br/>
		 * <b>FIXME<b>: Transformable nodes shall upate their transform if necessary before calling this method.</p>
		 *
		 * @param p_oScene The current scene
		 * @param p_oModelMatrix The matrix which represents the parent model matrix. Basically it stores the rotation/translation/scale of all the nodes above the current one.
		 * @param p_bChanged	A boolean value which specify if the state has changed since the previous rendering. If false, we save some matrix multiplication process.
		 */
		public override function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			updateTransform();
			// --
			if( p_bChanged || changed )
			{
				 if( p_oModelMatrix && !disable )
				 {
					modelMatrix.copy(p_oModelMatrix);
					modelMatrix.multiply4x3( m_oMatrix );
				 }
				 else
				 {
					modelMatrix.copy( m_oMatrix );
				 }
				 // -- fast model matrix inverssion
				invModelMatrix.n11 = modelMatrix.n11;
				invModelMatrix.n12 = modelMatrix.n21;
				invModelMatrix.n13 = modelMatrix.n31;
				invModelMatrix.n21 = modelMatrix.n12;
				invModelMatrix.n22 = modelMatrix.n22;
				invModelMatrix.n23 = modelMatrix.n32;
				invModelMatrix.n31 = modelMatrix.n13;
				invModelMatrix.n32 = modelMatrix.n23;
				invModelMatrix.n33 = modelMatrix.n33;
				invModelMatrix.n14 = -(modelMatrix.n11 * modelMatrix.n14 + modelMatrix.n21 * modelMatrix.n24 + modelMatrix.n31 * modelMatrix.n34);
				invModelMatrix.n24 = -(modelMatrix.n12 * modelMatrix.n14 + modelMatrix.n22 * modelMatrix.n24 + modelMatrix.n32 * modelMatrix.n34);
				invModelMatrix.n34 = -(modelMatrix.n13 * modelMatrix.n14 + modelMatrix.n23 * modelMatrix.n24 + modelMatrix.n33 * modelMatrix.n34);
			}
			// --
			super.update( modelMatrix, p_bChanged );
		}

		/**
		 * Updates the transform matrix of the current object/node before it is rendered.
		 */
		public function updateTransform():void
		{
			if( changed )
			{
				m_oMatrix.n11 = _vSide.x * _oScale.x;
				m_oMatrix.n12 = _vUp.x * _oScale.y;
				m_oMatrix.n13 = _vOut.x * _oScale.z;
				m_oMatrix.n14 = _p.x;

				m_oMatrix.n21 = _vSide.y * _oScale.x;
				m_oMatrix.n22 = _vUp.y * _oScale.y;
				m_oMatrix.n23 = _vOut.y * _oScale.z;
				m_oMatrix.n24 = _p.y;

				m_oMatrix.n31 = _vSide.z * _oScale.x;
				m_oMatrix.n32 = _vUp.z * _oScale.y;
				m_oMatrix.n33 = _vOut.z * _oScale.z;
				m_oMatrix.n34 = _p.z;
				// -- normalization of the frame to make sure the rotation error will not become too big.
				_vOut.normalize();
				_vSide.normalize();
				_vUp.normalize();
			}
		}

		/**
		 * Returns the position of this group or object.
		 *
		 * <p>Choose which coordinate system the returned position refers to, by passing a mode string:<br/>
		 * The position is returned as a Point3D in one of the following:<br/>
		 * If "local", the position is coordinates of the parent frame.
		 * If "absolute" the position is in world coordinates
		 * If "camera" the position is relative to the camera's coordinate system.
		 * Default value is "local"
		 *
		 * @return 	The position of the group or object
		 */
		public function getPosition( p_sMode:String = "local" ):Point3D
		{
			var l_oPos:Point3D;
			switch( p_sMode )
			{
				case "local" 	: l_oPos = new Point3D( _p.x, _p.y, _p.z ); break;
				case "camera" : l_oPos = new Point3D( viewMatrix.n14, viewMatrix.n24, viewMatrix.n34 ); break;
				case "absolute" 	: l_oPos = new Point3D( modelMatrix.n14, modelMatrix.n24, modelMatrix.n34 ); break;
				default 		: l_oPos = new Point3D( _p.x, _p.y, _p.z ); break;
			}
			return l_oPos;
		}

		/**
		 * Returns a string representation of this object
		 *
		 * @return	The fully qualified name of this class
		 */
		public override function toString():String
		{
		    	return "sandy.core.scenegraph.ATransformable";
		}
		//
		private var m_oMatrix:Matrix4;
		// Side Orientation Point3D
		protected var _vSide:Point3D;
		// view Orientation Point3D
		protected var _vOut:Point3D;
		// up Orientation Point3D
		protected var _vUp:Point3D;
		// current tilt value
		private var _nTilt:Number;
		// current yaw value
		private var _nYaw:Number;
		// current roll value
		private var _nRoll:Number;
		private var _vRotation:Point3D;
		private var _vLookatDown:Point3D; // Private absolute down Point3D
		private var _vLookAt:Point3D; // Last set value via lookAt() method; may not be valid if other camera movement has occurred since then.
		protected var _p:Point3D;
		protected var _oScale:Point3D;
		protected var m_tmpMt:Matrix4; // temporary transform matrix used at updateTransform
		protected var m_oPreviousOffsetRotation:Point3D = new Point3D();
	}
}
