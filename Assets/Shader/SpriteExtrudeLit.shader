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
			#pragma fragment frag
			#pragma geometry geom
			#pragma multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
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
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				SHADOW_COORDS(4)
			};
			
			fixed4 _Color;
			float _Depth;
			sampler2D _MainTex;
			sampler2D _SideTex;
			float4 _SideTex_ST;
			sampler2D _AlphaTex;
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

				float3 worldNormal = UnityObjectToWorldNormal(float3(0,0,-1));
				
				g2f OUT;
				OUT.normal = normal;
				// Draw Front Cap
				OUT.pos = UnityObjectToClipPos(v0);
				OUT.worldPos = UnityObjectToWorldDir(v0);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(IN[0].texcoord,0);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v1);
				OUT.worldPos = UnityObjectToWorldDir(v1);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(IN[1].texcoord,0);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2);
				OUT.worldPos = UnityObjectToWorldDir(v2);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(IN[2].texcoord,0);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				triStream.RestartStrip();
				worldNormal = UnityObjectToWorldNormal(float3(0,0,1));
				//Draw Back Side
				OUT.pos = UnityObjectToClipPos(v1 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v1 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(IN[1].texcoord,0);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v0 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(IN[0].texcoord,0);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v2 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(IN[2].texcoord,0);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);
				triStream.RestartStrip();
				
				//Draw Cardboard Side
				float3 v02 = v2 - v0;
				worldNormal = UnityObjectToWorldNormal(cross(v02,normal));
				OUT.pos = UnityObjectToClipPos(v0);
				OUT.worldPos = UnityObjectToWorldDir(v0 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v0dtex0,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2);
				OUT.worldPos = UnityObjectToWorldDir(v2);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v2dtex0,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v0 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v0dtex1,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				triStream.RestartStrip();

				OUT.pos = UnityObjectToClipPos(v2 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v2 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v2dtex1,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v0 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v0dtex1,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2);
				OUT.worldPos = UnityObjectToWorldDir(v2);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v2dtex0,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				triStream.RestartStrip();

				//Draw Cardboard Side 
				float3 v01 = v0 - v1;
				worldNormal = UnityObjectToWorldNormal(cross(v01,normal));
	
				OUT.pos = UnityObjectToClipPos(v1);
				OUT.worldPos = UnityObjectToWorldDir(v1);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v1dtex0,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0);
				OUT.worldPos = UnityObjectToWorldDir(v0);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v0dtex0,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v0 +normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v0dtex1,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				triStream.RestartStrip();

				OUT.pos = UnityObjectToClipPos(v0 +  normal);
				OUT.worldPos = UnityObjectToWorldDir(v0 +  normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v0dtex1,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v1 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v1 +  normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v1dtex1,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v1);
				OUT.worldPos = UnityObjectToWorldDir(v1);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v1dtex0,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				triStream.RestartStrip();
				

			}

			fixed4 SampleSpriteTexture (float3 uv)
			{
				fixed4 color;
				if(uv.z == 0)
				{
					color = tex2D (_MainTex, uv.xy);
				}
				else
				{
					color = tex2D(_SideTex,uv.xy);
				}	
				return color;
			}

			fixed4 frag(g2f IN) : SV_Target
			{
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(IN.worldPos));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * max(0, dot(normalize(IN.worldNormal), lightDir));
				fixed4 c = SampleSpriteTexture (IN.texcoord);
				UNITY_LIGHT_ATTENUATION(atten, IN, IN.worldPos);
				return fixed4(c.rgb * ambient +  (c.rgb * diffuse) * atten ,1);
			}
            
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
			#pragma fragment frag
			#pragma geometry geom
			#pragma multi_compile_fwdadd
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
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
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				SHADOW_COORDS(4)
			};
			
			fixed4 _Color;
			float _Depth;
			sampler2D _MainTex;
			sampler2D _SideTex;
			float4 _SideTex_ST;
			sampler2D _AlphaTex;
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

				float3 worldNormal = UnityObjectToWorldNormal(float3(0,0,-1));
				
				g2f OUT;
				OUT.normal = normal;
				// Draw Front Cap
				OUT.pos = UnityObjectToClipPos(v0);
				OUT.worldPos = UnityObjectToWorldDir(v0);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(IN[0].texcoord,0);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v1);
				OUT.worldPos = UnityObjectToWorldDir(v1);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(IN[1].texcoord,0);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2);
				OUT.worldPos = UnityObjectToWorldDir(v2);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(IN[2].texcoord,0);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				triStream.RestartStrip();
				worldNormal = UnityObjectToWorldNormal(float3(0,0,1));
				//Draw Back Side
				OUT.pos = UnityObjectToClipPos(v1 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v1 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(IN[1].texcoord,0);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v0 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(IN[0].texcoord,0);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v2 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(IN[2].texcoord,0);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);
				triStream.RestartStrip();
				
				//Draw Cardboard Side
				float3 v02 = v2 - v0;
				worldNormal = UnityObjectToWorldNormal(cross(v02,normal));
				OUT.pos = UnityObjectToClipPos(v0);
				OUT.worldPos = UnityObjectToWorldDir(v0 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v0dtex0,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2);
				OUT.worldPos = UnityObjectToWorldDir(v2);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v2dtex0,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v0 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v0dtex1,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				triStream.RestartStrip();

				OUT.pos = UnityObjectToClipPos(v2 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v2 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v2dtex1,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v0 + normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v0dtex1,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v2);
				OUT.worldPos = UnityObjectToWorldDir(v2);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v2dtex0,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				triStream.RestartStrip();

				//Draw Cardboard Side 
				float3 v01 = v0 - v1;
				worldNormal = UnityObjectToWorldNormal(cross(v01,normal));
	
				OUT.pos = UnityObjectToClipPos(v1);
				OUT.worldPos = UnityObjectToWorldDir(v1);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v1dtex0,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0);
				OUT.worldPos = UnityObjectToWorldDir(v0);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v0dtex0,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v0 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v0 +normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v0dtex1,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				triStream.RestartStrip();

				OUT.pos = UnityObjectToClipPos(v0 +  normal);
				OUT.worldPos = UnityObjectToWorldDir(v0 +  normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v0dtex1,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v1 + normal);
				OUT.worldPos = UnityObjectToWorldDir(v1 +  normal);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v1dtex1,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				OUT.pos = UnityObjectToClipPos(v1);
				OUT.worldPos = UnityObjectToWorldDir(v1);
				OUT.worldNormal = worldNormal;
				OUT.texcoord = float3(v1dtex0,1);
				TRANSFER_SHADOW(OUT);
				triStream.Append(OUT);

				triStream.RestartStrip();
				

			}

			fixed4 SampleSpriteTexture (float3 uv)
			{
				fixed4 color;
				if(uv.z == 0)
				{
					color = tex2D (_MainTex, uv.xy);
				}
				else
				{
					color = tex2D(_SideTex,uv.xy);
				}	
				return color;
			}

			fixed4 frag(g2f IN) : SV_Target
			{
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(IN.worldPos));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * max(0, dot(normalize(IN.worldNormal), lightDir));
				fixed4 c = SampleSpriteTexture (IN.texcoord);
				UNITY_LIGHT_ATTENUATION(atten, IN, IN.worldPos);
				return fixed4(c.rgb * ambient +  (c.rgb * diffuse) * atten ,1);
			}
            
		ENDCG
		}
		// ShadowPass
		UsePass "Sprites/SpriteExtrudeShadowCaster/ShadowCaster"
	}
}