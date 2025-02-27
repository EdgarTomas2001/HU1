//+------------------------------------------------------------------+
//|                                                 SignalMarker.mqh |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      ""
#property version   "1.00"

// Include necessary files
#include "../../../include/Constants/Defines.mqh"
#include "../../../include/Utils/Logger.mqh"

//+------------------------------------------------------------------+
//| Class to handle visual elements for trading signals                 |
//+------------------------------------------------------------------+
class CSignalMarker
{
private:
    long              m_chart_id;         // Chart ID for visual elements
    string            m_symbol;           // Current symbol
    CLogger*          m_logger;           // Logger instance
    
    // Object names for cleanup
    string            m_entry_markers[];  // Array of entry marker names
    string            m_exit_markers[];   // Array of exit marker names
    string            m_trend_lines[];    // Array of trend line names
    string            m_rectangles[];     // Array of rectangle names
    string            m_frames[];         // Array of frame names
    
    void              CleanupObjects();   // Remove all visual objects
    
 public:
                     CSignalMarker(long chart_id, string symbol, CLogger* logger);
                    ~CSignalMarker();
    
    // Signal visualization methods
    bool             DrawEntryMarker(datetime time, double price, bool isLong);
    bool             DrawExitMarker(datetime time, double price);
    bool             DrawTrendLine(datetime time1, double price1, 
                                  datetime time2, double price2);
    bool             DrawSupportResistance(double price, color clr);
    bool             DrawTransparentRectangle(datetime time1, double price1,
                                             datetime time2, double price2,
                                             color bgColor, double transparency);
    bool             DrawFrame(datetime time1, double price1,
                              datetime time2, double price2,
                              color frameColor);
    
    // Object management
    void             UpdateVisuals();     // Update all visual elements
    void             ClearVisuals();      // Clear all visual elements
};

//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CSignalMarker::CSignalMarker(long chart_id, string symbol, CLogger* logger)
{
    m_chart_id = chart_id;
    m_symbol = symbol;
    m_logger = logger;
}

//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
CSignalMarker::~CSignalMarker()
{
    CleanupObjects();
}

