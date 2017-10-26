using UnityEngine;
using System.Collections;


[ExecuteInEditMode]
public class Colorizer : MonoBehaviour
{
	public Color diffuseColor;
	

	void Update()
	{
		GetComponent<Renderer>().sharedMaterial.SetColor( "_Color", diffuseColor );
	}
}
