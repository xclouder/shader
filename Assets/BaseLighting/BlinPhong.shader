﻿Shader "BaseLighting/BlinPhong"
{
	Properties
	{
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
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

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				fixed3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
				fixed3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldNormal = normalize(mul(v.normal, (float3x3)_World2Object));
				o.worldPos = mul(_Object2World, v.vertex).xyz;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				fixed3 halfDir = normalize(worldLightDir + i.worldNormal);

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, worldLightDir));
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(i.worldNormal, halfDir)), _Gloss);


				i.color = ambient + diffuse + specular;

				return fixed4(i.color, 1.0);
			}
			ENDCG
		}
	}
}
