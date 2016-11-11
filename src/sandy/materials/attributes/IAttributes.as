
package sandy.materials.attributes
{
	import flash.display.Graphics;

	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.scenegraph.Sprite2D;
	import sandy.materials.Material;

	/**
	* Interface for all the elements that represent a material attribute property.
	* This interface is important to make attributes really flexible and allow users to extend it.
	*/
	public interface IAttributes
	{
		/**
		* @private
		*/
		function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void;

		/**
		* @private
		*/
		function drawOnSprite( p_oSprite:Sprite2D, p_oMaterial:Material, p_oScene:Scene3D ):void;

		/**
		* @private
		*/
		function init( p_oPolygon:Polygon ):void;

		/**
		* @private
		*/
		function unlink( p_oPolygon:Polygon ):void;

		/**
		* @private
		*/
		function begin( p_oScene:Scene3D ):void;

		/**
		* @private
		*/
		function finish( p_oScene:Scene3D ):void;

		/**
		* @private
		*/
		function get flags():uint;
	}
}