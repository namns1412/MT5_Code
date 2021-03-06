//+------------------------------------------------------------------+
//|                                             EA_BreakPointRSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyMA\SimpleDoubleMA.mqh>
input int Inp_ma_long=200;
input int Inp_ma_short=24;
CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CSimpleDoubleMA *ma_s=new CSimpleDoubleMA();
   ma_s.ExpertName("MA Simple");
   ma_s.ExpertMagic(2018011601);
   ma_s.Timeframe(_Period);
   ma_s.ExpertSymbol(_Symbol);
   ma_s.SetEventDetect(_Symbol,_Period);
   ma_s.InitStrategy(Inp_ma_long,Inp_ma_short);
   ma_s.ReInitPositions();
   Manager.AddStrategy(ma_s);
   
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
