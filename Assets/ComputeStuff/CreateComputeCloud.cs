using UnityEngine;
using System.Collections;

public class CreateComputeCloud : MonoBehaviour
{

    public GameObject computeCloudPrefab;

    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
 

        if (CC_INPUT.GetButtonDown(Wand.Left, WandButton.X) || Input.GetKeyDown(KeyCode.Space))
        {
            Instantiate(computeCloudPrefab, CC_CANOE.WandTransform(0).transform.position, Quaternion.identity);
        }


    }
}
