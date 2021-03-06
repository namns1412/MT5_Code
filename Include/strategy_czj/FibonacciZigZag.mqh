//+------------------------------------------------------------------+
//|                                              FibonacciZigZag.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
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
class FibonacciZigZagStrategy:public CStrategy
  {
protected:
   //---用于识别模式的参数
   int               handle_zigzag;//zigzag句柄
   int               num_zigzag;//波幅数量
   int               point_range;//波幅点差
   //---用于进出场的参数
   double            open_ratio;//入场的Fibonacci比例
   double            tp_ratio;//止盈的Fibonacci比例
   double            sl_ratio;//止损的Fibonacci比例
   double            lots;//下单手数

   //---中间变量
   MqlTick           latest_price;//当前的tick报价

   bool              pattern_exist;//模式是否存在
   double            max_price,min_price;
   double            pre_max_price,pre_min_price;
   bool              pattern_used;
   OpenSignal        open_signal;//模式是否存在
   double            open_price;//用于开仓的比较价格
   double            tp_price;//用于止盈的价格
   double            sl_price;//用于止损的价格
   PositionStates    p_states;

   bool              IsTrackEvents(const MarketEvent &event);

   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      IsTrackEvents();

public:
                     FibonacciZigZagStrategy(void){};
                    ~FibonacciZigZagStrategy(void){};
   //策略参数初始化--默认方式
   void              InitStrategy(void);
   //策略参数初始化--用户给定
   void              InitStrategy(int handle_zz,int num_zz,int p_range_min,double open_position_ratio,double take_profit_ratio,double stop_loss_ratio,double open_lots);
   //监控事件定义
   void              SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame);
   //仓位信息更新
   void              GetPositionStates(PositionStates &states);   //获取当前仓位信息
                                                                  //模式有效性判断
   virtual void      pattern_is_valid(const double &zigzags[]);
   virtual void      pattern_is_valid2(const double &zigzags[]);
   virtual void      pattern_is_valid3(const double &zigzags[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FibonacciZigZagStrategy::InitStrategy(void)
  {
   handle_zigzag=iCustom(ExpertSymbol(),Timeframe(),"Examples\\ZigZag");
   num_zigzag=3;
   point_range=500;
   open_ratio=0.618;
   tp_ratio=0.882;
   sl_ratio=-1;
   lots=0.1;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FibonacciZigZagStrategy::InitStrategy(int handle_zz,int num_zz,int p_range_min,double open_position_ratio,double take_profit_ratio,double stop_loss_ratio,double open_lots)
  {
   handle_zigzag=handle_zz;
   num_zigzag=num_zz;
   point_range=p_range_min;
   open_ratio=open_position_ratio;
   tp_ratio=take_profit_ratio;
   sl_ratio=stop_loss_ratio;
   lots=open_lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FibonacciZigZagStrategy::SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame)
  {
   AddBarOpenEvent(symbol,time_frame);
   AddTickEvent(symbol);
  }
//+------------------------------------------------------------------+
//|新BAR形成后要进行模式的识别，如果模式存在同时计算开仓的价格和止盈止损价格                                                       |
//+------------------------------------------------------------------+
void FibonacciZigZagStrategy::OnEvent(const MarketEvent &event)
  {
//新BAR形成且空仓需要进行模式识别
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      //复制zigzag指标数值--并取得极值点
      double zigzag_value[600];
      double extreme_value[];
      int counter=0;
      CopyBuffer(handle_zigzag,0,0,600,zigzag_value);
      for(int i=ArraySize(zigzag_value)-2;i>=0;i--)
        {
         if(zigzag_value[i]==0) continue;//过滤为0的值
         if(counter==num_zigzag) break;//极值数量达到给定的值不再取值
         counter++;
         ArrayResize(extreme_value,counter);
         extreme_value[counter-1]=zigzag_value[i];
        }
      //确定模式是否存在
      //pattern_is_valid(extreme_value);
      pattern_is_valid2(extreme_value);
      pattern_is_valid3(extreme_value);
      if(pattern_exist)
        {
         if(open_signal==OPEN_BUY_SIGNAL)
           {
            open_price=min_price+open_ratio*(max_price-min_price);
            tp_price=min_price+tp_ratio*(max_price-min_price);
            sl_price=min_price+sl_ratio*(max_price-min_price);
           }
         else
           {
            open_price=max_price-open_ratio*(max_price-min_price);
            tp_price=max_price-tp_ratio*(max_price-min_price);
            sl_price=max_price-sl_ratio*(max_price-min_price);
           }
        }
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
void FibonacciZigZagStrategy::pattern_is_valid(const double &zigzags[])
  {
   if(ArraySize(zigzags)<3)
     {
      pattern_exist=false;
      return;
     }
   double range1=zigzags[0]-zigzags[1];
   double range2=zigzags[1]-zigzags[2];
   int max_loc=ArrayMaximum(zigzags);
   int min_loc=ArrayMinimum(zigzags);
   double range=zigzags[max_loc]-zigzags[min_loc];

//最新的两个zigzag满足点差--则以最新的两个作为Fibonacci回撤计算的基准
   if(MathAbs(range1)>point_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
     {
      pattern_exist=true;
      if(range1<0)
        {
         open_signal=OPEN_SELL_SIGNAL;
         max_price=zigzags[1];
         min_price=zigzags[0];
        }
      else
        {
         open_signal=OPEN_BUY_SIGNAL;
         max_price=zigzags[0];
         min_price=zigzags[1];
        }
     }
//第二个和第三个zigzag满足点差--则以这两个zigzag作为Fibonacci回撤计算的基准
   else if(MathAbs(range2)>point_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
     {
      pattern_exist=true;
      if(range2<0)
        {
         open_signal=OPEN_SELL_SIGNAL;
         max_price=zigzags[2];
         min_price=zigzags[1];
        }
      else
        {
         open_signal=OPEN_BUY_SIGNAL;
         max_price=zigzags[1];
         min_price=zigzags[2];
        }
     }
//其他情况，不存在模式
   else
     {
      open_signal=OPEN_NULL_SIGNAL;
     }
//过滤一些大趋势下的反向小趋势的回撤情形
//if(range>1.1*MathMax(MathAbs(range1),MathAbs(range2)))
//   {
//    pattern_exist=false;
//   }
//如果前面判断的模式存在，还需要判断是否之前已经使用过该模式
   if(max_price!=pre_max_price || min_price!=pre_min_price)
     {
      pattern_used=false;
     }
   pre_max_price=max_price;
   pre_min_price=min_price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FibonacciZigZagStrategy::pattern_is_valid2(const double &zigzags[])
  {
   if(ArraySize(zigzags)<5)
     {
      pattern_exist=false;
      return;
     }
   bool buy_condition=zigzags[0]-zigzags[1]>point_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT) && zigzags[0]>zigzags[2] && zigzags[1]>zigzags[3];
   bool sell_condition=zigzags[1]-zigzags[0]>point_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT) && zigzags[0]<zigzags[2] && zigzags[1]<zigzags[3];
   if(buy_condition)
     {
      pattern_exist=true;
      open_signal=OPEN_BUY_SIGNAL;
      max_price=zigzags[0];
      min_price=zigzags[1];
     }
   else if(sell_condition)
     {
      pattern_exist=true;
      open_signal=OPEN_SELL_SIGNAL;
      max_price=zigzags[1];
      min_price=zigzags[0];
     }
   else
     {
      open_signal=OPEN_NULL_SIGNAL;
     }
//如果前面判断的模式存在，还需要判断是否之前已经使用过该模式
   if(max_price!=pre_max_price || min_price!=pre_min_price)
     {
      pattern_used=false;
     }
   pre_max_price=max_price;
   pre_min_price=min_price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FibonacciZigZagStrategy::pattern_is_valid3(const double &zigzags[])
  {
   if(ArraySize(zigzags)<5)
     {
      pattern_exist=false;
      return;
     }
   int maxloc=ArrayMaximum(zigzags);
   int minloc=ArrayMinimum(zigzags);

   bool buy_condition=maxloc<minloc && zigzags[maxloc]-zigzags[minloc]>point_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   bool sell_condition=maxloc>minloc && zigzags[maxloc]-zigzags[minloc]>point_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   if(buy_condition)
     {
      pattern_exist=true;
      open_signal=OPEN_BUY_SIGNAL;
      max_price=zigzags[maxloc];
      min_price=zigzags[minloc];
     }
   else if(sell_condition)
     {
      pattern_exist=true;
      open_signal=OPEN_SELL_SIGNAL;
      max_price=zigzags[maxloc];
      min_price=zigzags[minloc];
     }
   else
     {
      open_signal=OPEN_NULL_SIGNAL;
     }
//如果前面判断的模式存在，还需要判断是否之前已经使用过该模式
   if(max_price!=pre_max_price || min_price!=pre_min_price)
     {
      pattern_used=false;
     }
   pre_max_price=max_price;
   pre_min_price=min_price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FibonacciZigZagStrategy::GetPositionStates(PositionStates &states)
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
void FibonacciZigZagStrategy::InitBuy(const MarketEvent &event)
  {
   if(!IsTrackEvents(event)) return;//不是指定的事件发生不开仓
   if(p_states.open_buy>10) return;//只能允许一个仓位
   if(open_signal==OPEN_BUY_SIGNAL && latest_price.ask<open_price && !pattern_used)
     {
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots,latest_price.ask,sl_price,tp_price,"Buy"+string(pattern_used));
      open_signal=OPEN_NULL_SIGNAL;
      pattern_used=true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FibonacciZigZagStrategy::InitSell(const MarketEvent &event)
  {
//if(true) return;
   if(!IsTrackEvents(event)) return;
   if(p_states.open_sell>10) return;
   if(open_signal==OPEN_SELL_SIGNAL && latest_price.bid>open_price && !pattern_used)
     {
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots,latest_price.bid,sl_price,tp_price,"sell"+string(pattern_used));
      open_signal=OPEN_NULL_SIGNAL;
      pattern_used=true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FibonacciZigZagStrategy::IsTrackEvents(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_TICK) return false;
   if(event.symbol!=ExpertSymbol()) return false;
   return true;
  }
//+------------------------------------------------------------------+
