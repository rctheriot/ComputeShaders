Shader "Custom/CubeComputeShader"
{
	Properties
	{
		_Color("Point Color", Color) = (1, 1, 1, 1)
		_Size("Size", Range(0, 3)) = 0.05
	}

	SubShader
	{
		Pass
		{
			Tags{ "Queue" = "Geometry" "RenderType" = "Opaque" "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma target 5.0
			#pragma vertex vertexShader
			#pragma fragment fragmentShader
			#pragma geometry geometryShader

			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog

			#include "AutoLight.cginc"
			#include "UnityCG.cginc" 

			// **************************************************************
			// Data structures												*
			// **************************************************************
			struct GeometryInput
			{
				float4 pos	: POSITION;
				float4 color : COLOR;
			};

			struct FragmentInput
			{
				float4 pos	: SV_POSITION;
				float4 color : COLOR;
				float4 normal : NORMAL;

			};

			struct data
			{
				float3 pos;
			};

			// **************************************************************
			// Vars															*
			// **************************************************************
			StructuredBuffer<data> buf_Points;
			float _Size;
			float3 _worldPos;
			float4 _Color;
			float4 _LightColor0;
			float4 _ShadowCoord;

			// **************************************************************
			// Shader Programs												*
			// **************************************************************

			// Vertex Shader ------------------------------------------------
			GeometryInput vertexShader(uint id : SV_VertexID)
			{
				GeometryInput o;
				float4 position =  mul(_Object2World, float4(buf_Points[id].pos + _worldPos, 1.0f));
				o.pos = position;
				float d = distance(_worldPos, position);
				o.color = float4(.35 + (d / 25), .15 + (d / 80), 0.0 , 1.0);

				return o;
			}

			// Geometry Shader -----------------------------------------------------
			[maxvertexcount(36)]
			void geometryShader(point GeometryInput p[1], inout TriangleStream<FragmentInput> triStream)
			{
				float f = _Size; //half size

				const float4 vc[36] = { 
					float4(-f,  f,  f, 0.0f), float4(f,  f,  f, 0.0f), float4(f,  f, -f, 0.0f),    //Top                                 
					float4(f,  f, -f, 0.0f), float4(-f,  f, -f, 0.0f), float4(-f,  f,  f, 0.0f),    //Top

					float4(f,  f, -f, 0.0f), float4(f,  f,  f, 0.0f), float4(f, -f,  f, 0.0f),     //Right
					float4(f, -f,  f, 0.0f), float4(f, -f, -f, 0.0f), float4(f,  f, -f, 0.0f),     //Right

					float4(-f,  f, -f, 0.0f), float4(f,  f, -f, 0.0f), float4(f, -f, -f, 0.0f),     //Front
					float4(f, -f, -f, 0.0f), float4(-f, -f, -f, 0.0f), float4(-f,  f, -f, 0.0f),    //Front

					float4(-f, -f, -f, 0.0f), float4(f, -f, -f, 0.0f), float4(f, -f,  f, 0.0f),    //Bottom                                         
					float4(f, -f,  f, 0.0f), float4(-f, -f,  f, 0.0f), float4(-f, -f, -f, 0.0f),   //Bottom

					float4(-f,  f,  f, 0.0f), float4(-f,  f, -f, 0.0f), float4(-f, -f, -f, 0.0f),    //Left
					float4(-f, -f, -f, 0.0f), float4(-f, -f,  f, 0.0f), float4(-f,  f,  f, 0.0f),    //Left

					float4(-f,  f,  f, 0.0f), float4(-f, -f,  f, 0.0f), float4(f, -f,  f, 0.0f),    //Back
					float4(f, -f,  f, 0.0f), float4(f,  f,  f, 0.0f), float4(-f,  f,  f, 0.0f)     //Back
				};

				const int TRI_STRIP[36] = { 0, 1, 2,  3, 4, 5,
					6, 7, 8,  9,10,11,
					12,13,14, 15,16,17,
					18,19,20, 21,22,23,
					24,25,26, 27,28,29,
					30,31,32, 33,34,35
				};

				FragmentInput v[36];
				int i;

				// Position in view space
				for (i = 0; i < 36; i++) 
				{ 
					UNITY_INITIALIZE_OUTPUT(FragmentInput, v[i]);
					v[i].pos = mul(UNITY_MATRIX_MVP, p[0].pos + vc[i]);
					v[i].color = p[0].color; 
				}

				// Build the cube tile by submitting triangle strip vertices
				for (i = 0; i < 36 / 3; i++)
				{
					float4 v1 = p[0].pos + vc[i * 3 + 0];
					float4 v2 = p[0].pos + vc[i * 3 + 1];
					float4 v3 = p[0].pos + vc[i * 3 + 2];
					float normal = normalize(cross(v2.xyz - v1.xyz, v3.xyz - v1.xyz));

					v[TRI_STRIP[i * 3 + 0]].normal = normal;
					v[TRI_STRIP[i * 3 + 1]].normal = normal;
					v[TRI_STRIP[i * 3 + 2]].normal = normal;

					triStream.Append(v[TRI_STRIP[i * 3 + 0]]);
					triStream.Append(v[TRI_STRIP[i * 3 + 1]]);
					triStream.Append(v[TRI_STRIP[i * 3 + 2]]);

					triStream.RestartStrip();
				}

			}


			// Fragment Shader -----------------------------------------------
			float4 fragmentShader(FragmentInput input) : COLOR
			{
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 normal = input.normal;
				float lambert = float(max(-0.35, dot(normal, lightDirection)));
				float3 lighting = (ambient +  lambert ) * _LightColor0.rgb;

				float4 color = fixed4(input.color.xyz * lighting, 1.0f);

				return color;
			}

			ENDCG

		}

	}
	FallBack "Diffuse"
}
