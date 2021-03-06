//+------------------------------------------------------------------+
//|                                                ImpulseExpert.mq5 |
//|                                 Copyright 2016, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <Strategy\Samples\Impulse.mqh>

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CImpulse* impulse = new CImpulse();
   impulse.ExpertMagic(1218);
   impulse.Timeframe(Period());
   impulse.ExpertSymbol(Symbol());
   impulse.ExpertName("Impulse");
   impulse.Moving.MaPeriod(28);                      
   impulse.SetPercent(StopPercent);
   if(!Manager.AddStrategy(impulse))
      delete impulse;
//---
   return(INIT_SUCCEEDED);
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
