//+------------------------------------------------------------------+
//|                                              czj_Fi_Standard.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

input int period=500;
input int range_point=300;
input int range_period=50;
input int EA_Magic=8881;
input double open_level1=0.618;
input double open_level2=0.5;
input double open_level3=0.382;
input double profit_ratio_level1=0.882;
input double profit_ratio_level2=0.718;
input double profit_ratio_level3=0.618;
input double loss_ratio=-1.0;
input double lots_level1=0.1;
input double lots_level2=0.5;
input double lots_level3=1.0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
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
   check_for_close();
   check_for_open();
   
  }
//+------------------------------------------------------------------+

void check_for_open(void)
   {
   //检查bar数是否足够
   if(Bars(_Symbol,_Period)<period)
      return;
   //变量申明
   double high_price[];
   double low_price[];
   double take_profit=0;
   double stop_loss=0;
   double size=0;
   int max_loc;
   int min_loc;
   double max_price;
   double min_price;
   MqlTick latest_price;
   MqlTradeRequest mrequest;
   MqlTradeResult mresult;
   ZeroMemory(mrequest);
   ZeroMemory(mresult);
   int total_buy=0;
   int total_sell=0;
   int total=0;
   MqlRates rates[];
   datetime times[], max_time_new, min_time_new;
   static datetime max_time,min_time;
   //获取最新报价,历史最高，最低价
   if(!SymbolInfoTick(_Symbol,latest_price)) return;
   //CopyHigh(_Symbol,_Period,0,period,high_price);
   //CopyLow(_Symbol,_Period,0,period,low_price); 
   ArrayResize(high_price,period);
   ArrayResize(low_price,period);
   ArrayResize(times,period);
   int copied=CopyRates(_Symbol,_Period,0,period,rates);
   for(int i=0;i<copied;i++)
      {
      high_price[i]=rates[i].high;
      low_price[i]=rates[i].low;
      times[i]=rates[i].time;
      }
   max_loc = ArrayMaximum(high_price);
   min_loc = ArrayMinimum(low_price);
   max_price = high_price[max_loc];
   min_price = high_price[min_loc]; 
   max_time_new=times[max_loc];
   min_time_new=times[min_loc];
   bool state_change=true;
   
   if(max_time_new==max_time&&min_time_new==min_time)
      {
      state_change=false;   
      }
   else
      {
      Print(state_change);
      max_time=max_time_new;
      min_time=min_time_new;
      Print(max_time_new," ", max_time);
      }   
      
    
   //计算开平仓条件
   bool buy_condition_basic = (max_loc>min_loc)&&(max_loc-min_loc<range_period)&&(max_price-min_price>range_point*_Point);
   bool buy_condition_level1 = latest_price.ask<open_level1*(max_price-min_price)+min_price;
   bool buy_condition_level2 = latest_price.ask<open_level2*(max_price-min_price)+min_price;
   bool buy_condition_level3 = latest_price.ask<open_level3*(max_price-min_price)+min_price;
   
   bool sell_condition_basic = (max_loc<min_loc)&&(min_loc-max_loc<range_period)&&(max_price-min_price>range_point*_Point);
   bool sell_condition_level1 = latest_price.bid>max_price-open_level1*(max_price-min_price);
   bool sell_condition_level2 = latest_price.bid>max_price-open_level2*(max_price-min_price);
   bool sell_condition_level3 = latest_price.bid>max_price-open_level3*(max_price-min_price);
   // 当前仓位情况
   //if(PositionSelect(_Symbol)==true)
   //   {  
   //      total=PositionsTotal();
   //      for(int i=0;i<total;i++)
   //         {  
   //         string position_symbol=PositionGetSymbol(i);
   //         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
   //            total_buy++;
   //         else
   //            total_sell++;   
   //         }
   //   }

   // 买单判断并操作
   if(buy_condition_basic)
      {
      bool order_need_send=false;
      if(buy_condition_level1&&state_change)
         {
         take_profit=profit_ratio_level1*(max_price-min_price)+min_price;
         stop_loss=loss_ratio*(max_price-min_price)+min_price;
         size=lots_level1;
         order_need_send=true;
         }
      if(buy_condition_level2&&state_change)
         {
         take_profit=profit_ratio_level2*(max_price-min_price)+min_price;
         stop_loss=loss_ratio*(max_price-min_price)+min_price;
         size=lots_level2;
         order_need_send=true;
         }
      if(buy_condition_level3&&state_change)
         {
         take_profit=profit_ratio_level3*(max_price-min_price)+min_price;
         stop_loss=loss_ratio*(max_price-min_price)+min_price;
         size=lots_level3;
         order_need_send=true;
         }
      if(order_need_send)
         {
         mrequest.action=TRADE_ACTION_DEAL;
         mrequest.price=NormalizeDouble(latest_price.ask,_Digits);
         mrequest.symbol=_Symbol;
         mrequest.magic=EA_Magic;
         mrequest.type=ORDER_TYPE_BUY;
         mrequest.type_filling=ORDER_FILLING_FOK;
         mrequest.deviation=5;
         mrequest.volume=size;
         mrequest.tp=NormalizeDouble(take_profit,_Digits);
         mrequest.sl=NormalizeDouble(stop_loss, _Digits);
         OrderSend(mrequest, mresult);
         if(mresult.retcode==10009||mresult.retcode==10008)
            Alert("买入订单已经成功下单，订单#:", mresult.order,"!!");
         else
            {
               Alert("买入订单请求无法完成,", GetLastError(), latest_price.ask," ", take_profit," ", stop_loss);
               ResetLastError();
               return;
            } 
         }
      }
   // 卖单判断并操作   
   if(sell_condition_basic)
      {
      bool order_need_send=false;
      if(sell_condition_level1&&state_change)
         {  
         take_profit=max_price-profit_ratio_level1*(max_price-min_price);
         stop_loss=max_price-(loss_ratio)*(max_price-min_price);
         size=lots_level1;
         order_need_send=true;
         }
      if(sell_condition_level2&&state_change)
         {
         take_profit=max_price-profit_ratio_level2*(max_price-min_price);
         stop_loss=max_price-(loss_ratio)*(max_price-min_price);
         size=lots_level2;
         order_need_send=true;
         }
      if(sell_condition_level3&&state_change)
         {
         take_profit=max_price-profit_ratio_level3*(max_price-min_price);
         stop_loss=max_price-(loss_ratio)*(max_price-min_price);
         size=lots_level3;
         order_need_send=true;
         }
      if(order_need_send)
         {
         mrequest.action=TRADE_ACTION_DEAL;
         mrequest.price=NormalizeDouble(latest_price.bid,_Digits);
         mrequest.type=ORDER_TYPE_SELL;
         mrequest.symbol=_Symbol;
         mrequest.magic=EA_Magic;
         mrequest.type_filling=ORDER_FILLING_FOK;
         mrequest.deviation=5;
         mrequest.volume=size;
         mrequest.tp=NormalizeDouble(take_profit,_Digits);
         mrequest.sl=NormalizeDouble(stop_loss, _Digits);
         OrderSend(mrequest, mresult);
         if(mresult.retcode==10009||mresult.retcode==10008)
            Alert("卖出订单已经成功下单，订单#:", mresult.order,"!!");
         else
            {
            Alert("卖出订单请求无法完成,", GetLastError());
            ResetLastError();
            return;
            } 
         }
      }
      
   }
void check_for_close(void)
   {
      if(PositionsTotal()==0) return;
   }   