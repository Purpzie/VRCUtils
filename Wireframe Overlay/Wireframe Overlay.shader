Shader "Purpzie/Wireframe Overlay" {
	Properties {
		_WireframeColor ("Wireframe Color", Color) = (1, 1, 1, 1)
		_BackgroundColor ("Background Color", Color) = (0, 0, 0, 1)

		[Header(Rendering)] [Space]
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull", Int) = 0

		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Blend Op", Int) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Blend Src", Int) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Blend Dst", Int) = 0

		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOpAlpha ("Alpha Op", Int) = 0
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha ("Alpha Src", Int) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha ("Alpha Dst", Int) = 0

		[Header(Stencil)] [Space]
		[IntRange] _StencilRef ("Reference", Range(0, 255)) = 0
		[IntRange] _StencilReadMask ("Read Mask", Range(0, 255)) = 255
		[IntRange] _StencilWriteMask ("Write Mask", Range(0, 255)) = 255
		[Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Comparison", Int) = 8
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOp ("Pass", Int) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilFailOp ("Fail", Int) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOp ("ZFail", Int) = 0
	}

	SubShader {
		Tags {
			"RenderType" = "Transparent"
			"Queue" = "Overlay"
			"IgnoreProjector" = "True"
			"VRCFallback" = "Hidden"
		}

		ZWrite Off
		Cull [_CullMode]

		BlendOp [_BlendOp], [_BlendOpAlpha]
		Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]

		Stencil {
			Ref [_StencilRef]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
			Comp [_StencilComp]
			Pass [_StencilPassOp]
			Fail [_StencilFailOp]
			ZFail [_StencilZFailOp]
		}

		Pass {
			CGPROGRAM
				#pragma target 5.0
				#pragma multi_compile_instancing
				#pragma multi_compile _ SOFTPARTICLES_ON // is depth available?
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				uniform float4 _WireframeColor;
				uniform float4 _BackgroundColor;

				UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

				struct appdata {
					float4 vertex: POSITION;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f {
					float4 pos: SV_POSITION;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				v2f vert(appdata v) {
					UNITY_SETUP_INSTANCE_ID(v);
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f, o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					o.pos = UnityObjectToClipPos(v.vertex);
					return o;
				}

				// thank you d4rkplayer! https://gist.github.com/d4rkc0d3r/886be3b6c233349ea6f8b4a7fcdacab3
				float4x4 CreateClipToViewMatrix() {
					float4x4 flipZ = float4x4(
						1, 0, 0, 0,
						0, 1, 0, 0,
						0, 0, -1, 1,
						0, 0, 0, 1
					);
					float4x4 scaleZ = float4x4(
						1, 0, 0, 0,
						0, 1, 0, 0,
						0, 0, 2, -1,
						0, 0, 0, 1
					);
					float4x4 flipY = float4x4(
						1, 0, 0, 0,
						0, _ProjectionParams.x, 0, 0,
						0, 0, 1, 0,
						0, 0, 0, 1
					);

					float4x4 result = mul(scaleZ, flipZ);
					result = mul(unity_CameraInvProjection, result);
					result = mul(flipY, result);
					result._24 *= _ProjectionParams.x;
					result._42 *= -1;
					return result;
				}

				float3 GetViewSpacePos(float4 svPosition, float4x4 UNITY_MATRIX_I_P) {
					// sv position -> clip position (also from d4rkplayer's gist)
					float4 clipPos = float4(((svPosition.xy / _ScreenParams.xy) * 2 - 1) * int2(1, -1), svPosition.z, 1);
					#ifdef UNITY_SINGLE_PASS_STEREO
						clipPos.x -= 2 * unity_StereoEyeIndex;
					#endif

					float4 uv = ComputeScreenPos(clipPos);
					float depth = SAMPLE_DEPTH_TEXTURE_LOD(_CameraDepthTexture, float4(uv.xy / uv.w, 0, 0));
					float4 viewPos = mul(UNITY_MATRIX_I_P, float4(clipPos.xy / clipPos.w, depth, 1));
					return viewPos.xyz / viewPos.w;
				}

				float4 frag(v2f i): SV_TARGET {
					UNITY_SETUP_INSTANCE_ID(i);
					#ifdef SOFTPARTICLES_ON
						float4x4 UNITY_MATRIX_I_P = CreateClipToViewMatrix();

						/*
							adapted from https://github.com/lereldarion/unity-shaders/blob/198034c3fb29f22d77b6d1159ffc3172f98d9b87/Shaders/Overlay_Wireframe.shader#L101-L115
							which has the following license:

							MIT License

							Copyright (c) 2025 Lereldarion

							Permission is hereby granted, free of charge, to any person obtaining a copy
							of this software and associated documentation files (the "Software"), to deal
							in the Software without restriction, including without limitation the rights
							to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
							copies of the Software, and to permit persons to whom the Software is
							furnished to do so, subject to the following conditions:

							The above copyright notice and this permission notice shall be included in all
							copies or substantial portions of the Software.

							THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
							IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
							FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
							AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
							LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
							OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
							SOFTWARE.
						*/

						float3 viewPos = GetViewSpacePos(i.pos, UNITY_MATRIX_I_P);
						float3 left = GetViewSpacePos(i.pos + float4(-1, 0, 0, 0), UNITY_MATRIX_I_P);
						float3 down = GetViewSpacePos(i.pos + float4(0, 1, 0, 0), UNITY_MATRIX_I_P);
						float3 right = GetViewSpacePos(i.pos + float4(1, 0, 0, 0), UNITY_MATRIX_I_P);
						float3 up = GetViewSpacePos(i.pos + float4(0, -1, 0, 0), UNITY_MATRIX_I_P);

						left -= viewPos;
						down -= viewPos;
						right -= viewPos;
						up -= viewPos;

						float3 normDownLeft = normalize(cross(down, left));
						float3 normUpRight = normalize(cross(up, right));
						float3 normRightDown = normalize(cross(right, down));

						float normDiff = saturate(
							dot(float3(1, 1, 1), abs(normUpRight - normDownLeft))
							+ dot(float3(1, 1, 1), abs(normRightDown - normDownLeft))
						);

						return lerp(_BackgroundColor, _WireframeColor, normDiff);
					#else
						// no depth :(
						return _BackgroundColor;
					#endif
				}
			ENDCG
		}
	}
}
