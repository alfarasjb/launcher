#define     WINDOW_WIDTH      300
#define     WINDOW_HEIGHT     120
#define     WINDOW_X          10
#define     WINDOW_Y          10 
#define     WINDOW_X2         WINDOW_X + WINDOW_WIDTH
#define     WINDOW_Y2         WINDOW_Y + WINDOW_HEIGHT


struct Charts {
   string         chart_symbol; 
   long           chart_id; 
   ENUM_TIMEFRAMES chart_period;
} CHARTS;


input string            InpTemplatePath      = "DEF.tpl"; // Path to template at MQL4 Directory
input string            InpSymbolsPath       = "recurve"; // Path to symbols.ini from launcher common folder.
input ENUM_TIMEFRAMES   InpChartTimeframe    = PERIOD_M15; // Chart Timeframe