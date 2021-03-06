//+------------------------------------------------------------------+
//|                                                   DailyTrend.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include<Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
class DailyTrendStrategy:public CStrategy
  {
protected:
   double            high_yestoday[1];
   double            low_yestoday[1];
   double            open_today[1];
   MqlTick           latest_price;
   MqlDateTime       latest_time;
   bool              traded;

   double            k;
   double            size;
   int               sl_point;
   int               tp_point;

   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   //virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   //virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CheckPositionClose(void);
   virtual void      CheckPositionModify(void);
public:
                     DailyTrendStrategy(void){k=0.7;size=0.1;sl_point=300;tp_point=300;}
                     DailyTrendStrategy(const double k_value,const double size_value,const int stop_loss,const int take_profit){k=k_value; size=size_value;sl_point=stop_loss;tp_point=take_profit;}
   void              InitDefaultParameter();//默认初始化策略方法
   void              SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame);//设置需要监控的事件
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DailyTrendStrategy::SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame)
  {
   AddBarOpenEvent(symbol,time_frame);
   AddTickEvent(symbol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DailyTrendStrategy::OnEvent(const MarketEvent &event)
  {
//生成日线BAR数据时记录BAR的最高最低价及今天的开盘价
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN && event.period==PERIOD_D1)
     {
      CopyHigh(ExpertSymbol(),PERIOD_D1,1,1,high_yestoday);
      CopyLow(ExpertSymbol(),PERIOD_D1,1,1,low_yestoday);
      CopyOpen(ExpertSymbol(),PERIOD_D1,0,1,open_today);
      traded=false;
     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      TimeToStruct(latest_price.time,latest_time);
      CheckPositionModify();
      //CheckPositionClose();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DailyTrendStrategy::CheckPositionClose(void)
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=ExpertSymbol()) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      MqlDateTime pos_open_time;
      TimeToStruct(PositionGetInteger(POSITION_TIME),pos_open_time);
      if(latest_time.hour>=23)
        {
         Trade.PositionClose(ticket);
         continue;
        }
      if(PositionGetDouble(POSITION_PROFIT)/PositionGetDouble(POSITION_VOLUME)>300)
        {
         Trade.PositionClose(ticket);
         continue;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DailyTrendStrategy::CheckPositionModify(void)
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=ExpertSymbol()) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      double old_sl=PositionGetDouble(POSITION_SL);
      double new_sl;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         new_sl=latest_price.bid-(sl_point+50)*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         if(new_sl>old_sl)
           {
            if(Trade.PositionModify(ticket,new_sl,0.0))
               Print("Modify success!");
            else
               Trade.PrintRequest();
           }

        }
      else
        {
         new_sl=latest_price.ask+(sl_point+50)*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         if(new_sl<old_sl)
           {
            if(Trade.PositionModify(ticket,new_sl,0.0))
               Print("Modify success!");
            else
               Trade.PrintRequest();
           }
        }
     }

  }
//+------------------------------------------------------------------+
void DailyTrendStrategy::InitBuy(const MarketEvent &event)
  {
   if(traded) return;
   if(latest_time.hour>12) return;
   if(latest_price.ask>open_today[0]+k*(high_yestoday[0]-low_yestoday[0]))
     {
      double sl_value=latest_price.ask-sl_point*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      double tp_value=latest_price.ask+tp_point*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,size,latest_price.ask,sl_value,tp_value);
      traded=true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DailyTrendStrategy::InitSell(const MarketEvent &event)
  {
   if(traded) return;
   if(latest_time.hour>12) return;
   if(latest_price.bid<open_today[0]-k*(high_yestoday[0]-low_yestoday[0]))
     {
      double sl_value=latest_price.bid+sl_point*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      double tp_value=latest_price.bid-tp_point*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,size,latest_price.bid,sl_value,tp_value);
      traded=true;
     }
  }
//void DailyTrendStrategy::SupportBuy(const MarketEvent &event,CPosition *pos)
//   {
//    if(event.symbol!=ExpertSymbol()) return;
//    if(event.type!=MARKET_EVENT_TICK) return;
//    MqlDateTime pos_open_time;
//    TimeToStruct(pos.TimeOpen(),pos_open_time);
//    if(latest_time.hour>=23)
//      {
//       pos.CloseAtMarket("time over");
//      }
//      
//   }
//void DailyTrendStrategy::SupportSell(const MarketEvent &event,CPosition *pos)
//   {
//    if(event.symbol!=ExpertSymbol()) return;
//    if(event.type!=MARKET_EVENT_TICK) return;
//    MqlDateTime pos_open_time;
//    TimeToStruct(pos.TimeOpen(),pos_open_time);
//    if(latest_time.hour>=23)
//      pos.CloseAtMarket("time over");
//   }
