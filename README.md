# HU1 Expert Advisor Project

This is a modular MQL5 Expert Advisor project with a well-organized structure.

## Project Structure

```
HU1/
├── src/              # Main EA logic and implementation
│   ├── EA.mq5        # Main Expert Advisor file
│   ├── ChartManager/  # Chart management and visualization
│   └── Trading/      # Trading logic and decision making
├── include/          # Common functions and utilities
│   ├── Utils/        # Utility functions
│   └── Constants/    # Global constants and definitions
├── indicators/       # Custom indicators
│   ├── Custom/       # Custom indicator implementations
│   └── Config/       # Indicator configurations
├── config/          # Configuration files
│   ├── templates/    # Parameter templates
│   └── presets/      # Trading strategy presets
├── tests/           # Testing and validation
│   ├── backtest/     # Backtesting scripts
│   └── demo/         # Demo configurations
├── logs/            # Logging and debugging
│   ├── debug/        # Debug logs
│   └── errors/       # Error reports
└── docs/            # Documentation
    ├── manual/       # User manual
    ├── api/          # API documentation
    └── changelog/    # Version history
```

## Directory Descriptions

- **src**: Contains the main Expert Advisor implementation, including chart management and trading logic.
- **ChartManager**: Contains chart handling classes:
- M15ChartHandler.mqh: Manages 15-minute timeframe charts
- H1ChartHandler.mqh: Manages 1-hour timeframe charts
- H4ChartHandler.mqh: Manages 4-hour timeframe charts
- ChartManager.mqh: Coordinates multiple timeframe chart management
- **include**: Common utilities, functions, and header files used across the project.
- **indicators**: Custom indicators and their configurations for technical analysis.
- **config**: Configuration files and templates for EA parameters and settings.
- **tests**: Scripts and configurations for backtesting and demo trading.
- **logs**: Logging system for debugging and error tracking.
- **docs**: Comprehensive documentation including user manual and change logs.