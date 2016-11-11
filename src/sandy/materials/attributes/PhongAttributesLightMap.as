
package sandy.materials.attributes
{
	/**
	 * A lightmap used for some of the shaders.
	 *
	 * @version		3.1
	 */
	public final class PhongAttributesLightMap
	{
		/**
		 * An array of an array which contains the alphas of the strata. The values of the inner array must be between 0 and 1.
		 */
		public var alphas:Array = [[], []];
		
		/**
		 * An array of an array which contains the colors of the strata.
		 */
		public var colors:Array = [[], []];
		
		/**
		 * An array of an array which contains the ratios (length) of each strata.
		 */
		public var ratios:Array = [[], []];
	}
}