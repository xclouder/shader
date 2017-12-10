Shader "BaseLighting/DiffusePixelHalfLambert"
{
	Properties
	{
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				fixed3 normal : NORMAL;
			};

			struct v2f
			{
				fixed3 worldNormal : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			fixed4 _Diffuse;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldNormal = mul(v.normal, (fixed3x3)_World2Object);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 halfLambertDiffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(worldNormal, worldLight) * 0.5 + 0.5);

				fixed3 col = ambient + halfLambertDiffuse;

				return fixed4(col, 1);
			}
			ENDCG
		}
	}
}
