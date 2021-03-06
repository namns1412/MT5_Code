//+------------------------------------------------------------------+
//|                                               NewDataManager.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayDouble.mqh>
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//|      外汇全市场数据接口                                          |
//+------------------------------------------------------------------+
class CForexMarketDataManager:public CObject
  {
private:
   string            symbols[];//品种数组
   ENUM_TIMEFRAMES   tf[];//周期
   CArrayObj         price;//价格数据
   CArrayObj         symbol_time;//时间
   int               time_num[];
   int               symbol_num;
   int   tf_num;
public:
   void              SetParameter(const string &forex_symbol[],const ENUM_TIMEFRAMES &time_frame[]);//设置参数

   int               NumTime(const int index) {return time_num[index];};
   int               NumTime(const ENUM_TIMEFRAMES time_tf);
   int               NumSymbol(void){return symbol_num;};
   int               NumTimeFrame(void){return tf_num;};

   string            GetSymbolAt(const int index){return symbols[index];};//获取指定索引的品种数组
   CArrayLong        *GetTimeAt(const int index){return symbol_time.At(index);};
   ENUM_TIMEFRAMES   GetPeriodAt(const int index){return tf[index];};

   void              RefreshSymbolsPrice(datetime begin,datetime end);//刷新给定时间间隔的价格数据
   void              RefreshSymbolsPrice(datetime begin);//刷新给定时间起点和价格数据
   void              RefreshSymbolsPrice(int num);//刷新给定数量的价格数据
   
   CArrayDouble     *GetSymbolPriceAt(int index_symbol, int index_period);//返回给定品种周期索引的数据系列
   CArrayDouble     *GetSymbolPriceAt(string symbol_name, ENUM_TIMEFRAMES time_frame);//返回给定品种周期的数据系列
  };
//+------------------------------------------------------------------+
void CForexMarketDataManager::SetParameter(const string &forex_symbol[],const ENUM_TIMEFRAMES &time_frame[])
  {
   ArrayCopy(symbols,forex_symbol);
   ArrayCopy(tf,time_frame);
   symbol_num=ArraySize(symbols);
   tf_num=ArraySize(tf);
   ArrayResize(time_num,tf_num);
  }
int CForexMarketDataManager::NumTime(const ENUM_TIMEFRAMES time_tf)
   {
    for(int i=0;i<tf_num;i++)
      {
       if(tf[i]==time_tf)
         {
          return NumTime(i);
         }
      }
    return 0;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CForexMarketDataManager::RefreshSymbolsPrice(datetime begin,datetime end)
  {
   price.Shutdown();//清除之前的数据
   for(int i=0;i<tf_num;i++)
     {
      datetime dt=begin;
      CArrayLong *period_time=new CArrayLong();
      while(true)
        {
         dt=dt+PeriodSeconds(tf[i]);
         if(dt>end) break;
         period_time.Add(dt);
        }
      symbol_time.Add(period_time);
      time_num[i]=period_time.Total();
     }
   

   for(int i=0;i<symbol_num;i++)
     {
      CArrayObj *symbol_price=new CArrayObj();
      for(int k=0;k<tf_num;k++)
        {
         CArrayDouble *symbol_period_price = new CArrayDouble();
         for(int j=0;j<time_num[k];j++)
           {
            double close[];
            CArrayLong *period_time=symbol_time.At(k);
            
            if(CopyClose(symbols[i],tf[k],(datetime)(period_time.At(j)),1,close)<0)
               symbol_period_price.Add(EMPTY_VALUE);
            else
               symbol_period_price.Add(close[0]);
           }
          symbol_price.Add(symbol_period_price);
        }
      price.Add(symbol_price);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CForexMarketDataManager::RefreshSymbolsPrice(datetime begin)
  {
   RefreshSymbolsPrice(begin,TimeCurrent());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CForexMarketDataManager::RefreshSymbolsPrice(int num)
  {
   price.Shutdown();//清除之前的数据
   datetime end=TimeCurrent();
   for(int i=0;i<tf_num;i++)
     {
      datetime begin=end-num*PeriodSeconds(tf[i]);
      datetime dt=begin;
      CArrayLong *period_time=new CArrayLong();
      while(true)
        {
         dt=dt+PeriodSeconds(tf[i]);
         if(dt>end) break;
         period_time.Add(dt);
        }
      symbol_time.Add(period_time);
      time_num[i]=period_time.Total();
     }
   for(int i=0;i<symbol_num;i++)
     {
      CArrayObj *symbol_price=new CArrayObj();
      for(int k=0;k<tf_num;k++)
        {
         CArrayDouble *symbol_period_price = new CArrayDouble();
         for(int j=0;j<time_num[k];j++)
           {
            double close[];
            CArrayLong *period_time=symbol_time.At(k);
            
            if(CopyClose(symbols[i],tf[k],(datetime)(period_time.At(j)),1,close)<0)
               symbol_period_price.Add(EMPTY_VALUE);
            else
               symbol_period_price.Add(close[0]);
           }
          symbol_price.Add(symbol_period_price);
        }
      price.Add(symbol_price);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CArrayDouble *CForexMarketDataManager::GetSymbolPriceAt(int index_symbol,int index_period)
  {
   CArrayObj *symbol_price = price.At(index_symbol);
   return symbol_price.At(index_period);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CArrayDouble *CForexMarketDataManager::GetSymbolPriceAt(string symbol_name,ENUM_TIMEFRAMES time_frame)
  {
   int symbol_index=-1;
   int tf_index=-1;
   
   for(int i=0;i<ArraySize(symbols);i++)
     {
      if(symbol_name==symbols[i])
         {
          symbol_index=i;
          break;
         }  
     }
   for(int i=0;i<tf_num;i++)
     {
      if(time_frame==tf[i])
        {
         tf_index=i;
         break;
        }
     }
   if(symbol_index<0||tf_index<0)
     {
      return NULL;
     }
   return GetSymbolPriceAt(symbol_index,tf_index);
  }
