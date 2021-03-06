//+------------------------------------------------------------------+
//|                                                   RingBuffer.mqh |
//|                                 Copyright 2016, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include "RiBuffDbl.mqh"
//+------------------------------------------------------------------+
//| Calculate the exponential moving average in the ring buffer      |
//+------------------------------------------------------------------+
class CRiEMA : public CRiBuffDbl
{
private:
   double        m_prev_ema;        // Previous EMA value
   double        m_last_value;      // Last price value
   double        m_smoth_factor;    // Smoothing factor
   bool          m_calc_first_v;    // Flag indicating the first value calculation
   double        CalcEma();         // Direct average calculation
protected:
   virtual void  OnAddValue(double value);
   virtual void  OnChangeValue(int index, double del_value, double new_value);
   virtual void  OnSetMaxTotal(int max_total);
public:
                 CRiEMA(void);
   double        EMA(void);
};
//+------------------------------------------------------------------+
//| Subscribe to value adding/changing notifications                 |
//+------------------------------------------------------------------+
CRiEMA::CRiEMA(void) : m_prev_ema(EMPTY_VALUE), m_last_value(EMPTY_VALUE),
                                                m_calc_first_v(false)
{
}
//+------------------------------------------------------------------+
//| Calculate smoothing factor according to MetaQuotes EMA equation  |
//+------------------------------------------------------------------+
void CRiEMA::OnSetMaxTotal(int max_total)
{
   m_smoth_factor = 2.0/(1.0+max_total);
}
//+------------------------------------------------------------------+
//| Increase the total sum                                           |
//+------------------------------------------------------------------+
void CRiEMA::OnAddValue(double value)
{
   //Calculate the previous EMA value
   if(m_prev_ema != EMPTY_VALUE)
      m_prev_ema = CalcEma();
   //Save the current price
   m_last_value = value;
}
//+------------------------------------------------------------------+
//| Correct EMA                                                      |
//+------------------------------------------------------------------+
void CRiEMA::OnChangeValue(int index,double del_value,double new_value)
{
   if(index != GetMaxTotal()-1)
      return;
   m_last_value = new_value;
}
//+------------------------------------------------------------------+
//| Direct EMA calculation                                           |
//+------------------------------------------------------------------+
double CRiEMA::CalcEma(void)
{
   double value = m_last_value*m_smoth_factor+m_prev_ema*(1.0-m_smoth_factor);
   return value;
}
//+------------------------------------------------------------------+
//| Get the simple moving average                                    |
//+------------------------------------------------------------------+
double CRiEMA::EMA(void)
{
   if(m_calc_first_v)
      return CalcEma();
   else
   {
      m_prev_ema = m_last_value;
      m_calc_first_v = true;
   }
   return m_prev_ema;
}