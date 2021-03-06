//+------------------------------------------------------------------+
//|                                                EventListener.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#include <Strategy\Strategy.mqh>
#include <Expert\Signal\SignalMACD.mqh>
#include <Strategy\Strategy.mqh>
#include <Expert\Signal\SignalMACD.mqh>
//+------------------------------------------------------------------+
//| Strategy receives events and displays in terminal.               |
//+------------------------------------------------------------------+
class COnSignalMACD : public CStrategy
{
private:
   CSignalMACD       m_signal_macd;
   CSymbolInfo       m_info;
   CiOpen            m_open;
   CiHigh            m_high;
   CiLow             m_low;
   CiClose           m_close;
   CIndicators       m_indicators;
public:
                     COnSignalMACD(void);
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent& event, CPosition* pos);
   virtual void      SupportSell(const MarketEvent& event, CPosition* pos);
};
//+------------------------------------------------------------------+
//| Initialization of the CSignalMacd signal module                  |
//+------------------------------------------------------------------+
COnSignalMACD::COnSignalMACD(void)
{
   m_info.Name(Symbol());                                  // Initializing the object that represents the trading symbol of the strategy
   m_signal_macd.Init(GetPointer(m_info), Period(), 10);   // Initializing the signal module by the trading symbol and timeframe
   m_signal_macd.InitIndicators(GetPointer(m_indicators)); // Creating required indicators in the signal module based on the empty list of indicators m_indicators
   m_signal_macd.EveryTick(false);                         // Testing mode
   m_signal_macd.Magic(ExpertMagic());                     // Magic number
   m_signal_macd.PatternsUsage(4);                         // Pattern mask
   m_open.Create(Symbol(), Period());                      // Initializing the timeseries of Open prices
   m_high.Create(Symbol(), Period());                      // Initializing the timeseries of High prices
   m_low.Create(Symbol(), Period());                       // Initializing the timeseries of Low prices
   m_close.Create(Symbol(), Period());                     // Initializing the timeseries of Close prices
   m_signal_macd.SetPriceSeries(GetPointer(m_open),        // Initializing the signal module by timeseries objects
                              GetPointer(m_high),
                              GetPointer(m_low),
                              GetPointer(m_close));
}
//+------------------------------------------------------------------+
//| Buying.                                                          |
//+------------------------------------------------------------------+
void COnSignalMACD::InitBuy(const MarketEvent &event)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   m_indicators.Refresh();
   m_signal_macd.SetDirection();
   int power_buy = m_signal_macd.LongCondition();
   if(power_buy != 0)
      Trade.Buy(1.0);
}
//+------------------------------------------------------------------+
//| Closing Buys                                                     |
//+------------------------------------------------------------------+
void COnSignalMACD::SupportBuy(const MarketEvent &event, CPosition* pos)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   m_indicators.Refresh();
   m_signal_macd.SetDirection();
   int power_sell = m_signal_macd.ShortCondition();
   if(power_sell != 0)
      pos.CloseAtMarket();
}
//+------------------------------------------------------------------+
//| Selling.                                                         |
//+------------------------------------------------------------------+
void COnSignalMACD::InitSell(const MarketEvent &event)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   m_indicators.Refresh();
   m_signal_macd.SetDirection();
   int power_sell = m_signal_macd.ShortCondition();
   if(power_sell != 0)
      Trade.Sell(1.0);
}
//+------------------------------------------------------------------+
//| Closing Buys                                                     |
//+------------------------------------------------------------------+
void COnSignalMACD::SupportSell(const MarketEvent &event, CPosition* pos)
{
   if(event.type != MARKET_EVENT_BAR_OPEN)
      return;
   m_indicators.Refresh();
   m_signal_macd.SetDirection();
   int power_buy = m_signal_macd.LongCondition();
   if(power_buy != 0)
      pos.CloseAtMarket();
}
//+------------------------------------------------------------------+