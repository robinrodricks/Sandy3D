
package sandy.math 
{	
	/**
	 * Math functions for colors.
	 *  
	 * @author		Thomas Pfeiffer - kiroukou
	 * @author		Tabin Cédric - thecaptain
	 * @author		Nicolas Coevoet - [ NikO ]
	 * @since		0.1
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public class ColorMath
	{
		
		/**
		 * Returns the color with altered alpha value.
		 * 
		 * @param c	32-bit color.
		 * @param a	New alpha ( 0 - 1 ).
		 *
		 * @return	The hexadecimal value of the altered color.
		 */
		public static function applyAlpha (c:uint, a:Number):uint
		{
			var a0:uint = c / 0x1000000; return (c & 0xFFFFFF) + Math.floor(a * a0) * 0x1000000;
		}
		
		/**
		 * Converts color component values ( RGB ) to one hexadecimal value.
		 * 
		 * @param r	Red color ( 0 - 255 ).
		 * @param g	Green color ( 0 - 255 ).
		 * @param b	Blue color ( 0 - 255 ).
		 *
		 * @return	The hexadecimal value of the RGB color.
		 */
		public static function rgb2hex(r:Number, g:Number, b:Number):Number  
		{
			return ((r << 16) | (g << 8) | b);
		}
	
		/**
		 * Converts a hexadecimal color value to RGB components
		 * 
		 * @param hex	Hexadecimal color.
		 *
		 * @return	The RGB color of the hexadecimal.
		 */   
		public static function hex2rgb(hex:Number):Object 
		{
			var r:Number;
			var g:Number;
			var b:Number;
			r = (0xFF0000 & hex) >> 16;
			g = (0x00FF00 & hex) >> 8;
			b = (0x0000FF & hex);
			return {r:r,g:g,b:b} ;
		}
	
		/**
		* Converts hexadecimal color value to normalized rgb components ( 0 - 1 ).
		* 
		* @param	hex	hexadecimal color value.
		* @return	The normalized rgb components ( 0 - 1 ).
		*/   
		public static function hex2rgbn(hex:Number):Object 
		{
			var r:Number;
			var g:Number;
			var b:Number;
			r = (0xFF0000 & hex) >> 16;
			g = (0x00FF00 & hex) >> 8;
			b = (0x0000FF & hex);
			return {r:r/255,g:g/255,b:b/255} ;
		}
		
		/**
		 * Calculate the color for a particular lighting strength.
		 * <p>This converts the supplied pre-multiplied RGB color into HSL then modifies the L according to the light strength. 
		 * The result is then mapped back into the RGB space.</p>
		 */	
		public static function calculateLitColour(col:Number, lightStrength:Number):Number
		{
			var r:Number = ( col >> 16 )& 0xFF;
			var g:Number = ( col >> 8 ) & 0xFF;
			var b:Number = ( col ) 		& 0xFF;

			// divide by 256
			r *= 0.00390625;
			g *= 0.00390625;
			b *= 0.00390625;
													   
			var min:Number, mid:Number, max:Number, delta:Number;
			var l:Number, s:Number, h:Number, F:Number, n:Number = 0;
			
			var a:Array = [r,g,b];
			a.sort();
	
			min = a[0];
			mid = a[1];		
			max = a[2];
			
			var range:Number = max - min;
			
			l = (min + max) * 0.5;
			
			if (l == 0) 
			{
				s = 1;
			}
			else
			{
				delta = range * 0.5;
				
				if (l < 0.5) 
				{
					s = delta / l;
				}
				else 
				{
					s = delta / (1 - l);
				}
	
				if (range != 0) 
				{
					while (true) 
					{
						if (r == max) 
						{
							if (b == min) n = 0; 
							else n = 5;
							
							break;
						}
							
						if (g == max) 
						{
							if (b == min) n = 1; 
							else n = 2;
							
							break;
						}
							
						if (r == min) n = 3; 
						else n = 4;
						
						break;
					}
					
					if ((n % 2) == 0) 
					{
						F = mid - min;
					}
					else 
					{
						F = max - mid;
					}
					
					F = F / range;
					h = 60 * (n + F);
				}
			}

			if (lightStrength < 0.5) 
			{
				delta = s * lightStrength;
			}
			else 
			{
				delta = s * (1 - lightStrength);
			}
			

			min = lightStrength - delta;
			max = lightStrength + delta;

			n = Math.floor(h / 60);
			F = (h - n*60) * delta / 30;
			n %= 6;
			
			var mu:Number = min + F;
			var md:Number = max - F;
			
			switch (n) 
			{
				case 0: r = max; g= mu;  b= min; break;
				case 1: r = md;  g= max; b= min; break;
				case 2: r = min; g= max; b= mu; break;
				case 3: r = min; g= md;  b= max; break;
				case 4: r = mu;  g= min; b= max; break;
				case 5: r = max; g= min; b= md; break;
			}
				
			return ((r * 256) << 16 | (g * 256) << 8 |  (b * 256));
		}
	}
}