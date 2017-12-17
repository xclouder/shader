using UnityEngine;
using System.Collections;

public class Test : MonoBehaviour {

	// Use this for initialization
	void Start () {
		GameObject o = new GameObject("123");
		var tr = o.transform;

		GameObject.DestroyImmediate(o);

		var typ = tr.GetType();
		Debug.LogError("tr type:" + typ);


		if (tr == null)
		{
			Debug.LogError("tr is null");
		}

		tr.localPosition = new Vector3(1,1,1);

	}
	
	// Update is called once per frame
	void Update () {
	
	}

	[CUDLR.Command("test", "just a test", true)]
	public string MyTest()
	{
		return "hello";
	}
}
