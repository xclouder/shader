Shader "Unlit/ShadowReceive"
{
	Properties
	{
		_ShadowTex ("Shadow Texture", 2D) = "gray" {}
		_FalloffTex ("Falloff Texture", 2D) = "white" {}
		_Intensity ("Intensity", Range(0,1)) = 0.5
	}
	
	SubShader
	{
		Tags { "Queue" = "AlphaTest+1" }
		
		Pass
		{
		    ZWrite Off
		    ColorMask RGB
		    Blend DstColor Zero		//正片叠底
		    Offset -1, -1
		    
		    CGPROGRAM
		    #pragma vertex vert
		    #pragma fragment frag
		    #pragma multi_compile_fog
		    
		    #include "UnityCG.cginc"
		    
		    struct v2f
		    {
		        float4 pos:POSITION;
		        float4 sproj:TEXCOORD0;
		        UNITY_FOG_COORDS(1)
		    };
		    
		    float4x4 unity_Projector;
		    sampler2D _ShadowTex;
		    sampler2D _FalloffTex;
		    float _Intensity;
		    
		    v2f vert(float4 vertex:POSITION)
		    {
		        v2f o;
		        o.pos = UnityObjectToClipPos(vertex);
		        o.sproj = mul(unity_Projector, vertex);
		        UNITY_TRANSFER_FOG(o,o.pos);
				return o;
		    }
		    
		    float4 frag(v2f i):SV_TARGET
		    {
		    	//tex2Dproj 将定点进行一系列的坐标转换：模型坐标 > 世界坐标 > 相机视点坐标 > 裁剪坐标 > 归一化到屏幕坐标
		    	//tex2DProj 函数与 tex2D 函数的区别就在于：前者会对齐次纹理坐标除以最后一个分量 w ，然后再进行纹理检索
		    	//这里使用tex2Dproj原因是：纹理是Camera的TargetTexture，基于屏幕空间，所以采样的时候也必须按当前定点的屏幕空间来
		        half4 shadowCol = tex2Dproj(_ShadowTex, UNITY_PROJ_COORD(i.sproj));		//UNITY_PROJ_COORD 处理平台差异，一般返回原值
		        half maskCol = tex2Dproj(_FalloffTex, UNITY_PROJ_COORD(i.sproj)).r;		

		        half a = shadowCol.r * maskCol;
		        float c = 1.0 - _Intensity * a;
		        
		        UNITY_APPLY_FOG_COLOR(i.fogCoord, c, fixed4(1,1,1,1));

				return c;
		    }
		    
		    ENDCG
		}
	}
	
	FallBack Off
}
