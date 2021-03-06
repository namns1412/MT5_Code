//+------------------------------------------------------------------+
//|                                                 TP_Abritrage.mqh |
//|                                                      Daixiaorong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Daixiaorong"
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| 实现多级别止盈策略                                                                 |
//+------------------------------------------------------------------+
#include <Strategy\Strategy.mqh>
#include "..\Trailings\TrailingClassic.mqh"

input bool IsTrailing=false;
//+------------------------------------------------------------------+
//|多级别止盈策略类                                                                  |
//+------------------------------------------------------------------+
class MultiLayerTakeProfit:public CStrategy
  {
private:
   int               tp_buy_level;                //买单止盈等级
   int               tp_sell_level;               //卖单止盈等级
   double            level_gap;                   //每个等级相差的点数
   double            object_profit;
   CPosition        *latest_buy_pos;              //最近的买单仓位
   CPosition        *latest_sell_pos;             //最近的买单仓位
   double            buy_order_open_price[20];    //买单不同级别的开仓价格
   double            sell_order_open_price[20];   //空单不同级别的开仓价格
   double            LevelLots[];                 //每一级别的手数
   CArrayObj         VirtualPosition;
   PositionsStat     m_positions;
   void              RefreshActiveposition(PositionsStat &positions);
   bool              IsTrackEvents(const MarketEvent &event);
protected:
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      OnEvent(const MarketEvent &event);
public:
                     MultiLayerTakeProfit(void);
   bool              CalTakeProfitLevel(void);          //计算当前止盈等级
   double            CalTakeProfit(double point,ENUM_POSITION_TYPE m_type); //计算当前止盈点数
   void              RefreshPositions(PositionsStat &pos);  //刷新订单统计
   double            LevelGap(void) {return level_gap;}
   void              LevelGap(double value) {level_gap=value;}
   bool              LevelLot(const double &lots[]);
   double            ObjectProfit(void) {return object_profit;}
   void              ObjectProfit(double value) {object_profit=value;}
   void              SetAllTakeProfit(ENUM_POSITION_TYPE m_type,double tp);//设置所有的买单或卖单的止盈值
   bool              IsEscFirstLevel;             //判断第一级别是否需要模拟开仓
  };
//+------------------------------------------------------------------+
//| Initialization                                                                   |
//+------------------------------------------------------------------+
MultiLayerTakeProfit::MultiLayerTakeProfit(void)
  {
   tp_buy_level=0;
   tp_sell_level=0;
   level_gap=150;
   object_profit=230;
   IsEscFirstLevel=false;
   if(IsTrailing)
     {
      CTrailingClassic *classic=new CTrailingClassic();
      classic.SetDiffExtremum(0.00100);
      Trailing=classic;
     }
  }
//+------------------------------------------------------------------+
//|多单入场条件                                                                  |
//+------------------------------------------------------------------+
MultiLayerTakeProfit::InitBuy(const MarketEvent &event)
  {
   if(!IsTrackEvents(event)) return;
   if(!CalTakeProfitLevel()) return;
//---检查是否达到最大的止盈等级
   if(tp_buy_level>ArraySize(LevelLots)-1) return;
//---若当前的等级大于等于已有的多单数则允许开仓
   if(tp_buy_level>=positions.open_buy)
     {
      CPosition *pos;
      if(IsEscFirstLevel)
        {
         if(tp_buy_level==0)
           {
            CPosition *tmp_pos=new CPosition(0,ExpertMagic(),POSITION_TYPE_BUY,SymbolInfoDouble(event.symbol,SYMBOL_BID),event.symbol,TimeCurrent());
            pos=tmp_pos;
            VirtualPosition.Add(pos);
           }
         else
           {
            Trade.Buy(LevelLots[tp_buy_level],event.symbol,StringFormat("BUY 8111-%d[tp]",tp_buy_level));
            //---选中当前新开仓位
            PositionSelectByTicket(Trade.ResultOrder());
            CPosition *tmp_pos=new CPosition();
            pos=tmp_pos;
           }
         //---重新计算买卖单数
         RefreshPositions(positions);
         //---虚拟仓位数比实际仓位数多一个
         positions.open_buy++;
        }
      else
        {
         Trade.Buy(LevelLots[tp_buy_level],event.symbol,StringFormat("BUY 8111-%d[tp]",tp_buy_level));
         //---选中当前新开仓位
         PositionSelectByTicket(Trade.ResultOrder());
         CPosition *tmp_pos=new CPosition();
         pos=tmp_pos;
         //---重新计算买卖单数
         RefreshPositions(positions);
        }
      //---存储开仓价格
      buy_order_open_price[positions.open_buy-1]=pos.EntryPrice();
      //---计算当前止盈点数
      double symbol_point= SymbolInfoDouble(event.symbol,SYMBOL_POINT);
      double take_profit = NormalizeDouble(pos.EntryPrice()+CalTakeProfit(symbol_point,POSITION_TYPE_BUY)*symbol_point,
                                           (int)SymbolInfoInteger(event.symbol,SYMBOL_DIGITS));
      //---设置止盈价位
      if(pos.CurrentPrice()>take_profit) return;
      pos.TakeProfitValue(take_profit);
      SetAllTakeProfit(POSITION_TYPE_BUY,take_profit);
      latest_buy_pos=pos;
     }

  }
