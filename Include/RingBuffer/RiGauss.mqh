//+------------------------------------------------------------------+
//|                                                   RingBuffer.mqh |
//|                                 Copyright 2016, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include "RiBuffDbl.mqh"
#include <Math\AlgLib\AlgLib.mqh>
//+------------------------------------------------------------------+
//| Calculate the main parameters of the Gaussian distribution       |
//+------------------------------------------------------------------+
class CRiGaussProperty : public CRiBuffDbl
{
private:
   double        m_mean;      // Mean
   double        m_variance;  // Variance
   double        m_skewness;  // Skewness
   double        m_kurtosis;  // Kurtosis
protected:
   virtual void  OnChangeArray(void);
public:
   double        Mean(void){ return m_mean;}
   double        StdDev(void){return m_variance;}
   double        Skewness(void){return m_skewness;}
   double        Kurtosis(void){return m_kurtosis;}
};
//+------------------------------------------------------------------+
//| Calculation is performed in case of any array change             |
//+------------------------------------------------------------------+
void CRiGaussProperty::OnChangeArray(void)
{
   double array[];
   ToArray(array);
   CAlglib::SampleMoments(array, m_mean, m_variance, m_skewness, m_kurtosis);
}