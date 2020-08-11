Shader "Sprites/SpriteExtrudeDefferedLit"
{
	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_Metallic ("Metallic", Range(0, 1)) = 1
		_Gloss ("Gloss", Range(0, 1)) = 0.8
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
	//	Lighting On
		ZWrite On
		Pass
		{
			Tags {"LightMode"="Deferred"}
			
		CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag_deffered_lit
			#pragma geometry geom_lit
			#pragma exclude_renderers nomrt
			#pragma multi_compile ___ UNITY_HDR_ON
			#include "UnityCG.cginc"
			#include "SpriteExtrude.cginc"
		ENDCG
		}
		// ShadowPass
		UsePass "Sprites/SpriteExtrudeShadowCaster/ShadowCaster"
	}
}