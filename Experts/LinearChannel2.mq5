//+------------------------------------------------------------------+
//|                                                 LinerChannel.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>

input int min_period=30;
input int max_period=100;
input int EA_Magic=101;

static int last_buy_level=0;
static int last_sell_level=0;
static double last_buy_price;
static double last_sell_price;
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
    int total_size=0, buy_size=0, sell_size=0;
    double total_profit_buy=0,total_profit_sell=0;
    double total_lots_buy=0,total_lots_sell=0;
    double lots;
    double target_win_points=200.0;
    double add_position_loss_points=400.0;

    MqlTick latest_price;
    if(!SymbolInfoTick(_Symbol,latest_price)) return;

    total_size=PositionsTotal();
    //遍历当前所有仓位，分别计算买单和卖单的总盈利和，总仓位数，总手数
    for(int i=0;i<total_size;i++)
      {
       PositionGetSymbol(i);
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         {
          buy_size++;
          total_profit_buy+=PositionGetDouble(POSITION_PROFIT);
          total_lots_buy+=PositionGetDouble(POSITION_VOLUME);
         }
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         {
          sell_size++;
          total_profit_sell+=PositionGetDouble(POSITION_PROFIT);
          total_lots_sell+=PositionGetDouble(POSITION_VOLUME);
         }
      }
     //如果当前Long仓位达到止盈值则进行平仓
     if(total_lots_buy>0&&total_profit_buy/total_lots_buy>target_win_points)
      {
       for(int i=0;i<total_size;i++)
         {
          PositionGetSymbol(i);
          if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            bool close_flag=ExtTrade.PositionClose(PositionGetInteger(POSITION_TICKET),3);
         }
      }
    //如果当前Short仓位达到止盈值则进行平仓
    if(total_lots_sell>0&&total_profit_sell/total_lots_sell>target_win_points)
      {
       for(int i=0;i<total_size;i++)
         {
          PositionGetSymbol(i);
          if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
            bool close_flag=ExtTrade.PositionClose(PositionGetInteger(POSITION_TICKET),3);
         }
      }
    //如果多头损失超过一定值(与上次开仓价进行比较超过固定值)进行加仓
    if(total_lots_buy>0&&(last_buy_price-latest_price.ask>add_position_loss_points*_Point))
      {
      lots=new_lots(0.01,buy_size);
      Print("new lots buy:", lots);
      MqlTradeRequest mrequest;
      MqlTradeResult mresult;
      ZeroMemory(mrequest);
      ZeroMemory(mresult);
      mrequest.action=TRADE_ACTION_DEAL;
      mrequest.price=NormalizeDouble(latest_price.ask,_Digits);
      mrequest.symbol=_Symbol;
      mrequest.magic=EA_Magic;
      mrequest.type=ORDER_TYPE_BUY;
      mrequest.type_filling=ORDER_FILLING_FOK;
      mrequest.deviation=5;
      mrequest.volume=lots;
      OrderSend(mrequest, mresult);
      last_buy_price=mrequest.price;
      }
    if(total_lots_sell>0&&latest_price.bid-last_sell_price>add_position_loss_points*_Point)
      {
      lots=new_lots(0.01,sell_size);
      Print("new lots sell:", lots);
      MqlTradeRequest mrequest;
      MqlTradeResult mresult;
      ZeroMemory(mrequest);
      ZeroMemory(mresult);
      mrequest.action=TRADE_ACTION_DEAL;
      mrequest.price=NormalizeDouble(latest_price.bid,_Digits);
      mrequest.symbol=_Symbol;
      mrequest.magic=EA_Magic;
      mrequest.type=ORDER_TYPE_SELL;
      mrequest.type_filling=ORDER_FILLING_FOK;
      mrequest.deviation=5;
      mrequest.volume=lots;
      OrderSend(mrequest, mresult);
      last_sell_price=mrequest.price;
      }
      
    
   }
double new_lots(const double f1=0.01, const int num=1)
   {
    //Print("in new_lots:", f1, " ", num, " ", 
    return 0.01*1/sqrt(5)*(MathPow((1+sqrt(5))/2,num)-MathPow((1-sqrt(5))/2,num));
   }

