
#ifndef SPRITE_EXTRUDE
#define SPRITE_EXTRUDE

fixed4 _Color;
float _Depth;
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _SideTex;
float4 _SideTex_ST;
float _Metallic;
float _Gloss;
 #include "AutoLight.cginc"
 #include "Lighting.cginc"
 
//#endif
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
 //   SHADOW_COORDS(4) Geometry shader not suppot forward rendering path
};
struct structurePS
{
    half4 specular : SV_Target0;
    half4 albedo : SV_Target1;
    half4 normal : SV_Target2;
    half4 emission : SV_Target3;
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
   
    float2 v0dtex0 = float2(v0d * _SideTex_ST.x + _SideTex_ST.z ,0 + _SideTex_ST.w);
    float2 v1dtex0 = float2(v1d * _SideTex_ST.x + _SideTex_ST.z ,0 + _SideTex_ST.w);
    float2 v2dtex0 = float2(v2d * _SideTex_ST.x + _SideTex_ST.z,0+ _SideTex_ST.w);

    float2 v0dtex1 = float2(v0d * _SideTex_ST.x + _SideTex_ST.z,1 * _SideTex_ST.y+ _SideTex_ST.w);
    float2 v1dtex1 = float2(v1d * _SideTex_ST.x + _SideTex_ST.z,1 * _SideTex_ST.y+ _SideTex_ST.w);
    float2 v2dtex1 = float2(v2d * _SideTex_ST.x + _SideTex_ST.z,1 * _SideTex_ST.y+ _SideTex_ST.w);

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
    
    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v0));
    triStream.Append(v);

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v1));
    triStream.Append(v);

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v2));
    triStream.Append(v);

    triStream.RestartStrip();

    //Draw Back Side
    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v1 + normal));
    triStream.Append(v);

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v0 + normal));
    triStream.Append(v);

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v2 + normal));
    triStream.Append(v);
    triStream.RestartStrip();
    
    //Draw Cardboard Side 
    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v0));
    triStream.Append(v);

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v2));
    triStream.Append(v);

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v0 + normal));
    triStream.Append(v);

    triStream.RestartStrip();

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v2 + normal));
    triStream.Append(v);

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v0 + normal));
    triStream.Append(v);

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v2));
    triStream.Append(v);

    triStream.RestartStrip();

    //Draw Cardboard Side 
    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v1));
    triStream.Append(v);

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v0));
    triStream.Append(v);

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v0 + normal));
    triStream.Append(v);

    triStream.RestartStrip();

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v0 +  normal));
    triStream.Append(v);

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v1 + normal));
    triStream.Append(v);

    v.pos = UnityApplyLinearShadowBias(UnityObjectToClipPos(v1));
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

    float2 v0dtex0 = float2(v0d * _SideTex_ST.x + _SideTex_ST.z ,0 + _SideTex_ST.w);
    float2 v1dtex0 = float2(v1d * _SideTex_ST.x + _SideTex_ST.z ,0 + _SideTex_ST.w);
    float2 v2dtex0 = float2(v2d * _SideTex_ST.x + _SideTex_ST.z,0+ _SideTex_ST.w);

    float2 v0dtex1 = float2(v0d * _SideTex_ST.x + _SideTex_ST.z,1 * _SideTex_ST.y+ _SideTex_ST.w);
    float2 v1dtex1 = float2(v1d * _SideTex_ST.x + _SideTex_ST.z,1 * _SideTex_ST.y+ _SideTex_ST.w);
    float2 v2dtex1 = float2(v2d * _SideTex_ST.x + _SideTex_ST.z,1 * _SideTex_ST.y+ _SideTex_ST.w);

    float3 normal = float3(0,0,1 * _Depth);

    float3 worldNormal = UnityObjectToWorldNormal(float3(0,0,-1));
    
    g2f_lit v;
    v.normal = normal;
    // Draw Front Cap
    v.pos = UnityObjectToClipPos(v0);
    v.worldPos = UnityObjectToWorldDir(v0);
    v.worldNormal = worldNormal;
    v.texcoord = float3(IN[0].texcoord,0);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v1);
    v.worldPos = UnityObjectToWorldDir(v1);
    v.worldNormal = worldNormal;
    v.texcoord = float3(IN[1].texcoord,0);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2);
    v.worldPos = UnityObjectToWorldDir(v2);
    v.worldNormal = worldNormal;
    v.texcoord = float3(IN[2].texcoord,0);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    triStream.RestartStrip();
    worldNormal = UnityObjectToWorldNormal(float3(0,0,1));
    //Draw Back Side
    v.pos = UnityObjectToClipPos(v1 + normal);
    v.worldPos = UnityObjectToWorldDir(v1 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(IN[1].texcoord,0);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    v.worldPos = UnityObjectToWorldDir(v0 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(IN[0].texcoord,0);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2 + normal);
    v.worldPos = UnityObjectToWorldDir(v2 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(IN[2].texcoord,0);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);
    triStream.RestartStrip();
    
    //Draw Cardboard Side
    float3 v02 = v2 - v0;
    worldNormal = UnityObjectToWorldNormal(cross(v02,normal));
    v.pos = UnityObjectToClipPos(v0);
    v.worldPos = UnityObjectToWorldDir(v0 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v0dtex0,1);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2);
    v.worldPos = UnityObjectToWorldDir(v2);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v2dtex0,1);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    v.worldPos = UnityObjectToWorldDir(v0 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v0dtex1,1);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    triStream.RestartStrip();

    v.pos = UnityObjectToClipPos(v2 + normal);
    v.worldPos = UnityObjectToWorldDir(v2 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v2dtex1,1);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    v.worldPos = UnityObjectToWorldDir(v0 + normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v0dtex1,1);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v2);
    v.worldPos = UnityObjectToWorldDir(v2);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v2dtex0,1);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    triStream.RestartStrip();

    //Draw Cardboard Side 
    float3 v01 = v0 - v1;
    worldNormal = UnityObjectToWorldNormal(cross(v01,normal));

    v.pos = UnityObjectToClipPos(v1);
    v.worldPos = UnityObjectToWorldDir(v1);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v1dtex0,1);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0);
    v.worldPos = UnityObjectToWorldDir(v0);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v0dtex0,1);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v0 + normal);
    v.worldPos = UnityObjectToWorldDir(v0 +normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v0dtex1,1);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    triStream.RestartStrip();

    v.pos = UnityObjectToClipPos(v0 +  normal);
    v.worldPos = UnityObjectToWorldDir(v0 +  normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v0dtex1,1);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v1 + normal);
    v.worldPos = UnityObjectToWorldDir(v1 +  normal);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v1dtex1,1);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);

    v.pos = UnityObjectToClipPos(v1);
    v.worldPos = UnityObjectToWorldDir(v1);
    v.worldNormal = worldNormal;
    v.texcoord = float3(v1dtex0,1);
   // TRANSFER_SHADOW(v);
    triStream.Append(v);
    triStream.RestartStrip();
}

