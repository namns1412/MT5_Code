//+------------------------------------------------------------------+
//|                                               SimpleDoubleMA.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>

class CSimpleDoubleMA:public CStrategy
   {
private:
   int period_ma_long;
   int period_ma_short;
   int handle_ma_long;
   int handle_ma_short;
   double ma_long[];
   double ma_short[];
   MqlTick latest_price;
   double order_lots;
protected:
   virtual void      OnEvent(const MarketEvent &event);
public:
   CSimpleDoubleMA(void){};
   ~CSimpleDoubleMA(void){};
   void InitStrategy(int ma_long,int ma_short);
   void SetEventDetect(string symbol, ENUM_TIMEFRAMES time_frames);
   };
void CSimpleDoubleMA::InitStrategy(int tau_ma_long,int tau_ma_short)
   {
    period_ma_long=tau_ma_long;
    period_ma_short=tau_ma_short;
    handle_ma_long=iMA(ExpertSymbol(),Timeframe(),period_ma_long,0,MODE_SMA,PRICE_CLOSE);
    handle_ma_short=iMA(ExpertSymbol(),Timeframe(),period_ma_short,0,MODE_SMA,PRICE_CLOSE);
    order_lots=0.1;
   }
void CSimpleDoubleMA::SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frames)
   {
   AddBarOpenEvent(symbol,time_frames);
   AddTickEvent(symbol);
   }
void CSimpleDoubleMA::OnEvent(const MarketEvent &event)
   {
    // 品种的tick事件发生时候的处理
    if(event.symbol==ExpertSymbol()&&event.type==MARKET_EVENT_TICK)
      {
       CopyBuffer(handle_ma_long,0,0,2,ma_long);
       CopyBuffer(handle_ma_short,0,0,2,ma_short);
       bool short_condition=ma_short[0]>ma_long[0]&&ma_short[1]<ma_long[1];
       bool long_condition=ma_short[0]<ma_long[0]&&ma_short[1]>ma_long[1];
       SymbolInfoTick(ExpertSymbol(),latest_price);
       for(int i=0;i<ActivePositions.Total();i++)
         {
          CPosition *cpos=ActivePositions.At(i);
          if(cpos.ExpertMagic()!=ExpertMagic())continue;
          if(cpos.Symbol() != ExpertSymbol())continue;
          
          if(cpos.Direction()==POSITION_TYPE_BUY&&short_condition)
             Trade.PositionClose(cpos.ID(),-1,"Close");
          if(cpos.Direction()==POSITION_TYPE_SELL&&long_condition)
             Trade.PositionClose(cpos.ID(),-1,"Close");
         }
      }
     //---品种的BAR事件发生时候的处理
     if(event.symbol==ExpertSymbol()&&event.period==Timeframe()&&event.type==MARKET_EVENT_BAR_OPEN)
       {
        CopyBuffer(handle_ma_long,0,0,2,ma_long);
       CopyBuffer(handle_ma_short,0,0,2,ma_short);
       bool short_condition=ma_short[0]>ma_long[0]&&ma_short[1]<ma_long[1];
       bool long_condition=ma_short[0]<ma_long[0]&&ma_short[1]>ma_long[1];
       if(positions.open_buy==0&&long_condition)
          Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,order_lots,latest_price.ask,0,0,"buy MA");
        if(positions.open_sell==0&&short_condition)
          Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,order_lots,latest_price.bid,0,0,"sell MA");
       }
   }   