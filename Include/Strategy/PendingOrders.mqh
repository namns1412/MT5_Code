//+------------------------------------------------------------------+
//|                                                PendingOrders.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#include <Dictionary.mqh>
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| A class representing a pending order                             |
//+------------------------------------------------------------------+
class CPendingOrder : public CObject
{
private:
   ulong                   m_ticket;
   CTrade                  m_trade;
public:
                           CPendingOrder(ulong ticket);
   ulong                   Magic(void);
   string                  Symbol(void);
   string                  Comment(void);
   ENUM_ORDER_TYPE         Type(void);
   ENUM_ORDER_STATE        State(void);
   ENUM_ORDER_TYPE_FILLING TypeFilling(void);
   ENUM_ORDER_TYPE_TIME    TypeTime(void);
   ulong                   Ticket(void);
   datetime                TimeExp(void);
   datetime                TimeDone(void);
   datetime                TimeSetup(void);
   long                    TimeSetupMsc(void);
   long                    TimeDoneMsc(void);
   long                    PositionID(void);
   long                    PositionByID(void);
   
   double                  VolumeInit(void);
   double                  VolumeCurrent(void);
   double                  PriceOpen(void);
   double                  PriceCurrent(void);
   double                  StopLoss(void);
   double                  TakeProfit(void);
   bool                    IsMain(string symbol, ulong magic);
   bool                    Modify(const double price,const double sl,const double tp,
                                  const ENUM_ORDER_TYPE_TIME type_time,const datetime expiration,const double stoplimit=0.0);
   bool                    Modify(double price);
   bool                    Delete(void);
};

//+------------------------------------------------------------------+
//| Create a class of a pending order                                |
//+------------------------------------------------------------------+
CPendingOrder::CPendingOrder(ulong ticket)
{
   if(!OrderSelect(ticket))
      m_ticket = 0;
   else
      m_ticket = ticket;
}
//+------------------------------------------------------------------+
//| Modifies a pending order                                         |
//+------------------------------------------------------------------+
bool CPendingOrder::Modify(const double price,const double sl,const double tp,
                    const ENUM_ORDER_TYPE_TIME type_time,const datetime expiration,const double stoplimit=0.0)
{
   return m_trade.OrderModify(m_ticket, price, sl, tp, type_time, expiration, stoplimit);
}
//+------------------------------------------------------------------+
//| Modifies a pending order                                         |
//+------------------------------------------------------------------+
bool CPendingOrder::Modify(double price)
{
   return m_trade.OrderModify(m_ticket, price, StopLoss(), TakeProfit(), TypeTime(), TimeExp(), 0.0);
}
//+------------------------------------------------------------------+
//| Deletes a pending order                                          |
//+------------------------------------------------------------------+
bool CPendingOrder::Delete(void)
{
   return m_trade.OrderDelete(m_ticket);
}
//+------------------------------------------------------------------+
//| Returns true if the order belongs to the EA with the specified   |
//| magic number and symbol. Returns false if otherwise              |
//|                                                                  |
//+------------------------------------------------------------------+
bool CPendingOrder::IsMain(string symbol,ulong magic)
{
   if(Magic() == magic && Symbol() == symbol)
      return true;
   return false;
}
//+------------------------------------------------------------------+
//| Returns the magic number of the order                            |
//+------------------------------------------------------------------+
ulong CPendingOrder::Magic(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return OrderGetInteger(ORDER_MAGIC);
}

