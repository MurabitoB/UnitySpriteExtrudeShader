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
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma geometry geom
			#include "UnityCG.cginc"
			#include "SpriteExtrude.cginc"
			struct appdata_t
			{
				float4 pos   : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2g
			{
				float4 pos   : SV_POSITION;
				float2 texcoord  : TEXCOORD0;
			};
			struct g2f
			{
				float4 pos   : SV_POSITION;
				float3 texcoord  : TEXCOORD0;
			};
			
			fixed4 _Color;
			float _Depth;
			v2g vert(appdata_t IN)
			{
				v2g OUT;
				OUT.pos = IN.pos;
				OUT.texcoord = IN.texcoord;
				return OUT;
			}
			[maxvertexcount(18)]
			void geom(triangle v2g IN[3],inout TriangleStream<g2f> triStream)
			{
				float3 v0 = IN[0].pos.xyz;
				float3 v1 = IN[1].pos.xyz;
				float3 v2 = IN[2].pos.xyz;

				float2 v0td = normalize(float2(IN[0].texcoord.y- 0.5f,IN[0].texcoord.x- 0.5f));
				float2 v1td = normalize(float2(IN[1].texcoord.y- 0.5f,IN[1].texcoord.x- 0.5f));
				float2 v2td = normalize(float2(IN[2].texcoord.y- 0.5f,IN[2].texcoord.x- 0.5f));

				float v0d = atan2(v0td.y,v0td.x);
				float v1d = atan2(v1td.y,v1td.x);
				float v2d = atan2(v2td.y,v2td.x);

				float2 v0dtex0 = float2(v0d * _SideTex_ST.x ,0);
				float2 v1dtex0 = float2(v1d * _SideTex_ST.x,0);
				float2 v2dtex0 = float2(v2d * _SideTex_ST.x,0);

				float2 v0dtex1 = float2(v0d * _SideTex_ST.x,1 * _SideTex_ST.y);
				float2 v1dtex1 = float2(v1d * _SideTex_ST.x,1 * _SideTex_ST.y);
				float2 v2dtex1 = float2(v2d * _SideTex_ST.x,1 * _SideTex_ST.y);

				float3 normal = float3(0,0,1 * _Depth);
				g2f OUT;
				// Draw Front Cap
				
				OUT.pos = UnityObjectToClipPos(v0);
				OUT.texcoord = float3(IN[0].texcoord,0);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v1);
				OUT.texcoord = float3(IN[1].texcoord,0);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2);
				OUT.texcoord = float3(IN[2].texcoord,0);
				triStream.Append(OUT);

				triStream.RestartStrip();

				//Draw Back Side
				OUT.pos = UnityObjectToClipPos(v1 + normal);
				OUT.texcoord = float3(IN[1].texcoord,0);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal) ;
				OUT.texcoord = float3(IN[0].texcoord,0);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2 + normal);
				OUT.texcoord = float3(IN[2].texcoord,0);
				triStream.Append(OUT);
				triStream.RestartStrip();
				
				//Draw Cardboard Side 
				OUT.pos = UnityObjectToClipPos(v0);
				OUT.texcoord = float3(v0dtex0,1);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2);
				OUT.texcoord = float3(v2dtex0,1);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				OUT.texcoord = float3(v0dtex1,1);
				triStream.Append(OUT);

				triStream.RestartStrip();

				OUT.pos = UnityObjectToClipPos(v2 + normal);
				OUT.texcoord = float3(v2dtex1,1);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				OUT.texcoord = float3(v0dtex1,1);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2);
				OUT.texcoord = float3(v2dtex0,1);
				triStream.Append(OUT);

				triStream.RestartStrip();

				//Draw Cardboard Side 
				OUT.pos = UnityObjectToClipPos(v1);
				OUT.texcoord = float3(v1dtex0,1);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0);
				OUT.texcoord = float3(v0dtex0,1);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				OUT.texcoord = float3(v0dtex1,1);
				triStream.Append(OUT);

				triStream.RestartStrip();

				OUT.pos = UnityObjectToClipPos(v0 +  normal);
				OUT.texcoord = float3(v0dtex1,1);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v1 + normal);
				OUT.texcoord = float3(v1dtex1,1);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v1);
				OUT.texcoord = float3(v1dtex0,1);
				triStream.Append(OUT);

				triStream.RestartStrip();


			}

			fixed4 frag(g2f IN) : SV_Target
			{
				fixed4 c = SampleSpriteTexture (IN.texcoord);
				return c;
			}
            
		ENDCG
		}
	}
}