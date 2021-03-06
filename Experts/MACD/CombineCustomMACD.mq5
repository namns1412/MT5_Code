//+------------------------------------------------------------------+
//|                                            CombineCustomMACD.mq5 |
//|                                      Copyright 2017,Daixiaorong. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,Daixiaorong."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <Strategy\Samples\CustomMACD.mqh>

input ENUM_TIMEFRAMES time_frame=PERIOD_M1;
input double price_diverge=0.005; //价格偏离阀值
input double ind_diverge=0.005;   //指标偏离阀值
input int takeprofit=100;         //止盈点数
input int stoploss=100;           //止损点数
input double inp_lot=1.00;           //手数
input bool inp_every_tick=true;    //每个Tick是否检查出场条件
input int long_in_pattern=3;        //多单进场模式
input int long_out_pattern=1;       //多单出场模式
input int short_in_pattern=3;       //空单进场模式
input int short_out_pattern=1;      //空单出场模式

CStrategyList Manager;
ENUM_TIMEFRAMES period_array[]={PERIOD_M1,PERIOD_M2,PERIOD_M5,PERIOD_M20,PERIOD_M30,PERIOD_H1};
//+------------------------------------------------------------------+
//| 组合最优周期和最优品种的MACD策略                                 |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   for(int i=0;i<ArraySize(period_array);i++)
     {
      CustomMACD *m_siganl=new CustomMACD();
      m_siganl.ExpertMagic(20170001+i);
      m_siganl.Timeframe(period_array[i]);
      m_siganl.ExpertSymbol(Symbol());
      m_siganl.ExpertName("MACD Strategy"+(string)period_array[i]);
      m_siganl.OrdersCommment("period"+(string)period_array[i]);
      m_siganl.TakeProfit(takeprofit*(i+1));
      m_siganl.StopLoss(stoploss*(i+1));
      m_siganl.EveryTick(inp_every_tick);
      m_siganl.Lots(inp_lot);
      m_siganl.SetPattern(long_in_pattern,long_out_pattern,short_in_pattern,short_out_pattern);
      if(!Manager.AddStrategy(m_siganl))
         delete m_siganl;
     }

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
