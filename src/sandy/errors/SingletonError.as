
package sandy.errors
{
	/**
	 * The SingletonError class is used as a workaround for private constructors not existing
	 * in ActionScript 3.0. Every singleton class in Sandy has a private static variable
	 * called <code>instance</code>. The <code>instance</code> variable is given a 
	 * reference to an instance of the class the first time the class constructor or
	 * <code>getInstance()</code> is called. If an attempt is made to instantiate the
	 * class a the second time, a <code>SingletonError</code> will be thrown. Always 
	 * use the static method <code>Class.getInstance()</code> to get an instance of the 
	 * class.
	 * 
	 * @author		Dennis Ippel - ippeldv
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public class SingletonError extends Error
	{
		/**
		 * All the constructor does is pass the error message to the superclass.
		 */		
		public function SingletonError()
		{
			super("Class cannot be instantiated");
		}
	}
}