fixed4 frag(g2f_standard IN) : SV_Target
{
    fixed4 c = SampleSpriteTexture(IN.texcoord);
    return c;
}
structurePS frag_deffered_lit (g2f_lit vs)
{
    structurePS ps;
    float3 normalDirection = normalize(vs.worldNormal);
    half3 specular;
    half specularMonochrome; 
    half3 diffuseColor = DiffuseAndSpecularFromMetallic(SampleSpriteTexture(vs.texcoord), _Metallic, specular, specularMonochrome );
    ps.albedo = half4(diffuseColor, 1.0 );
    ps.specular = half4(specular,_Gloss );
    ps.normal = half4( normalDirection * 0.5 + 0.5, 1.0 );
    ps.emission = half4(0,0,0,1);
    #ifndef UNITY_HDR_ON
        ps.emission.rgb = exp2(-ps.emission.rgb);
    #endif
    return ps;
}
// Geometry shader not support Forward Rending Path
// fixed4 frag_lit(g2f_lit IN) : SV_Target
// {
//     fixed3 lightDir = normalize(UnityWorldSpaceLightDir(IN.worldPos));
//     fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
//     fixed3 diffuse = _LightColor0.rgb * max(0, dot(normalize(IN.worldNormal), lightDir));
//     fixed4 c = SampleSpriteTexture (IN.texcoord);
//     UNITY_LIGHT_ATTENUATION(atten, IN, IN.worldPos);
//     return fixed4(c.rgb * ambient +  (c.rgb * diffuse) * atten ,1);
// }

#endif