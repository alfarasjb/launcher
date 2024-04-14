
#include <Controls/Defines.mqh> 
#include <Controls/Dialog.mqh>
#include <Controls/Button.mqh>
#include <Controls/Label.mqh> 
#include "definition.mqh"

#define  INDENT_X        10
#define  GAP_Y           7 
#define  BUTTON_Y          80
#define  BUTTON_WIDTH      80
#define  BUTTON_HEIGHT     25
class CRootLauncher : public CAppDialog{
   private:
      string         TEMPLATE_PATH, SYMBOLS_PATH;
      string         SYMBOLS[]; 
      Charts         EXTERNAL_CHARTS[]; 
   public:
      CRootLauncher();
      ~CRootLauncher();
      
               void     Init(); 
      
               CLabel   template_lbl, symbols_lbl; 
               CButton  m_run_button, m_reload_button, m_clear_button; 
               
      virtual  bool     Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2); 
      
      template <typename T>   bool  RowCreate(CLabel &lbl, string key, T value, int row_number); 
                              bool  ButtonCreate(CButton &bt, string name, const int column_num); 

               EVENT_MAP_BEGIN(CRootLauncher)
               ON_EVENT(ON_CLICK, m_run_button, OnClickRunButton);
               ON_EVENT(ON_CLICK, m_reload_button, OnClickReloadButton);
               ON_EVENT(ON_CLICK, m_clear_button, OnClickClearButton); 
               EVENT_MAP_END(CAppDialog)
               
               
               void     OnClickRunButton(); 
               void     OnClickReloadButton();
               void     OnClickClearButton(); 
               
      
      //--- MAIN FUNCTIONS 
               bool     LoadSymbols(); 
               bool     LoadCharts(); 
               bool     ParseSymbols(string symbols); 
               bool     BuildExternalCharts(long chart_id);
               bool     ClearCharts(); 
               
               int      AddToSymbols(string symbol); 

      template <typename T>   int   Append(T &data, T &dst[]); 
      template <typename T>   int   Clear(T &src[]); 

}; 


CRootLauncher::CRootLauncher(void) {
   Init(); 
}

CRootLauncher::~CRootLauncher(void) {}

bool        CRootLauncher::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2) {
   if (!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2)) return false; 
   if (!RowCreate(template_lbl, "Template Path", TEMPLATE_PATH, 1)) return false; 
   if (!RowCreate(symbols_lbl, "Symbols Path", SYMBOLS_PATH, 2)) return false; 
   if (!ButtonCreate(m_run_button, "Run", 1)) return false; 
   if (!ButtonCreate(m_reload_button, "Reload", 2)) return false; 
   if (!ButtonCreate(m_clear_button, "Clear", 3)) return false; 
   
   return true; 
}

void        CRootLauncher::Init(void) {
   TEMPLATE_PATH  = StringFormat("MQL4\\%s", InpTemplatePath); 
   SYMBOLS_PATH   = StringFormat("launcher\\%s\\symbols.ini", InpSymbolsPath);
   Clear(SYMBOLS);
   Clear(EXTERNAL_CHARTS);
}

template <typename T>
bool        CRootLauncher::RowCreate(CLabel &lbl,string key,T value,int row_number) {
   string label_string     = StringFormat("%s: %s", key, (string)value); 
   
   int y1   = row_number * (CONTROLS_FONT_SIZE + GAP_Y); 
   if (!lbl.Create(0, key, 0, INDENT_X, y1, 50, 10)) return false;
   if (!lbl.Text(label_string))  return false;
   if (!Add(lbl)) return false;
   return true; 

}


bool        CRootLauncher::ButtonCreate(CButton &bt,string name, const int column_num) {
   int x1   = INDENT_X + ((column_num-1)*(BUTTON_WIDTH+INDENT_X)); 
   int y1   = 60;
   int x2   = x1 + BUTTON_WIDTH;
   int y2   = y1 + BUTTON_HEIGHT; 
   if (!bt.Create(0, name, 0, x1, y1, x2, y2)) return false;
   if (!bt.Text(name)) return false; 
   if (!Add(bt)) return false;
   return true; 
}

void        CRootLauncher::OnClickRunButton(void) {
   Clear(EXTERNAL_CHARTS);
   LoadSymbols(); 
   LoadCharts();
}

