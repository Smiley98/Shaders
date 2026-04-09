Shader "Hidden/FullscreenShader"
{
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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

            float sdCircle( float2 p, float r )
            {
                return length(p) - r;
            }

            float sdSphere( float3 p, float r )
            {
                return length(p) - r;
            }

            float sdBox( float3 p, float3 b )
            {
                float3 q = abs(p) - b;
                return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
            }

            float map(float3 p)
            {
                float t = sin(_Time.y) * 0.5 + 0.5;
                float3 pSphere = p - float3(-2.0, 0.0, 2.0);
                float3 pBox = p - float3( 2.0, 0.0, 2.0);
                
                float dSphere = sdSphere(pSphere, 1.0);
                float dBox = sdBox(pBox, float3(1.0, 1.0, 1.0));
                
                return min(dSphere, dBox);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * 2.0 - 1.0;
                uv.x *= _ScreenParams.x / _ScreenParams.y;
                
                // Extra practice: find a way to apply Unity's camera rotation to our ray direction!
                float3x3 cam = (float3x3)UNITY_MATRIX_V;
                float3 ro = _WorldSpaceCameraPos;
                float3 rd = normalize(float3(uv.x, uv.y, 1.0));
                rd = mul(cam, rd);
                
                float3 p = ro;   // position along ray
                float t = 0.0; // distance along ray
                
                float far = 5.0;
                
                for (int i = 0; i < 64; i++)
                {
                    float d = map(p); // 1) Compute safe distance
                    t += d;           // 2) Accumulate distance along ray
                    p = ro + rd * t;  // 3) Calculate position along ray
                    
                    if (d <= 0.01)
                    {
                        break;
                    }
                    
                    if (t >= far)
                    {
                        break;
                    }
                }
                
                float3 rgb = float3(1.0, 1.0, 1.0) * (t / far);
                fixed4 col = fixed4(rgb, 1.0);
                return col;
            }

            ENDCG
        }
    }
}
