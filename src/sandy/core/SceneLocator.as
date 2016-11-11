
package sandy.core
{
	import flash.utils.Dictionary;	
	/**
	 * The SceneLocator serves as a registry of all scenes in the application.
	 *
	 * <p>An application can only have one SceneLocator. Using the SceneLocator, scenes can be located, registered, and unregistered.</p>
	 * <p>When scenes are created in an application, they automatically
	 * register with the SceneLocator registry.</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		26.07.2007
	 *
	 * @see Scene3D
	 */
	public class SceneLocator
	{

		private static var _oI	: SceneLocator;
		private var _m		: Dictionary;

		/**
		 * Creates the SceneLocator registry.
		 *
		 * <p>This constructor is never called directly. Instead the registry instance is retrieved by calling SceneLocator.getInstance().</p>
		 *
		 * @param access	A singleton access flag object
		 */
		public function SceneLocator( access : PrivateConstructorAccess )
		{
			_m = new Dictionary( true );
		}

		/**
		 * Returns the instance of this SceneLocator object.
		 *
		 * @return This instance.
		 */
		public static function getInstance() : SceneLocator
		{
			if ( !_oI ) _oI = new SceneLocator( new PrivateConstructorAccess() );
			return _oI;
		}


		/**
		 * Returns the Scene3D object with the specified name.
		 *
		 * @param key 	The name of the scene.
		 *
		 * @return The requested scene.
		 */
		public function getScene( key : String ) : Scene3D
		{
			if ( !(isRegistered( key )) ) trace( "Can't locate scene instance with '" + key + "' name in " + this );
			return _m[ key ] as Scene3D;
		}

		/**
		 * Checks if a scene with the specified name is registered.
		 *
		 * @param 	key The name of the scene to check.
		 *
		 * @return true if a scene with that name is registered, false otherwise.
		 */
		public function isRegistered( key : String ) : Boolean
		{
			return _m[ key ] != null;
		}

		/**
		 * Registers a scene.
		 *
		 * @param key	The name of the scene.
		 * @param o		The Scene3D object.
		 *
		 * @return Whether the scene was successfully registered.
		 */
		public function registerScene( key : String, o : Scene3D ) : Boolean
		{
			if ( isRegistered( key ) )
			{
				trace( "scene instance is already registered with '" + key + "' name in " + this );
				return false;

			}
			else
			{
				_m[ key ] = o;
				return true;
			}
		}

		/**
		 * Unregisters a scene with the specified name.
		 *
		 * @param	key The name of the scene to unregister.
		 */
		public function unregisterScene( key : String ) : void
		{
			_m[ key ] = null;
		}

	}
}

internal final class PrivateConstructorAccess {}
