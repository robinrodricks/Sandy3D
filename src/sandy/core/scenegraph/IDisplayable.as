
package sandy.core.scenegraph
{
	
	import flash.display.Sprite;
	
	import sandy.materials.Material;
	
	/**
	 * The IDisplayable interface should be implemented by all visible objects.
	 * 
	 * <This ensures that all necessary methods are implemented>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public interface IDisplayable
	{
		function clear():void;
		// The container of this object
		function get container():Sprite;	
		// The depth of this object
		function get depth():Number;
		
		function get changed():Boolean;
		
		function get material():Material;
		
		// Called only if the useSignelContainer property is enabled!
		function display( p_oContainer:Sprite = null  ):void;
	}
}