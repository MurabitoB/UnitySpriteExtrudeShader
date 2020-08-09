Shader "Sprites/SpriteExtrudeLit"
{
	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_SideTex("Side Texture",2D) = "white"{}
		_Depth("depth",float) = 1
	}

	SubShader
	{
		Tags
		{
			"DisableBatching" = "True" 
			"RenderType"="Opaque" 
			"Queue"="Geometry"
			"IgnoreProjector"="True" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Back
		Lighting On
		ZWrite On
		Pass
		{
			Tags
			{ 
				"LightMode"="ForwardBase"
			}
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_lit
			#pragma geometry geom_lit
			#pragma multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "SpriteExtrude.cginc"
			

            
		ENDCG
		}
		Pass
		{
			Tags
			{ 
				"LightMode"="ForwardAdd"
			}
			Blend One One
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_lit
			#pragma geometry geom_lit
			#pragma multi_compile_fwdadd
			#include "UnityCG.cginc"
			#include "SpriteExtrude.cginc"


            
		ENDCG
		}
		// ShadowPass
		UsePass "Sprites/SpriteExtrudeShadowCaster/ShadowCaster"
	}
}