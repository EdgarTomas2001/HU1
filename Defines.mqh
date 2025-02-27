//+------------------------------------------------------------------+
//|                                                     Defines.mqh |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      ""
#property version   "1.00"

// EA Version Information
#define EA_NAME     "HU1"
#define EA_VERSION  "1.0.0"

// Trading Constants
#define MAX_POSITIONS     10     // Maximum number of open positions
#define MIN_STOP_LEVEL   20     // Minimum stop level in points
#define DEFAULT_SLIPPAGE 3      // Default slippage in points

// Risk Management
#define MAX_RISK_PERCENT 2.0    // Maximum risk per trade as percentage
#define MIN_RISK_PERCENT 0.5    // Minimum risk per trade as percentage

// Time Filters
#define TRADING_START_HOUR 1     // Trading session start hour (GMT)
#define TRADING_END_HOUR   23    // Trading session end hour (GMT)
#define FRIDAY_END_HOUR    21    // Early closure on Friday (GMT)

// Indicator Parameters
#define FAST_MA_PERIOD    10     // Fast Moving Average period
#define SLOW_MA_PERIOD    20     // Slow Moving Average period
#define RSI_PERIOD        14     // RSI period
#define RSI_OVERBOUGHT    70     // RSI overbought level
#define RSI_OVERSOLD      30     // RSI oversold level

// Visual Settings
#define CHART_FONT_SIZE   10     // Default font size for chart objects
#define SIGNAL_LINE_WIDTH 2      // Width of signal lines on chart
#define UP_ARROW_CODE     233    // Character code for up arrow
#define DOWN_ARROW_CODE   234    // Character code for down arrow

// Color Definitions
#define COLOR_BUY         clrDodgerBlue    // Buy signal color
#define COLOR_SELL        clrCrimson       // Sell signal color
#define COLOR_NEUTRAL     clrGray          // Neutral state color
#define COLOR_PROFIT      clrLimeGreen     // Profit highlight color
#define COLOR_LOSS        clrRed           // Loss highlight color

// Logging Levels
#define LOG_LEVEL_ERROR   1     // Error messages
#define LOG_LEVEL_WARN    2     // Warning messages
#define LOG_LEVEL_INFO    3     // Information messages
#define LOG_LEVEL_DEBUG   4     // Debug messages