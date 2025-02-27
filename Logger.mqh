//+------------------------------------------------------------------+
//|                                                      Logger.mqh |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      ""
#property version   "1.00"

//+------------------------------------------------------------------+
//| Class for handling logging functionality                           |
//+------------------------------------------------------------------+
class CLogger
{
private:
    string            m_symbol;          // Symbol for logging context
    string            m_log_file;        // Log file path
    bool              m_initialized;     // Initialization flag
    bool              m_log_to_file;     // Flag to enable/disable file logging
    
    string            FormatLogMessage(const string level, const string message);
    string            GetTimestamp();
    bool              WriteToFile(const string message);
    
public:
                     CLogger(const string symbol = "", const bool log_to_file = false);
                    ~CLogger();
    
    bool             Init();            // Initialize logger
    void             Cleanup();         // Cleanup resources
    
    // Logging methods for different severity levels
    void             Info(const string message);
    void             Warning(const string message);
    void             Error(const string message);
    void             Debug(const string message);
};

//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CLogger::CLogger(const string symbol = "", const bool log_to_file = false)
{
    m_symbol = symbol;
    m_log_to_file = log_to_file;
    m_initialized = false;
    
    // Set up log file path if file logging is enabled
    if(m_log_to_file)
    {
        m_log_file = "Logs\\" + m_symbol + "_" + TimeToString(TimeLocal(), TIME_DATE) + ".log";
    }
}

//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
CLogger::~CLogger()
{
    Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize logger                                                  |
//+------------------------------------------------------------------+
bool CLogger::Init()
{
    if(m_initialized)
        return true;
    
    // Create logs directory if logging to file is enabled
    if(m_log_to_file)
    {
        string logs_dir = "Logs";
        if(!FolderCreate(logs_dir))
        {
            Print("Failed to create logs directory");
            return false;
        }
    }
    
    m_initialized = true;
    return true;
}

//+------------------------------------------------------------------+
//| Cleanup resources                                                  |
//+------------------------------------------------------------------+
void CLogger::Cleanup()
{
    m_initialized = false;
}

//+------------------------------------------------------------------+
//| Format log message with timestamp and level                        |
//+------------------------------------------------------------------+
string CLogger::FormatLogMessage(const string level, const string message)
{
    string symbol_prefix = (m_symbol != "") ? "[" + m_symbol + "] " : "";
    return GetTimestamp() + " " + symbol_prefix + "[" + level + "] " + message;
}

//+------------------------------------------------------------------+
//| Get current timestamp                                              |
//+------------------------------------------------------------------+
string CLogger::GetTimestamp()
{
    return TimeToString(TimeLocal(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
}

//+------------------------------------------------------------------+
//| Write message to log file                                          |
//+------------------------------------------------------------------+
bool CLogger::WriteToFile(const string message)
{
    if(!m_log_to_file)
        return true;
        
    int handle = FileOpen(m_log_file, FILE_WRITE|FILE_READ|FILE_TXT|FILE_ANSI);
    if(handle == INVALID_HANDLE)
    {
        Print("Failed to open log file: ", GetLastError());
        return false;
    }
    
    // Move to end of file
    FileSeek(handle, 0, SEEK_END);
    
    // Write message with newline
    bool result = FileWriteString(handle, message + "\n");
    FileClose(handle);
    
    return result;
}

//+------------------------------------------------------------------+
//| Log info level message                                             |
//+------------------------------------------------------------------+
void CLogger::Info(const string message)
{
    string formatted_message = FormatLogMessage("INFO", message);
    Print(formatted_message);
    WriteToFile(formatted_message);
}

//+------------------------------------------------------------------+
//| Log warning level message                                          |
//+------------------------------------------------------------------+
void CLogger::Warning(const string message)
{
    string formatted_message = FormatLogMessage("WARNING", message);
    Print(formatted_message);
    WriteToFile(formatted_message);
}

//+------------------------------------------------------------------+
//| Log error level message                                            |
//+------------------------------------------------------------------+
void CLogger::Error(const string message)
{
    string formatted_message = FormatLogMessage("ERROR", message);
    Print(formatted_message);
    WriteToFile(formatted_message);
}

//+------------------------------------------------------------------+
//| Log debug level message                                            |
//+------------------------------------------------------------------+
void CLogger::Debug(const string message)
{
    string formatted_message = FormatLogMessage("DEBUG", message);
    Print(formatted_message);
    WriteToFile(formatted_message);
}