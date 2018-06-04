using UnityEngine;
using System.Collections;

public class MusicShader : MonoBehaviour {

public enum MusicMaterialType{
	musicV4,
	musicV5
}
	public Material material;
	public MusicMaterialType musicMaterialsType;
	[Range(0.0005f,0.5f)]
	public float delay = 0.0166f;
	public float multiplyer = 1.0f;
	[HideInInspector]
	[System.NonSerialized]
	public float[] spactrumDataDelay;
    [HideInInspector]
    [System.NonSerialized]
    public Texture2D dataTexture;
    public FilterMode filterMode;


	
	int numSamples = 256;

	void Start(){
		for(int j =0;j<1;j++){
            dataTexture = new Texture2D(numSamples, 1, TextureFormat.RGBA32, false);
            dataTexture.filterMode = filterMode;
            material.SetTexture("_MusicData", dataTexture);

			spactrumDataDelay = new float[numSamples];
		}
	}

	void Update() {
        float[] spectrum = new float[numSamples];
        GetComponent<AudioSource>().GetSpectrumData(spectrum, 0, FFTWindow.BlackmanHarris);
		
		for(int j =0;j<1;j++){
			int i = 1;
			while (i < numSamples+1) {
				float newData =  (spectrum[i - 1]*1.0f*multiplyer);


				// apply delay 
				if(newData>spactrumDataDelay[i-1]){
					spactrumDataDelay[i-1] += (delay*Time.deltaTime);
					if(spactrumDataDelay[i-1] > newData){
						spactrumDataDelay[i-1] = newData;
					}
				}else{
					spactrumDataDelay[i-1] -= (delay*Time.deltaTime);
					if(spactrumDataDelay[i-1] <0f){
						spactrumDataDelay[i-1] = 0f;
					}
				}
				
				// set texture pixes
                if (musicMaterialsType == MusicMaterialType.musicV4) {
                    dataTexture.SetPixel(i - 1, 1, new Color((spactrumDataDelay[i - 1] * 255.0f), 0, 0, 0));
				}else{
                    ShaderUtil.WriteFloatToTexturePixel(spactrumDataDelay[i - 1], ref dataTexture, i - 1, 1);
				}
				i++;
			}
            // update texture pixels
			dataTexture.Apply();
		}
	}
}