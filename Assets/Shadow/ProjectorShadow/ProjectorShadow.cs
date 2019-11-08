using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectorShadow : MonoBehaviour
{
	public Vector2 renderTextureSize = new Vector2(2048, 2048);
	public float projectorSize = 8f;
	public LayerMask layerIgnoreReceiver;
	
	private RenderTexture m_shadowRT;

	private Projector m_projector;
	private Camera m_shadowCamera;
	
	public LayerMask layerCaster;

	public Shader replaceShader;
	
	private void Start()
	{
		m_shadowRT = new RenderTexture(Mathf.RoundToInt(renderTextureSize.x), Mathf.RoundToInt(renderTextureSize.y), 0, RenderTextureFormat.R8);
		m_shadowRT.name = "ShadowRT";

		m_shadowRT.antiAliasing = 1;
		m_shadowRT.filterMode = FilterMode.Bilinear;
		m_shadowRT.wrapMode = TextureWrapMode.Clamp;

		m_projector = GetComponent<Projector>();
		m_projector.orthographic = true;
		m_projector.orthographicSize = projectorSize;
		m_projector.ignoreLayers = layerIgnoreReceiver;
		m_projector.material.SetTexture("_ShadowTex", m_shadowRT);
		
		m_shadowCamera = gameObject.AddComponent<Camera>();
		m_shadowCamera.clearFlags = CameraClearFlags.Color;
		m_shadowCamera.backgroundColor = Color.black;
		m_shadowCamera.orthographic = true;
		m_shadowCamera.orthographicSize = projectorSize;
		m_shadowCamera.depth = -100.0f;
		m_shadowCamera.nearClipPlane = m_projector.nearClipPlane;
		m_shadowCamera.farClipPlane = m_projector.farClipPlane;
		m_shadowCamera.targetTexture = m_shadowRT;
		
		m_shadowCamera.cullingMask = layerCaster;
		m_shadowCamera.SetReplacementShader(replaceShader, "RenderType");
	}
	
	
}
