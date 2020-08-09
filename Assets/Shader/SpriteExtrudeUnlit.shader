Shader "Sprites/SpriteExtrudeUnlit"
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
			"RenderType"="Opaque" 
			"Queue"="Geometry"
			"IgnoreProjector"="True" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Back
		Lighting Off
		ZWrite On
	//	Blend One OneMinusSrcAlpha

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom_standard
			#include "UnityCG.cginc"
			#include "SpriteExtrude.cginc"

		ENDCG
		}
	}
}