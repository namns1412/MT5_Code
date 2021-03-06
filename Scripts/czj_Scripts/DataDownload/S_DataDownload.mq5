//+------------------------------------------------------------------+
//|                                               S_DataDownload.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
//   datetime dt_begin=D'1990.01.01';//H12
//   datetime dt_end=D'2017.12.01';
//
//   ENUM_TIMEFRAMES tf[]={PERIOD_M15};
//   string dir[]={"M15"};
//   string symbol[]={"_DXY"};
//   
//   for(int j=0;j<ArraySize(tf);j++)
//     {
//      for(int i=0;i<ArraySize(symbol);i++)
//        {
//         download_forex_data(symbol[i],tf[j],dt_begin,dt_end,"download_data\\"+dir[j]);
//        }
//      
//     }
   
   download_chart_data();
   
  }
void download_chart_data()
   {
    double data_temp[];
    datetime dt_begin=D'2015.12.01';
    datetime dt_end=D'2016.06.01';
    CopyClose(_Symbol,_Period,dt_begin,dt_end,data_temp);
    Print(ArraySize(data_temp));
   }
//+------------------------------------------------------------------+
void download_all_symbols()
   {
     //datetime dt_begin=D'2010.01.01';//D1
   //ENUM_TIMEFRAMES tf=PERIOD_D1;
   //datetime dt_begin=D'2015.01.01';//H12
   //ENUM_TIMEFRAMES tf=PERIOD_H12;
   datetime dt_begin=D'1990.01.01';//H12
   datetime dt_end=D'2017.12.01';
   
   //ENUM_TIMEFRAMES tf[]={PERIOD_D1,PERIOD_H4,PERIOD_H1,PERIOD_M30,PERIOD_M15,PERIOD_M5};
   //string dir[]={"D1","H4","H1","M30","M15","M5"};
   //ENUM_TIMEFRAMES tf[]={PERIOD_M30,PERIOD_M15,PERIOD_M5};2
   //string dir[]={"M30","M15","M5"};
   ENUM_TIMEFRAMES tf[]={PERIOD_H1};
   string dir[]={"H1"};
   Print("市场交易品种数量：",SymbolsTotal(false));
   
   for(int j=0;j<ArraySize(tf);j++)
     {
      for(int i=0;i<SymbolsTotal(false);i++)
        {
         //if(SymbolName(i,false)!="EURGBP") continue;
         Print("第"+(string)i+"个品种:",SymbolName(i,false));
         download_forex_data(SymbolName(i,false),tf[j],dt_begin,dt_end,"download_data\\"+dir[j]);
        }
     }
   
   }

bool download_forex_data(string symbol, ENUM_TIMEFRAMES period, datetime dt_begin, datetime dt_end, string dir_name)
   {
    Print("begin to download data...");
    MqlRates rates[];
    if(CopyRates(symbol,period,dt_begin,dt_end,rates)<0)
      {
       Print("复制数据失败",GetLastError());
       return false;
      }
    Print("data download OK!");
    Print("From "+ TimeToString(rates[0].time,TIME_DATE) + " to "+ TimeToString(rates[ArraySize(rates)-1].time,TIME_DATE));
    Print("Total number:",ArraySize(rates));
    Print("Begin to write data to file...");
    int file_handle=FileOpen(dir_name+"\\"+symbol+".txt",FILE_WRITE|FILE_CSV);
    if(file_handle!=INVALID_HANDLE)
      {
       FileWrite(file_handle, "date_time","open","high","low","close","real_volume","tick_volume","spread");
       for(int i=0;i<ArraySize(rates);i++)
         {
          FileWrite(file_handle,rates[i].time,rates[i].open,rates[i].high,rates[i].low,rates[i].close,rates[i].real_volume,rates[i].tick_volume,rates[i].spread);
         }
        FileClose(file_handle);
        Print("Write data OK!");
        return true;
      }
    else 
      {
       Print("打开文件错误",GetLastError());
       return false;
      }
   }