//+------------------------------------------------------------------+
//| Returns the symbol of the order                                  |
//+------------------------------------------------------------------+
string CPendingOrder::Symbol(void)
{
   if(!OrderSelect(m_ticket))return "";
   return OrderGetString(ORDER_SYMBOL);
}
//+------------------------------------------------------------------+
//| Returns the order comment                                        |
//+------------------------------------------------------------------+
string CPendingOrder::Comment(void)
{
   if(!OrderSelect(m_ticket))return "";
   return OrderGetString(ORDER_COMMENT);
}
//+------------------------------------------------------------------+
//| Returns the order type                                           |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE CPendingOrder::Type(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
}
//+------------------------------------------------------------------+
//| Returns the order state                                          |
//+------------------------------------------------------------------+
ENUM_ORDER_STATE CPendingOrder::State(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE);
}
//+------------------------------------------------------------------+
//| Returns the order execution type                                 |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING CPendingOrder::TypeFilling(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return (ENUM_ORDER_TYPE_FILLING)OrderGetInteger(ORDER_TYPE_FILLING);
}
//+------------------------------------------------------------------+
//| Type of order execution time                                     |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_TIME CPendingOrder::TypeTime(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return (ENUM_ORDER_TYPE_TIME)OrderGetInteger(ORDER_TYPE_TIME);
}
//+------------------------------------------------------------------+
//| The ticket of the order                                          |
//+------------------------------------------------------------------+
ulong CPendingOrder::Ticket(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return (ulong)OrderGetInteger(ORDER_TICKET);
}
//+------------------------------------------------------------------+
//| Order expiration time                                            |
//+------------------------------------------------------------------+
datetime CPendingOrder::TimeExp(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return (datetime)OrderGetInteger(ORDER_TIME_EXPIRATION);
}
//+------------------------------------------------------------------+
//| Order execution time                                             |
//+------------------------------------------------------------------+
datetime CPendingOrder::TimeDone(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return (datetime)OrderGetInteger(ORDER_TIME_DONE);
}
//+------------------------------------------------------------------+
//| Order placing time                                               |
//+------------------------------------------------------------------+
datetime CPendingOrder::TimeSetup(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return (datetime)OrderGetInteger(ORDER_TIME_SETUP);
}
//+------------------------------------------------------------------+
//| Order placing time in milliseconds                               |
//+------------------------------------------------------------------+
long CPendingOrder::TimeSetupMsc(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return OrderGetInteger(ORDER_TIME_SETUP_MSC);
}
//+------------------------------------------------------------------+
//| Order execution time in milliseconds                             |
//+------------------------------------------------------------------+
long CPendingOrder::TimeDoneMsc(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return OrderGetInteger(ORDER_TIME_DONE_MSC);
}
//+------------------------------------------------------------------+
//| ID of the position to which the order belongs                    |
//+------------------------------------------------------------------+
long CPendingOrder::PositionID(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return OrderGetInteger(ORDER_POSITION_ID);
}
//+------------------------------------------------------------------+
//| ID of position to which the order belongs for hedge accounts     |
//+------------------------------------------------------------------+
long CPendingOrder::PositionByID(void)
{
   if(!OrderSelect(m_ticket))return 0;
   return OrderGetInteger(ORDER_POSITION_BY_ID);
}
//+------------------------------------------------------------------+
//| Initial order volume                                             |
//+------------------------------------------------------------------+
double CPendingOrder::VolumeInit(void)
{
   if(!OrderSelect(m_ticket))return 0.0;
   return OrderGetDouble(ORDER_VOLUME_INITIAL);
}
//+------------------------------------------------------------------+
//| Filled volume of the order                                       |
//+------------------------------------------------------------------+
double CPendingOrder::VolumeCurrent(void)
{
   if(!OrderSelect(m_ticket))return 0.0;
   return OrderGetDouble(ORDER_VOLUME_CURRENT);
}
//+------------------------------------------------------------------+
//| Order Open price                                                 |
//+------------------------------------------------------------------+
double CPendingOrder::PriceOpen(void)
{
   if(!OrderSelect(m_ticket))return 0.0;
   return OrderGetDouble(ORDER_PRICE_OPEN);
}
//+------------------------------------------------------------------+
//| Order Open price                                                 |
//+------------------------------------------------------------------+
double CPendingOrder::PriceCurrent(void)
{
   if(!OrderSelect(m_ticket))return 0.0;
   return OrderGetDouble(ORDER_PRICE_CURRENT);
}
//+------------------------------------------------------------------+
//| Stop Loss of the order                                           |
//+------------------------------------------------------------------+
double CPendingOrder::StopLoss(void)
{
   if(!OrderSelect(m_ticket))return 0.0;
   return OrderGetDouble(ORDER_SL);
}
//+------------------------------------------------------------------+
//| Take Profit of the order                                         |
//+------------------------------------------------------------------+
double CPendingOrder::TakeProfit(void)
{
   if(!OrderSelect(m_ticket))return 0.0;
   return OrderGetDouble(ORDER_TP);
}
//+------------------------------------------------------------------+
//| A class for operations with pending orders                       |
//+------------------------------------------------------------------+
class COrdersEnvironment
{
private:
   CDictionary    m_orders;         // The total number of all pending orders
public:
                  COrdersEnvironment(void);
   int            Total(void);
   CPendingOrder* GetOrder(int index);
};
//+------------------------------------------------------------------+
//| We need to know the current symbol and magic number of the EA    |
//+------------------------------------------------------------------+
COrdersEnvironment::COrdersEnvironment(void)
{
}
//+------------------------------------------------------------------+
//| Returns a pending order                                          |
//+------------------------------------------------------------------+
CPendingOrder* COrdersEnvironment::GetOrder(int index)
{
   ulong ticket = OrderGetTicket(index);
   if(ticket == 0)
      return NULL;
   int total = m_orders.Total();
   if(m_orders.ContainsKey(ticket))
      return m_orders.GetObjectByKey(ticket);
   if(!OrderSelect(ticket))
      return NULL;
   CPendingOrder* order = new CPendingOrder(ticket);
   m_orders.AddObject(ticket, order);
   return order;
}
//+------------------------------------------------------------------+
//| Returns the number of pending orders                             |
//+------------------------------------------------------------------+
int COrdersEnvironment::Total(void)
{
   return OrdersTotal();   
}