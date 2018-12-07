using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class DialMove : MonoBehaviour {
    [SerializeField]
    Text text;
    [SerializeField]
    GameObject microwave;
    [SerializeField]
    GameObject player;
    [SerializeField]
    GameObject grid;
    private float distance;
    [SerializeField]
    private float maxDistance;
    [SerializeField]
    GameObject dial;
    [SerializeField]
    private float moveAmount;
    public float MoveAmount
    {
        set
        {
            moveAmount = value;
        }
        get
        {
            return moveAmount;
        }
    }
    private Vector3 panelSpaceMax;
    private Vector3 panelSpaceMin;
    private MeshRenderer panelMesh;

    [SerializeField]
    private GameObject topBounds;
    [SerializeField]
    private GameObject botBounds;
    
	// Use this for initialization
	void Start () {

       
        maxDistance = grid.GetComponent<GridGenerator>().Width;
	}
	
	// Update is called once per frame
	void Update () {
        ChangeDialPositon();
        MoveAmountCalculate();
       // text.text = moveAmount.ToString();
	}

    void MoveAmountCalculate()
    {
        distance = Vector3.Distance(player.transform.position, microwave.transform.position) / maxDistance;

        if(distance >= 1)
        {
            distance = 0.99f;
        }
        else if(distance <= 0)
        {
            distance = 0.01f;
        }

        moveAmount = distance;   
    }

    void ChangeDialPositon()
    {
        Vector3 newPos;
        newPos = dial.transform.position;
      
        newPos.y = Mathf.Lerp(topBounds.transform.position.y, botBounds.transform.position.y, moveAmount);
        dial.transform.position = newPos;
    }
}
