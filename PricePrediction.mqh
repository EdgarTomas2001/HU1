//+------------------------------------------------------------------+
//|                                               PricePrediction.mqh |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      ""
#property version   "1.00"

// Include necessary files
#include "LSTMNetwork.mqh"
#include "C:\Users\Edgar Tomas\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\HU1\include\Constants\Defines.mqh"
#include "C:\Users\Edgar Tomas\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\HU1\include\Utils\Logger.mqh"

//+------------------------------------------------------------------+
//| Class for price prediction using LSTM                              |
//+------------------------------------------------------------------+
class CPricePrediction
{
private:
    CLSTMNetwork *m_network;         // LSTM network instance
    int          m_lookbackPeriod;   // Number of historical bars to consider
    int          m_predictionSteps;  // Number of steps to predict ahead
    double       m_trainingData[];   // Array to store preprocessed training data
    double       m_scaleFactor;      // Data scaling factor
    CLogger     *m_logger;           // Logger instance
    
    // Private methods
    void         PreprocessData(const double &prices[], double &processed[]);
    void         NormalizeData(double &data[]);
    void         DenormalizeData(double &data[]);
    
public:
                 CPricePrediction();
                ~CPricePrediction();
    
    // Initialization
    bool         Init(int lookbackPeriod, int predictionSteps, int hiddenSize);
    
    // Training and prediction
    bool         Train(const double &prices[]);
    bool         PredictNextPrice(const double &currentPrices[], double &prediction);
    
    // Data management
    void         UpdateTrainingData(const double &newPrice);
};

//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CPricePrediction::CPricePrediction()
{
    m_network = NULL;
    m_lookbackPeriod = 0;
    m_predictionSteps = 0;
    m_scaleFactor = 0.0;
    m_logger = new CLogger("../logs/debug/price_prediction.log");
}

//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
CPricePrediction::~CPricePrediction()
{
    if(m_network != NULL)
    {
        delete m_network;
        m_network = NULL;
    }
    
    if(m_logger != NULL)
    {
        delete m_logger;
        m_logger = NULL;
    }
}

//+------------------------------------------------------------------+
//| Initialize the price prediction system                             |
//+------------------------------------------------------------------+
bool CPricePrediction::Init(int lookbackPeriod, int predictionSteps, int hiddenSize)
{
    if(lookbackPeriod <= 0 || predictionSteps <= 0 || hiddenSize <= 0)
    {
        m_logger.Error("Invalid initialization parameters");
        return false;
    }
    
    m_lookbackPeriod = lookbackPeriod;
    m_predictionSteps = predictionSteps;
    
    // Create and initialize LSTM network
    m_network = new CLSTMNetwork();
    if(!m_network.Init(1, hiddenSize, 1, lookbackPeriod))
    {
        m_logger.Error("Failed to initialize LSTM network");
        return false;
    }
    
    m_logger.Info(StringFormat("Initialized price prediction with lookback=%d, steps=%d", 
                              lookbackPeriod, predictionSteps));
    return true;
}

//+------------------------------------------------------------------+
//| Preprocess price data for LSTM input                               |
//+------------------------------------------------------------------+
void CPricePrediction::PreprocessData(const double &prices[], double &processed[])
{
    int size = ArraySize(prices);
    ArrayResize(processed, size);
    ArrayCopy(processed, prices);
    
    // Calculate returns instead of using raw prices
    for(int i = size - 1; i > 0; i--)
    {
        processed[i] = (prices[i] - prices[i-1]) / prices[i-1];
    }
    processed[0] = 0;
    
    NormalizeData(processed);
}

//+------------------------------------------------------------------+
//| Normalize data to [-1, 1] range                                    |
//+------------------------------------------------------------------+
void CPricePrediction::NormalizeData(double &data[])
{
    int size = ArraySize(data);
    if(size == 0) return;
    
    // Find max absolute value for scaling
    m_scaleFactor = 0;
    for(int i = 0; i < size; i++)
    {
        double absValue = MathAbs(data[i]);
        if(absValue > m_scaleFactor)
            m_scaleFactor = absValue;
    }
    
    // Avoid division by zero
    if(m_scaleFactor > 0)
    {
        for(int i = 0; i < size; i++)
        {
            data[i] /= m_scaleFactor;
        }
    }
}

//+------------------------------------------------------------------+
//| Denormalize data back to original scale                            |
//+------------------------------------------------------------------+
void CPricePrediction::DenormalizeData(double &data[])
{
    int size = ArraySize(data);
    for(int i = 0; i < size; i++)
    {
        data[i] *= m_scaleFactor;
    }
}

//+------------------------------------------------------------------+
//| Train the prediction model                                         |
//+------------------------------------------------------------------+
bool CPricePrediction::Train(const double &prices[])
{
    if(ArraySize(prices) < m_lookbackPeriod + m_predictionSteps)
    {
        m_logger.Error("Insufficient data for training");
        return false;
    }
    
    // Preprocess training data
    double processed[];
    PreprocessData(prices, processed);
    
    // Prepare training sequences
    double inputs[];
    double targets[];
    ArrayResize(inputs, m_lookbackPeriod);
    ArrayResize(targets, 1);
    
    // Train on sliding windows
    for(int i = 0; i < ArraySize(processed) - m_lookbackPeriod - m_predictionSteps; i++)
    {
        ArrayCopy(inputs, processed, 0, i, m_lookbackPeriod);
        targets[0] = processed[i + m_lookbackPeriod];
        
        if(!m_network.Train(inputs, targets))
        {
            m_logger.Error("Training failed at sequence " + IntegerToString(i));
            return false;
        }
    }
    
    m_logger.Info("Training completed successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Predict the next price movement                                    |
//+------------------------------------------------------------------+
bool CPricePrediction::PredictNextPrice(const double &currentPrices[], double &prediction)
{
    if(ArraySize(currentPrices) < m_lookbackPeriod)
    {
        m_logger.Error("Insufficient data for prediction");
        return false;
    }
    
    // Preprocess input data
    double processed[];
    PreprocessData(currentPrices, processed);
    
    // Prepare input sequence
    double input[];
    ArrayResize(input, m_lookbackPeriod);
    ArrayCopy(input, processed, 0, ArraySize(processed) - m_lookbackPeriod, m_lookbackPeriod);
    
    // Make prediction
    double output[];
    if(!m_network.Predict(input, output))
    {
        m_logger.Error("Prediction failed");
        return false;
    }
    
    // Denormalize prediction
    DenormalizeData(output);
    prediction = output[0];
    
    return true;
}

//+------------------------------------------------------------------+
//| Update training data with new price                                |
//+------------------------------------------------------------------+
void CPricePrediction::UpdateTrainingData(const double &newPrice)
{
    // Add new price to training data and maintain sliding window
    int size = ArraySize(m_trainingData);
    if(size >= m_lookbackPeriod)
    {
        for(int i = 0; i < size - 1; i++)
        {
            m_trainingData[i] = m_trainingData[i + 1];
        }
        m_trainingData[size - 1] = newPrice;
    }
    else
    {
        ArrayResize(m_trainingData, size + 1);
        m_trainingData[size] = newPrice;
    }
}