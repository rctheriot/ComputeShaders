Shader "Custom/nBodyCubeShader"
{
	Properties
	{
		_MainTex("TileTexture", 2D) = "white" {}
		_Color("Point Color", Color) = (1, 1, 1, 1)
		_Size("Size", Range(0, 3)) = 0.15
	}

		SubShader
	{
		Pass
	{
		Tags{ "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
		LOD 200

		CGPROGRAM
	#pragma target 5.0
	#pragma vertex VS_Main
	#pragma fragment FS_Main
	#pragma geometry GS_Main
	#include "UnityCG.cginc" 

		// **************************************************************
		// Data structures												*
		// **************************************************************
		struct GS_INPUT
	{
		float4	pos	: POSITION;
		float4 color : COLOR;
		float4 pos2 : POSITION1;
	};

	struct FS_INPUT
	{
		float4	pos		: POSITION;
		float2 uv_MainTex : TEXCOORD0;
		float4 color : COLOR;
	};

	struct data
	{
		float3 pos;
	};



	// **************************************************************
	// Vars															*
	// **************************************************************

	float _Size;
	float4x4 _VP;
	Texture2D _SpriteTex;
	SamplerState sampler_SpriteTex;
	StructuredBuffer<data> buf_Points;
	StructuredBuffer<data> buf_Mass;
	float4       _MainTex_ST;
	sampler2D _MainTex;
	float3 _centerPos;
	float4 _Color;

	// **************************************************************
	// Shader Programs												*
	// **************************************************************

	// Vertex Shader ------------------------------------------------
	GS_INPUT VS_Main(uint id : SV_VertexID)
	{

		GS_INPUT o;
		float4 position = mul(_Object2World, float4(buf_Points[id].pos, 1.0f));
		o.pos = position;
		o.pos2 = float4(buf_Mass[id].pos, 0);
		float d = distance(_centerPos, position);
		o.color = float4(.35 + (55 / d), .15 + (20 / d), (1 / d), 1.0);
		return o;

	}

	// Geometry Shader -----------------------------------------------------
	[maxvertexcount(36)]
	void GS_Main(point GS_INPUT p[1], inout TriangleStream<FS_INPUT> triStream)
	{
		float f = p[0].pos2.x * .00005;

		const float4 vc[36] = { float4(-f,  f,  f, 0.0f), float4(f,  f,  f, 0.0f), float4(f,  f, -f, 0.0f),    //Top                                 
			float4(f,  f, -f, 0.0f), float4(-f,  f, -f, 0.0f), float4(-f,  f,  f, 0.0f),    //Top

			float4(f,  f, -f, 0.0f), float4(f,  f,  f, 0.0f), float4(f, -f,  f, 0.0f),     //Right
			float4(f, -f,  f, 0.0f), float4(f, -f, -f, 0.0f), float4(f,  f, -f, 0.0f),     //Right

			float4(-f,  f, -f, 0.0f), float4(f,  f, -f, 0.0f), float4(f, -f, -f, 0.0f),     //Front
			float4(f, -f, -f, 0.0f), float4(-f, -f, -f, 0.0f), float4(-f,  f, -f, 0.0f),     //Front

			float4(-f, -f, -f, 0.0f), float4(f, -f, -f, 0.0f), float4(f, -f,  f, 0.0f),    //Bottom                                         
			float4(f, -f,  f, 0.0f), float4(-f, -f,  f, 0.0f), float4(-f, -f, -f, 0.0f),     //Bottom

			float4(-f,  f,  f, 0.0f), float4(-f,  f, -f, 0.0f), float4(-f, -f, -f, 0.0f),    //Left
			float4(-f, -f, -f, 0.0f), float4(-f, -f,  f, 0.0f), float4(-f,  f,  f, 0.0f),    //Left

			float4(-f,  f,  f, 0.0f), float4(-f, -f,  f, 0.0f), float4(f, -f,  f, 0.0f),    //Back
			float4(f, -f,  f, 0.0f), float4(f,  f,  f, 0.0f), float4(-f,  f,  f, 0.0f)     //Back
		};


		const float2 UV1[36] = { float2(0.0f,    0.0f), float2(1.0f,    0.0f), float2(1.0f,    0.0f),         //Esta em uma ordem
			float2(1.0f,    0.0f), float2(1.0f,    0.0f), float2(1.0f,    0.0f),         //aleatoria qualquer.

			float2(0.0f,    0.0f), float2(1.0f,    0.0f), float2(1.0f,    0.0f),
			float2(1.0f,    0.0f), float2(1.0f,    0.0f), float2(1.0f,    0.0f),

			float2(0.0f,    0.0f), float2(1.0f,    0.0f), float2(1.0f,    0.0f),
			float2(1.0f,    0.0f), float2(1.0f,    0.0f), float2(1.0f,    0.0f),

			float2(0.0f,    0.0f), float2(1.0f,    0.0f), float2(1.0f,    0.0f),
			float2(1.0f,    0.0f), float2(1.0f,    0.0f), float2(1.0f,    0.0f),

			float2(0.0f,    0.0f), float2(1.0f,    0.0f), float2(1.0f,    0.0f),
			float2(1.0f,    0.0f), float2(1.0f,    0.0f), float2(1.0f,    0.0f),

			float2(0.0f,    0.0f), float2(1.0f,    0.0f), float2(1.0f,    0.0f),
			float2(1.0f,    0.0f), float2(1.0f,    0.0f), float2(1.0f,    0.0f)
		};

		const int TRI_STRIP[36] = { 0, 1, 2,  3, 4, 5,
			6, 7, 8,  9,10,11,
			12,13,14, 15,16,17,
			18,19,20, 21,22,23,
			24,25,26, 27,28,29,
			30,31,32, 33,34,35
		};

		FS_INPUT v[36];
		int i;

		// Assign new vertices positions 
		for (i = 0; i<36; i++) { v[i].pos = p[0].pos + vc[i]; }

		// Assign UV values
		for (i = 0; i<36; i++) v[i].uv_MainTex = TRANSFORM_TEX(UV1[i], _MainTex);

		// Position in view space
		for (i = 0; i < 36; i++) { v[i].pos = mul(UNITY_MATRIX_MVP, v[i].pos); v[i].color = p[0].color; }

		// Build the cube tile by submitting triangle strip vertices
		for (i = 0; i<36 / 3; i++)
		{
			triStream.Append(v[TRI_STRIP[i * 3 + 0]]);
			triStream.Append(v[TRI_STRIP[i * 3 + 1]]);
			triStream.Append(v[TRI_STRIP[i * 3 + 2]]);
			triStream.RestartStrip();
		}
	}



	// Fragment Shader -----------------------------------------------
	float4 FS_Main(FS_INPUT input) : COLOR
	{
		float4 col = input.color;

		return col;
	}

		ENDCG
	}

	}
}
