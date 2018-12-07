Shader "Unlit/Grid"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_HighColor("HighColor", Color) = (1,1,1,1)
		_LowColor("LowColor", Color) = (1,1,1,1)
	}
		SubShader
	{
		Tags { "RenderType" = "Transparent" }
		LOD 100

		Blend SrcAlpha OneMinusSrcAlpha

		CGINCLUDE
		#pragma vertex vert
		#pragma fragment frag
		#pragma geometry geom

		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
			float4 tangent : TANGENT;
			float4 color : COLOR;
			float3 normal : NORMAL;
		};

		struct v2g
		{
			float4 position : SV_POSITION;
			float2 uv : TEXCOORD0;
			float4 tangent : TANGENT;
			float3 normal : COLOR;
			float3 forwardVector : TEXCOORD1;
		};

		struct g2f
		{
			float4 position : SV_POSITION;
			fixed4 color : COLOR;
		};

	
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float Spacing;
		float OrbSize;
		float LineThickness;
		fixed4 OrbColor;
		fixed4 LineColor;
		fixed4 _LowColor;
		fixed4 _HighColor;
		half _LerpFactor;

		v2g vert(appdata v)
		{
			v2g o;
			o.position = v.vertex;
			o.uv = v.uv;
			o.tangent = v.tangent;
			o.normal = v.color;
			o.forwardVector = v.normal;
			return o;
		}

		fixed4 frag(g2f i) : SV_Target
		{
			// sample the texture
			//fixed4 col = tex2D(_MainTex, i.uv);
			fixed4 col = i.color;
			return col;
		}
		ENDCG

		Pass
		{
			CGPROGRAM

			//Orb geometry shader
			[maxvertexcount(128)]
			void geom(point v2g input[1], inout TriangleStream<g2f> triangleStream)
			{
				g2f output;
				float4 pos = input[0].position;

				float4 verts[8] =
				{
					float4(0.0, 0.0, 0.0, 0.0),
					float4(OrbSize, 0.0, 0.0, 0.0),
					float4(0.0, -OrbSize, 0.0, 0.0),
					float4(OrbSize, -OrbSize, 0.0, 0.0),
					float4(0.0, 0.0, OrbSize, 0.0),
					float4(OrbSize, 0.0, OrbSize, 0.0),
					float4(0.0, -OrbSize, OrbSize, 0.0),
					float4(OrbSize, -OrbSize, OrbSize, 0.0)
				};

				int tris[36] =
				{
					//Front
					0, 1, 2,
					2, 1, 3,
					//Back
					5, 4, 6,
					6, 7, 5,
					//Right
					1, 5, 7,
					7, 3, 1, 
					//Left
					4, 0, 6, 
					6, 0, 2,
					//Bottom
					7, 6, 2,
					2, 3, 7,
					//Top
					4, 5, 0, 
					0, 5, 1
				};

				int count = 0;
				for (uint i = 0; i < 36; i++)
				{
					count++;
					output.position = UnityObjectToClipPos(pos + verts[tris[i]]);
					output.color = lerp(_LowColor, _HighColor, input[0].uv.x);
					triangleStream.Append(output);

					if (count >=3)
					{
						triangleStream.RestartStrip();
						count = 0;
					}
				}
			}

			ENDCG
		}

			Pass
		{
			CGPROGRAM
			
			//Grid lines geometry shader
			[maxvertexcount(128)]
			void geom(point v2g input[1], inout TriangleStream<g2f> triangleStream)
			{
				g2f output;
				float4 pos = input[0].position;

				float3 tan = input[0].tangent - input[0].position;
				float3 norm = input[0].normal - input[0].position;
				float3 forwardVector = input[0].forwardVector - input[0].position;

				float3 vRightCenter = float3(OrbSize, -OrbSize * 0.5, OrbSize * 0.5);
				float3 vForwardCenter = float3(OrbSize * 0.5, -OrbSize * 0.5, OrbSize);
				float3 vDownCenter = float3(OrbSize * 0.5, -OrbSize, OrbSize * 0.5);

				float halfThickness = LineThickness * 0.5;

				float4 downLine[8] =
				{
					float4(vDownCenter.x - halfThickness, -OrbSize, vDownCenter.z - halfThickness, 0.0),
					float4(vDownCenter.x + halfThickness, -OrbSize, vDownCenter.z - halfThickness, 0.0),
					float4(vDownCenter.x - halfThickness + tan.x, tan.y, vDownCenter.z - halfThickness + tan.z, 0.0),
					float4(vDownCenter.x + halfThickness + tan.x, tan.y, vDownCenter.z - halfThickness + tan.z, 0.0),
					float4(vDownCenter.x - halfThickness, -OrbSize, vDownCenter.z + halfThickness, 0.0),
					float4(vDownCenter.x + halfThickness, -OrbSize, vDownCenter.z + halfThickness, 0.0),
					float4(vDownCenter.x - halfThickness + tan.x, tan.y, vDownCenter.z + halfThickness + tan.z, 0.0),
					float4(vDownCenter.x + halfThickness + tan.x, tan.y, vDownCenter.z + halfThickness + tan.z, 0.0)
				};

				float4 rightLine[8] =
				{
					float4(OrbSize, vRightCenter.y + halfThickness , vRightCenter.z - halfThickness, 0.0),
					float4(norm.x, vRightCenter.y + halfThickness + norm.y, vRightCenter.z - halfThickness + norm.z, 0.0),
					float4(OrbSize, vRightCenter.y - halfThickness, vRightCenter.z - halfThickness, 0.0),
					float4(norm.x, vRightCenter.y - halfThickness + norm.y, vRightCenter.z - halfThickness + norm.z, 0.0),
					float4(OrbSize, vRightCenter.y + halfThickness, vRightCenter.z + halfThickness, 0.0),
					float4(norm.x, vRightCenter.y + halfThickness + norm.y, vRightCenter.z + halfThickness + norm.z, 0.0),
					float4(OrbSize, vRightCenter.y - halfThickness, vRightCenter.z + halfThickness, 0.0),
					float4(norm.x, vRightCenter.y - halfThickness + norm.y, vRightCenter.z - halfThickness + norm.z, 0.0)
				};

				float4 forwardLine[8] =
				{
					float4(vForwardCenter.x - halfThickness, vForwardCenter.y + halfThickness, OrbSize, 0.0),
					float4(vForwardCenter.x + halfThickness, vForwardCenter.y + halfThickness, OrbSize, 0.0),
					float4(vForwardCenter.x - halfThickness, vForwardCenter.y - halfThickness, OrbSize, 0.0),
					float4(vForwardCenter.x + halfThickness, vForwardCenter.y - halfThickness, OrbSize, 0.0),
					float4(vForwardCenter.x - halfThickness + forwardVector.x, vForwardCenter.y + halfThickness + forwardVector.y, forwardVector.z, 0.0),
					float4(vForwardCenter.x + halfThickness + forwardVector.x, vForwardCenter.y + halfThickness + forwardVector.y, forwardVector.z, 0.0),
					float4(vForwardCenter.x - halfThickness + forwardVector.x, vForwardCenter.y - halfThickness + forwardVector.y, forwardVector.z, 0.0),
					float4(vForwardCenter.x + halfThickness + forwardVector.x, vForwardCenter.y - halfThickness + forwardVector.y, forwardVector.z, 0.0)
				};

				int tris[36] =
				{
					//Front
					0, 1, 2,
					2, 1, 3,
					//Back
					5, 4, 6,
					6, 7, 5,
					//Right
					1, 5, 7,
					7, 3, 1, 
					//Left
					4, 0, 6, 
					6, 0, 2,
					//Bottom
					7, 6, 2,
					2, 3, 7,
					//Top
					4, 5, 0, 
					0, 5, 1
				};

				uint count = 0;
				for (uint j = 0; j < 36; j++)
				{
					count++;
					output.position = UnityObjectToClipPos(pos + downLine[tris[j]]);
					output.color = LineColor;
					triangleStream.Append(output);

					if (count >= 3)
					{
						triangleStream.RestartStrip();
						count = 0;
					}
				}

				count = 0;
				for (uint k = 0; k < 36; k++)
				{
					count++;
					output.position = UnityObjectToClipPos(pos + rightLine[tris[k]]);
					output.color = LineColor;
					triangleStream.Append(output);

					if (count >= 3)
					{
						triangleStream.RestartStrip();
						count = 0;
					}
				}

				count = 0;
				for (uint l = 0; l < 36; l++)
				{
					count++;
					output.position = UnityObjectToClipPos(pos + forwardLine[tris[l]]);
					output.color = LineColor;
					triangleStream.Append(output);

					if (count >= 3)
					{
						triangleStream.RestartStrip();
						count = 0;
					}
				}
			}

			ENDCG
		}
	}
}
