
package sandy.primitive
{
	import sandy.core.scenegraph.TransformGroup;

	/**
	* A SkyBox is a TransformGroup of six Plane3D objects that form a box.
	*
	* @author		Thomas Pfeiffer
	 * @version		3.1
	* @date 		26.09.2007
	*
	* @example The following code creates a SkyBox with appearances for the front, back, left, and right sides.
	* <listing version="3.1">
	* var mySkyBox:SkyBox = new SkyBox( "game_sky", 3000, 6, 6 );
	*
	* // Set the appearance for the front, back, left, and right sides
	* mySkyBox.front.appearance = new Appearance( new BitmapMaterial( myPic.bitmapData ) );
	* mySkyBox.back.appearance = new Appearance( new BitmapMaterial( myPic.bitmapData ) );
	* mySkyBox.left.appearance = new Appearance( new BitmapMaterial( myPic.bitmapData ) );
	* mySkyBox.right.appearance = new Appearance( new BitmapMaterial( myPic.bitmapData ) );
	*
	* // Remove unneeded sides
	* mySkyBox.top.remove();
	* mySkyBox.bottom.remove();
	*
	* // Link the skybox to a group to display it
	* aGroup.addChild( mySkyBox );
	* </listing>
	*
	* @see Plane3D
	*/
	public class SkyBox extends TransformGroup
	{
		private var m_aPlanes:Array = new Array(6);

		/**
		* Creates a SkyBox object.
		*
		* <p>The skybox is created as a TransformGroup. This is a special behaviour comparing the other primitives which directly extend Shape3D.
		* A skyBox isn't a graphical object itself, but it is composed of 6 planes (Plane3D objects) that represents the 6 sides of the skybox.</p>
		*
		* <p>The planes are automatically created, and placed for you. You can access them individually thanks to the getter methods.
		* The planes are created with a default name, which is simply the concatenation of the skybox name and "_left" for the left side, "_top" for the top side, etc.</p>
		*
		* @param p_sName		The name of the skybox. It is recommended to give a explicit name.
		* @param p_nDim			The dimension of the skybox. This number is used for the width, height, and depth.
		* @param p_nQualityH	Number of horizontal segments of the planes of the skybox. (WARNING: Some faces are rotated, and so, the quality isn't representative. To fix!)
		* @param p_nQualityV	Number of vertical segments of the planes of the skybox. (WARNING: Some faces are rotated, and so, the quality isn't representative. To fix!)
		*
		*/
		public function SkyBox(p_sName:String=null, p_nDim:Number = 100, p_nQualityH:uint = 1, p_nQualityV:uint=1 )
		{
			super(p_sName); // TOP BOTTOM
			var l_oPlane:Plane3D;
			// -- LEFT
			l_oPlane = new Plane3D( p_sName+"_left", p_nDim, p_nDim, p_nQualityH, p_nQualityV, Plane3D.YZ_ALIGNED );
			l_oPlane.rotateX = -90;
			l_oPlane.rotateY = 180;
			l_oPlane.x = -p_nDim/2;
			l_oPlane.enableClipping = true;
			m_aPlanes[0] = l_oPlane;
			// -- RIGHT
			l_oPlane = new Plane3D( p_sName+"_right", p_nDim, p_nDim, p_nQualityH, p_nQualityV, Plane3D.YZ_ALIGNED );
			l_oPlane.rotateX = -90;
			l_oPlane.x = p_nDim/2;
			l_oPlane.enableClipping = true;
			m_aPlanes[1] = l_oPlane;
			// -- FRONT
			l_oPlane = new Plane3D( p_sName+"_front", p_nDim, p_nDim, p_nQualityH, p_nQualityV, Plane3D.XY_ALIGNED );
			l_oPlane.z = p_nDim/2;
			l_oPlane.enableClipping = true;
			m_aPlanes[2] = l_oPlane;
			// -- BACK
			l_oPlane = new Plane3D( p_sName+"_back", p_nDim, p_nDim, p_nQualityH, p_nQualityV, Plane3D.XY_ALIGNED );
			l_oPlane.rotateY = 180;
			l_oPlane.z = -p_nDim/2;
			l_oPlane.enableClipping = true;
			m_aPlanes[3] = l_oPlane;
			// -- TOP
			l_oPlane = new Plane3D( p_sName+"_top", p_nDim, p_nDim, p_nQualityH, p_nQualityV, Plane3D.ZX_ALIGNED );
			l_oPlane.rotateX = 180;
			l_oPlane.y = p_nDim/2;
			l_oPlane.enableClipping = true;
			m_aPlanes[4] = l_oPlane;
			// -- BOTTOM
			l_oPlane = new Plane3D( p_sName+"_bottom", p_nDim, p_nDim, p_nQualityH, p_nQualityV, Plane3D.ZX_ALIGNED );
			l_oPlane.y = -p_nDim/2;
			l_oPlane.enableClipping = true;
			m_aPlanes[5] = l_oPlane;

			for each( l_oPlane in m_aPlanes )
			{
				//l_oPlane.enableBackFaceCulling = false;
				l_oPlane.enableForcedDepth = true;
				l_oPlane.forcedDepth = 10000000000000;
				this.addChild( l_oPlane );
			}
		}

		/**
		* The left plane of the SkyBox.
		*/
		public function get left():Plane3D
		{
			return m_aPlanes[0];
		}

		/**
		* The right plane of the SkyBox.
		*/
		public function get right():Plane3D
		{
			return m_aPlanes[1];
		}

		/**
		* The front plane of the SkyBox.
		*/
		public function get front():Plane3D
		{
			return m_aPlanes[2];
		}

		/**
		* The back plane of the SkyBox.
		*/
		public function get back():Plane3D
		{
			return m_aPlanes[3];
		}

		/**
		* The top plane of the SkyBox.
		*/
		public function get top():Plane3D
		{
			return m_aPlanes[4];
		}

		/**
		* The bottom plane of the SkyBox.
		*/
		public function get bottom():Plane3D
		{
			return m_aPlanes[5];
		}
	}
}