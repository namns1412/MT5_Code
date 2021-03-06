//+------------------------------------------------------------------+
//|                                                       Sample.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

// 外部输入参数
input int StopLoss=30;
input int TakeProfit=100;
input int ADX_Period=8;
input int MA_Period=8;
input int EA_Magic=12345;
input double Adx_Min=22.0;
input double Lots=0.1;
// 其他参数
int adxHandle;
int maHandle;
double plsDI[], minDI[], adxVal[];
double maVal[];
double p_close;
int STP, TKP;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   adxHandle=iADX(NULL,0,ADX_Period);
   maHandle=iMA(_Symbol,_Period,MA_Period,0,MODE_EMA,PRICE_CLOSE);
   if(adxHandle<0 || maHandle<0)
      {
         Alert("创建指标句柄失败:",GetLastError(),"!!");
      }
   STP=StopLoss;
   TKP=TakeProfit;
   if(_Digits==3||_Digits==5)
      {
         STP=STP*10;
         TKP=TKP*10;
      }
   //Print("当前图表Symbol:", _Symbol," ", _Point," ", _Digits);
   //Print("这是在初始化函数中，已经初始化成功！");
   //Print("adx句柄值:", adxHandle, " ma句柄值:", maHandle);
   //Print("止盈点:", TKP, " 止损点:", STP);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   IndicatorRelease(adxHandle);
   IndicatorRelease(maHandle);
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //Print("这是在Ontick函数中");
   if(Bars(_Symbol,_Period)<60)
      {
         Alert("Bar数目不到60个，EA将退出！");
         return;
      }
    static datetime Old_Time;
    datetime New_Time[1];
    bool IsNewBar=false;
    
    int copied = CopyTime(_Symbol,_Period,0,1,New_Time);
    if(copied>0)
      {
         if(Old_Time!=New_Time[0])
            {
               IsNewBar=true;
               //if(MQLInfoInteger(MQL_DEBUG)) Print("此时产生了新柱 ", New_Time[0], "旧的时间为 ", Old_Time);
               Old_Time=New_Time[0];
            }
      }
    else
      {
         Alert("复制历史时间失败,错误:",GetLastError());
         ResetLastError();
         return;
      }
    if(IsNewBar==false) return;
    
    int Mybars=Bars(_Symbol,_Period);
    if(Mybars<60)
      {
         Alert("Bar数目不够60个，EA将要退出！");
         return;
      }
      
    MqlTick latest_price;
    MqlTradeRequest mrequest;
    MqlTradeResult mresult;
    MqlRates mrate[];
    ZeroMemory(mrequest);
    
    ArraySetAsSeries(mrate,true);
    ArraySetAsSeries(plsDI,true);
    ArraySetAsSeries(minDI,true);
    ArraySetAsSeries(adxVal,true);
    ArraySetAsSeries(maVal,true);
    
    if(!SymbolInfoTick(_Symbol,latest_price))
      {
         Alert("获取最新报价错误：", GetLastError());
         return;
      }
    if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
      {
         Alert("复制数据失败", GetLastError());
         return;
      }
    if(CopyBuffer(adxHandle,0,0,3,adxVal)<0||CopyBuffer(adxHandle,1,0,3,plsDI)<0||CopyBuffer(adxHandle,2,0,3,minDI)<0)
      {
         Alert("复制ADX指标数据失败",GetLastError());
         return;
      }
    if(CopyBuffer(maHandle,0,0,3,maVal)<0)
      {
         Alert("复制MA指标失败", GetLastError());
         return;
      }
    bool Buy_Opened=false;
    bool Sell_Opened=false;
    
    if(PositionSelect(_Symbol)==true)
      {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            {
               Buy_Opened=true;
            }
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
            {
               Sell_Opened=true;
            }   
      }
    p_close=mrate[1].close;
    
    bool Buy_Condition_1 = (maVal[0]>maVal[1])&&(maVal[1]>maVal[2]);
    bool Buy_Condition_2 = (p_close>maVal[1]);
    bool Buy_Condition_3 = (adxVal[0]>Adx_Min);
    bool Buy_Condition_4 = (plsDI[0]>minDI[0]);
    
    if(Buy_Condition_1&&Buy_Condition_2)
      {
         if(Buy_Condition_3&&Buy_Condition_4)
            {
               if(Buy_Opened)
                  {
                     //Alert("当前已经有买入的仓位");
                     return;
                  }
               mrequest.action=TRADE_ACTION_DEAL;
               mrequest.price=NormalizeDouble(latest_price.ask,_Digits);
               //mrequest.sl=NormalizeDouble(latest_price.ask-STP*_Point,_Digits);
               //mrequest.tp=NormalizeDouble(latest_price.ask+TKP*_Point,_Digits);
               mrequest.sl=NormalizeDouble(latest_price.ask-100*0.01,_Digits);
               mrequest.tp=NormalizeDouble(latest_price.ask+100*0.01,_Digits);
               mrequest.symbol=_Symbol;
               mrequest.volume=Lots;
               mrequest.magic=EA_Magic;
               mrequest.type=ORDER_TYPE_BUY;
               mrequest.type_filling=ORDER_FILLING_FOK;
               mrequest.deviation=100;
               OrderSend(mrequest, mresult);
               Print("发送了一个买单:");
               if(mresult.retcode==10009||mresult.retcode==10008)
                  {
                     Alert("买入订单已经成功下单，订单#:", mresult.order,"!!");
                  }
               else
                  {
                     Alert("买入订单请求无法完成,", GetLastError());
                     ResetLastError();
                     return;
                  }   
            }
      }
   bool Sell_Condition_1 = (maVal[0]<maVal[1]) && (maVal[1]<maVal[2]);  // MA-8 向下降低
   bool Sell_Condition_2 = (p_close <maVal[1]);                         // 前一收盘价低于 MA-8
   bool Sell_Condition_3 = (adxVal[0]>Adx_Min);                         // 当前 ADX 值大于最小值 (22)
   bool Sell_Condition_4 = (plsDI[0]<minDI[0]);                         // -DI 大于 +DI
   
 //--- 放到一起
   if(Sell_Condition_1 && Sell_Condition_2)
       {
         if(Sell_Condition_3 && Sell_Condition_4)
           {
            // 还有未平卖出仓位?
            if (Sell_Opened) 
            {
                Alert("我们已经有了卖出仓位!!!"); 
                return;    // 不建新的卖出仓位
            }
            mrequest.action = TRADE_ACTION_DEAL;                                 // 立即执行订单
            mrequest.price = NormalizeDouble(latest_price.bid,_Digits);          // 最新买家报价
            mrequest.sl = NormalizeDouble(latest_price.bid + STP*_Point,_Digits); // 止损
            mrequest.tp = NormalizeDouble(latest_price.bid - TKP*_Point,_Digits); // 获利
            mrequest.symbol = _Symbol;                                         // 货币对
            mrequest.volume = Lots;                                            // 交易手数
            mrequest.magic = EA_Magic;                                        // 订单幻数
            mrequest.type= ORDER_TYPE_SELL;                                     // 卖出订单
            mrequest.type_filling = ORDER_FILLING_FOK;                          // 订单执行类型
            mrequest.deviation=100;                                           // 当前价格偏移
            //--- 发送订单
            OrderSend(mrequest,mresult);  
            if(mresult.retcode==10009 || mresult.retcode==10008) //请求完成或者已下订单
              {
                  Alert("卖出订单已经成功下单，订单#:",mresult.order,"!!");
              }
            else
              {
                  Alert("卖出订单请求无法完成 -错误:",GetLastError());
                  ResetLastError();
                  return;
              }
            }
          } 
    
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
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
//---
   
  }
//+------------------------------------------------------------------+
