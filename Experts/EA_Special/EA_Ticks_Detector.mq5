//+------------------------------------------------------------------+
//|                                            EA_Ticks_Detector.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Files\FilePipe.mqh>

input string pipe_tick="pipe_tick1";

string symbols[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
CFilePipe  PipeTick;
MqlTick tick;
int ask;
int bid;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
// 建立品种tick事件的监控
   for(int i=0;i<ArraySize(symbols);i++)
     {
      if(iCustom(symbols[i],PERIOD_M1,"iSpy",ChartID(),i)==INVALID_HANDLE)
        {
         Print("Error in setting of spy on ",symbols[i]);
         return(INIT_FAILED);
        }
     }
// 连接tick数据传输的管道
   if(PipeTick.Open("\\\\REN\\pipe\\"+pipe_tick,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!PipeTick.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      Print("成功与服务器tick数据传输管道连接成功！");   
      return(INIT_SUCCEEDED);
     }
   if(PipeTick.Open("\\\\.\\pipe\\"+pipe_tick,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!PipeTick.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      Print("成功与服务器tick数据传输管道连接成功！");  
      return(INIT_SUCCEEDED);
     }
   Print("与服务器tick数据传输管道连接失败！");  
//---
   return(INIT_FAILED);

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

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {  
   if(id<=CHARTEVENT_CUSTOM) return;
   int index=id-CHARTEVENT_CUSTOM;
   switch(index)
     {
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
//      tick事件触发，读取对应品种的tick数据
         SymbolInfoTick(symbols[index-1],tick);
         ask=tick.ask/SymbolInfoDouble(symbols[index-1],SYMBOL_POINT);
         bid=tick.bid/SymbolInfoDouble(symbols[index-1],SYMBOL_POINT);
         //Print(TimeToString(TimeCurrent(),TIME_SECONDS)," -> id=",
         //      index,":  ",sparam," "," ask=",ask," bid=",bid);
//       发送数据至服务器
         PipeTick.WriteInteger(index-1);
         PipeTick.WriteInteger(ask);
         PipeTick.WriteInteger(bid);
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
