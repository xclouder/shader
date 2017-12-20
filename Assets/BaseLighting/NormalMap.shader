Shader "BaseLighting/NormalMap"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20

		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("NormalMap", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
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
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;

				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			float4 _Color;
			float4 _Diffuse;
			float4 _Specular;
			float _Gloss;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _BumpMap;
			float4 _BumpMap_ST;

			float _BumpScale;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				//mainTex uv & bumpTex uv
				o.uv.xy = v.vertex.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				//o.uv.xy = TRANSFORM_TEX(v.vertex, _MainTex);
				o.uv.zw = v.vertex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				//o.uv.zw = TRANSFORM_TEX(v.vertex, _BumpMap);

				//convert to tangent space
//				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
//				fixed3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

				//or just use the built-in macro
				TANGENT_SPACE_ROTATION;

				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal;

				//If the texture is not marked as "Normal map"
				tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				//Or mark the texture as "Normal map", and use the built-in function
//				tangentNormal = UnpackNormal(packedNormal);
//				tangentNormal.xy *= _BumpScale;
//				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				half3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(halfDir, tangentNormal)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}
	}
}
