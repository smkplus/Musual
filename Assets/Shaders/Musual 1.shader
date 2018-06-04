Shader "Unlit/NewUnlitShader"
{
	Properties
	{
	//dynamic texture
	_MusicData ("MusicData (Alpha)", 2D) = "white" {} 
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MusicData;
			float4 _MusicData_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MusicData);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col =tex2D(_MusicData, i.uv);
				/*
2D LED Spectrum - Visualiser
Based on Led Spectrum Analyser by: simesgreen - 27th February, 2013 https://www.shadertoy.com/view/Msl3zr
2D LED Spectrum by: uNiversal - 27th May, 2015
Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
*/



    // quantize coordinates
    const float bands = 30.0;
    const float segs = 40.0;
    float2 p;
    p.x = floor(i.uv.x*bands)/bands;
    p.y = floor(i.uv.y*segs)/segs;

    // read frequency data from first row of texture
    float fft  = tex2D( _MusicData, float2(p.x,0.0) ).x;

    // led color
    float3 color = lerp(float3(0.0, 2.0, 0.0), float3(2.0, 0.0, 0.0), sqrt(i.uv.y));

    // mask for bar graph
    float mask = (p.y < fft) ? 1.0 : 0.1;

    // led shape
    float2 d = frac((i.uv - p) *float2(bands, segs)) - 0.5;
    float led = smoothstep(0.5, 0.35, abs(d.x)) *
                smoothstep(0.5, 0.35, abs(d.y));
    float3 ledColor = led*color*mask;

    // output final color
    return float4(ledColor, 1.0);


				return col;
			}
			ENDCG
		}
	}
}
