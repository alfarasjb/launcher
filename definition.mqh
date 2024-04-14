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

enum TemplateSource {
   MODE_MQL_DIRECTORY,
   MODE_EA_DIRECTORY,
}; 

input string            InpTemplatePath      = "DEF_VER_1.2.tpl"; // Path to template at MQL4 Directory
input string            InpSymbolsPath       = "recurve\\aggressive"; // Path to symbols.ini from launcher common folder.
input ENUM_TIMEFRAMES   InpChartTimeframe    = PERIOD_M15; // Chart Timeframe
input TemplateSource    InpTemplateSrc       = MODE_EA_DIRECTORY; // Template Source Directory