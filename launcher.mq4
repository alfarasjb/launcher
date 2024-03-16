
#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property version   "1.00"
#property strict

#include "root.mqh"

CRootLauncher     ExtDialog; 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if (!ExtDialog.Create(0, "Launcher", 0, WINDOW_X, WINDOW_Y, WINDOW_X2, WINDOW_Y2)) return INIT_FAILED; 
   ExtDialog.Run(); 
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0, -1, -1); 
   ExtDialog.Destroy(reason); 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   ExtDialog.ChartEvent(id,lparam,dparam,sparam); 

}


