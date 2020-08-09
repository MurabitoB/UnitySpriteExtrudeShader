
#ifndef SPRITE_EXTRUDE
#define SPRITE_EXTRUDE

fixed4 _Color;
float _Depth;
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _SideTex;
float4 _SideTex_ST;
#include "AutoLight.cginc"

// The reason why the below macro exist
// https://forum.unity.com/threads/unrecognized-identifier-shadow_coords-error-in-2017-3.509446/


#ifndef AUTOLIGHT_FIXES_INCLUDED
#define AUTOLIGHT_FIXES_INCLUDED
 
#include "HLSLSupport.cginc"
#include "UnityShadowLibrary.cginc"
 
// Problem 1: SHADOW_COORDS - undefined identifier.
// Why: Using SHADOWS_DEPTH without SPOT.
// The file AutoLight.cginc only takes into account the case where you use SHADOWS_DEPTH + SPOT (to enable SPOT just add a Spot Light in the scene).
// So, if your scene doesn't have a Spot Light, it will skip the SHADOW_COORDS definition and shows the error.
// Now, to workaround this you can:
// 1. Add a Spot Light to your scene
// 2. Use this CGINC to workaround this scase.  Also, you can copy this in your own shader.
#if defined (SHADOWS_DEPTH) && !defined (SPOT)
#       define SHADOW_COORDS(idx1) unityShadowCoord2 _ShadowCoord : TEXCOORD##idx1;
#endif
 
 
// Problem 2: _ShadowCoord - invalid subscript.
// Why: nor Shadow screen neighter Shadow Depth or Shadow Cube and trying to use _ShadowCoord attribute.
// The file AutoLight.cginc defines SHADOW_COORDS to empty when no one of these options are enabled (SHADOWS_SCREEN, SHADOWS_DEPTH and SHADOWS_CUBE),
// So, if you try to call "o._ShadowCoord = ..." it will break because _ShadowCoord isn't an attribute in your structure.
// To workaround this you can:
// 1. Check if one of those defines actually exists in any place where you have "o._ShadowCoord...".
// 2. Use the define SHADOWS_ENABLED from this file to perform the same check.
#if defined (SHADOWS_SCREEN) || defined (SHADOWS_DEPTH) || defined (SHADOWS_CUBE)
#    define SHADOWS_ENABLED
#    define TRANSFER_SHADOW(a) a._ShadowCoord = ComputeScreenPos(a.pos);
#endif
 
#endif
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
struct g2f_lit
{
    float4 pos   : SV_POSITION;
    float3 texcoord  : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
    float3 worldNormal : TEXCOORD3;
    SHADOW_COORDS(4)
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
[maxvertexcount(18)]
void geom_lit(triangle v2g IN[3],inout TriangleStream<g2f_lit> triStream)
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
    
    g2f_lit v;
    v.normal = normal;
    // Draw Front Cap
    v.pos = UnityObjectToClipPos(v0);
    v.worldPos = UnityObjectToWorldDir(v0);
    v.worldNormal = worldNormal;
    v.texcoord = float3(IN[0].texcoord,0);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v1);
    v.worldPos = UnityObjectToWorldDir(v1);
    v.worldNormal = worldNormal;
    v.texcoord = float3(IN[1].texcoord,0);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2);
    v.worldPos = UnityObjectToWorldDir(v2);
    v.worldNormal = worldNormal;
    v.texcoord = float3(IN[2].texcoord,0);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    triStream.RestartStrip();
    worldNormal = UnityObjectToWorldNormal(float3(0,0,1));
    //Draw Back Side
    v.pos = UnityObjectToClipPos(v1 + normal);
    v.worldPos = UnityObjectToWorldDir(v1 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(IN[1].texcoord,0);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    v.worldPos = UnityObjectToWorldDir(v0 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(IN[0].texcoord,0);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2 + normal);
    v.worldPos = UnityObjectToWorldDir(v2 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(IN[2].texcoord,0);
    TRANSFER_SHADOW(v);
    triStream.Append(v);
    triStream.RestartStrip();
    
    //Draw Cardboard Side
    float3 v02 = v2 - v0;
    worldNormal = UnityObjectToWorldNormal(cross(v02,normal));
    v.pos = UnityObjectToClipPos(v0);
    v.worldPos = UnityObjectToWorldDir(v0 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v0dtex0,1);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2);
    v.worldPos = UnityObjectToWorldDir(v2);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v2dtex0,1);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    v.worldPos = UnityObjectToWorldDir(v0 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v0dtex1,1);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    triStream.RestartStrip();

    v.pos = UnityObjectToClipPos(v2 + normal);
    v.worldPos = UnityObjectToWorldDir(v2 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v2dtex1,1);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    v.worldPos = UnityObjectToWorldDir(v0 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v0dtex1,1);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2);
    v.worldPos = UnityObjectToWorldDir(v2);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v2dtex0,1);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    triStream.RestartStrip();

    //Draw Cardboard Side 
    float3 v01 = v0 - v1;
    worldNormal = UnityObjectToWorldNormal(cross(v01,normal));

    v.pos = UnityObjectToClipPos(v1);
    v.worldPos = UnityObjectToWorldDir(v1);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v1dtex0,1);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0);
    v.worldPos = UnityObjectToWorldDir(v0);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v0dtex0,1);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    v.worldPos = UnityObjectToWorldDir(v0 +normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v0dtex1,1);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    triStream.RestartStrip();

    v.pos = UnityObjectToClipPos(v0 +  normal);
    v.worldPos = UnityObjectToWorldDir(v0 +  normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v0dtex1,1);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v1 + normal);
    v.worldPos = UnityObjectToWorldDir(v1 +  normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v1dtex1,1);
    TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v1);
    v.worldPos = UnityObjectToWorldDir(v1);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v1dtex0,1);
    TRANSFER_SHADOW(v);
    triStream.Append(v);
    triStream.RestartStrip();
}

fixed4 frag(g2f_standard IN) : SV_Target
{
    fixed4 c = SampleSpriteTexture(IN.texcoord);
    return c;
}
#endif