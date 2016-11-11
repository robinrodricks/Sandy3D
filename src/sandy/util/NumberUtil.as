
package sandy.util 
{
	/**
	 * Utility class for useful numeric constants and number manipulation.
	 *  
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public class NumberUtil 
	{
		/**
		 * Math constant pi&#42;2.
		 */
		public static function get TWO_PI():Number { return __TWO_PI; }
		private static var __TWO_PI:Number = 2 * Math.PI;
		
		/**
		 * Math constant pi.
		 */
		public static function get PI():Number { return __PI; }
		private static var __PI:Number = Math.PI;	
		
		/**
		 * Math constant pi/2.
		 */
		public static function get HALF_PI():Number { return __HALF_PI; }
		private static var __HALF_PI:Number = 0.5 * Math.PI;	
		
		/**
		 * Constant used to convert angle from radians to degrees.
		 */
		public static function get TO_DEGREE():Number { return __TO_DREGREE; }
		private static var __TO_DREGREE:Number = 180 /  Math.PI;
		
		/**
		 * Constant used to convert degrees to radians.
		 */
		public static function get TO_RADIAN():Number { return __TO_RADIAN; }
		private static var __TO_RADIAN:Number = Math.PI / 180;
		
		/**
		 * Value used to compare numbers with. 
		 * 
		 * <p>Basically used to say if a number is zero or not.<br />
		 * Adjust this number with regard to the precision of your application</p>
		 */
		public static var TOL:Number = 0.00001;	
			
		/**
		 * Determines if a number is regarded as zero.
		 *
		 * <p>Adjust the TOL property depending on the precision of your application.</p>
		 *
		 * @param p_nN 	The number to compare to zero.
		 *
		 * @return 	Whether the number is to be regarded as zero.
		 */
		public static function isZero( p_nN:Number ):Boolean
		{
			return _fABS( p_nN ) < TOL ;
		}
		
		/**
		 * Compares two numbers and determines if they are equal.
		 * 
		 * <p>Adjust the TOL property depending on the precision of your application.</p>
		 *
		 * @param p_nN 	The first number.
		 * @param p_nM 	The second number.
		 *
		 * @return 	Whether the numbers are regarded as equal.
		 */
		public static function areEqual( p_nN:Number, p_nM:Number ):Boolean
		{
			return _fABS( p_nN - p_nM ) < TOL ;
		}
		
		/**
		 * Converts an angle from radians to degrees
		 *
		 * @param p_nRad	A number representing the angle in radians.
		 * @return 		The angle in degrees.
		 */
		public static function toDegree ( p_nRad:Number ):Number
		{
			return p_nRad * TO_DEGREE;
		}
		
		/**
		 * Converts an angle from degrees to radians.
		 * 
		 * @param p_nDeg 	A number representing the angle in dregrees.
		 * @return 		The angle in radians.
		 */
		public static function toRadian ( p_nDeg:Number ):Number
		{
			return p_nDeg * TO_RADIAN;
		}
			
		/**
		 * Constrains a number to a given interval.
		 * 
		 * @param p_nN 		The number to constrain.
		 * @param p_nMin 	The minimal valid value.
		 * @param p_nMax 	The maximal valid value.
		 *
		 * @return 		The constrained number.
		 */
		public static function constrain( p_nN:Number, p_nMin:Number, p_nMax:Number ):Number
		{
			return Math.max( Math.min( p_nN, p_nMax ) , p_nMin );
		}
		 
		/**
		 * Rounds a number to specified accuracy.
		 *
		 * <p>To round off the number to 2 decimals, set the the accuracy to 0.01</p>
		 *
		 * @param p_nN					The number to round.
		 * @param p_nRoundToInterval	The accuracy to which to round.
		 *
		 * @return 			The rounded number.
		 */
		public static function roundTo (p_nN:Number, p_nRoundToInterval:Number=0):Number 
		{
			if (p_nRoundToInterval == 0) 
			{
				p_nRoundToInterval = 1;
			}
			return Math.round(p_nN/p_nRoundToInterval) * p_nRoundToInterval;
		}
		 	 
		private static var _fABS:Function = Math.abs;	
	}
}