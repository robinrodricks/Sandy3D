
package sandy.math 
{
	import sandy.core.data.Matrix4;
	import sandy.core.data.Point3D;
	import sandy.util.NumberUtil;	

	/**
	 * Math functions for Matrix4 calculations.
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		0.1
	 * @version		3.1
	 * @date 		26.07.2007
	 *
	 * @see sandy.core.data.Matrix4
	 */
	public class Matrix4Math 
	{
		/**
		 * Specifies whether to use fast math calculations.
		 */
		public static var USE_FAST_MATH:Boolean = false;
		
		// we force initialization of the fast math table
		private const _fastMathInitialized:Boolean = FastMath.initialized;
		
		/**
		 * Computes the multiplication of two Matrix4 matrices, as if they were 3x3.
		 *
		 * @param m1 	The first matrix.
		 * @param m2	The second matrix.
		 *
		 * @return The resulting matrix.
		 */
		public static function multiply3x3(m1:Matrix4, m2:Matrix4) : Matrix4 
		{
			const m111:Number = m1.n11, m211:Number = m2.n11,
			m121:Number = m1.n21, m221:Number = m2.n21,
			m131:Number = m1.n31, m231:Number = m2.n31,
			m112:Number = m1.n12, m212:Number = m2.n12,
			m122:Number = m1.n22, m222:Number = m2.n22,
			m132:Number = m1.n32, m232:Number = m2.n32,
			m113:Number = m1.n13, m213:Number = m2.n13,
			m123:Number = m1.n23, m223:Number = m2.n23,
			m133:Number = m1.n33, m233:Number = m2.n33;
			
			return new Matrix4
			(
				m111 * m211 + m112 * m221 + m113 * m231,
				m111 * m212 + m112 * m222 + m113 * m232,
				m111 * m213 + m112 * m223 + m113 * m233,
				0,
				m121 * m211 + m122 * m221 + m123 * m231,
				m121 * m212 + m122 * m222 + m123 * m232,
				m121 * m213 + m122 * m223 + m123 * m233,
				0,
				m131 * m211 + m132 * m221 + m133 * m231,
				m131 * m212 + m132 * m222 + m133 * m232,
				m131 * m213 + m132 * m223 + m133 * m233,
				0,
				0,0,0,1			
			);
		}

	
		/**
		 * Computes the multiplication of two Matrix4 matrices.
		 *
		 * <p>[<strong>ToDo</strong>: Explain this multiplication ]</p>
		 *
		 * @param m1 	The first matrix.
		 * @param m2	The second matrix.
		 *
		 * @return The resulting matrix.
		 */
		public static function multiply4x3( m1:Matrix4, m2:Matrix4 ):Matrix4
		{
			const m111:Number = m1.n11, m211:Number = m2.n11,
				m121:Number = m1.n21, m221:Number = m2.n21,
				m131:Number = m1.n31, m231:Number = m2.n31,
				m112:Number = m1.n12, m212:Number = m2.n12,
				m122:Number = m1.n22, m222:Number = m2.n22,
				m132:Number = m1.n32, m232:Number = m2.n32,
				m113:Number = m1.n13, m213:Number = m2.n13,
				m123:Number = m1.n23, m223:Number = m2.n23,
				m133:Number = m1.n33, m233:Number = m2.n33,
				m214:Number = m2.n14, m224:Number = m2.n24,	m234:Number = m2.n34;
			
			return new Matrix4
			(
				m111 * m211 + m112 * m221 + m113 * m231,
				m111 * m212 + m112 * m222 + m113 * m232,
				m111 * m213 + m112 * m223 + m113 * m233,
				m214 * m111 + m224 * m112 + m234 * m113 + m1.n14,
				
				m121 * m211 + m122 * m221 + m123 * m231,
				m121 * m212 + m122 * m222 + m123 * m232,
				m121 * m213 + m122 * m223 + m123 * m233,
				m214 * m121 + m224 * m122 + m234 * m123 + m1.n24,
				
				m131 * m211 + m132 * m221 + m133 * m231,
				m131 * m212 + m132 * m222 + m133 * m232,
				m131 * m213 + m132 * m223 + m133 * m233,
				m214 * m131 + m224 * m132 + m234 * m133 + m1.n34,
				
				0, 0, 0, 1
			);
		}
			
		/**
		 * Computes the multiplication of two Matrix4 matrices.
		 *
		 * <p>[<strong>ToDo</strong>: Explain this multiplication ]</p>
		 *
		 * @param m1 	The first matrix.
		 * @param m2	The second matrix.
		 *
		 * @return The resulting matrix.
		 */
		public static function multiply(m1:Matrix4, m2:Matrix4) : Matrix4 
		{
			const m111:Number = m1.n11, m121:Number = m1.n21, m131:Number = m1.n31, m141:Number = m1.n41,
				m112:Number = m1.n12, m122:Number = m1.n22, m132:Number = m1.n32, m142:Number = m1.n42, 
				m113:Number = m1.n13, m123:Number = m1.n23, m133:Number = m1.n33, m143:Number = m1.n43,
				m114:Number = m1.n14, m124:Number = m1.n24, m134:Number = m1.n34, m144:Number = m1.n44,
				m211:Number = m2.n11, m221:Number = m2.n21, m231:Number = m2.n31, m241:Number = m2.n41,
				m212:Number = m2.n12, m222:Number = m2.n22, m232:Number = m2.n32, m242:Number = m2.n42, 
				m213:Number = m2.n13, m223:Number = m2.n23, m233:Number = m2.n33, m243:Number = m2.n43,
				m214:Number = m2.n14, m224:Number = m2.n24, m234:Number = m2.n34, m244:Number = m2.n44;
			
			return new Matrix4
			(
				m111 * m211 + m112 * m221 + m113 * m231 + m114 * m241,
				m111 * m212 + m112 * m222 + m113 * m232 + m114 * m242,
				m111 * m213 + m112 * m223 + m113 * m233 + m114 * m243,
				m111 * m214 + m112 * m224 + m113 * m234 + m114 * m244,
		
				m121 * m211 + m122 * m221 + m123 * m231 + m124 * m241,
				m121 * m212 + m122 * m222 + m123 * m232 + m124 * m242,
				m121 * m213 + m122 * m223 + m123 * m233 + m124 * m243,
				m121 * m214 + m122 * m224 + m123 * m234 + m124 * m244,
		
				m131 * m211 + m132 * m221 + m133 * m231 + m134 * m241,
				m131 * m212 + m132 * m222 + m133 * m232 + m134 * m242,
				m131 * m213 + m132 * m223 + m133 * m233 + m134 * m243,
				m131 * m214 + m132 * m224 + m133 * m234 + m134 * m244,
		
				m141 * m211 + m142 * m221 + m143 * m231 + m144 * m241,
				m141 * m212 + m142 * m222 + m143 * m232 + m144 * m242,
				m141 * m213 + m142 * m223 + m143 * m233 + m144 * m243,
				m141 * m214 + m142 * m224 + m143 * m234 + m144 * m244
			);
		}
		
		/**
		 * Computes the addition of two Matrix4 matrices.
		 *
		 * @param m1 	The first matrix.
		 * @param m2	The second matrix.
		 *
		 * @return The resulting matrix.
		 */
		public static function addMatrix4(m1:Matrix4, m2:Matrix4): Matrix4
		{
			return new Matrix4
			(
				m1.n11 + m2.n11, m1.n12 + m2.n12, m1.n13 + m2.n13, m1.n14 + m2.n14,
				m1.n21 + m2.n21, m1.n22 + m2.n22, m1.n23 + m2.n23, m1.n24 + m2.n24,
				m1.n31 + m2.n31, m1.n32 + m2.n32, m1.n33 + m2.n33, m1.n34 + m2.n34,
				m1.n41 + m2.n41, m1.n42 + m2.n42, m1.n43 + m2.n43, m1.n44 + m2.n44
			);
		}
		
		/**
		 * Returns the clone of a Matrix4 matrix.
		 *
		 * @param m1	The matrix to clone.
		 *
		 * @return The resulting matrix.
		 */
		public static function clone(m:Matrix4):Matrix4
		{
			return new Matrix4
			(
				m.n11,m.n12,m.n13,m.n14,
				m.n21,m.n22,m.n23,m.n24,
				m.n31,m.n32,m.n33,m.n34,
				m.n41,m.n42,m.n43,m.n44
			);
		}
		
		/**
		 * Multiplies a 3D vertex by a Matrix4 matrix.
		 *
		 * @param m		The matrix.
		 * @param pv	The vertex.
		 *
		 * @return The resulting Point3D.
		 */    
		public static function transform( m:Matrix4, pv:Point3D ): Point3D
		{
			const x:Number=pv.x, y:Number=pv.y, z:Number=pv.z;
			return  new Point3D( 	(x * m.n11 + y * m.n12 + z * m.n13 + m.n14),
						(x * m.n21 + y * m.n22 + z * m.n23 + m.n24),
						(x * m.n31 + y * m.n32 + z * m.n33 + m.n34)
					);
		}
	
		/**
		 * Multiplies a 3D Point3D by a Matrix4 matrix as a 3x3 matrix.
		 *
		 * <p>Uses the upper left 3 by 3 elements</p>
		 *
		 * @param m	The matrix.
		 * @param v	The Point3D.
		 *
		 * @return The resulting Point3D.
		 */
		public static function transform3x3( m:Matrix4, pv:Point3D ):Point3D
		{
			const x:Number=pv.x, y:Number=pv.y, z:Number=pv.z;
			return  new Point3D( 	(x * m.n11 + y * m.n12 + z * m.n13),
						(x * m.n21 + y * m.n22 + z * m.n23),
						(x * m.n31 + y * m.n32 + z * m.n33)
					);
		}
	        
		/**
		 * Computes a rotation Matrix4 matrix from the Euler angle in degrees.
		 *
		 * @param ax	Angle of rotation around X axis in degrees.
		 * @param ay	Angle of rotation around Y axis in degrees.
		 * @param az	Angle of rotation around Z axis in degrees.
		 *
		 * @return The resulting matrix.
		 */
		public static function eulerRotation ( ax:Number, ay:Number, az:Number ) : Matrix4
		{
			var m:Matrix4 = new Matrix4();
			ax = - NumberUtil.toRadian(ax);
			ay =   NumberUtil.toRadian(ay);
			az = - NumberUtil.toRadian(az);
			// --
			const a:Number = ( USE_FAST_MATH == false ) ? Math.cos( ax ) : FastMath.cos(ax);
			const b:Number = ( USE_FAST_MATH == false ) ? Math.sin( ax ) : FastMath.sin(ax);
			const c:Number = ( USE_FAST_MATH == false ) ? Math.cos( ay ) : FastMath.cos(ay);
			const d:Number = ( USE_FAST_MATH == false ) ? Math.sin( ay ) : FastMath.sin(ay);
			const e:Number = ( USE_FAST_MATH == false ) ? Math.cos( az ) : FastMath.cos(az);
			const f:Number = ( USE_FAST_MATH == false ) ? Math.sin( az ) : FastMath.sin(az);
			const ad:Number = a * d	;
			const bd:Number = b * d	;
	
			m.n11 =   c  * e         ;
			m.n12 =   c  * f         ;
			m.n13 = - d              ;
			m.n21 =   bd * e - a * f ;
			m.n22 =   bd * f + a * e ;
			m.n23 =   b  * c 	 ;
			m.n31 =   ad * e + b * f ;
			m.n32 =   ad * f - b * e ;
			m.n33 =   a  * c         ;
		
			return m;
		}
		
		/**
		 * Computes a rotation Matrix4 matrix for an x axis rotation.
		 *
		 * @param angle	Angle of rotation.
		 *
		 * @return The resulting matrix.
		 */
		public static function rotationX ( angle:Number ):Matrix4
		{
			var m:Matrix4 = new Matrix4();
			angle = NumberUtil.toRadian(angle);
			const c:Number = ( USE_FAST_MATH == false ) ? Math.cos( angle ) : FastMath.cos( angle );
			const s:Number = ( USE_FAST_MATH == false ) ? Math.sin( angle ) : FastMath.sin( angle );
	
			m.n22 =  c;
			m.n23 =  s;
			m.n32 = -s;
			m.n33 =  c;
			return m;
		}
		
		/**
		 * Computes a rotation Matrix4 matrix for an y axis rotation.
		 *
		 * @param angle	Angle of rotation.
		 *
		 * @return The resulting matrix.
		 */
		public static function rotationY ( angle:Number ):Matrix4
		{
			var m:Matrix4 = new Matrix4();
			angle = NumberUtil.toRadian(angle);
			const c:Number = ( USE_FAST_MATH == false ) ? Math.cos( angle ) : FastMath.cos( angle );
			const s:Number = ( USE_FAST_MATH == false ) ? Math.sin( angle ) : FastMath.sin( angle );
			// --
			m.n11 =  c;
			m.n13 = -s;
			m.n31 =  s;
			m.n33 =  c;
			return m;
		}
		
		/**
		 * Computes a rotation Matrix4 matrix for an z axis rotation.
		 *
		 * @param angle	Angle of rotation.
		 *
		 * @return The resulting matrix.
		 */
		public static function rotationZ ( angle:Number ):Matrix4
		{
			var m:Matrix4 = new Matrix4();
			angle = NumberUtil.toRadian(angle);
			const c:Number = ( USE_FAST_MATH == false ) ? Math.cos( angle ) : FastMath.cos( angle );
			const s:Number = ( USE_FAST_MATH == false ) ? Math.sin( angle ) : FastMath.sin( angle );
			// --
			m.n11 =  c;
			m.n12 =  s;
			m.n21 = -s;
			m.n22 =  c;
			return m;
		}
		
		/**
		 * Computes a rotation Matrix4 matrix for a general axis of rotation.
		 *
		 * @param v 	The axis of rotation.
		 * @param angle The angle of rotation in degrees.
		 *
		 * @return The resulting matrix.
		 */
		public static function axisRotationPoint3D ( v:Point3D, angle:Number ) : Matrix4
		{
			return Matrix4Math.axisRotation( v.x, v.y, v.z, angle );
		}
		
		/**
		 * Computes a rotation Matrix4 matrix for a general axis of rotation.
		 *
		 * <p>[<strong>ToDo</strong>: My gosh! Explain this Thomas ;-) ]</p>
		 *
		 * @param u 	rotation X.
		 * @param v 	rotation Y.
		 * @param w		rotation Z.
		 * @param angle	The angle of rotation in degrees.
		 *
		 * @return The resulting matrix.
		 */
		public static function axisRotation ( u:Number, v:Number, w:Number, angle:Number ) : Matrix4
		{
			var m:Matrix4 = new Matrix4();
			angle = NumberUtil.toRadian( angle );
			// -- modification pour verifier qu'il n'y ai pas un probleme de precision avec la camera
			const c:Number = ( USE_FAST_MATH == false ) ? Math.cos( angle ) : FastMath.cos( angle );
			const s:Number = ( USE_FAST_MATH == false ) ? Math.sin( angle ) : FastMath.sin( angle );
			const scos:Number	= 1 - c ;
			// --
			var suv	:Number = u * v * scos ;
			var svw	:Number = v * w * scos ;
			var suw	:Number = u * w * scos ;
			var sw	:Number = s * w ;
			var sv	:Number = s * v ;
			var su	:Number = s * u ;
			
			m.n11  =   c + u * u * scos	;
			m.n12  = - sw 	+ suv 			;
			m.n13  =   sv 	+ suw			;
	
			m.n21  =   sw 	+ suv 			;
			m.n22  =   c + v * v * scos 	;
			m.n23  = - su 	+ svw			;
	
			m.n31  = - sv	+ suw 			;
			m.n32  =   su	+ svw 			;
			m.n33  =   c	+ w * w * scos	;
	
			return m;
		}
		
		/**
		 * Computes a translation Matrix4 matrix.
		 * 
		 * <pre>
		 * |1  0  0  0|
		 * |0  1  0  0|
		 * |0  0  1  0|
		 * |Tx Ty Tz 1|
		 * </pre>
		 * 
		 * @param nTx 	Translation in the x direction.
		 * @param nTy 	Translation in the y direction.
		 * @param nTz 	Translation in the z direction.
		 *
		 * @return The resulting matrix.
		 */
		public static function translation(nTx:Number, nTy:Number, nTz:Number) : Matrix4 
		{
			var m:Matrix4 = new Matrix4();
			m.n14 = nTx;
			m.n24 = nTy;
			m.n34 = nTz;
			return m;
		}
	
		/**
		 * Computes a translation Matrix4 matrix from a Point3D.
		 * 
		 * <pre>
		 * |1  0  0  0|
		 * |0  1  0  0|
		 * |0  0  1  0|
		 * |Tx Ty Tz 1|
		 * </pre>
		 * 
		 * @param v		Translation Point3D.
		 *
		 * @return The resulting matrix.
		 */
		public static function translationPoint3D( v:Point3D ) : Matrix4 
		{
			var m:Matrix4 = new Matrix4();
			m.n14 = v.x;
			m.n24 = v.y;
			m.n34 = v.z;
			return m;
		}
		
		/**
		 * Computes a scale Matrix4 matrix.
		 * 
		 * <pre>
		 * |Sx 0  0  0|
		 * |0  Sy 0  0|
		 * |0  0  Sz 0|
		 * |0  0  0  1|
		 * </pre>
		 *
		 * @param nXScale 	Scale factor in the x direction.
		 * @param nYScale 	Scale factor in the y direction.
		 * @param nZScale 	Scale factor in the z direction.
		 *
		 * @return The resulting matrix.
		 */
		public static function scale(nXScale:Number, nYScale:Number, nZScale:Number) : Matrix4 
		{
			var matScale : Matrix4 = new Matrix4();
			matScale.n11 = nXScale;
			matScale.n22 = nYScale;
			matScale.n33 = nZScale;
			return matScale;
		}
		
		/**
		 * Computes a scale Matrix4 matrix from a scale Point3D.
		 * 
		 * <pre>
		 * |Sx 0  0  0|
		 * |0  Sy 0  0|
		 * |0  0  Sz 0|
		 * |0  0  0  1|
		 * </pre>
		 *
		 * @param v	The Point3D containing the scale values.
		 *
		 * @return The resulting matrix.
		 */
		public static function scalePoint3D( v:Point3D) : Matrix4 
		{
			var matScale : Matrix4 = new Matrix4();
			matScale.n11 = v.x;
			matScale.n22 = v.y;
			matScale.n33 = v.z;
			return matScale;
		}
			
		/**
		 * Computes the determinant of a Matrix4 matrix.
		 *
		 * @param m 	The matrix.
		 *
		 * @return The determinant.
		 */
		public static function det( m:Matrix4 ):Number
		{
			return		(m.n11 * m.n22 - m.n21 * m.n12) * (m.n33 * m.n44 - m.n43 * m.n34)- (m.n11 * m.n32 - m.n31 * m.n12) * (m.n23 * m.n44 - m.n43 * m.n24)
					 + 	(m.n11 * m.n42 - m.n41 * m.n12) * (m.n23 * m.n34 - m.n33 * m.n24)+ (m.n21 * m.n32 - m.n31 * m.n22) * (m.n13 * m.n44 - m.n43 * m.n14)
					 - 	(m.n21 * m.n42 - m.n41 * m.n22) * (m.n13 * m.n34 - m.n33 * m.n14)+ (m.n31 * m.n42 - m.n41 * m.n32) * (m.n13 * m.n24 - m.n23 * m.n14);
	
		}
		
		/**
		 * Computes the 3x3 determinant of a Matrix4 matrix.
		 *
		 * <p>Uses the upper left 3 by 3 elements.</p>
		 *
		 * @param m		The matrix.
		 *
		 * @return The determinant.
		 */
		public static function det3x3( m:Matrix4 ):Number
		{	
			return m.n11 * ( m.n22 * m.n33 - m.n23 * m.n32 ) + m.n21 * ( m.n32 * m.n13 - m.n12 * m.n33 ) + m.n31 * ( m.n12 * m.n23 - m.n22 * m.n13 );
		}
	
		/**
		 * Computes the trace of a Matrix4 matrix.
		 *
		 * <p>The trace value is the sum of the element on the diagonal of the matrix.</p>
		 *
		 * @param m		The matrix we want to compute the trace.
		 *
		 * @return The trace value.
		 */
		public static function getTrace( m:Matrix4 ):Number
		{
			return m.n11 + m.n22 + m.n33 + m.n44;
		}
		
		/**
		* Returns the inverse of a Matrix4 matrix.
		*
		* @param m	The matrix to invert.
		*
		* @return 	The inverse Matrix4 matrix.
		*/
		public static function getInverse( m:Matrix4 ):Matrix4
		{
			//take the determinant
			var d:Number = Matrix4Math.det( m );
			if( Math.abs(d) < 0.001 )
			{
				//We cannot invert a Matrix4 with a null determinant
				return null;
			}
			//We use Cramer formula, so we need to devide by the determinant. We prefer multiply by the inverse
			d = 1/d;
			var m11:Number = m.n11;var m21:Number = m.n21;var m31:Number = m.n31;var m41:Number = m.n41;
			var m12:Number = m.n12;var m22:Number = m.n22;var m32:Number = m.n32;var m42:Number = m.n42;
			var m13:Number = m.n13;var m23:Number = m.n23;var m33:Number = m.n33;var m43:Number = m.n43;
			var m14:Number = m.n14;var m24:Number = m.n24;var m34:Number = m.n34;var m44:Number = m.n44;
			return new Matrix4 (
			d * ( m22*(m33*m44 - m43*m34) - m32*(m23*m44 - m43*m24) + m42*(m23*m34 - m33*m24) ),
			-d* ( m12*(m33*m44 - m43*m34) - m32*(m13*m44 - m43*m14) + m42*(m13*m34 - m33*m14) ),
			d * ( m12*(m23*m44 - m43*m24) - m22*(m13*m44 - m43*m14) + m42*(m13*m24 - m23*m14) ),
			-d* ( m12*(m23*m34 - m33*m24) - m22*(m13*m34 - m33*m14) + m32*(m13*m24 - m23*m14) ),
			-d* ( m21*(m33*m44 - m43*m34) - m31*(m23*m44 - m43*m24) + m41*(m23*m34 - m33*m24) ),
			d * ( m11*(m33*m44 - m43*m34) - m31*(m13*m44 - m43*m14) + m41*(m13*m34 - m33*m14) ),
			-d* ( m11*(m23*m44 - m43*m24) - m21*(m13*m44 - m43*m14) + m41*(m13*m24 - m23*m14) ),
			d * ( m11*(m23*m34 - m33*m24) - m21*(m13*m34 - m33*m14) + m31*(m13*m24 - m23*m14) ),
			d * ( m21*(m32*m44 - m42*m34) - m31*(m22*m44 - m42*m24) + m41*(m22*m34 - m32*m24) ),
			-d* ( m11*(m32*m44 - m42*m34) - m31*(m12*m44 - m42*m14) + m41*(m12*m34 - m32*m14) ),
			d * ( m11*(m22*m44 - m42*m24) - m21*(m12*m44 - m42*m14) + m41*(m12*m24 - m22*m14) ),
			-d* ( m11*(m22*m34 - m32*m24) - m21*(m12*m34 - m32*m14) + m31*(m12*m24 - m22*m14) ),
			-d* ( m21*(m32*m43 - m42*m33) - m31*(m22*m43 - m42*m23) + m41*(m22*m33 - m32*m23) ),
			d * ( m11*(m32*m43 - m42*m33) - m31*(m12*m43 - m42*m13) + m41*(m12*m33 - m32*m13) ),
			-d* ( m11*(m22*m43 - m42*m23) - m21*(m12*m43 - m42*m13) + m41*(m12*m23 - m22*m13) ),
			d * ( m11*(m22*m33 - m32*m23) - m21*(m12*m33 - m32*m13) + m31*(m12*m23 - m22*m13) )
			);
		}
		
		/**
		 * Computes a Matrix4 matrix for a rotation around a specific axis through a specific point.
		 * 
		 * <p>NOTE - The axis must be normalized!</p>
		 *
		 * @param axis 		A Point3D representing the axis of rotation.
		 * @param ref 		The center of rotation.
		 * @param pAngle	The angle of rotation in degrees.
		 *
		 * @return The resulting matrix.
		 */
		public static function axisRotationWithReference( axis:Point3D, ref:Point3D, pAngle:Number ):Matrix4
		{
			var angle:Number = ( pAngle + 360 ) % 360;
			var m:Matrix4 = Matrix4Math.translation ( ref.x, ref.y, ref.z );
			m = Matrix4Math.multiply ( m, Matrix4Math.axisRotation( axis.x, axis.y, axis.z, angle ));
			m = Matrix4Math.multiply ( m, Matrix4Math.translation ( -ref.x, -ref.y, -ref.z ));
			return m;
		}
	}
}