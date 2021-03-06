//+------------------------------------------------------------------+
//|                                                    Fibonacci.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <Trade\Trade.mqh>
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
struct PositionStates
  {
   int               open_buy;
   int               open_sell;
   int               open_total;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OpenSignal
  {
   OPEN_BUY_SIGNAL,
   OPEN_SELL_SIGNAL,
   OPEN_NULL_SIGNAL
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class FibonacciRatioStrategy:public CStrategy
  {
protected:
   int               num_pattern_recognize; //模式识别需要的周期
   int               num_pattern_max;//模式允许的最大周期
   int               point_range;//模式允许的最小点差

   double            open_ratio;//入场的Fibonacci比例
   double            tp_ratio;//止盈的Fibonacci比例
   double            sl_ratio;//止损的Fibonacci比例
   double            lots;//下单手数

   MqlTick           latest_price;//当前的tick报价

   double            max_price,min_price;
   OpenSignal        open_signal;//模式是否存在
   double            open_price;//用于开仓的比较价格
   double            tp_price;//用于止盈的价格
   double            sl_price;//用于止损的价格

   bool              IsTrackEvents(const MarketEvent &event);

   PositionStates    p_states;
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   //virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   //virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      IsTrackEvents();

public:
                     FibonacciRatioStrategy(void){};
                    ~FibonacciRatioStrategy(void){};
   void  SetOpenRatio(double o_ratio) {open_ratio=o_ratio;}
   void  SetCloseRatio(double take_profit_ratio,double stop_loss_ratio){tp_ratio=take_profit_ratio;sl_ratio=stop_loss_ratio;}
   void  SetLots(double l){lots=l;}
   void  SetPatternParameter(int num_for_recognize_pattern,int num_of_pattern,int point_range_of_pattern)
     {
      num_pattern_recognize=num_for_recognize_pattern;
      num_pattern_max=num_of_pattern;
      point_range=point_range_of_pattern;
     }
   void              SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame);
   void              GetPositionStates(PositionStates &states);   //获取当前仓位信息
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FibonacciRatioStrategy::SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame)
  {
   AddBarOpenEvent(symbol,time_frame);
   AddTickEvent(symbol);
  }
//+------------------------------------------------------------------+
//|新BAR形成后要进行模式的识别，如果模式存在同时计算开仓的价格和止盈止损价格                                                       |
//+------------------------------------------------------------------+
void FibonacciRatioStrategy::OnEvent(const MarketEvent &event)
  {
//新BAR形成且空仓需要进行模式识别
   if(event.symbol==ExpertSymbol()&&event.type==MARKET_EVENT_BAR_OPEN && (p_states.open_buy==0 || p_states.open_sell==0))
     {
      //计算最高最低价及对应的位置
      double high[],low[];
      int max_loc,min_loc;

      ArrayResize(high,num_pattern_recognize);
      ArrayResize(low,num_pattern_recognize);
      CopyHigh(ExpertSymbol(),Timeframe(),0,num_pattern_recognize,high);
      CopyLow(ExpertSymbol(),Timeframe(),0,num_pattern_recognize,low);

      max_loc=ArrayMaximum(high);
      min_loc=ArrayMinimum(low);

      max_price=high[max_loc];
      min_price=low[min_loc];

      //最高最低价必须超过给定价格差并且两个极值价格间的Bar数必须小于给定的模式最大长度
      if(max_price-min_price>=point_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT) && max_price-min_price<=5*point_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT) && MathAbs(max_loc-min_loc)<=num_pattern_max)
        {
         if(max_loc>min_loc)
           {
            open_signal=OPEN_BUY_SIGNAL;
            open_price=open_ratio*(max_price-min_price)+min_price;
            tp_price=NormalizeDouble(tp_ratio*(max_price-min_price)+min_price,SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS));
            sl_price=NormalizeDouble(sl_ratio*(max_price-min_price)+min_price,SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS));
           }
         if(max_loc<min_loc)
           {
            open_signal=OPEN_SELL_SIGNAL;
            open_price=max_price-open_ratio*(max_price-min_price);
            tp_price=NormalizeDouble(max_price-tp_ratio*(max_price-min_price),SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS));
            sl_price=NormalizeDouble(max_price-sl_ratio*(max_price-min_price),SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS));
           }
        }
      else open_signal=OPEN_NULL_SIGNAL;
     }
//tick事件发生时，需要进行最新价格获取，仓位信息的获取(用于后续可能的开仓)
   if(event.type==MARKET_EVENT_TICK && event.symbol==ExpertSymbol())
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      GetPositionStates(p_states);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FibonacciRatioStrategy::GetPositionStates(PositionStates &states)
  {
   states.open_buy=0;
   states.open_sell=0;
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) states.open_buy++;
      else states.open_sell++;
      states.open_total++;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FibonacciRatioStrategy::InitBuy(const MarketEvent &event)
  {
   if(!IsTrackEvents(event)) return;//不是指定的事件发生不开仓
   if(p_states.open_buy>0) return;//只能允许一个仓位
   if(open_signal==OPEN_BUY_SIGNAL && latest_price.ask<open_price)
     {
      
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots,latest_price.ask,sl_price,tp_price,"Buy");
      open_signal=OPEN_NULL_SIGNAL;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FibonacciRatioStrategy::InitSell(const MarketEvent &event)
  {
   //if(true) return;
   if(!IsTrackEvents(event)) return;
   if(p_states.open_sell>0) return;
   if(open_signal==OPEN_SELL_SIGNAL && latest_price.bid>open_price)
     {
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots,latest_price.bid,sl_price,tp_price,"sell");
      open_signal=OPEN_NULL_SIGNAL;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FibonacciRatioStrategy::IsTrackEvents(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_TICK) return false;
   if(event.symbol!=ExpertSymbol()) return false;
   return true;
  }
//+------------------------------------------------------------------+
