Shader "Hidden/FullscreenShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
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

            sampler2D _MainTex;
            
            float4 frag (v2f i) : SV_Target
            {
                float time = _Time.y;
                float ncos = cos(time) * 0.5 + 0.5;

                i.uv.x *= _ScreenParams.x / _ScreenParams.y;

                float4 col = float4(i.uv, ncos, 1.0);
                return col;
            }
            ENDCG
        }
    }
}
