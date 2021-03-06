//+------------------------------------------------------------------+
//|                                                 GridAddTrend.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <strategy_czj\common\strategy_common.mqh>
#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridAddTrend:public CStrategy
  {
private:
   int               points_add;
   double            profits_win;
   double            base_price;
   double            up_price;
   double            down_price;
   int               num_position;
   int               last_direction;
   MqlTick           latest_price;
   double            init_lots;
   PositionInfor     pos_state;
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CloseAllPosition();
   virtual bool      CloseCondition();
   void              RefreshPositionState(void);
public:
                     CGridAddTrend(void);
                    ~CGridAddTrend(void){};
   void              InitStrategy(int points=100,double win_profits=100,double lots_begin=0.01);
   void              SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame);
   double            CalLots();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGridAddTrend::CGridAddTrend(void)
  {
   points_add=100;
   init_lots=0.01;
   profits_win=100;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridAddTrend::InitStrategy(int points=100,double win_profits=100,double lots_begin=0.01)
  {
   points_add=points;
   profits_win=win_profits;
   init_lots=lots_begin;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridAddTrend::OnEvent(const MarketEvent &event)
  {
// 品种的tick事件发生时候的处理

   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      //      判断是否需要进行平仓的操作
      if(CloseCondition()) CloseAllPosition();
      //      首次开仓的情况
      if(positions.open_total==0)
        {

         base_price=latest_price.ask-points_add*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         up_price=base_price+points_add*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         down_price=base_price-points_add*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         double current_lots=CalLots();
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,current_lots,latest_price.ask,0,0);
         last_direction=1;
        }
      //       加仓的情况
      else
        {
         //         上一次是买的情况
         if(last_direction==1 && latest_price.bid<down_price)
           {
            double current_lots=CalLots();
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,current_lots,latest_price.bid,0,0);
            last_direction=0;
           }
         //         上一次是卖的情况
         if(last_direction==0 && latest_price.ask>up_price)
           {
            double current_lots=CalLots();
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,current_lots,latest_price.ask,0,0);
            last_direction=1;
           }
        }

     }
//---品种的BAR事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.period==Timeframe() && event.type==MARKET_EVENT_BAR_OPEN)
     {
     }

  }
bool CGridAddTrend::CloseCondition(void)
   {
    RefreshPositionState();
    if((pos_state.lots_buy+pos_state.lots_sell)==0) return false;
    if((pos_state.profits_buy+pos_state.profits_sell)/(pos_state.lots_buy+pos_state.lots_sell)>profits_win)
      {
       return true;
      }
    return false;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridAddTrend::CloseAllPosition(void)
  {
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==ExpertSymbol())
         Trade.PositionClose(cpos.ID());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridAddTrend::SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame)
  {
   AddBarOpenEvent(symbol,time_frame);
   AddTickEvent(symbol);
  }
double CGridAddTrend::CalLots(void)
   {
    //return (1/sqrt(5)*(MathPow((1+sqrt(5))/2,positions.open_total+2)-MathPow((1-sqrt(5))/2,positions.open_total+2)))*init_lots;
    //return (positions.open_total+1)*init_lots;
    return (positions.open_total+2)*init_lots;
   }
void CGridAddTrend::RefreshPositionState(void)
  {
   pos_state.Init();
//计算buy总盈利、buy总手数，sell总盈利，sell总手数
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()!=ExpertSymbol())continue;
      if(cpos.Direction()==POSITION_TYPE_BUY)
        {
         pos_state.profits_buy+=cpos.Profit();
         pos_state.lots_buy+=cpos.Volume();
         pos_state.num_buy+=1;
        }
      if(cpos.Direction()==POSITION_TYPE_SELL)
        {
         pos_state.profits_sell+=cpos.Profit();
         pos_state.lots_sell+=cpos.Volume();
         pos_state.num_sell+=1;
        }
     }
  }
//+------------------------------------------------------------------+
