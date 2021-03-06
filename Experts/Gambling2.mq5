//+------------------------------------------------------------------+
//|                                                 LinerChannel.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>

input int loss_point_add_position=300;
input int win_point=200;
input int EA_Magic=102;
input int type_ratio=1;
input int period_found_extremum=10;
input int extremum_num=20;
input int window_extrem=10;

double last_buy_price;
double last_sell_price;
double support_price[];
double resistence_price[];
CTrade ExtTrade;

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
   check_for_open();
   manage_position();
  }
//+------------------------------------------------------------------+
void manage_position()
   {
    int total_position_num=0, buy_position_num=0, sell_position_num=0;
    double total_profit_buy=0,total_profit_sell=0;
    double total_lots_buy=0,total_lots_sell=0;
    double lots;
    bool buy_need_close=false, sell_need_close=false;
    bool buy_need_add=false, sell_need_add=false;

    MqlTick latest_price;
    if(!SymbolInfoTick(_Symbol,latest_price)) return;

    total_position_num=PositionsTotal();
    //遍历当前所有仓位，分别计算买单和卖单的总盈利和，总仓位数，总手数
    for(int i=0;i<total_position_num;i++)
      {
       PositionGetSymbol(i);
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         {
          buy_position_num++;
          total_profit_buy+=PositionGetDouble(POSITION_PROFIT);
          total_lots_buy+=PositionGetDouble(POSITION_VOLUME);
         }
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         {
          sell_position_num++;
          total_profit_sell+=PositionGetDouble(POSITION_PROFIT);
          total_lots_sell+=PositionGetDouble(POSITION_VOLUME);
         }
      }
     //如果当前多头达到止盈条件则进行平仓：当前持有买仓且平均每手盈利超过给定点数
     buy_need_close=total_lots_buy>0&&total_profit_buy/total_lots_buy>win_point;
     if(buy_need_close)
      {
       for(int i=0;i<total_position_num;i++)
         {
          PositionGetSymbol(i);
          if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            ExtTrade.PositionClose(PositionGetInteger(POSITION_TICKET),3);
         }
        total_lots_buy=0;
        total_profit_buy=0;
        buy_position_num=0;
      }
    //如果当前Short仓位达到止盈条件则进行平仓：当前持有卖仓且每手盈利超过给定点数
    sell_need_close=total_lots_sell>0&&total_profit_sell/total_lots_sell>win_point;
    if(sell_need_close)
      {
       for(int i=0;i<total_position_num;i++)
         {
          PositionGetSymbol(i);
          if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
            ExtTrade.PositionClose(PositionGetInteger(POSITION_TICKET),3);
         }
       total_lots_sell=0;
       total_profit_sell=0;
       sell_position_num=0;
      }
    //多头加仓：当前持有多头&&当前价格跌到
    double price_buy_limit = get_price_support_level(support_price,buy_position_num,loss_point_add_position*_Point);
    buy_need_add=total_lots_buy>0&&(latest_price.ask<price_buy_limit);
    if(buy_need_add)
      {
      lots=new_lots(0.01,buy_position_num, type_ratio);
      ExtTrade.PositionOpen(_Symbol,ORDER_TYPE_BUY,lots,latest_price.ask,0,0,"buy add postion"+string(buy_position_num));
      }
    
    //空头加仓：当前持仓,当前价格涨到新的阻力位
    double price_sell_limit=get_price_resistence_level(resistence_price,sell_position_num,loss_point_add_position*_Point);
    sell_need_add=total_lots_sell>0&&(latest_price.bid>price_sell_limit);
    //if(total_lots_sell>0) Print(latest_price.bid, " ", price_sell_limit);
    if(sell_need_add)
      {
      Print("add sell position");
      lots=new_lots(0.01,sell_position_num,type_ratio);
      ExtTrade.PositionOpen(_Symbol,ORDER_TYPE_SELL,lots,latest_price.bid,0,0,"sell add position"+string(sell_position_num));
      }
   }
double new_lots(const double f1=0.01, const int num=1, const int ratio_type=0)
   {
    //Print("in new_lots:", f1, " ", num, " ", 
    if(ratio_type==0) return f1*1/sqrt(5)*(MathPow((1+sqrt(5))/2,num)-MathPow((1-sqrt(5))/2,num));
    return f1*MathCeil(0.5*exp(0.3382*num));
   }

