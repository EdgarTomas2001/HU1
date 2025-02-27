//+------------------------------------------------------------------+
//|                                              KMeansClustering.mqh |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      ""
#property version   "1.00"

// Include necessary files
#include "C:\Users\Edgar Tomas\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\HU1\include\Constants\Defines.mqh"
#include "C:\Users\Edgar Tomas\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\HU1\include\Utils\Logger.mqh"

//+------------------------------------------------------------------+
//| Class for implementing K-means clustering algorithm                |
//+------------------------------------------------------------------+
class CKMeansClustering
{
private:
    int         m_k;                // Number of clusters
    int         m_maxIterations;    // Maximum iterations for convergence
    double      m_tolerance;        // Convergence tolerance
    int         m_dataPoints[];     // Array to store input data points
    int         m_clusters[];       // Array to store cluster assignments
    double      m_centroids[];      // Array to store cluster centroids
    CLogger    *m_logger;           // Logger instance
    
    // Private methods
    bool        InitializeCentroids();
    double      CalculateDistance(double point1, double point2);
    int         FindNearestCluster(double point);
    bool        UpdateCentroids();
    
public:
                CKMeansClustering();
               ~CKMeansClustering();
    
    // Initialization and setup
    bool        Init(int k, int maxIterations = 100, double tolerance = 0.0001);
    void        SetData(const double &data[]);
    
    // Core clustering operations
    bool        Fit();              // Execute clustering algorithm
    int         Predict(double point); // Predict cluster for new point
    
    // Getters
    void        GetClusters(int &clusters[]) const { ArrayCopy(clusters, m_clusters); }
    void        GetCentroids(double &centroids[]) const { ArrayCopy(centroids, m_centroids); }
};

//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CKMeansClustering::CKMeansClustering()
{
    m_k = 0;
    m_maxIterations = 0;
    m_tolerance = 0.0;
    m_logger = new CLogger("../logs/debug/kmeans.log");
}

//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
CKMeansClustering::~CKMeansClustering()
{
    if(m_logger != NULL)
    {
        delete m_logger;
        m_logger = NULL;
    }
}

//+------------------------------------------------------------------+
//| Initialize the clustering algorithm                                |
//+------------------------------------------------------------------+
bool CKMeansClustering::Init(int k, int maxIterations = 100, double tolerance = 0.0001)
{
    if(k <= 0)
    {
        m_logger.Error("Invalid number of clusters");
        return false;
    }
    
    m_k = k;
    m_maxIterations = maxIterations;
    m_tolerance = tolerance;
    
    m_logger.Info(StringFormat("Initialized K-means with k=%d, maxIterations=%d", k, maxIterations));
    return true;
}

//+------------------------------------------------------------------+
//| Set input data for clustering                                      |
//+------------------------------------------------------------------+
void CKMeansClustering::SetData(const double &data[])
{
    ArrayResize(m_dataPoints, ArraySize(data));
    ArrayCopy(m_dataPoints, data);
}

//+------------------------------------------------------------------+
//| Initialize cluster centroids                                       |
//+------------------------------------------------------------------+
bool CKMeansClustering::InitializeCentroids()
{
    int dataSize = ArraySize(m_dataPoints);
    if(dataSize < m_k)
    {
        m_logger.Error("Not enough data points for clustering");
        return false;
    }
    
    ArrayResize(m_centroids, m_k);
    ArrayResize(m_clusters, dataSize);
    
    // Initialize centroids using k-means++ method
    m_centroids[0] = m_dataPoints[0];
    
    for(int i = 1; i < m_k; i++)
    {
        double maxDistance = 0;
        int farthestPoint = 0;
        
        // Find the point farthest from existing centroids
        for(int j = 0; j < dataSize; j++)
        {
            double minDistance = DBL_MAX;
            for(int c = 0; c < i; c++)
            {
                double dist = CalculateDistance(m_dataPoints[j], m_centroids[c]);
                if(dist < minDistance) minDistance = dist;
            }
            
            if(minDistance > maxDistance)
            {
                maxDistance = minDistance;
                farthestPoint = j;
            }
        }
        
        m_centroids[i] = m_dataPoints[farthestPoint];
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate Euclidean distance between two points                    |
//+------------------------------------------------------------------+
double CKMeansClustering::CalculateDistance(double point1, double point2)
{
    return MathAbs(point1 - point2);
}

//+------------------------------------------------------------------+
//| Find nearest cluster for a given point                             |
//+------------------------------------------------------------------+
int CKMeansClustering::FindNearestCluster(double point)
{
    double minDistance = DBL_MAX;
    int nearestCluster = 0;
    
    for(int i = 0; i < m_k; i++)
    {
        double distance = CalculateDistance(point, m_centroids[i]);
        if(distance < minDistance)
        {
            minDistance = distance;
            nearestCluster = i;
        }
    }
    
    return nearestCluster;
}

//+------------------------------------------------------------------+
//| Update cluster centroids                                          |
//+------------------------------------------------------------------+
bool CKMeansClustering::UpdateCentroids()
{
    double newCentroids[];
    int clusterCounts[];
    
    ArrayResize(newCentroids, m_k);
    ArrayResize(clusterCounts, m_k);
    ArrayInitialize(newCentroids, 0);
    ArrayInitialize(clusterCounts, 0);
    
    // Calculate sum of points in each cluster
    for(int i = 0; i < ArraySize(m_dataPoints); i++)
    {
        int cluster = m_clusters[i];
        newCentroids[cluster] += m_dataPoints[i];
        clusterCounts[cluster]++;
    }
    
    // Calculate new centroids
    bool hasChanged = false;
    for(int i = 0; i < m_k; i++)
    {
        if(clusterCounts[i] > 0)
        {
            double newCentroid = newCentroids[i] / clusterCounts[i];
            if(MathAbs(newCentroid - m_centroids[i]) > m_tolerance)
            {
                hasChanged = true;
            }
            m_centroids[i] = newCentroid;
        }
    }
    
    return hasChanged;
}

//+------------------------------------------------------------------+
//| Execute clustering algorithm                                       |
//+------------------------------------------------------------------+
bool CKMeansClustering::Fit()
{
    if(!InitializeCentroids())
    {
        return false;
    }
    
    bool centroidsChanged = true;
    int iteration = 0;
    
    while(centroidsChanged && iteration < m_maxIterations)
    {
        // Assign points to nearest clusters
        for(int i = 0; i < ArraySize(m_dataPoints); i++)
        {
            m_clusters[i] = FindNearestCluster(m_dataPoints[i]);
        }
        
        // Update centroids
        centroidsChanged = UpdateCentroids();
        iteration++;
    }
    
    m_logger.Info(StringFormat("Clustering completed in %d iterations", iteration));
    return true;
}

//+------------------------------------------------------------------+
//| Predict cluster for new data point                                |
//+------------------------------------------------------------------+
int CKMeansClustering::Predict(double point)
{
    return FindNearestCluster(point);
}