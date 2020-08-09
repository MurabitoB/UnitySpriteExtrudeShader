
#ifndef SPRITE_EXTRUDE
#define SPRITE_EXTRUDE

fixed4 _Color;
float _Depth;
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _SideTex;
float4 _SideTex_ST;
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "UnityCG.cginc"

inline fixed4 SampleSpriteTexture (float3 uv)
{
    if(uv.z == 0)
        return tex2D (_MainTex, uv.xy);
    else
        return tex2D(_SideTex,uv.xy);
}
struct appdata_simple
{
    float4 pos   : POSITION;
};
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
struct v2g_simple
{
    float4 pos   : SV_POSITION;
};
struct g2f_simple
{
    float4 pos   : SV_POSITION;
};
struct g2f_standard
{
    float4 pos   : SV_POSITION;
    float3 texcoord  : TEXCOORD0;
};

v2g vert(appdata_t IN)
{
    v2g v;
    v.pos = IN.pos;
    v.texcoord = IN.texcoord;
    return v;
}
v2g_simple vert_simple(appdata_simple IN)
{
    v2g_simple v;
    v.pos = IN.pos;
    return v;
}
[maxvertexcount(18)]
void geom_standard(triangle v2g IN[3],inout TriangleStream<g2f_standard> triStream)
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
    g2f_standard v;
    // Draw Front Cap
    
    v.pos = UnityObjectToClipPos(v0);
    v.texcoord = float3(IN[0].texcoord,0);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v1);
    v.texcoord = float3(IN[1].texcoord,0);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2);
    v.texcoord = float3(IN[2].texcoord,0);
    triStream.Append(v);

    triStream.RestartStrip();

    //Draw Back Side
    v.pos = UnityObjectToClipPos(v1 + normal);
    v.texcoord = float3(IN[1].texcoord,0);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal) ;
    v.texcoord = float3(IN[0].texcoord,0);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2 + normal);
    v.texcoord = float3(IN[2].texcoord,0);
    triStream.Append(v);
    triStream.RestartStrip();
    
    //Draw Cardboard Side 
    v.pos = UnityObjectToClipPos(v0);
    v.texcoord = float3(v0dtex0,1);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2);
    v.texcoord = float3(v2dtex0,1);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    v.texcoord = float3(v0dtex1,1);
    triStream.Append(v);

    triStream.RestartStrip();

    v.pos = UnityObjectToClipPos(v2 + normal);
    v.texcoord = float3(v2dtex1,1);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    v.texcoord = float3(v0dtex1,1);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2);
    v.texcoord = float3(v2dtex0,1);
    triStream.Append(v);

    triStream.RestartStrip();

    //Draw Cardboard Side 
    v.pos = UnityObjectToClipPos(v1);
    v.texcoord = float3(v1dtex0,1);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0);
    v.texcoord = float3(v0dtex0,1);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    v.texcoord = float3(v0dtex1,1);
    triStream.Append(v);

    triStream.RestartStrip();

    v.pos = UnityObjectToClipPos(v0 +  normal);
    v.texcoord = float3(v0dtex1,1);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v1 + normal);
    v.texcoord = float3(v1dtex1,1);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v1);
    v.texcoord = float3(v1dtex0,1);
    triStream.Append(v);

    triStream.RestartStrip();


}
[maxvertexcount(18)]
void geom_simple(triangle v2g_simple IN[3],inout TriangleStream<g2f_simple> triStream)
{
    float3 v0 = IN[0].pos.xyz;
    float3 v1 = IN[1].pos.xyz;
    float3 v2 = IN[2].pos.xyz;
    float3 normal = float3(0,0,1 * _Depth);
    g2f_simple v;
    // Draw Front Cap
    
    v.pos = UnityObjectToClipPos(v0);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v1);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2);
    triStream.Append(v);

    triStream.RestartStrip();

    //Draw Back Side
    v.pos = UnityObjectToClipPos(v1 + normal);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal) ;
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2 + normal);
    triStream.Append(v);
    triStream.RestartStrip();
    
    //Draw Cardboard Side 
    v.pos = UnityObjectToClipPos(v0);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    triStream.Append(v);

    triStream.RestartStrip();

    v.pos = UnityObjectToClipPos(v2 + normal);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2);
    triStream.Append(v);

    triStream.RestartStrip();

    //Draw Cardboard Side 
    v.pos = UnityObjectToClipPos(v1);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    triStream.Append(v);

    triStream.RestartStrip();

    v.pos = UnityObjectToClipPos(v0 +  normal);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v1 + normal);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v1);
    triStream.Append(v);
    triStream.RestartStrip();
    

}

fixed4 frag(g2f_standard IN) : SV_Target
{
    fixed4 c = SampleSpriteTexture(IN.texcoord);
    return c;
}
#endif