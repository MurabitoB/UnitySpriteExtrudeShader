Shader "Sprites/SpriteExtrudeShadowCaster"
{
	SubShader
	{
		Tags
		{ 
			"RenderType"="Opaque" 
			"Queue"="Geometry"
			"CanUseSpriteAtlas"="True"
			"LightMode"="ShadowCaster"
		}
		Pass
		{
			Name "ShadowCaster"
			CGPROGRAM
			#pragma vertex vert_simple
			#pragma fragment frag_simple
			#pragma geometry geom_simple
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
			#include "SpriteExtrude.cginc"
			
			fixed4 frag_simple(g2f_simple IN) : SV_Target
			{
				return fixed4(1,1,1,1);
			}
            
		ENDCG
		}
	}
}