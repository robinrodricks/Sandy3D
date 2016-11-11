
package sandy.materials
{
	/**
	 * Interface for setting and getting alpha on a material.
	 * 
	 * @author		flexrails
	 * @version		3.1
	 * @date 		22.03.2008
	 **/
	public interface IAlphaMaterial
	{
		/**
		 * Indicates the alpha transparency value of the material. Valid values are 0 (fully transparent) to 1 (fully opaque).
		 */
		function set alpha(p_nValue:Number):void;

		/**
		 * @private
		 */ 
		function get alpha():Number;
	}
}