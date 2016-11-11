
package sandy.parser
{
	/**
	 * Static class that defines the chunks offsets of 3DS file.
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		1.0
	 * @version		3.1
	 * @date 		04.08.2007
	 */
	public final class Parser3DSChunkTypes
	{
		 //>------ primary chunk

		 public static const MAIN3DS       :uint = 0x4D4D;

		 public static const EDIT3DS       :uint = 0x3D3D;  // this is the start of the editor config
		 public static const KEYF3DS       :uint = 0xB000;  // this is the start of the keyframer config

		 //>------ sub defines of EDIT3DS

		 public static const EDIT_MATERIAL :uint = 0xAFFF;
		 public static const EDIT_CONFIG1  :uint = 0x0100;
		 public static const EDIT_CONFIG2  :uint = 0x3E3D;
		 public static const EDIT_VIEW_P1  :uint = 0x7012;
		 public static const EDIT_VIEW_P2  :uint = 0x7011;
		 public static const EDIT_VIEW_P3  :uint = 0x7020;
		 public static const EDIT_VIEW1    :uint = 0x7001;
		 public static const EDIT_BACKGR   :uint = 0x1200;
		 public static const EDIT_AMBIENT  :uint = 0x2100;
		 public static const EDIT_OBJECT   :uint = 0x4000;

		 public static const EDIT_UNKNW01  :uint = 0x1100;
		 public static const EDIT_UNKNW02  :uint = 0x1201;
		 public static const EDIT_UNKNW03  :uint = 0x1300;
		 public static const EDIT_UNKNW04  :uint = 0x1400;
		 public static const EDIT_UNKNW05  :uint = 0x1420;
		 public static const EDIT_UNKNW06  :uint = 0x1450;
		 public static const EDIT_UNKNW07  :uint = 0x1500;
		 public static const EDIT_UNKNW08  :uint = 0x2200;
		 public static const EDIT_UNKNW09  :uint = 0x2201;
		 public static const EDIT_UNKNW10  :uint = 0x2210;
		 public static const EDIT_UNKNW11  :uint = 0x2300;
		 public static const EDIT_UNKNW12  :uint = 0x2302;
		 public static const EDIT_UNKNW13  :uint = 0x3000;
		 public static const EDIT_UNKNW14  :uint = 0xAFFF;

		 //>------ sub defines of EDIT_OBJECT
		 public static const OBJ_TRIMESH   :uint = 0x4100;
		 public static const OBJ_LIGHT     :uint = 0x4600;
		 public static const OBJ_CAMERA    :uint = 0x4700;

		 public static const OBJ_UNKNWN01  :uint = 0x4010;
		 public static const OBJ_UNKNWN02  :uint = 0x4012; //>>---- Could be shadow

		 // MAP_TEXFLNM is part of MAT_TEXMAP, MAT_TEXMAP is part of EDIT_MATERIAL
		 public static const MAT_NAME      :uint = 0xA000;
		 public static const MAT_TEXMAP    :uint = 0xA200;
		 public static const MAT_TEXFLNM   :uint = 0xA300;

		 //>------ sub defines of OBJ_CAMERA
		 public static const CAM_UNKNWN01  :uint = 0x4710;
		 public static const CAM_UNKNWN02  :uint = 0x4720;

		 //>------ sub defines of OBJ_LIGHT
		 public static const LIT_OFF       :uint = 0x4620;
		 public static const LIT_SPOT      :uint = 0x4610;
		 public static const LIT_UNKNWN01  :uint = 0x465A;

		 //>------ sub defines of OBJ_TRIMESH
		 public static const TRI_VERTEXL   :uint = 0x4110;
		 public static const TRI_FACEL2    :uint = 0x4111;
		 public static const TRI_FACEL1    :uint = 0x4120;
		 public static const TRI_MATERIAL  :uint = 0x4130;
		 public static const TRI_TEXCOORD  :uint = 0x4140;	// DAS 11-26-04
		 public static const TRI_SMOOTH    :uint = 0x4150;
		 public static const TRI_LOCAL     :uint = 0x4160;
		 public static const TRI_VISIBLE   :uint = 0x4165;


		 //>>------ sub defs of KEYF3DS

		 public static const KEYF_UNKNWN01 	:uint = 0xB009;
		 public static const KEYF_UNKNWN02 	:uint = 0xB00A;
		 public static const KEYF_FRAMES   	:uint = 0xB008;
		 public static const KEYF_OBJDES   	:uint = 0xB002;

		 //>>------ FRAMES INFO
		 public static const NODE_ID   		:uint = 0xB030;
		 public static const NODE_HDR   	:uint = 0xB010;
		 public static const PIVOT   		:uint = 0xB013;
		 public static const POS_TRACK_TAG	:uint = 0xB020;
		 public static const ROT_TRACK_TAG	:uint = 0xB021;
		 public static const SCL_TRACK_TAG	:uint = 0xB022;

		 //>>------  these define the different color chunk types
		 public static const COL_RGB  :uint = 0x0010;
		 public static const COL_TRU  :uint = 0x0011;
		 public static const COL_UNK  :uint = 0x0013;

		 //>>------ defines for viewport chunks

		 public static const TOP           :uint = 0x0001;
		 public static const BOTTOM        :uint = 0x0002;
		 public static const LEFT          :uint = 0x0003;
		 public static const RIGHT         :uint = 0x0004;
		 public static const FRONT         :uint = 0x0005;
		 public static const BACK          :uint = 0x0006;
		 public static const USER          :uint = 0x0007;
		 public static const CAMERA        :uint = 0x0008; // :uint = 0xFFFF is the actual code read from file
		 public static const LIGHT         :uint = 0x0009;
		 public static const DISABLED      :uint = 0x0010;
		 public static const BOGUS         :uint = 0x0011;
	}
}