void check_for_open()
   {
    MqlTick latest_price;
    if(Bars(_Symbol,_Period)<min_period)
      return;
    if(!SymbolInfoTick(_Symbol,latest_price)) return;
    if(open_condition()==1)
      {
         MqlTradeRequest mrequest;
         MqlTradeResult mresult;
         ZeroMemory(mrequest);
         ZeroMemory(mresult);
         mrequest.action=TRADE_ACTION_DEAL;
         mrequest.price=NormalizeDouble(latest_price.ask,_Digits);
         mrequest.symbol=_Symbol;
         mrequest.magic=EA_Magic;
         mrequest.type=ORDER_TYPE_BUY;
         mrequest.type_filling=ORDER_FILLING_FOK;
         mrequest.deviation=5;
         mrequest.volume=0.01;
         //mrequest.tp=NormalizeDouble(latest_price.ask+200*_Point,_Digits);
         OrderSend(mrequest, mresult);
         last_buy_price=mrequest.price;
      }
   if(open_condition()==0)
      {
         MqlTradeRequest mrequest;
         MqlTradeResult mresult;
         ZeroMemory(mrequest);
         ZeroMemory(mresult);
         mrequest.action=TRADE_ACTION_DEAL;
         mrequest.price=NormalizeDouble(latest_price.bid,_Digits);
         mrequest.symbol=_Symbol;
         mrequest.magic=EA_Magic;
         mrequest.type=ORDER_TYPE_SELL;
         mrequest.type_filling=ORDER_FILLING_FOK;
         mrequest.deviation=5;
         mrequest.volume=0.01;
         //mrequest.tp=NormalizeDouble(latest_price.bid-200*_Point,_Digits);
         OrderSend(mrequest, mresult);
         last_sell_price=mrequest.price;
      }   
   }

int open_condition()
   {
    int total_buy=0;
    int total_sell=0;
    int total=PositionsTotal();
    
   for(int i=0;i<total;i++)
      {  
      string position_symbol=PositionGetSymbol(i);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         total_buy++;
      else
         total_sell++;   
      }
    double close_price[];
    ArrayResize(close_price,min_period);
    CopyClose(_Symbol,_Period,0,min_period,close_price);
    double coff[], std;
    std=cal_linear_regression_std(close_price,coff);
    MqlTick latest_price;
    if(!SymbolInfoTick(_Symbol,latest_price)) return -1;
    if(coff[3]<0.8) return -1;
    if(coff[0]<0&&latest_price.bid>coff[2]+2*std&&total_buy<1) return 1;
    if(coff[0]>0&&latest_price.ask<coff[2]-2*std&&total_sell<1) return 0;
    return -1;
   }
   
double cal_linear_regression_std(const double& price[], double& res[])
   {
    ArrayResize(res,4);
    double sumX,sumY,sumXY,sumX2,sumY2,a,b,F,S,r2;
    int X, sample_size;
    //--- calculate coefficient a and b of equation linear regression 
    F=0.0;
    S=0.0;
    sumX=0.0;
    sumY=0.0;
    sumXY=0.0;
    sumX2=0.0;
    sumY2=0.0;
    X=0;
    sample_size=ArraySize(price);
    for(int i=0;i<sample_size;i++)
      {
       sumX+=X;
       sumY+=price[i];
       sumXY+=X*price[i];
       sumX2+=MathPow(X,2);
       sumY2+=MathPow(price[i],2);
       X++;
      }
    a=(sumX*sumY-sample_size*sumXY)/(MathPow(sumX,2)-sample_size*sumX2);
    b=(sumY-a*sumX)/sample_size;
    r2=(sample_size*sumXY-sumX*sumY)/(MathSqrt(sample_size*sumX2-MathPow(sumX,2))*MathSqrt(sample_size*sumY2-MathPow(sumY,2)));
//--- calculate values of main line and error F
    X=0;
    for(int i=0; i<sample_size;i++)
      {
       F+=MathPow(price[i]-(b+a*X),2);
       X++;
      }
//--- calculate deviation S       
    S=NormalizeDouble(MathSqrt(F/(sample_size+1))/MathCos(MathArctan(a*M_PI/180)*M_PI/180),_Digits);
    res[0]=a;
    res[1]=b;
    res[2]=(b+a*(X+1));
    res[3]=MathAbs(r2);
    return S;
   }   