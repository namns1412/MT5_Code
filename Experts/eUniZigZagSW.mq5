#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- input parameters

enum ESorce{
   Src_HighLow=0,
   Src_Close=1,
   Src_RSI=2,
   Src_MA=3
};

enum EDirection{
   Dir_NBars=0,
   Dir_CCI=1
};

//--- input parameters
input ESorce      SrcSelect =  Src_HighLow;
input EDirection  DirSelect =  Dir_NBars;
input int                  RSIPeriod   =  14;
input ENUM_APPLIED_PRICE   RSIPrice    =  PRICE_CLOSE;
input int                  MAPeriod    =  14;
input int                  MAShift     =  0;
input ENUM_MA_METHOD       MAMethod    =  MODE_SMA;
input ENUM_APPLIED_PRICE   MAPrice     =  PRICE_CLOSE;
input int                  CCIPeriod   =  14;
input ENUM_APPLIED_PRICE   CCIPrice    =  PRICE_TYPICAL;
input int                  ZZPeriod   =  14;

int handle=INVALID_HANDLE;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   handle=iCustom(Symbol(),Period(),"ZigZags\\iUniZigZagSW",SrcSelect,
                                             DirSelect,
                                             RSIPeriod,
                                             RSIPrice,
                                             MAPeriod,
                                             MAShift,
                                             MAMethod,
                                             MAPrice,
                                             CCIPeriod,
                                             CCIPrice,
                                             ZZPeriod);
   
   if(handle==INVALID_HANDLE){
      Alert("Ошибка загрузки индикатора");
      return(INIT_FAILED);
   }

   Comment("");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   if(handle!=INVALID_HANDLE){
      IndicatorRelease(handle);   
   }
   Comment("");
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   string cs="";

   // направление

   double dir[1];

   if(CopyBuffer(handle,3,0,1,dir)<=0){
      Print("Ошибка получения данных от зигзага");
      return;
   }

   if(dir[0]==1){
      cs=cs+"Направление вверх";
   }
   if(dir[0]==-1){
      cs=cs+"Направление вниз";
   }   
   
   // Последние вершины/впадины 
   
   double lhb[1],llb[1],zz[1],zz1[1],zz2[1];
   int ind; 
   
   // количество баров на графике
   int bars=Bars(Symbol(),Period());   
   if(bars<=0){
      Print("Выполняется синхронизация таймрейма");
      return;
   }   
   
   if(dir[0]==1){
      
      // индекс бара последней вершины при отсчете от нуля слева
      if(CopyBuffer(handle,4,0,1,lhb)<=0){
         Print("Ошибка получения данных от зигзага 2");
         return;
      }
      
      // индекс бара при отсчете справа от нуля
      ind=bars-(int)lhb[0]-1;
      
      // значение зигзага на баре ind
      if(CopyBuffer(handle,2,ind,1,zz)<=0){
         Print("Ошибка получения данных от зигзага 3");
         return;
      } 
      
      //===
      
      // индекс впадины предшествующей этой вершине
      if(CopyBuffer(handle,5,ind,1,llb)<=0){
         Print("Ошибка получения данных от зигзага 4");
         return;
      }      
      
      // индекс бара при отсчете справа от нуля
      ind=bars-(int)llb[0]-1;     
      
      // значение зигзага на баре ind
      if(CopyBuffer(handle,2,ind,1,zz1)<=0){
         Print("Ошибка получения данных от зигзага 5");
         return;
      }        
      
      cs=cs+"\n"+(string)zz1[0]+" "+(string)zz[0];     
   }
   else if(dir[0]==-1){
   
      // индекс бара последней впадины при отсчете от нуля слева
      if(CopyBuffer(handle,5,0,1,llb)<=0){
         Print("Ошибка получения данных от зигзага 6");
         return;
      }
      
      // индекс бара при отсчете справа от нуля
      ind=bars-(int)llb[0]-1;
      
      // значение зигзага на баре ind:
      if(CopyBuffer(handle,2,ind,1,zz)<=0){
         Print("Ошибка получения данных от зигзага 7");
         return;
      } 
      
      //===
      
      // индекс вершины предшествующей этой впадине
      if(CopyBuffer(handle,4,ind,1,lhb)<=0){
         Print("Ошибка получения данных от зигзага 8");
         return;
      }      
      
      // индекс бара при отсчете справа от нуля
      ind=bars-(int)lhb[0]-1;     
      
      // значение зигзага на баре ind
      if(CopyBuffer(handle,2,ind,1,zz1)<=0){
         Print("Ошибка получения данных от зигзага 9");
         return;
      }              
      
      cs=cs+"\n"+(string)zz1[0]+" "+(string)zz[0];     
   }
   
   
   
   Comment(cs,"\n",GetTickCount());

   
}
//+------------------------------------------------------------------+
