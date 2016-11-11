
package sandy.core.scenegraph 
{    
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import sandy.core.Scene3D;
	import sandy.events.BubbleEvent;
	import sandy.core.data.Matrix4;
	import sandy.view.Frustum;

	/**
	 * Transform audio volume and pan relative to the Camera3D 
	 * 
	 * @author		Daniel Reitterer - Delta 9
	 * @version		3.1
	 * @date 		14.12.2007
	 */
	public class Sound3D extends ATransformable
	{
		// events
		public static var LOOP:String = "loop";
		public static var CULL_PLAY:String = "cullPlay";
		public static var CULL_STOP:String = "cullStop";
		// type
		public static const SPEECH:String = "speech";
		public static const NOISE:String = "noise";
		
		/**
		 * Max volume of the sound if camera position is at sound position
		 */
		public var soundVolume:Number;
		/**
		 * The radius of the sound
		 */
		public var soundRadius:Number;
		/**
		* If pan is true the panning of the sound is relative to the camera rotation
		 */
		public var soundPan:Boolean=true;
		/**
		 * Maximal pan is a positive Number from 0-1 or higher
		 */
		public var maxPan:Number = 1;
		/**
		 * If the sound contains two channels, stereo have to be set to true in order to mix left and right channels correctly
		 */
		public var stereo:Boolean = false;
		/**
		 * If flipPan is true the left and right channels of the sound are mirrored if the camera is facing away from the sound
		 */
		public var flipPan:Boolean=true;
		/**
		 * Type is either SPEECH or NOISE, SPEECH will start the sound at the last position if the camera enters the sphere of the sound
		 */
		public var type:String = SPEECH;
		/**
		 * The start time to play the audio from
		 */
		public var startTime:Number = 0;
		/**
		 * Number of loops before the sound stops
		 */
		public var loops:int = 0xffffff;
		/**
		 * Start time to play the audio from if the sound loops
		 */
		public var loopStartTime:Number=0;
		/**
		 * Returns true if the stereo panorama is mirrored, flipPan have to be true to enable stereo flipping
		 */
		public function get isFlipped ():Boolean{return _isFlipped;}
		
		private var _isFlipped:Boolean=false;
		private var _isPlaying:Boolean=false;
		private var soundCulled:Boolean=false;
		private var m_oSoundTransform:SoundTransform = new SoundTransform(1,0);
		private var sMode:String = ""; // sound, channel or url
		private var urlReq:URLRequest;
		private var channelRef:SoundChannel;
		private var soundRef:Sound;
		private var lastPosition:Number=0;
		private var lastStopTime:Number=0;
		private var cPlaying:Boolean=false;
		private var duration:Number=0;
		private var cLoop:int=0;
		
		/**
		 * Creates a 3D sound object wich can be placed in the 3d scene. Set stereo to true if the sound source is in stereo.
		 * If stereo is true, both channels are at the same position in 3d space, but the stereo panorama is kept and mirrored if required.
		 * To create a true stereo effect, take two Sound3D instances and two mono sound sources on different locations in 3d space.
		 * 
		 * @param 	p_sName				A string identifier for this object
		 * @param	p_oSoundSource		The sound source, a String, UrlRequest, Sound or a SoundChannel object
		 * @param	p_nVolume			Volume of the sound
		 * @param	p_nMaxPan			Max pan of the sound, if zero panning is disabled
		 * @param	p_nRadius			Radius of the sound in 3d units
		 * @param	p_bStereo			If the sound contains two different channels
		 */
		public function Sound3D( p_sName:String = "", p_oSoundSource:*=null, p_nVolume:Number=1, 
								p_nMaxPan:Number=0, p_nRadius:Number=1, p_bStereo:Boolean=false ) 
		{
			super( p_sName );
			
			soundVolume = p_nVolume;
			soundRadius = p_nRadius;
			soundSource = p_oSoundSource;
			stereo = p_bStereo;
			
			if(p_nMaxPan == 0) 
			{
				soundPan = false;
			}
			else
			{
				soundPan = true;
				maxPan = p_nMaxPan;
			}
	    }
		
		/**
		 * Start Sound sources of type Sound or UrlRequest. 
		 * Sound sources of type SoundChannel don't support the play method
		 * @param	p_nStartTime
		 * @param	p_iLoops
		 */
		public function play (p_nStartTime:Number=-1, p_iLoops:int=-1, p_nLoopStartTime:Number=-1, p_bResume:Boolean=false) :void 
		{
			if(!_isPlaying && sMode != "channel") 
			{
				
				if(p_nStartTime != -1) lastPosition = p_nStartTime;
				if(p_iLoops != -1) loops = p_iLoops;
				if(p_nLoopStartTime != -1) loopStartTime = p_nLoopStartTime;
				
				if(!p_bResume) 
				{
					lastPosition = startTime;
					lastStopTime = getTimer();
				}
				cLoop = 0;
				_isPlaying = true;
				cPlaying = false;
			}
		}
		
		/**
		 * Stop the sound source and SoundChannel
		 */
		public function stop () :void 
		{
			if(_isPlaying && sMode != "channel") 
			{
				if(cPlaying) cStop();
				_isPlaying = false;
				cPlaying = false;
			}
		}
		
		public function get currentLoop () :int 
		{
			return cLoop;
		}
		
		/**
		 * Set the sound source, the sound source can be a String, URLRequest, Sound or SoundChannel object
		 */
		public function set soundSource (s:*) :void 
		{
			if(s is Sound) 
			{
				sMode = "sound";
				soundRef = s as Sound;
				if(soundRef.length > 0) duration = soundRef.length;
			}
			else if(s is SoundChannel) 
			{
				sMode = "channel";
				_isPlaying = true;
				channelRef = s as SoundChannel;
			}
			else if(s is String) 
			{
				sMode = "url";
				urlReq = new URLRequest(s);
			}
			else
			{
				sMode = "url";
				urlReq = s as URLRequest;
			}
		}
		
		/**
		 * Returns the sound source, the sound source may be a URLRequest, Sound or SoundChannel object
		 */
		public function get soundSource () :* 
		{
			switch (sMode) 
			{
				case "sound":
					return soundRef;
				case "channel":
					return channelRef;
				case "url":
					return urlReq;
				default:
					return null;
			}
		}
		
		public function get soundMode () :String 
		{
			return sMode;
		}
		
		private function updateSoundTransform () :void 
		{
			var gv:Matrix4 = modelMatrix;
			var rv:Matrix4 = scene.camera.modelMatrix;
			var dx:Number = gv.n14 - rv.n14;
			var dy:Number = gv.n24 - rv.n24;
			var dz:Number = gv.n34 - rv.n34;
			var dist:Number = Math.sqrt(dx*dx + dy*dy + dz*dz);
			
			if(dist <= 0.001) 
			{
				m_oSoundTransform.volume = soundVolume;
				m_oSoundTransform.pan = 0;
				soundCulled = false;
			}
			else if(dist <= soundRadius) 
			{
				var pa:Number = 0;
				if(soundPan) 
				{
					var d:Number = dx*rv.n11 + dy*rv.n21 + dz*rv.n31;
					var ang:Number = Math.acos(d/dist) - Math.PI/2;
					pa = - (ang/100 * (100/(Math.PI/2))) * maxPan;
					if(pa < -1) pa = -1;
					else if(pa > 1) pa = 1;
				}
				m_oSoundTransform.volume = (soundVolume/soundRadius) * (soundRadius-dist);
				m_oSoundTransform.pan = pa;
				soundCulled = false;
			}
			else 
			{
				if(!soundCulled) 
				{
					m_oSoundTransform.volume = 0;
					m_oSoundTransform.pan = 0;
					soundCulled = true;
				}
			}
		}
		
		// updates the sound channel and also set stereo panning in sound transform
		private function updateChannelRef () :void 
		{
			if(stereo) 
			{				
				var span:Number = m_oSoundTransform.pan;
				var pa:Number;
				
				if(span<0) 
				{
					pa = (span<-1 ? 1:-span);
					m_oSoundTransform.leftToLeft = 1;
					m_oSoundTransform.leftToRight = 0;
					m_oSoundTransform.rightToLeft = pa;
					m_oSoundTransform.rightToRight = 1-pa;
				}
				else
				{
					pa = (span > 1 ? 1:span);
					m_oSoundTransform.leftToLeft = 1-pa;
					m_oSoundTransform.leftToRight = pa;
					m_oSoundTransform.rightToLeft = 0;
					m_oSoundTransform.rightToRight = 1;
				}
				
				if(flipPan) 
				{
					
					var x2:Number = modelMatrix.n11;
					var y2:Number = modelMatrix.n21;
					var z2:Number = modelMatrix.n31;
					
					var gv:Matrix4 = scene.camera.modelMatrix;
					var mz:Number = -(x2*gv.n11 + y2*gv.n21 + z2*gv.n31);
					
					if(mz > 0) 
					{
						
						var l2l:Number = m_oSoundTransform.leftToLeft;
						var l2r:Number = m_oSoundTransform.leftToRight;
						var r2l:Number = m_oSoundTransform.rightToLeft;
						var r2r:Number = m_oSoundTransform.rightToRight;
						
						m_oSoundTransform.leftToLeft = l2l+(l2r-l2l)*mz;
						m_oSoundTransform.leftToRight = l2r+(l2l-l2r)*mz;
						m_oSoundTransform.rightToLeft = r2l+(r2r-r2l)*mz;
						m_oSoundTransform.rightToRight = r2r+(r2l-r2r)*mz;
						_isFlipped = true;
					}
					else
					{
						_isFlipped = false;
					}
				}
			}
			
			channelRef.soundTransform = m_oSoundTransform;
		}
		
		private function soundCompleteHandler (e:Event) :void 
		{
			if(cLoop < loops) 
			{
				cLoop++;
				cPlaying = false;
				lastPosition = loopStartTime;
				lastStopTime = getTimer();
				cPlay();
				m_oEB.dispatchEvent( new BubbleEvent( LOOP, this ) );
			}
			else
			{
				if(sMode != "channel") 
				{
					_isPlaying = false;
					
					cStop();
				}
			}
		}
		
		private function completeHandler (e:Event) :void 
		{
			duration = soundRef.length;
		}
		
		/**
		 * Play the sound if the camera enters the culling sphere with the sound radius.
		 * This method should not be called if mode is "channel"
		 * 
		 * @param	isUrl true if thr urlReq should be loaded
		 */
		private function cPlay (isUrl:Boolean=false) :void 
		{
			if(!cPlaying) 
			{
				cPlaying = true;
				
				if(channelRef != null) channelRef.stop();
				
				if(isUrl) 
				{
					soundRef = new Sound();
					soundRef.addEventListener(Event.COMPLETE, completeHandler);
					soundRef.load(urlReq);
				}
				
				if(type == SPEECH) 
				{
					var len:Number = duration;
					var time:Number = startTime;
					
					if(len > 0) 
					{
						time = lastPosition + (getTimer()-lastStopTime);
						if(time > len) 
						{
							var fn:Number = time/len;
							var f:int = fn;
							cLoop += f;
							if(cLoop>loops) 
							{
								stop();
								return;
							}
							time = fn-f == 0 ? len : time - (len*f);
						}
					}
					channelRef = soundRef.play(time, 0);
				}
				else
				{
					channelRef = soundRef.play(startTime, 0);
				}
				if(!channelRef.hasEventListener(Event.SOUND_COMPLETE))
					channelRef.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
			}
		}
		
		private function cStop (isUrl:Boolean=false) :void 
		{
			if(cPlaying) 
			{
				cPlaying = false;
				if(channelRef != null) 
				{
					lastPosition = channelRef.position;
					lastStopTime = getTimer();
					channelRef.stop();
					channelRef.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				}
			}
		}
		
		public override function cull ( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean) :void 
		{
			if(_isPlaying) 
			{
				updateSoundTransform();
				
				var isUrl:Boolean = sMode == "url";
				
				if(isUrl || sMode == "sound") 
				{
					if(!soundCulled) 
					{
						if(!cPlaying) 
						{
							cPlay(isUrl);
							m_oEB.dispatchEvent( new BubbleEvent( CULL_PLAY, this ) );
						}
					}
					else
					{
						if(cPlaying) 
						{
							cStop(isUrl);
							m_oEB.dispatchEvent( new BubbleEvent( CULL_STOP, this ) );
						}
					}
				}
				
				updateChannelRef();
			}
		}
		
		public function get soundChannel () :SoundChannel 
		{
			return channelRef;
		}
		
		public override function toString () :String 
		{
			return "sandy.core.scenegraph.Sound3D";
		}
		
	}
}