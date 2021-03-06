//+------------------------------------------------------------------+
//|                                                   RingBuffer.mqh |
//|                                 Copyright 2016, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include <Object.mqh>
#include "RiBuffDbl.mqh"
#include "RiSMA.mqh"
#include "RiMaxMin.mqh"
//+------------------------------------------------------------------+
//| Stochastic indicator class                                       |
//+------------------------------------------------------------------+
class CRiStoch : public CObject
{
private:
   CRiMaxMin     m_max;          // High/Low indicator
   CRiMaxMin     m_min;          // High/Low indicator
   CRiSMA        m_slowed_k;     // K% smoothing
   CRiSMA        m_slowed_d;     // D% moving average
public:
   void          ChangeLast(double new_value);
   void          AddValue(double close, double high, double low);
   void          SetPeriodK(int period);
   void          SetPeriodD(int period);
   void          SetSlowedPeriodK(int period);
   double        GetStochK(void);
   double        GetStochD(void);
};
//+------------------------------------------------------------------+
//| Adding new values and Stochastic calculation                     |
//+------------------------------------------------------------------+
void CRiStoch::AddValue(double close, double high, double low)
{
   m_max.AddValue(high);                     // Add the new High value
   m_min.AddValue(low);                      // Add the new Low value
   double c = close;
   double max = m_max.MaxValue();
   double min = m_min.MinValue();
   double delta = max - min;
   double k = 0.0;
   if(delta != 0.0)
      k = (c-min)/delta*100.0;               // Find K% using the equation
   m_slowed_k.AddValue(k);                   // Smooth K% (K% slowing)
   m_slowed_d.AddValue(m_slowed_k.SMA());    // Find %D from the smoothed K%
}
//+------------------------------------------------------------------+
//| Get the fast period                                              |
//+------------------------------------------------------------------+
void CRiStoch::SetPeriodK(int period)
{
   m_max.SetMaxTotal(period);
   m_min.SetMaxTotal(period);
}
//+------------------------------------------------------------------+
//| Set the slow period                                              |
//+------------------------------------------------------------------+
void CRiStoch::SetSlowedPeriodK(int period)
{  
   m_slowed_k.SetMaxTotal(period);
}
//+------------------------------------------------------------------+
//| Set the signal line period                                       |
//+------------------------------------------------------------------+
void CRiStoch::SetPeriodD(int period)
{  
   m_slowed_d.SetMaxTotal(period);
}
//+------------------------------------------------------------------+
//| Get the %K value                                                 |
//+------------------------------------------------------------------+
double CRiStoch::GetStochK(void)
{
   return m_slowed_k.SMA();
}
//+------------------------------------------------------------------+
//| Get the %D value                                                 |
//+------------------------------------------------------------------+
double CRiStoch::GetStochD(void)
{
   return m_slowed_d.SMA();
}