//---首次开仓判断--空仓则进行开仓
void check_for_open()
   {
    MqlTick latest_price;
    double high[],low[],max_price[],min_price[];
    ArrayResize(high,period_found_extremum);
    ArrayResize(low,period_found_extremum);
    
    
    //获取最新报价失败，返回
    if(!SymbolInfoTick(_Symbol,latest_price)) return;
    //计算当前持仓情况
    int buy_total=0,sell_total=0;
    for(int i=0;i<PositionsTotal();i++)
      {
       PositionGetSymbol(i);
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) buy_total++;
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) sell_total++;
      }
    //未持多头，开多仓，计算支撑位价格序列
    //if(buy_total==0)
    if(false)
      {
      //开多头
      ExtTrade.PositionOpen(_Symbol,ORDER_TYPE_BUY,0.01,latest_price.ask,0,0,"first buy position");
      //last_buy_price=latest_price.ask;
      //计算支撑价格序列:历史最低价格序列->历史极小值序列->满足条件的极小值序列(阈值过滤，降序排列)
      CopyLow(_Symbol,_Period,0,period_found_extremum,low);
      get_extremum_price(low,window_extrem,min_price,"min");    
      extremum_price_filter(min_price,latest_price.ask,loss_point_add_position*_Point,support_price,"min");
      }
    //未持空头，开空头，计算阻力位价格序列
    if(sell_total==0)
      {
       ExtTrade.PositionOpen(_Symbol,ORDER_TYPE_SELL,0.01,latest_price.bid,0,0,"first sell position");
       //last_buy_price=latest_price.bid;
       //计算支撑价格序列:历史最高价格序列->历史极大值序列->满足条件的极大值序列(阈值过滤，升序排列)
       datetime dt[];
       CopyTime(_Symbol,_Period,0,period_found_extremum,dt);
       CopyHigh(_Symbol,_Period,0,period_found_extremum,high);
       Print(_Period==PERIOD_M1, "***high: first-",dt[period_found_extremum-1], ":", high[period_found_extremum-1], " last-", dt[0], ":",  high[0], " test:",Bars(_Symbol, _Period, dt[0],dt[period_found_extremum-1]));
       get_extremum_price(high,window_extrem,max_price,"max");
       Print("***extreme before filter: first-", max_price[0], " last-", max_price[ArraySize(max_price)-1]);
       extremum_price_filter(max_price,latest_price.bid,loss_point_add_position*_Point,resistence_price,"max");
       Print("check for open: first-", resistence_price[0], " last-", resistence_price[ArraySize(resistence_price)-1]);
       //for(int i=0;i<ArraySize(max_price);i++)
       //  Print(max_price[i]);
      }   
   }

//计算给定价格序列的极值点(极大值或极小值)
int get_extremum_price(const double& price[], const int window, double& extrem_price[],const string type_extremum="max")
   {
    int counter=0;
    ArrayResize(extrem_price,1,100);
    for(int i=window;i<ArraySize(price)-window;i++)
      {
       bool is_extrem=true;
       for(int j=i-window;j<i+window;j++)
         {
          if((type_extremum=="max"&&price[i]<price[j])||(type_extremum=="min"&&price[i]>price[j]))
            {
             is_extrem=false;
             break;
            }
         }
       if(is_extrem)
         {
          ArrayResize(extrem_price,counter+1);
          extrem_price[counter]=price[i];
          counter++;
         }   
      }
    return ArraySize(extrem_price);
   }
// 极值点序列过滤：选择超过给定阈值，过滤相邻价位较小的价格序列
int extremum_price_filter(const double& source_extremum_price[],const double base_price,const double depth, double& target_extremum_price[], const string type_extremum="max")
   {
    int counter=0;
    double sort_price[];
    //排序:极大值按照升序排序，极小值按照降序排序
    ArrayResize(sort_price,ArraySize(source_extremum_price));
    ArrayCopy(sort_price,source_extremum_price);
    ArraySort(sort_price);
    if(type_extremum=="max")
      {
       ArraySetAsSeries(sort_price,false);
       Print("sort:升序 ", sort_price[0], " ", sort_price[ArraySize(sort_price)-1]);
      }
    else
      {
       ArraySetAsSeries(sort_price,true);   
       Print("sort:降序 ", sort_price[0], " ", sort_price[ArraySize(sort_price)-1]);
      }
    //阈值过滤：极大值递增加档，极小值递减加档；
    ArrayResize(target_extremum_price,1,100);
    for(int i=0;i<ArraySize(sort_price);i++)
      {
       bool is_valid_price;
       if(counter==0)
         {
          is_valid_price=((type_extremum=="max")&&(source_extremum_price[i]>base_price+depth))||((type_extremum=="min")&&(source_extremum_price[i]<base_price-depth));
          if(is_valid_price)
            {
             ArrayResize(target_extremum_price,counter+1);
             target_extremum_price[counter]=source_extremum_price[i];
             counter++; 
            }
         }
       else
         {
          is_valid_price=((type_extremum=="max")&&(source_extremum_price[i]>target_extremum_price[counter-1]+depth))||((type_extremum=="min")&&(source_extremum_price[i]<target_extremum_price[counter-1]-depth));
          if(source_extremum_price[i]>target_extremum_price[counter-1]+depth)
            {
             ArrayResize(target_extremum_price,counter+1);
             target_extremum_price[counter]=source_extremum_price[i];
             counter++;
            }
         }
      }
    return(ArraySize(target_extremum_price));
   }

//根据支撑价格序列获取给定等级对应的支撑价格(支撑价格序列必须降序排序)
double get_price_support_level(const double& support_ts[], const int level_num, const double step_fixed)
   {
    if(level_num==0) return(0.0);
    int size=ArraySize(support_ts);
    if(level_num<=size) return(support_ts[level_num-1]);
    else return(support_ts[size-1]-(level_num-size)*step_fixed);
   }
//根据阻力价格序列获取给定等级对应的阻力价格(阻力价格序列必须升序排序)
double get_price_resistence_level(const double& resistence_ts[], const int level_num, const double step_fixed)
   {
    if(level_num==0) return(0.0);
    int size=ArraySize(resistence_ts);
    if(level_num<=size) return(resistence_ts[level_num-1]);
    else return(resistence_ts[size-1]+ (level_num-size)*step_fixed);
   }