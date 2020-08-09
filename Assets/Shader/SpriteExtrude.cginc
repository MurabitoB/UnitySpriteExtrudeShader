

sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _SideTex;
float4 _SideTex_ST;
inline fixed4 SampleSpriteTexture (float3 uv)
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