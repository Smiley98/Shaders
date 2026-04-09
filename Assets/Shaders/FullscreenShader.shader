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



            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y;
                float ncos = cos(t) * 0.5 + 0.5;

                fixed4 col = fixed4(i.uv, ncos, 1.0);
                return col;
            }
            ENDCG
        }
    }
}
