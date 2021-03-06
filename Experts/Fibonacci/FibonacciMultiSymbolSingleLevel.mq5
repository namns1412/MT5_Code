//+------------------------------------------------------------------+
//|                              FibonacciMultiSymbolSingleLevel.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\Fibonacci.mqh>
#include <Strategy\StrategiesList.mqh>

input int period_search_mode=500;   //搜素模式的大周期
input int range_point=300; //模式的最小点数差
input int range_period=50; //模式的最大数据长度

input double open_level=0.618; //开仓点
input double tp_level=0.882; //止盈平仓点
input double sl_level=-1.0; //止损平仓点
input double open_lots=0.1; //开仓手数

string symbols[]={"XAUUSD","XTIUSD","GBPUSD","EURUSD","USDJPY","USDCHF","AUDUSD","USDCAD","NZDUSD"};
//string symbols[]={"GBPUSD"};

CStrategyList Manager;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   FibonacciRatioStrategy *strategy[];
   int num_symbol=ArraySize(symbols);
   ArrayResize(strategy,num_symbol);
   for(int i=0;i<num_symbol;i++)
     {
      ENUM_TIMEFRAMES period=_Period;
      string symbol=symbols[i];
      strategy[i]=new FibonacciRatioStrategy();
      strategy[i].ExpertMagic(10+i);
      strategy[i].Timeframe(period);
      strategy[i].ExpertSymbol(symbol);
      strategy[i].ExpertName("Fibonacci Ratio Strategy");
      strategy[i].SetPatternParameter(period_search_mode,range_period,range_point);
      strategy[i].SetOpenRatio(open_level);
      strategy[i].SetCloseRatio(tp_level,sl_level);
      strategy[i].SetLots(open_lots);
      strategy[i].SetEventDetect(symbol,period);
   
      Manager.AddStrategy(strategy[i]);
     }
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+