//+------------------------------------------------------------------+
//|                                          RiBuffIndicatorStat.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
enum IndicatorType
   {
    ENUM_INDICATOR_ORIGIN,
    ENUM_INDICATOR_BIAS,
    ENUM_INDICATOR_WILLIAM
   };

#include "RiBuffStat.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CRiBuffIndicatorStats
  {
private:
   CRiBuffStats      origin_price;
   CRiBuffStats      indicator_buffer;
   IndicatorType     indicator_type;
   double            indicator_value;

public:
                     CRiBuffIndicatorStats(void);
                     CRiBuffIndicatorStats(const CRiBuffIndicatorStats &obj);
   void              AddValue(double value);
   void              SetMaxTotal(int max_total);
   void              SetIndicatorType(IndicatorType ind_type){indicator_type=ind_type;};
   CRiBuffStats GetOriginRiBuffer(){return origin_price;};
   CRiBuffStats GetIndicatorRiBuffer(){return indicator_buffer;};
  };
//+------------------------------------------------------------------+
//|                   构造函数                                       |
//+------------------------------------------------------------------+
CRiBuffIndicatorStats::CRiBuffIndicatorStats(void)
  {
  }
CRiBuffIndicatorStats::CRiBuffIndicatorStats(const CRiBuffIndicatorStats &obj)
  {
   origin_price=obj.origin_price;
   indicator_buffer=obj.indicator_buffer;
   indicator_type=obj.indicator_type;
   indicator_value=obj.indicator_value;
  }
void CRiBuffIndicatorStats::SetMaxTotal(int max_total)
   {
    origin_price.SetMaxTotal(max_total);
    indicator_buffer.SetMaxTotal(max_total);
   }
//+------------------------------------------------------------------+
//|             增加新值时的处理                                     |
//+------------------------------------------------------------------+
void CRiBuffIndicatorStats::AddValue(double value)
  {
   origin_price.AddValue(value);
   switch(indicator_type)
     {
      case ENUM_INDICATOR_ORIGIN:
         indicator_value=origin_price.GetValue(origin_price.GetTotal()-1);
         indicator_buffer.AddValue(indicator_value);
         break;
      case  ENUM_INDICATOR_BIAS:
        indicator_value=(origin_price.GetValue(origin_price.GetTotal()-1)-origin_price.Mu())/origin_price.Mu();
        indicator_buffer.AddValue(indicator_value);
        break;
      case ENUM_INDICATOR_WILLIAM:
         
         break;
      default:
        indicator_value=origin_price.GetValue(origin_price.GetTotal()-1);
        indicator_buffer.AddValue(indicator_value);
        break;
     }
   
  }
//+------------------------------------------------------------------+
