//+------------------------------------------------------------------+
//|                                                   TradeInfo.mqh |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      ""
#property version   "1.00"

// Include necessary files
#include "../../../include/Constants/Defines.mqh"
#include "../../../include/Utils/Logger.mqh"

//+------------------------------------------------------------------+
//| Class to handle trade information visual elements                   |
//+------------------------------------------------------------------+
class CTradeInfo
{
private:
    long              m_chart_id;         // Chart ID for visual elements
    string            m_symbol;           // Current symbol
    CLogger*          m_logger;           // Logger instance
    
    // Object names
    string            m_position_labels[];  // Position information labels
    string            m_risk_labels[];     // Risk information labels
    string            m_pnl_labels[];      // Profit/Loss labels
    
    void              CleanupObjects();     // Remove all visual objects
    
public:
                     CTradeInfo(long chart_id, string symbol, CLogger* logger);
                    ~CTradeInfo();
    
    // Display methods
    bool             ShowPositionInfo(string info, color clr = clrWhite);
    bool             ShowRiskInfo(double riskAmount, double riskPercent);
    bool             ShowProfitLoss(double profit, color clr = clrWhite);
    bool             ShowTradeStatus(string status, color clr = clrWhite);
    
    // Object management
    void             UpdateVisuals();     // Update all visual elements
    void             ClearVisuals();      // Clear all visual elements
};

//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CTradeInfo::CTradeInfo(long chart_id, string symbol, CLogger* logger)
{
    m_chart_id = chart_id;
    m_symbol = symbol;
    m_logger = logger;
}

//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
CTradeInfo::~CTradeInfo()
{
    CleanupObjects();
}

//+------------------------------------------------------------------+
//| Show position information                                          |
//+------------------------------------------------------------------+
bool CTradeInfo::ShowPositionInfo(string info, color clr)
{
    string name = m_symbol + "_Pos_" + IntegerToString(ArraySize(m_position_labels));
    if(ObjectCreate(m_chart_id, name, OBJ_LABEL, 0, 0, 0))
    {
        ObjectSetString(m_chart_id, name, OBJPROP_TEXT, info);
        ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, clr);
        ObjectSetInteger(m_chart_id, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
        ObjectSetInteger(m_chart_id, name, OBJPROP_XDISTANCE, 10);
        ObjectSetInteger(m_chart_id, name, OBJPROP_YDISTANCE, 20 * (ArraySize(m_position_labels) + 1));
        
        ArrayResize(m_position_labels, ArraySize(m_position_labels) + 1);
        m_position_labels[ArraySize(m_position_labels) - 1] = name;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Show risk information                                             |
//+------------------------------------------------------------------+
bool CTradeInfo::ShowRiskInfo(double riskAmount, double riskPercent)
{
    string info = StringFormat("Risk: $%.2f (%.2f%%)", riskAmount, riskPercent);
    string name = m_symbol + "_Risk_" + IntegerToString(ArraySize(m_risk_labels));
    
    if(ObjectCreate(m_chart_id, name, OBJ_LABEL, 0, 0, 0))
    {
        ObjectSetString(m_chart_id, name, OBJPROP_TEXT, info);
        ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, riskPercent > MAX_RISK_PERCENT ? clrRed : clrYellow);
        ObjectSetInteger(m_chart_id, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
        ObjectSetInteger(m_chart_id, name, OBJPROP_XDISTANCE, 10);
        ObjectSetInteger(m_chart_id, name, OBJPROP_YDISTANCE, 20 * (ArraySize(m_risk_labels) + 5));
        
        ArrayResize(m_risk_labels, ArraySize(m_risk_labels) + 1);
        m_risk_labels[ArraySize(m_risk_labels) - 1] = name;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Show profit/loss information                                       |
//+------------------------------------------------------------------+
bool CTradeInfo::ShowProfitLoss(double profit, color clr)
{
    string info = StringFormat("P/L: $%.2f", profit);
    string name = m_symbol + "_PnL_" + IntegerToString(ArraySize(m_pnl_labels));
    
    if(ObjectCreate(m_chart_id, name, OBJ_LABEL, 0, 0, 0))
    {
        ObjectSetString(m_chart_id, name, OBJPROP_TEXT, info);
        ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, clr);
        ObjectSetInteger(m_chart_id, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
        ObjectSetInteger(m_chart_id, name, OBJPROP_XDISTANCE, 10);
        ObjectSetInteger(m_chart_id, name, OBJPROP_YDISTANCE, 20 * (ArraySize(m_pnl_labels) + 3));
        
        ArrayResize(m_pnl_labels, ArraySize(m_pnl_labels) + 1);
        m_pnl_labels[ArraySize(m_pnl_labels) - 1] = name;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Show trade status                                                  |
//+------------------------------------------------------------------+
bool CTradeInfo::ShowTradeStatus(string status, color clr)
{
    string name = m_symbol + "_Status";
    if(ObjectCreate(m_chart_id, name, OBJ_LABEL, 0, 0, 0))
    {
        ObjectSetString(m_chart_id, name, OBJPROP_TEXT, status);
        ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, clr);
        ObjectSetInteger(m_chart_id, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
        ObjectSetInteger(m_chart_id, name, OBJPROP_XDISTANCE, 10);
        ObjectSetInteger(m_chart_id, name, OBJPROP_YDISTANCE, 20);
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Update all visual elements                                         |
//+------------------------------------------------------------------+
void CTradeInfo::UpdateVisuals()
{
    ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Clear all visual elements                                          |
//+------------------------------------------------------------------+
void CTradeInfo::ClearVisuals()
{
    CleanupObjects();
    ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Remove all visual objects                                          |
//+------------------------------------------------------------------+
void CTradeInfo::CleanupObjects()
{
    // Clean up position labels
    for(int i = 0; i < ArraySize(m_position_labels); i++)
        ObjectDelete(m_chart_id, m_position_labels[i]);
    ArrayFree(m_position_labels);
    
    // Clean up risk labels
    for(int i = 0; i < ArraySize(m_risk_labels); i++)
        ObjectDelete(m_chart_id, m_risk_labels[i]);
    ArrayFree(m_risk_labels);
    
    // Clean up PnL labels
    for(int i = 0; i < ArraySize(m_pnl_labels); i++)
        ObjectDelete(m_chart_id, m_pnl_labels[i]);
    ArrayFree(m_pnl_labels);
}