//+------------------------------------------------------------------+
//|空单入场条件                                                                  |
//+------------------------------------------------------------------+
MultiLayerTakeProfit::InitSell(const MarketEvent &event)
  {
   if(!IsTrackEvents(event)) return;
   if(!CalTakeProfitLevel()) return;
//---检查是否达到最大的止盈等级
   if(tp_sell_level>ArraySize(LevelLots)-1) return;
//---若当前的等级大于等于已有的多单数则允许开仓
   if(tp_sell_level>=positions.open_sell)
     {
      CPosition *pos;
      if(IsEscFirstLevel)
        {
         if(tp_sell_level==0)
           {
            CPosition *tmp_pos=new CPosition(0,ExpertMagic(),POSITION_TYPE_SELL,SymbolInfoDouble(event.symbol,SYMBOL_ASK),event.symbol,TimeCurrent());
            pos=tmp_pos;
            VirtualPosition.Add(pos);
           }
         else
           {
            Trade.Sell(LevelLots[tp_sell_level],event.symbol,StringFormat("SELL 8111-%d[tp]",tp_sell_level));
            //---选中当前新开仓位
            PositionSelectByTicket(Trade.ResultOrder());
            CPosition *tmp_pos=new CPosition();
            pos=tmp_pos;
           }
         //---重新计算买卖单数
         RefreshPositions(positions);
         //---虚拟仓位数比实际仓位数多一个
         positions.open_sell++;
        }
      else
        {
         Trade.Sell(LevelLots[tp_sell_level],event.symbol,StringFormat("SELL 8111-%d[tp]",tp_sell_level));
         //---选中当前新开仓位
         PositionSelectByTicket(Trade.ResultOrder());
         CPosition *tmp_pos=new CPosition();
         pos=tmp_pos;
         //---重新计算买卖单数
         RefreshPositions(positions);
        }
      //---存储开仓价格
      sell_order_open_price[positions.open_sell-1]=pos.EntryPrice();
      //---计算当前止盈点数
      double symbol_point= SymbolInfoDouble(event.symbol,SYMBOL_POINT);
      double take_profit = NormalizeDouble(pos.EntryPrice()-CalTakeProfit(symbol_point,POSITION_TYPE_SELL)*symbol_point,
                                           (int)SymbolInfoInteger(event.symbol,SYMBOL_DIGITS));
      //---设置止盈价位 
      pos.TakeProfitValue(take_profit);
      SetAllTakeProfit(POSITION_TYPE_SELL,take_profit);
      latest_sell_pos=pos;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MultiLayerTakeProfit::OnEvent(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_TICK) return;
   if(!IsEscFirstLevel) return;
   if(VirtualPosition.FreeMode()) VirtualPosition.FreeMode(false);
   RefreshPositions(positions);
   for(int i=0;i<VirtualPosition.Total();i++)
     {
      CPosition *cpos=VirtualPosition.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()!=ExpertSymbol())continue;
      if(cpos.Direction()==POSITION_TYPE_BUY)
        {
         if(cpos.CurrentPrice()>=cpos.TakeProfitValue())
            VirtualPosition.Delete(i);
         else
            positions.open_buy++;
        }
      else
        {
         if(cpos.CurrentPrice()<=cpos.TakeProfitValue())
            VirtualPosition.Delete(i);
         else
            positions.open_sell++;
        }
      positions.open_total+=1;
     }
  }
//+------------------------------------------------------------------+
//|计算当前的止盈等级                                                                  |
//+------------------------------------------------------------------+
bool MultiLayerTakeProfit::CalTakeProfitLevel(void)
  {
//---计算买单的止盈等级
   if(positions.open_buy>0)
     {
      if(!latest_buy_pos.IsActive()) return false;
      if(latest_buy_pos.CurrentPrice()<latest_buy_pos.EntryPrice()-level_gap*SymbolInfoDouble(latest_buy_pos.Symbol(),SYMBOL_POINT))
        {
         tp_buy_level=positions.open_buy;
        }
     }
   else
      tp_buy_level=0;

//---计算卖单的止盈等级      
   if(positions.open_sell>0)
     {
      if(!latest_sell_pos.IsActive()) return false;
      if(latest_sell_pos.CurrentPrice()>latest_sell_pos.EntryPrice()+level_gap*SymbolInfoDouble(latest_sell_pos.Symbol(),SYMBOL_POINT))
        {
         tp_sell_level=positions.open_sell;
        }
     }
   else
      tp_sell_level=0;
   return true;
  }
