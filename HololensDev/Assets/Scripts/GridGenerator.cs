using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GridGenerator : MonoBehaviour
{
    [SerializeField]
    private int width;
    public int Width
    {
        get
        {
            return width;
        }
    }

    [SerializeField]
    private int height;
    [SerializeField]
    private int depth;
    [SerializeField]
    private float spacing;
    [SerializeField]
    private float orbSize;
    [SerializeField]
    private float lineThickness;
    [SerializeField]
    private Color orbColor;
    [SerializeField]
    private Color lineColor;

    private bool originalPointsSet;
    private Vertex[] vertices;
    private Vector3[] points;
    private Vector2[] lerpFactors;

    private Color[] rightVectors;
    private Vector4[] downVectors;
    private Vector3[] forwardVectors;

    private Vector3[] normals;
    private int[] indices;
    private Mesh mesh;
    private MeshRenderer meshRenderer;
    [SerializeField]
    private ReactToDistance react;

    public struct Vertex
    {
        public Vector3 globalPosition;
        public Vector3 localPosition;
        public Vector3 velocity;
        public Vector3 originalPosition;
    }

    private int XCount
    {
        get { return Mathf.CeilToInt(width / spacing); }
    }

    private int YCount
    {
        get { return Mathf.CeilToInt(height / spacing); }
    }

    private int ZCount
    {
        get { return Mathf.CeilToInt(depth / spacing); }
    }

    // Use this for initialization
    void Start()
    {
        originalPointsSet = false;
        GetComponent<MeshFilter>().sharedMesh = new Mesh();
        meshRenderer = GetComponent<MeshRenderer>();
        ValidateValues();
        InitializeGrid();
        UpdateGrid();
       
    }

    void Update()
    {
        UpdateGrid();
    }

    void OnValidate()
    {
        ValidateValues();
    }

    public void SetOriginalPoints()
    {
        if (!originalPointsSet)
        {
            originalPointsSet = true;

            for (int i = 0; i < vertices.Length; i++)
            {
                vertices[i].originalPosition = vertices[i].globalPosition;
            }
        }
    }

    void ValidateValues()
    {
        width = width <= 1 ? 2 : width;
        height = height <= 1 ? 2 : height;
        depth = depth <= 1 ? 2 : depth;

        int min = Mathf.Min(width, height, depth);

        spacing = Mathf.Clamp(spacing, 0.1f, min - 1);
    }

    void InitializeGrid()
    {
        int size = XCount * YCount * ZCount;

        if (size >= 65000)
        {
            Debug.Log("Vertex count limit exceeded");
            while (size > 65000)
            {
                width--;
                height--;
                depth--;

                size = XCount * YCount * ZCount;
            }
        }

        vertices = new Vertex[size];
        points = new Vector3[vertices.Length];
        indices = new int[vertices.Length];
        lerpFactors = new Vector2[vertices.Length];
        normals = new Vector3[vertices.Length];
        rightVectors = new Color[vertices.Length];
        downVectors = new Vector4[vertices.Length];
        forwardVectors = new Vector3[vertices.Length];
    }

    void UpdateGrid()
    {
        mesh = GetComponent<MeshFilter>().sharedMesh;

        if (meshRenderer == null)
        {
            meshRenderer = GetComponent<MeshRenderer>();
        }

        for (int z = 0; z < ZCount; z++)
        {
            for (int y = 0; y < YCount; y++)
            {
                for (int x = 0; x < XCount; x++)
                {
                    
                    Vector3 pos = new Vector3(x * spacing, y * spacing, z * spacing);
                    int index = (z * XCount * YCount) + (y * XCount) + x;
                    vertices[index] = react.ChangePosition(vertices[index]);
                    vertices[index].localPosition = originalPointsSet ? transform.InverseTransformPoint(vertices[index].globalPosition) : pos;
                    if (!originalPointsSet)
                    {
                        vertices[index].velocity = Vector3.zero;
                        vertices[index].globalPosition = transform.position + vertices[index].localPosition;
                    }
                    
                    indices[index] = index;
                    rightVectors[index] = x == XCount - 1 ? new Color(vertices[index].localPosition.x, vertices[index].localPosition.y, vertices[index].localPosition.z, 0) : new Color(vertices[index + 1].localPosition.x, vertices[index + 1].localPosition.y, vertices[index + 1].localPosition.z);
                    downVectors[index] = y == 0 ? (Vector4)vertices[index].localPosition : (Vector4) vertices[index - (XCount)].localPosition;
                    forwardVectors[index] = z == ZCount - 1 ? vertices[index].localPosition : vertices[index + (XCount * YCount)].localPosition;
                    float distance = Vector3.Distance(transform.position + vertices[index].localPosition, react.transform.position) / react.DistanceFactor;
                    float distance2 = Vector3.Distance(react.transform.position, react.MagnetPosition) / react.DistanceFactor;
                    points[index] = vertices[index].localPosition;
                    //normals[index] = originalPointsSet ? (originalPoints[index] - points[index]) : Vector3.zero;

                    float d = distance * (distance2 * 0.5f);

                    if (Vector3.Distance(react.transform.position, transform.position + vertices[index].localPosition) >= 3.0f)
                    {
                        d *= 0.5f;
                    }

                    lerpFactors[index] = new Vector2(d, 0);
                }
            }
        }

        SetOriginalPoints();

        mesh.vertices = points;
        mesh.uv = lerpFactors;
        mesh.tangents = downVectors;
        mesh.colors = rightVectors;
        mesh.normals = forwardVectors;
        mesh.SetIndices(indices, MeshTopology.Points, 0);
        meshRenderer.sharedMaterial.SetFloat("Spacing", spacing);
        meshRenderer.sharedMaterial.SetFloat("OrbSize", orbSize);
        meshRenderer.sharedMaterial.SetFloat("LineThickness", lineThickness);
        meshRenderer.sharedMaterial.SetColor("OrbColor", orbColor);
        meshRenderer.sharedMaterial.SetColor("LineColor", lineColor);
        mesh.RecalculateBounds();
    }
}
