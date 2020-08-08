Shader "Sprites/SpriteExtrudeShadowCaster"
{
	SubShader
	{
		
		Pass
		{
			Name "ShadowCaster"
			Tags
			{ 
				"RenderType"="Opaque" 
				"Queue"="Geometry"
				"CanUseSpriteAtlas"="True"
				"LightMode"="ShadowCaster"
			}
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
				#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
			
			struct appdata_t
			{
				float4 pos   : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2g
			{
				float4 pos   : SV_POSITION;
			};
			struct g2f
			{
				float4 pos   : SV_POSITION;
			};
			
			float _Depth;

			v2g vert(appdata_t IN)
			{
				v2g OUT;
				OUT.pos = IN.pos;
				return OUT;
			}
			[maxvertexcount(18)]
			void geom(triangle v2g IN[3],inout TriangleStream<g2f> triStream)
			{
				float3 v0 = IN[0].pos.xyz;
				float3 v1 = IN[1].pos.xyz;
				float3 v2 = IN[2].pos.xyz;
				float3 normal = float3(0,0,1 * _Depth);
				g2f OUT;
				// Draw Front Cap
				
				OUT.pos = UnityObjectToClipPos(v0);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v1);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2);
				triStream.Append(OUT);

				triStream.RestartStrip();

				//Draw Back Side
				OUT.pos = UnityObjectToClipPos(v1 + normal);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal) ;
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2 + normal);
				triStream.Append(OUT);
				triStream.RestartStrip();
				
				//Draw Cardboard Side 
				OUT.pos = UnityObjectToClipPos(v0);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				triStream.Append(OUT);

				triStream.RestartStrip();

				OUT.pos = UnityObjectToClipPos(v2 + normal);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2);
				triStream.Append(OUT);

				triStream.RestartStrip();

				//Draw Cardboard Side 
				OUT.pos = UnityObjectToClipPos(v1);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				triStream.Append(OUT);

				triStream.RestartStrip();

				OUT.pos = UnityObjectToClipPos(v0 +  normal);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v1 + normal);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v1);
				triStream.Append(OUT);
				triStream.RestartStrip();
				

			}
			fixed4 frag(g2f IN) : SV_Target
			{
				return fixed4(1,1,1,1);
			}
            
		ENDCG
		}
	}
}