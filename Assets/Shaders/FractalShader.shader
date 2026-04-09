Shader "Unlit/FractalShader"
{
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float3 palette(float t)
            {
                float3 a = float3(0.5, 0.5, 0.5);
                float3 b = float3(0.5, 0.5, 0.5);
                float3 c = float3(1.0, 1.0, 1.0);
                float3 d = float3(0.263,0.416,0.557);
                return a + b * cos(6.28318 * (c * t + d));
            }

            float4 frag (v2f i) : SV_Target
            {
                float time = _Time.y;

                // aspect-corrected uvs within [-1, 1]
                float2 uv = i.uv;
                uv = uv * 2.0 - 1.0;
                //uv.x *= _ScreenParams.x / _ScreenParams.y;
                
                // copy of original uv so we can sample global distance relative to centre (before space repetition)
                float2 uv0 = uv;
                
                // Accumulate colour onto a black background
                float3 finalColor = float3(0.0, 0.0, 0.0);
                
                // Increase/decrease the iteration count to control number of repetitions
                for (float i = 0.0; i < 4.0; i++)
                {
                    // Repeat space then re-centre uvs
                    uv = frac(uv * 1.5) - 0.5;
                    
                    // Combining x^2 and e^-x^2
                    float d = length(uv) * exp(-length(uv0));
                    
                    // Animate colours based on distance, iteration count, and time
                    float3 col = palette(length(uv0) + i*.4 + time*.4);
                    
                    // Create ripples
                    d = sin(d*8. + time)/8.;
                    d = abs(d);
                    d = pow(0.01 / d, 1.2);
                    
                    // Attenuate colour based on restricted logarithmic curve
                    finalColor += col * clamp(log(d), 0.01, 0.8);
                }
                
                return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
