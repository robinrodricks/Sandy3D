package sandy.core.data 
{
	/**
	 * @author thomas
	 */
	public class Pool 
	{
		private var m_nSize:int = 300;
		private const m_aVertices:Array = new Array();
		private var m_nIdVertice:int = 0;
		
		private const m_aUV:Array = new Array();
		private var m_nIdUV:int = 0;
		
		private const m_aPoint3Ds:Array = new Array();
		private var m_nIdPoint3D:int = 0;
		
		private static var INSTANCE:Pool = null;

		public static function getInstance():Pool
		{
			if( INSTANCE == null ) INSTANCE = new Pool();
			return INSTANCE;
		}

		public function Pool () 
		{
			if (INSTANCE != null)
			{
				throw new Error ("There *MUST* be single Pool instance.");
			}

			for( var i:int = 0; i < m_nSize; i++ )
			{
				m_aVertices[int(i)] = new Vertex();
				m_aUV[int(i)] = new UVCoord();
				m_aPoint3Ds[int(i)] = new Point3D();
			}
		}
		
		public function init():void
		{
			m_nIdVertice = m_nIdUV = m_nIdPoint3D = 0;// trace (m_aVertices.length);
		}
		
		public function get nextVertex():Vertex
		{
			if( m_nIdVertice >= m_aVertices.length )
				m_aVertices[m_aVertices.length] = new Vertex();
			// --
			var l_oV:Vertex = m_aVertices[int(m_nIdVertice++)];
			l_oV.projected = false;
			l_oV.transformed = false;
			return l_oV;
		}
		
		public function get nextUV():UVCoord
		{
			if( m_nIdUV >= m_aUV.length )
				m_aUV[m_aUV.length] = new UVCoord();
			// --
			return m_aUV[int(m_nIdUV++)];
		}
		
		public function get nextPoint3D():Point3D
		{
			if( m_nIdPoint3D >= m_aPoint3Ds.length )
				m_aPoint3Ds[m_aPoint3Ds.length] = new Point3D();
			// --
			return m_aPoint3Ds[int(m_nIdPoint3D++)];
		}
		
	}
}
