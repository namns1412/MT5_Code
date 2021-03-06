//+------------------------------------------------------------------+
//|                                                       EA_PCA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyCombination\strategyCombinationTrend2.mqh>
input int Inp_period_short=24;
input int Inp_period_long=200;
input double Inp_delta_short=2.5;
input double Inp_delta_long=2.5;
input int Inp_win_points=100;
input int Inp_lots=1.0;

CStrategyList Manager;
double coef_f1[]={-0.399507059528915,-0.370922865570124,-0.427589364667445,-0.181076685848670,0.503477240176153,0.104966594162066,0.471891501283697};
double coef_f2[]={0.156120119973915,0.715731392291141,-0.126736008372040,0.117875179050492,0.0299506048976982,-0.178609072735887,0.632929908423311};
double coef_f3[]={0.327979989020678,-0.516986378765809,0.201814258438518,0.527692590134551,0.0381730990152814,-0.452048047705465,0.316482422036138};
double coef_f4[]={0.307570633268989,0.146945928345138,-0.249584580981536,-0.171309807453575,0.589245072698589,-0.508662449132625,-0.431532668105931};
double coef_f5[]={0.743086948081259,-0.204609032796194,-0.395675619296499,-0.273858340231410,-0.188255687857085,0.350251237192899,0.127605689151442};
double coef_f6[]={0.0337389911317090,0.130386150934774,-0.311275182193609,0.743528195407073,0.254599822340319,0.458321993809418,-0.239279326649219};
double coef_f7[]={0.246035603007154,0.0491057587483893,0.666807638436350,-0.132957092001832,0.544688365174624,0.401573043778991,0.129610056992029};
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CStrategyCombinationTrend *com=new CStrategyCombinationTrend();
   com.ExpertName("pca trend2策略");
   com.ExpertMagic(51804300);
   com.Timeframe(_Period);
   com.ExpertSymbol(_Symbol);
   com.InitStrategy(Inp_period_short,Inp_delta_short,Inp_period_long,Inp_delta_long,coef_f1,Inp_win_points,Inp_lots);
   Manager.AddStrategy(com);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Manager.OnTick();
  }
//+------------------------------------------------------------------+
