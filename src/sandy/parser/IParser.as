
package sandy.parser
{
	import flash.events.IEventDispatcher;

	import sandy.materials.Appearance;

	/**
	 * The IParser interface defines the interface that parser classes such as ColladaParser must implement.
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		1.0
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public interface IParser extends IEventDispatcher
	{
		/**
		 * This method starts the parsing process.
		 */
		function parse():void;

		/**
		 * Creates a transformable node in the object tree of the world.
		 *
		 * @param p_oAppearance	The default appearance that will be applied to the parsed object.
		 */
		function set standardAppearance( p_oAppearance:Appearance ):void;
	}
}