
package sandy.materials
{
	/**
	 * Represents the material types used in Sandy.
	 * 
	 * <p>All materialy types used in Sandy are registered here as constant properties.<br/>
	 * If new materials are added to the Sandy library, they should be registered here.</p> 
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		26.07.2007
	 */
	public class MaterialType
	{
		/**
		 * Specifies the default material.
		 */
		public static const NONE:MaterialType = new MaterialType("default");

		/**
		 * Specifies a ColorMaterial.
		 */
		public static const COLOR:MaterialType = new MaterialType("color");

		/**
		 * Specifies a WireFrameMaterial.
		 */
		public static const WIREFRAME:MaterialType = new MaterialType("wireframe");

		/**
		 * Specifies a BitmapMaterial.
		 */
		public static const BITMAP:MaterialType = new MaterialType("bitmap");

		/**
		 * Specifies a MovieMaterial.
		 */
		public static const MOVIE:MaterialType = new MaterialType("movie");

		/**
		 * Specifies a VideoMaterial.
		 */
		public static const VIDEO:MaterialType = new MaterialType("video");

		/**
		 * Specifies a OutlineMaterial.
		 */
		public static const OUTLINE:MaterialType = new MaterialType("outline");
		
		
		public function MaterialType( p_sType:String )
		{
			m_sType = p_sType;
		}
		
		public function typeString( ):String
		{
			return m_sType;
		}
		private var m_sType:String;
	}
}
