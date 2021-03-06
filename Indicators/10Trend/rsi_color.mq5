//+------------------------------------------------------------------+
//|                                                    RSI_Color.mq5 |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alexander Fedosov"
#property link      "https://www.mql5.com/en/users/alex2356"
#property version   "1.00"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_buffers 3 
#property indicator_plots   3 

//---
#property indicator_type1   DRAW_HISTOGRAM 
#property indicator_color1  clrDarkGreen 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  5 
#property indicator_type2   DRAW_HISTOGRAM 
#property indicator_color2  clrCrimson 
#property indicator_style2  STYLE_SOLID 
#property indicator_width2  5 
#property indicator_type3   DRAW_HISTOGRAM 
#property indicator_color3  clrDarkGray 
#property indicator_style3  STYLE_SOLID 
#property indicator_width3  5 

//--- input parameters
input int      RSI_Period=8;
input double   Overbuying=55.0;
input double   Overselling=45.0;

//---
int RSI_Handle,min_rates_total;
double rsi[];
//---- indicator buffers
double   ExtBuffer1[],ExtBuffer2[],ExtBuffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   SetIndexBuffer(0,ExtBuffer1);
   SetIndexBuffer(1,ExtBuffer2);
   SetIndexBuffer(2,ExtBuffer3);
   ArraySetAsSeries(ExtBuffer1,true);
   ArraySetAsSeries(ExtBuffer2,true);
   ArraySetAsSeries(ExtBuffer3,true);
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI Color");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);

   RSI_Handle=iRSI(Symbol(),PERIOD_CURRENT,RSI_Period,PRICE_CLOSE);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора");
      return(INIT_FAILED);
     }
//--- initialization of variables of data calculation start
   min_rates_total=RSI_Period+1;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(RSI_Handle)<rates_total || rates_total<min_rates_total)
      return(0);
//--- declarations of local variables 
   int limit,to_copy,i;
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(rsi,true);
//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-2; // starting index for calculation of all bars
     }
   else
      limit=rates_total-prev_calculated; // Starting index for the calculation of new bars
   to_copy=limit+2;
//---

//---
   if(CopyBuffer(RSI_Handle,0,0,to_copy,rsi)<=0)
      return(0);
//--- Fill in the indicator buffer with values 
   for(i=limit; i>=0 && !IsStopped(); i--)
     {
      ExtBuffer1[i]=0.0;
      ExtBuffer2[i]=0.0;
      ExtBuffer3[i]=0.0;
      if(rsi[i]<=Overselling)
         ExtBuffer2[i]=1;
      else if(rsi[i]>=Overbuying)
                      ExtBuffer1[i]=1;
      else
         ExtBuffer3[i]=1;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
