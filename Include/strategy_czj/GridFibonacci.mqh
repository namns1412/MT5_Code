//+------------------------------------------------------------------+
//|                                                GridFibonacci.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"

#include <Strategy\Strategy.mqh>

class CGridFibonacciStrategy:public CStrategy
  {
private:
   int               open_points;//用于开仓的偏离基准价格点数
   int               win_points;//用于止盈的偏离基准价格点数
   int               position_max;//允许的最大仓位数
   double            init_lots;//初始的仓位大小

   double            base_price;//基准价格
   int               open_num;//记录已经开仓的次数
                              //PositionStates pos_state;//记录仓位的情况
   MqlTick           latest_price;//最新的tick报价
   bool              close_condition;//记录平仓条件
   int               last_position_direction;//记录最后一次的仓位方向
   double tp_buy;
   double tp_sell;

public:
                     CGridFibonacciStrategy(void);
                    ~CGridFibonacciStrategy(void){};
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   void              SupportBuyAndSell();
   void  ModifyTPLevel();
   virtual void      OnEvent(const MarketEvent &event);
   void              SetEventDetect(string symbol);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridFibonacciStrategy::CGridFibonacciStrategy(void)
  {
   open_points=50;
   win_points=300;
   position_max=20;
   init_lots=0.01;
   SymbolInfoTick(ExpertSymbol(),latest_price);
   base_price=latest_price.bid;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridFibonacciStrategy::InitBuy(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_TICK && event.symbol!=ExpertSymbol()) return;
   if(positions.open_total>=position_max) return;
   if(positions.open_total==0)//空仓的情况
     {
      if(latest_price.ask>base_price+open_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,init_lots,latest_price.ask,0,0,"open buy level-1");
         last_position_direction=1;
         ModifyTPLevel();
         Print("Empty position in init buy:",last_position_direction);
        }

     }
   if(last_position_direction==-1)//上次是卖仓
     {
      if(latest_price.ask>base_price+open_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
        {
         double fi=1/MathSqrt(5)*(MathPow((1+MathSqrt(5))/2,positions.open_total+2)-MathPow((1-MathSqrt(5))/2,positions.open_total+2));
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,init_lots*fi,latest_price.ask,0,0,"open buy level-"+(positions.open_total+1));
         last_position_direction=1;
         ModifyTPLevel();
         Print("Last is sell position in init buy:",last_position_direction);
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridFibonacciStrategy::InitSell(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_TICK && event.symbol!=ExpertSymbol()) return;
   if(positions.open_total>=position_max) return;
   if(positions.open_total==0)//空仓的情况
     {
      if(latest_price.bid<base_price-open_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,init_lots,latest_price.bid,0,0,"open sell level-1");
         last_position_direction=-1;
         //ModifyTPLevel();
         Print("Empty position in init sell:",last_position_direction);
         //return;
        }

     }
   if(last_position_direction==1)//上一次是买仓
     {
      if(latest_price.bid<base_price-open_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
        {
         double fi=1/MathSqrt(5)*(MathPow((1+MathSqrt(5))/2,positions.open_total+2)-MathPow((1-MathSqrt(5))/2,positions.open_total+2));
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,init_lots*fi,latest_price.bid,0,0,"open sell level-"+(positions.open_total+1));
         last_position_direction=-1;
         //ModifyTPLevel();
         Print("last is buy position in init sell:",last_position_direction);
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridFibonacciStrategy::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      if(last_position_direction==1)
         close_condition=latest_price.bid>base_price+win_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)?true:false;
      else
         close_condition=latest_price.ask<base_price-win_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)?true:false;
      if(close_condition)
        {
         base_price=latest_price.bid;
         SupportBuyAndSell();
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridFibonacciStrategy::SetEventDetect(string symbol)
  {
   AddTickEvent(_Symbol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridFibonacciStrategy::SupportBuyAndSell(void)
  {
   for(int i=ActivePositions.Total()-1; i>=0; i--)
     {
      CPosition *pos=ActivePositions.At(i);
      if(pos.ExpertMagic()!=ExpertMagic())continue;
      if(pos.Symbol()!=ExpertSymbol())continue;
      Trade.PositionClose(pos.ID());
      //pos.CloseAtMarket();
     }
  }
void CGridFibonacciStrategy::ModifyTPLevel(void)
   {
   
   tp_buy=base_price+win_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   tp_sell=base_price-win_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   double tp_price = last_position_direction==1?tp_buy:tp_sell;
    for(int i=ActivePositions.Total()-1; i>=0; i--)
     {
      CPosition *pos=ActivePositions.At(i);
      if(pos.ExpertMagic()!=ExpertMagic())continue;
      if(pos.Symbol()!=ExpertSymbol())continue;
      Print("modify position", tp_price);
      Trade.PositionModify(pos.ID(),0,tp_price);
     }
   }
//+------------------------------------------------------------------+
