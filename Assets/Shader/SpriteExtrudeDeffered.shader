Shader "Sprites/SpriteExtrudeDeffered"
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
			Tags {"LightMode"="Deferred"}
			
		CGPROGRAM
		struct structurePS
			{
				half4 albedo : SV_Target0;
				half4 specular : SV_Target1;
				half4 normal : SV_Target2;
				half4 emission : SV_Target3;
			};
			#pragma vertex vert
			#pragma fragment pixel_shader
			#pragma geometry geom_lit
			#pragma exclude_renderers nomrt
			#pragma multi_compile ___ UNITY_HDR_ON
			#include "UnityCG.cginc"
			#include "SpriteExtrude.cginc"
			structurePS pixel_shader (g2f_lit vs)
			{
				structurePS ps;
				float3 normalDirection = normalize(vs.worldNormal);
				half3 specular;
				half specularMonochrome; 
				half3 diffuseColor = DiffuseAndSpecularFromMetallic(SampleSpriteTexture(vs.texcoord), 0, specular, specularMonochrome );
				ps.albedo = half4( diffuseColor, 1.0 );
				ps.specular = half4( specular, 0 );
				ps.normal = half4( normalDirection * 0.5 + 0.5, 1.0 );
				ps.emission = half4(0,0,0,1);
				#ifndef UNITY_HDR_ON
					ps.emission.rgb = exp2(-ps.emission.rgb);
				#endif
				return ps;
			}
		ENDCG
		}
		// ShadowPass
		UsePass "Sprites/SpriteExtrudeShadowCaster/ShadowCaster"
	}
}