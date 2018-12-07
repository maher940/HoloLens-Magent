using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ReactToDistance : MonoBehaviour
{

    [SerializeField]
    GameObject magnet;
    [SerializeField]
    private float shakeDistance;
    [SerializeField]
    private float distanceFactor;
    [SerializeField]
    private float shakeSpeed;
    [SerializeField]
    private float speedFactor;
    [SerializeField]
    private float cutoffDistance;

    private float distance;
    private float distanceFromOgPos;
    private Vector3 ogPos;
    [SerializeField]
    private float speed;
    private Vector3 direction;
    private Vector3 positiveMovePos;
    private Vector3 negativeMovePos;
    [SerializeField]
    private float distanceToChange;
    [SerializeField]
    private bool positive;
    [SerializeField]
    private GridGenerator gridGenerator;
    [SerializeField]
    private float playerFactor;
    Renderer rend;

 
    public Vector3 MagnetPosition
    {
        get { return magnet.transform.position; }
    }

    public float DistanceFactor
    {
        get { return distanceFactor; }
    }

    // Use this for initialization
    void Start()
    {
        rend = GetComponent<Renderer>();
        speed = 1;
        positive = true;
        ogPos = transform.position;
    }

    // Update is called once per frame
    void Update()
    {

    }

    void ChangeColor()
    {
        distance = Vector3.Distance(transform.position, magnet.transform.position) / 25;

        if (distance > 1)
        {
            distance = 1;
        }

        rend.sharedMaterial.SetFloat("_LerpFactor", distance);
    }

    public GridGenerator.Vertex ChangePosition(GridGenerator.Vertex vertex)
    {

        //Vector3 p = Vector3.zero;
        float distance = Vector3.Distance(vertex.globalPosition, transform.position);

        if (distance >= cutoffDistance)
        {
            return vertex;
        }

         float playerSpeed = (speedFactor / Vector3.Distance(transform.position, vertex.globalPosition)) * playerFactor;
         float speed = (speedFactor / Vector3.Distance(transform.position, MagnetPosition)) * shakeSpeed;

        
        speed = speed * playerSpeed;

       

        if (vertex.velocity == Vector3.zero)
        {
            vertex.velocity = (transform.position - vertex.globalPosition).normalized;
        }

        if (Vector3.Distance(vertex.globalPosition, vertex.originalPosition) > distanceToChange)
        {
            vertex.velocity = -vertex.velocity;
            vertex.globalPosition += vertex.velocity * (speed * 2) * Time.deltaTime;
        }
        else
        {
            vertex.globalPosition += vertex.velocity * speed * Time.deltaTime;
        }

        return vertex;
    }


}