void        CRootLauncher::OnClickReloadButton(void) {
   ClearCharts();
   Clear(EXTERNAL_CHARTS);
   LoadSymbols(); 
   LoadCharts(); 
}

void        CRootLauncher::OnClickClearButton(void) { ClearCharts(); }


bool        CRootLauncher::LoadSymbols(void) {
   
   if (!FileIsExist(SYMBOLS_PATH, FILE_COMMON)) {
      PrintFormat("symbols.ini not found at %s", SYMBOLS_PATH); 
      return false; 
   }
   else {
      Print("symbols.ini found."); 
   }
   
   string result[];
   int handle  = FileOpen(SYMBOLS_PATH, FILE_COMMON | FILE_SHARE_READ | FILE_TXT | FILE_ANSI); 
   if (handle == INVALID_HANDLE) {
      PrintFormat("Failed to load symbols.ini: %s", SYMBOLS_PATH); 
      return false; 
   }
   
   FileSeek(handle, 0, SEEK_SET); 
   while (!FileIsEnding(handle)) {
      string filestring    = StringTrimLeft(StringTrimRight(FileReadString(handle))); 
      
      int split            = StringSplit(filestring, '=', result); 
      if (split > 0) {
         int num_symbols      = Append(result[0], SYMBOLS); 
      }
      
   }
     
   FileClose(handle);
   FileFlush(handle);
   return true; 
}

template <typename T>
int         CRootLauncher::Append(T &data,T &dst[]) {
   int size = ArraySize(dst);
   ArrayResize(dst, size+1);
   dst[size]   = data;
   return ArraySize(dst); 
}

template <typename T>
int         CRootLauncher::Clear(T &src[]) {
   ArrayFree(src);
   ArrayResize(src, 0); 
   return ArraySize(src); 
}


bool        CRootLauncher::LoadCharts(void) {
   int num_symbols   = ArraySize(SYMBOLS);
   
   for (int i = 0; i < num_symbols; i++) {
      string symbol  = SYMBOLS[i]; 
      PrintFormat("Initializing: %s", symbol);
      
      long id  = ChartOpen(symbol, InpChartTimeframe); 
      string file_path;
      switch (InpTemplateSrc) {
         case MODE_MQL_DIRECTORY:
             file_path  = "\\"+InpTemplatePath; 
             break;
         case MODE_EA_DIRECTORY:
            file_path   = InpTemplatePath;
            break; 
      }
      long chart_id  = ChartApplyTemplate(id, file_path);
      if (!chart_id) {
         PrintFormat("Failed to apply template on %s, ID: %s, Path: %s", symbol, (string)id, InpTemplatePath); 
         //ChartClose(id);
         return false; 
      }
      else {
         PrintFormat("%s: Template Applied", symbol); 
         Charts chart;
         chart.chart_id       = id;
         chart.chart_period   = ChartPeriod(chart.chart_id);
         chart.chart_symbol   = ChartSymbol(chart.chart_id);
         Append(chart, EXTERNAL_CHARTS);
      }
   }
   return true; 
}

bool        CRootLauncher::BuildExternalCharts(long chart_id) {
   if (chart_id < 0) return false;
   long  next     = ChartNext(chart_id);
   long  current  = ChartID(); 
   if (chart_id != current) {
      Charts chart;
      chart.chart_id       = chart_id;
      chart.chart_period   = ChartPeriod(chart_id);
      chart.chart_symbol   = ChartSymbol(chart_id);
      Append(chart, EXTERNAL_CHARTS);
   }
   BuildExternalCharts(next);
   return true; 

}

bool        CRootLauncher::ClearCharts(void) {
   long  first = ChartFirst();
   BuildExternalCharts(first); 
   
   int num_charts = ArraySize(EXTERNAL_CHARTS); 
   for (int i = 0; i < num_charts; i++) {
      long  id = EXTERNAL_CHARTS[i].chart_id;
      bool closed = ChartClose(id);
      switch(closed) {
         case true:     PrintFormat("ID: %s Closed.", (string)id); break;
         case false:    PrintFormat("ID: %s failed to close.", (string)id); break;
      }
   }
   Clear(EXTERNAL_CHARTS); 
   Clear(SYMBOLS);
   return true; 
}