//+------------------------------------------------------------------+
//| Draw entry marker on chart                                         |
//+------------------------------------------------------------------+
bool CSignalMarker::DrawEntryMarker(datetime time, double price, bool isLong)
{
    string name = m_symbol + "_Entry_" + IntegerToString(ArraySize(m_entry_markers));
    if(ObjectCreate(m_chart_id, name, OBJ_ARROW, 0, time, price))
    {
        ObjectSetInteger(m_chart_id, name, OBJPROP_ARROWCODE, isLong ? 233 : 234);
        ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, isLong ? clrLime : clrRed);
        ArrayResize(m_entry_markers, ArraySize(m_entry_markers) + 1);
        m_entry_markers[ArraySize(m_entry_markers) - 1] = name;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Draw exit marker on chart                                          |
//+------------------------------------------------------------------+
bool CSignalMarker::DrawExitMarker(datetime time, double price)
{
    string name = m_symbol + "_Exit_" + IntegerToString(ArraySize(m_exit_markers));
    if(ObjectCreate(m_chart_id, name, OBJ_ARROW, 0, time, price))
    {
        ObjectSetInteger(m_chart_id, name, OBJPROP_ARROWCODE, 251);
        ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, clrYellow);
        ArrayResize(m_exit_markers, ArraySize(m_exit_markers) + 1);
        m_exit_markers[ArraySize(m_exit_markers) - 1] = name;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Draw trend line on chart                                           |
//+------------------------------------------------------------------+
bool CSignalMarker::DrawTrendLine(datetime time1, double price1, 
                                 datetime time2, double price2)
{
    string name = m_symbol + "_Trend_" + IntegerToString(ArraySize(m_trend_lines));
    if(ObjectCreate(m_chart_id, name, OBJ_TREND, 0, time1, price1, time2, price2))
    {
        ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, clrBlue);
        ObjectSetInteger(m_chart_id, name, OBJPROP_STYLE, STYLE_DASH);
        ArrayResize(m_trend_lines, ArraySize(m_trend_lines) + 1);
        m_trend_lines[ArraySize(m_trend_lines) - 1] = name;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Draw support/resistance level                                      |
//+------------------------------------------------------------------+
bool CSignalMarker::DrawSupportResistance(double price, color clr)
{
    string name = m_symbol + "_SR_" + DoubleToString(price, _Digits);
    if(ObjectCreate(m_chart_id, name, OBJ_HLINE, 0, 0, price))
    {
        ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, clr);
        ObjectSetInteger(m_chart_id, name, OBJPROP_STYLE, STYLE_DOT);
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Update all visual elements                                         |
//+------------------------------------------------------------------+
void CSignalMarker::UpdateVisuals()
{
    // Implement update logic for dynamic visual elements
    ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Clear all visual elements                                          |
//+------------------------------------------------------------------+
void CSignalMarker::ClearVisuals()
{
    CleanupObjects();
    ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Remove all visual objects                                          |
//+------------------------------------------------------------------+
void CSignalMarker::CleanupObjects()
{
    // Clean up entry markers
    for(int i = 0; i < ArraySize(m_entry_markers); i++)
        ObjectDelete(m_chart_id, m_entry_markers[i]);
    ArrayFree(m_entry_markers);
    
    // Clean up exit markers
    for(int i = 0; i < ArraySize(m_exit_markers); i++)
        ObjectDelete(m_chart_id, m_exit_markers[i]);
    ArrayFree(m_exit_markers);
    
    // Clean up trend lines
    for(int i = 0; i < ArraySize(m_trend_lines); i++)
        ObjectDelete(m_chart_id, m_trend_lines[i]);
    ArrayFree(m_trend_lines);
    
    // Clean up rectangles
    for(int i = 0; i < ArraySize(m_rectangles); i++)
        ObjectDelete(m_chart_id, m_rectangles[i]);
    ArrayFree(m_rectangles);
    
    // Clean up frames
    for(int i = 0; i < ArraySize(m_frames); i++)
        ObjectDelete(m_chart_id, m_frames[i]);
    ArrayFree(m_frames);
}

//+------------------------------------------------------------------+
//| Draw a transparent rectangle on the chart                          |
//+------------------------------------------------------------------+
bool CSignalMarker::DrawTransparentRectangle(datetime time1, double price1,
                                             datetime time2, double price2,
                                             color bgColor, double transparency)
{
    string name = m_symbol + "_rect_" + IntegerToString(ArraySize(m_rectangles));
    
    if(!ObjectCreate(m_chart_id, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2))
    {
        m_logger.Error("Failed to create rectangle object");
        return false;
    }
    
    ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, bgColor);
    ObjectSetInteger(m_chart_id, name, OBJPROP_FILL, true);
    ObjectSetInteger(m_chart_id, name, OBJPROP_BACK, true);
    ObjectSetDouble(m_chart_id, name, OBJPROP_TRANSPARENCY, transparency);
    
    ArrayResize(m_rectangles, ArraySize(m_rectangles) + 1);
    m_rectangles[ArraySize(m_rectangles) - 1] = name;
    
    return true;
}

//+------------------------------------------------------------------+
//| Draw a frame on the chart                                          |
//+------------------------------------------------------------------+
bool CSignalMarker::DrawFrame(datetime time1, double price1,
                              datetime time2, double price2,
                              color frameColor)
{
    string name = m_symbol + "_frame_" + IntegerToString(ArraySize(m_frames));
    
    if(!ObjectCreate(m_chart_id, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2))
    {
        m_logger.Error("Failed to create frame object");
        return false;
    }
    
    ObjectSetInteger(m_chart_id, name, OBJPROP_COLOR, frameColor);
    ObjectSetInteger(m_chart_id, name, OBJPROP_FILL, false);
    ObjectSetInteger(m_chart_id, name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(m_chart_id, name, OBJPROP_BACK, false);
    
    ArrayResize(m_frames, ArraySize(m_frames) + 1);
    m_frames[ArraySize(m_frames) - 1] = name;
    
    return true;
}