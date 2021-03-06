//+------------------------------------------------------------------+
//|                               FibonacciMultiSymbolMultiLevel.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\Fibonacci.mqh>
#include <Strategy\StrategiesList.mqh>

input int period_search_mode=12;   //搜素模式的大周期
input int range_point=500; //模式的最小点数差
input int range_period=4; //模式的最大数据长度

input double open_level1=0.618; //开仓点
input double tp_level1=0.882; //止盈平仓点
input double sl_level1=-0.618; //止损平仓点
input double open_lots1=0.1; //开仓手数

input double open_level2=0.5; //开仓点
input double tp_level2=0.786; //止盈平仓点
input double sl_level2=-1.0; //止损平仓点
input double open_lots2=0.2; //开仓手数

input double open_level3=0.382; //开仓点
input double tp_level3=0.5; //止盈平仓点
input double sl_level3=-1.0; //止损平仓点
input double open_lots3=0.4; //开仓手数
//string symbols[]={"XAUUSD","GBPUSD","EURUSD","USDJPY","USDCHF","XTIUSD","AUDUSD","USDCAD","NZDUSD","GBPNZD"};
string symbols[]={"GBPUSD","EURUSD","USDJPY","USDCHF","AUDUSD","USDCAD","NZDUSD"};
//string symbols[]={"GBPUSD"};

CStrategyList Manager;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   FibonacciRatioStrategy *strategy1[];
   FibonacciRatioStrategy *strategy2[];
   FibonacciRatioStrategy *strategy3[];
  int num_symbol=ArraySize(symbols);
   ArrayResize(strategy1,num_symbol);
   ArrayResize(strategy2,num_symbol);
   ArrayResize(strategy3,num_symbol);
   for(int i=0;i<num_symbol;i++)
     {
      ENUM_TIMEFRAMES period=_Period;
      string symbol=symbols[i];
      strategy1[i]=new FibonacciRatioStrategy();
      strategy1[i].ExpertMagic(10+i);
      strategy1[i].Timeframe(period);
      strategy1[i].ExpertSymbol(symbol);
      strategy1[i].ExpertName("Fibonacci Ratio Strategy");
      strategy1[i].SetPatternParameter(period_search_mode,range_period,range_point);
      strategy1[i].SetOpenRatio(open_level1);
      strategy1[i].SetCloseRatio(tp_level1,sl_level1);
      strategy1[i].SetLots(open_lots1);
      strategy1[i].SetEventDetect(symbol,period);
      
      strategy2[i]=new FibonacciRatioStrategy();
      strategy2[i].ExpertMagic(20+i);
      strategy2[i].Timeframe(period);
      strategy2[i].ExpertSymbol(symbol);
      strategy2[i].ExpertName("Fibonacci Ratio Strategy");
      strategy2[i].SetPatternParameter(period_search_mode,range_period,range_point);
      strategy2[i].SetOpenRatio(open_level2);
      strategy2[i].SetCloseRatio(tp_level2,sl_level2);
      strategy2[i].SetLots(open_lots2);
      strategy2[i].SetEventDetect(symbol,period);
      
      strategy3[i]=new FibonacciRatioStrategy();
      strategy3[i].ExpertMagic(30+i);
      strategy3[i].Timeframe(period);
      strategy3[i].ExpertSymbol(symbol);
      strategy3[i].ExpertName("Fibonacci Ratio Strategy");
      strategy3[i].SetPatternParameter(period_search_mode,range_period,range_point);
      strategy3[i].SetOpenRatio(open_level3);
      strategy3[i].SetCloseRatio(tp_level3,sl_level3);
      strategy3[i].SetLots(open_lots3);
      strategy3[i].SetEventDetect(symbol,period);
   
      Manager.AddStrategy(strategy1[i]);
      Manager.AddStrategy(strategy2[i]);
      Manager.AddStrategy(strategy3[i]);

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