//+------------------------------------------------------------------+
//| 重新计算当前仓位买卖单数                                                                 |
//+------------------------------------------------------------------+
void  MultiLayerTakeProfit::RefreshPositions(PositionsStat &pos)
  {
   pos.open_buy=0;
   pos.open_sell=0;
   pos.open_total=0;
   pos.open_complex=0;
   for(int i=0; i<PositionsTotal(); i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=ExpertMagic())continue;
      if(PositionGetString(POSITION_SYMBOL)!=ExpertSymbol())continue;
      pos.open_total+=1;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         pos.open_buy++;
      else
         pos.open_sell++;
     }
  }
//+------------------------------------------------------------------+
//| 计算当前的止盈值,每一级别手数一定的情况下，每手的预期盈利时230，反推出当前需要设置的点数                                                               |
//+------------------------------------------------------------------+
double MultiLayerTakeProfit::CalTakeProfit(double point,ENUM_POSITION_TYPE m_type)
  {
   double price_diff[];
   if(m_type==POSITION_TYPE_BUY)
     {
      if(positions.open_buy<2) return object_profit;
      double total_lots=0.0;
      ArrayResize(price_diff,positions.open_buy-1,20);
      //---计算总手数
      for(int i=0;i<positions.open_buy;i++)
        {
         total_lots+=LevelLots[i]*100;
        }
      //---计算开盘价差
      for(int i=0;i<positions.open_buy-1;i++)
        {
         price_diff[i]=buy_order_open_price[i]-buy_order_open_price[i+1];
        }
      //---计算价差累积
      double cumsum_diff=0.0;
      double temp_sum=0.0;
      for(int j=positions.open_buy-2;j>=0;j--)
        {
         cumsum_diff+=(price_diff[j]/point);
         temp_sum+=(cumsum_diff*LevelLots[j]*100);
        }
      return (double)MathRound((total_lots*object_profit+temp_sum)/total_lots);
     }

   if(m_type==POSITION_TYPE_SELL)
     {
      if(positions.open_sell<2) return object_profit;
      double total_lots=0.0;
      ArrayResize(price_diff,positions.open_sell-1,20);
      //---计算总手数
      for(int i=0;i<positions.open_sell;i++)
        {
         total_lots+=LevelLots[i]*100;
        }
      //---计算开盘价差
      for(int i=0;i<positions.open_sell-1;i++)
        {
         price_diff[i]=sell_order_open_price[i+1]-sell_order_open_price[i];
        }
      //---计算价差累积
      double cumsum_diff=0.0;
      double temp_sum=0.0;
      for(int j=positions.open_sell-2;j>=0;j--)
        {
         cumsum_diff+=(price_diff[j]/point);
         temp_sum+=(cumsum_diff*LevelLots[j]*100);
        }
      return (double)MathRound((total_lots*object_profit+temp_sum)/total_lots);
     }
   Print(__FUNCTION__+"输入的类型错误!");
   return 0.0;
  }
//+------------------------------------------------------------------+
//|修改所有买单或卖单的止盈值                                                                  |
//+------------------------------------------------------------------+
void MultiLayerTakeProfit::SetAllTakeProfit(ENUM_POSITION_TYPE m_type,double tp)
  {
   for(int i=0; i<ActivePositions.Total(); i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()!=ExpertSymbol())continue;
      if(cpos.Direction()==m_type)
         cpos.TakeProfitValue(tp);
     }
   if(!IsEscFirstLevel) return;
   for(int i=0;i<VirtualPosition.Total();i++)
     {
      CPosition *cpos=VirtualPosition.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()!=ExpertSymbol())continue;
      if(cpos.Direction()==m_type)
         cpos.TakeProfitValue(tp);
     }
  }
//+------------------------------------------------------------------+
//| 判断是否追踪事件                                                                 |
//+------------------------------------------------------------------+
bool MultiLayerTakeProfit::IsTrackEvents(const MarketEvent &event)
  {
//We handle only opening of a new bar on the working symbol and timeframe
   if(event.type != MARKET_EVENT_BAR_OPEN)return false;
   if(event.period != Timeframe())return false;
   if(event.symbol != ExpertSymbol())return false;
   return true;
  }
//+------------------------------------------------------------------+
//|  设置每一级别的止盈下单的手数                                                                |
//+------------------------------------------------------------------+
bool  MultiLayerTakeProfit::LevelLot(const double &lots[])
  {
   int num=ArraySize(lots);
   ArrayResize(LevelLots,num,100);
   for(int i=0;i<num;i++)
     {
      LevelLots[i]=lots[i];
     }
   return true;
  }

//+------------------------------------------------------------------+
