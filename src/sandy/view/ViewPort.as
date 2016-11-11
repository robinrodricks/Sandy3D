
package sandy.view 
{
	import flash.geom.Point;
	
	/**
	 * The view port represents the rendered screen.
	 *
	 * <p>This is the area where the view of the camera is projected.<br/>
	 * It may be the whole or only a part of the stage</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @author		James Dahl - optimization with bitwise and int type.
	 * @version		3.1
	 * @date 		26.07.2007
	 */	
	public final class ViewPort
	{
	    /**
		 * A point representing the offset to change the view port center.
		 * <p>If you set myCamera.viewport.offset.y to 100, everything drawn at the screen will be moved 100 pixels down (due to Flash vertical axis convention).</p>
		 */
		public const offset:Point = new Point();
				
		/**
		 * Flag which specifies if the view port dimension has changed.
		 */
		public var hasChanged:Boolean = false;
		
	    /**
		 * Creates a new ViewPort.
		 *
		 * @param p_nW 	The width of the rendered screen.
		 * @param p_nH 	The height of the rendered screen.
		 **/
		public function ViewPort ( p_nW:Number, p_nH:Number )
		{
			width = p_nW;
			height = p_nH;
		}
		
		/**
		 * Updates the view port.
		 */
		public function update():void
		{
			m_nW2 = m_nW >> 1;
            m_nH2 = m_nH >> 1;
            // --
            m_nRatio = (m_nH)? m_nW / m_nH : 0;
            // --
            hasChanged = true;
		}
		
		
	    /**
		 * The width of the view port.
		 **/
		public function get width():int { return m_nW; }
		
	    /**
		 * The height of the view port.
		 **/
		public function get height():int { return m_nH; }
		
		 /**
		 * Half the width of the view port. Used to center Camera3D.
		 **/
		public function get width2():int { return m_nW2; }
		
		/**
		 * Half the height of the view port. Used to center Camera3D.
		 **/
		public function get height2():int { return m_nH2; }
		
	    /**
		 * The width/height ratio of the view port.
		 **/
		public function get ratio():Number { return m_nRatio; }
		
	    /**
		 * @private
		 **/
		public function set width( p_nValue:int ):void { m_nW = p_nValue; update(); }
		
	    /**
		 * @private
		 **/
		public function set height( p_nValue:int ):void { m_nH = p_nValue; update(); }

		
		private var m_nW:int = 0;
		private var m_nW2:int = 0;
		private var m_nH:int = 0;
		private var m_nH2:int = 0;
		private var m_nRatio:Number = 0;
	}
}