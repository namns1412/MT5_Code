//+------------------------------------------------------------------+
//|                                             Signal_MACD_BOLL.mqh |
//|                                                      Daixiaorong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Daixiaorong"
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|MACD指标与布林带结合                                                          |
//+------------------------------------------------------------------+
#include <Expert\Signal\SignalBOLL.mqh>
#include <Strategy\Strategy.mqh>
#include <Strategy\SignalAdapter.mqh>
input string Inp_String_MACD             ="----------MACD-----------";
input int    Inp_Signal_MACD_PeriodFast  =12;
input int    Inp_Signal_MACD_PeriodSlow  =24;
input int    Inp_Signal_MACD_PeriodSignal=9;
input int    Inp_Signal_MACD_TakeProfit  =50;
input int    Inp_Signal_MACD_StopLoss    =20;
input int    Inp_Siganl_MACD_Pattern     =1;
input string Inp_String_BOLL             ="----------BOLL-----------";
input int    Inp_Signal_BOLL_Period      =20;
input int    Inp_Signal_BOLL_Deviation   =2;
input int    Inp_Signal_BOLL_TakeProfit  =50;
input int    Inp_Signal_BOLL_StopLoss    =20;
input int    Inp_Siganl_BOLL_Pattern     =0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COnSignal_MACD_BOLL : public CStrategy
  {
private:
   CSignalAdapter    m_adapter_macd;
   CSignalAdapter    m_adapter_boll;
public:
                     COnSignal_MACD_BOLL(void);
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   virtual void      SupportSell(const MarketEvent &event,CPosition *pos);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
COnSignal_MACD_BOLL::COnSignal_MACD_BOLL(void)
  {
   MqlSignalParams params;
   params.every_tick = false;
   params.magic = 32910;
   params.point = 10.0;
   params.symbol = Symbol();
   params.period = Period();
   params.usage_pattern = Inp_Siganl_MACD_Pattern;
   params.signal_type = SIGNAL_MACD;
   CSignalMACD* macd = m_adapter_macd.CreateSignal(params);
   macd.PeriodFast(Inp_Signal_MACD_PeriodFast);
   macd.PeriodSignal(Inp_Signal_MACD_PeriodSignal);
   macd.PeriodSlow(Inp_Signal_MACD_PeriodSlow);
   macd.TakeLevel(Inp_Signal_MACD_TakeProfit);
   macd.StopLevel(Inp_Signal_MACD_StopLoss);
   //---
   params.usage_pattern = Inp_Siganl_BOLL_Pattern;
   params.magic = 32911;
   params.signal_type = SIGNAL_BOLL;
   CSignalBOLL* boll = m_adapter_boll.CreateSignal(params);
   boll.BandsPeriod(Inp_Signal_BOLL_Period);
   boll.Deviation(Inp_Signal_BOLL_Deviation);
   boll.TakeLevel(Inp_Signal_BOLL_TakeProfit);
   boll.StopLevel(Inp_Signal_BOLL_StopLoss);
  }
//+------------------------------------------------------------------+
//| Buying.                                                          |
//+------------------------------------------------------------------+
void COnSignal_MACD_BOLL::InitBuy(const MarketEvent &event)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   //if(positions.open_buy > 0)
   //   return;
   if(m_adapter_macd.LongSignal() && m_adapter_boll.LongSignal())
      Trade.Buy(0.1,ExpertSymbol(),"");
}
//+------------------------------------------------------------------+
//| Closing Buys                                                     |
//+------------------------------------------------------------------+
void COnSignal_MACD_BOLL::SupportBuy(const MarketEvent &event, CPosition* pos)
{
   if(event.type != MARKET_EVENT_TICK)
      return;
   if(m_adapter_boll.ShortSignal())
      pos.CloseAtMarket();
}
//+------------------------------------------------------------------+
//| Selling.                                                         |
//+------------------------------------------------------------------+
void COnSignal_MACD_BOLL::InitSell(const MarketEvent &event)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   //if(positions.open_sell > 0)
   //   return;
   if(m_adapter_macd.ShortSignal() && m_adapter_boll.ShortSignal())
      Trade.Sell(1.0);
}
//+------------------------------------------------------------------+
//| Closing Buys                                                     |
//+------------------------------------------------------------------+
void COnSignal_MACD_BOLL::SupportSell(const MarketEvent &event, CPosition* pos)
{
   if(event.type != MARKET_EVENT_TICK)
      return;
   if(m_adapter_boll.LongSignal())
      pos.CloseAtMarket();
}
//+------------------------------------------------------------------+