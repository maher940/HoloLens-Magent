Shader "Unlit/PanelUnlit"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ColorTop("Top Color", Color) = (1,1,1,1)
		_ColorBottom("Bottom Color", Color) = (1, 1, 1, 1)
		_ColorMid("Mid Color", Color) = (1, 1, 1, 1)
		_LerpFactor("LerpFactor", Range(0.001,0.999)) = 1
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
			// make fog work
			
			
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _ColorTop;
			fixed4 _ColorBottom;
			fixed4 _ColorMid;
			float _LerpFactor;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				
				//fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 col = lerp(_ColorBottom, _ColorMid, i.uv.y / _LerpFactor) * step(i.uv.y, _LerpFactor);
				col += lerp(_ColorMid, _ColorTop, (i.uv.y - _ColorMid) / (1 - _LerpFactor)) * step(_LerpFactor, i.uv.y);
				col.a = 1;
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
