//+------------------------------------------------------------------+
//|                                            TwoSymbolArbtrage.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include "common.mqh"
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayLong.mqh>
#include <strategy_czj\common\CombinePositionState.mqh>
#include <strategy_czj\common\strategy_common.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTwoSymbolArbitrage:public CStrategy
  {
private:
   string            major_symbol;//主交易品种
   string            minor_symbol;//次交易品种
   RelationType      type_relation;//品种相关关系
   MqlTick           latest_price_major; //最新的symbol-major tick报价
   MqlTick           latest_price_minor; //最新的symbol-minor tick报价
   CArrayObj         combine_pos_state;// 仓位状态

protected:
   int               indicator_handle;   // 套利使用的指标
   double            indicator_values[];
   ArbitragePosition pos_statics; // 所有仓位的统计结果

   double            ind_up_open_short; // 指标开空0.9
   double            ind_down_open_long; // 指标开多0.1
   double            ind_up_close_long; // 指标平多0.7
   double            ind_down_close_short; // 指标平空0.3
   int               win_points; // 每手止盈点数
   double            time_out_days;// 固定时间出场

   double            lots_major_symbol; // major手数
   double            lots_minor_symbol; // minor手数
   double            base_lots;
   string            open_tag;   // 开仓的comment
   string            close_tag; // 平仓的comment

   bool              levels_to_close; // 是否多级条件出发出场
   int               num_levels; // 级数

   double            win_levels[]; // 每一级的止盈点
   double            ind_close_long_levels[]; // 每一级注意赢点同时对应的平多指标触发
   double            ind_close_short_levels[]; // 每一级注意赢点同时对应的平多指标触发

protected:

   virtual void      OnEvent(const MarketEvent &event);//事件处理
   void              RefreshPosition(void);//刷新仓位信息
   virtual bool      OpenLongCondition();// 开多头条件
   virtual bool      OpenShortCondition();// 开空头条件
   virtual void      OpenLongPosition();// 开多头仓位
   virtual void      OpenShortPosition();// 开空头仓位
   virtual bool      CloseCondition(CCombinePositionState *pos);// 平仓条件
   virtual void      ClosePosition(CCombinePositionState *pos);// 平仓操作
   virtual void      CalLots();// 计算手数

public:
                     CTwoSymbolArbitrage(void);
                    ~CTwoSymbolArbitrage(void){};
   virtual void      SetIndicatorParameter(string symbol_major,string symbol_minor,CointergrationCalType type_cointergration,IndicatorCalType type_indicator,int tau_indicator,bool use_prob,int prob_tau);//设置指标参数
   virtual void      SetOpenCloseParameter(double indicator_open_long,double indicator_open_short,double indicator_close_long,double indicator_close_short,int points_win,double out_days,double lots_base);
   virtual void      SetCloseLevels(bool need_levels=false,int levels_num=1);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTwoSymbolArbitrage::CTwoSymbolArbitrage(void)
  {
//CTwoSymbolArbitrage::SetIndicatorParameter("XAUUSD","USDJPY",ENUM_COINTERGRATION_TYPE_MULTIPLY,ENUM_INDICATOR_TYPE_BIAS,1440);
//ind_down_open_long=-0.3;
//ind_up_open_short=0.3;
//base_lots=0.1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTwoSymbolArbitrage::SetIndicatorParameter(string symbol_major,
                                                string symbol_minor,
                                                CointergrationCalType type_cointergration,
                                                IndicatorCalType type_indicator,
                                                int tau_indicator,
                                                bool use_prob,
                                                int prob_tau)
  {
   major_symbol=symbol_major;
   minor_symbol=symbol_minor;
   indicator_handle=iCustom(ExpertSymbol(),Timeframe(),"MyIndicators\\CZJIndicators\\TwoSymbolCointerIndicator",symbol_major,symbol_minor,type_cointergration,tau_indicator,type_indicator,use_prob,prob_tau);
   switch(type_cointergration)
     {
      case ENUM_COINTERGRATION_TYPE_DIVIDE:
      case ENUM_COINTERGRATION_TYPE_LOG_DIFF:
      case ENUM_COINTERGRATION_TYPE_MINUS:
         type_relation=ENUM_RELATION_TYPE_POSITIVE;
         break;
      case ENUM_COINTERGRATION_TYPE_PLUS:
      case ENUM_COINTERGRATION_TYPE_MULTIPLY:
         type_relation=ENUM_RELATION_TYPE_NEGATIVE;
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTwoSymbolArbitrage::SetOpenCloseParameter(double indicator_open_long,
                                                double indicator_open_short,
                                                double indicator_close_long,
                                                double indicator_close_short,
                                                int points_win,
                                                double out_days,
                                                double lots_base)
  {
   ind_down_open_long=indicator_open_long;
   ind_up_open_short=indicator_open_short;
   ind_up_close_long=indicator_close_long;
   ind_down_close_short=indicator_close_short;
   win_points=points_win;
   time_out_days=out_days;
   base_lots=lots_base;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTwoSymbolArbitrage::SetCloseLevels(bool need_levels=false,int levels_num=1)
  {
   levels_to_close=need_levels;
   num_levels=levels_num;
   if(levels_to_close)
     {
      ArrayResize(win_levels,levels_num);
      ArrayResize(ind_close_long_levels,levels_num);
      ArrayResize(ind_close_short_levels,levels_num);
      for(int i=0;i<levels_num;i++)
        {
         win_levels[i]=win_points/(i+2);
         ind_close_long_levels[i]=ind_up_close_long-(ind_up_close_long-ind_down_open_long)*(levels_num-i-1)/levels_num;
         ind_close_short_levels[i]=ind_down_close_short+(ind_up_open_short-ind_down_close_short)*(levels_num-i-1)/levels_num;
        }
     }
  }
//+------------------------------------------------------------------+
//|                     事件处理                                       |
//+------------------------------------------------------------------+
void CTwoSymbolArbitrage::OnEvent(const MarketEvent &event)
  {
// EA挂载品种的Bar事件处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {

     }
//EA挂载品种的Tick事件处理
   if((event.symbol==ExpertSymbol()) && event.type==MARKET_EVENT_TICK)
     {
      CopyBuffer(indicator_handle,0,0,1,indicator_values);
      SymbolInfoTick(major_symbol,latest_price_major);
      SymbolInfoTick(minor_symbol,latest_price_minor);
      //       刷新仓位信息
      RefreshPosition();
      //      平仓判断
      for(int i=combine_pos_state.Total()-1;i>=0;i--)
        {
         CCombinePositionState *pos=combine_pos_state.At(i);
         if(CloseCondition(pos))
           {
            ClosePosition(pos);
            combine_pos_state.Delete(i);
           }
        }
      //    刷新仓位，进行开仓判断
      RefreshPosition();
      if(OpenLongCondition())
        {
         CalLots();
         OpenLongPosition();
        }
      if(OpenShortCondition())
        {
         CalLots();
         OpenShortPosition();
        }
     }
  }
//+------------------------------------------------------------------+
//|                  开多头操作                                      |
//+------------------------------------------------------------------+
void CTwoSymbolArbitrage::OpenLongPosition()
  {
   CCombinePositionState *pos_combine=new CCombinePositionState(POSITION_TYPE_BUY);
   switch(type_relation)
     {
      case ENUM_RELATION_TYPE_NEGATIVE:
         Trade.PositionOpen(major_symbol,ORDER_TYPE_BUY,lots_major_symbol,latest_price_major.ask,0,0,open_tag);
         pos_combine.AddPosID(Trade.ResultOrder());
         Trade.PositionOpen(minor_symbol,ORDER_TYPE_BUY,lots_minor_symbol,latest_price_minor.ask,0,0,open_tag);
         pos_combine.AddPosID(Trade.ResultOrder());
         break;
      case ENUM_RELATION_TYPE_POSITIVE:
         Trade.PositionOpen(major_symbol,ORDER_TYPE_BUY,lots_major_symbol,latest_price_major.ask,0,0,open_tag);
         pos_combine.AddPosID(Trade.ResultOrder());
         Trade.PositionOpen(minor_symbol,ORDER_TYPE_SELL,lots_minor_symbol,latest_price_minor.bid,0,0,open_tag);
         pos_combine.AddPosID(Trade.ResultOrder());
         break;
      default:
         Print("Relation ship has not defined!");
         break;
     }
   combine_pos_state.Add(pos_combine);
  }
//+------------------------------------------------------------------+
//|                 开空头操作                                     |
//+------------------------------------------------------------------+
void CTwoSymbolArbitrage::OpenShortPosition()
  {
   CCombinePositionState *pos_combine=new CCombinePositionState(POSITION_TYPE_SELL);
   switch(type_relation)
     {
      case ENUM_RELATION_TYPE_NEGATIVE:
         Trade.PositionOpen(major_symbol,ORDER_TYPE_SELL,lots_major_symbol,latest_price_major.bid,0,0,open_tag);
         pos_combine.AddPosID(Trade.ResultOrder());
         Trade.PositionOpen(minor_symbol,ORDER_TYPE_SELL,lots_minor_symbol,latest_price_minor.bid,0,0,open_tag);
         pos_combine.AddPosID(Trade.ResultOrder());
         break;
      case ENUM_RELATION_TYPE_POSITIVE:
         Trade.PositionOpen(major_symbol,ORDER_TYPE_SELL,lots_major_symbol,latest_price_major.bid,0,0,open_tag);
         pos_combine.AddPosID(Trade.ResultOrder());
         Trade.PositionOpen(minor_symbol,ORDER_TYPE_BUY,lots_minor_symbol,latest_price_minor.ask,0,0,open_tag);
         pos_combine.AddPosID(Trade.ResultOrder());
         break;
      default:
         Print("Relation ship has not defined!");
         break;
     }
   combine_pos_state.Add(pos_combine);
  }
//+------------------------------------------------------------------+
//|                     刷新仓位信息                                 |
//+------------------------------------------------------------------+
void CTwoSymbolArbitrage::RefreshPosition(void)
  {
   pos_statics.Init();
   for(int i=0;i<combine_pos_state.Total();i++)
     {
      CCombinePositionState *pos=combine_pos_state.At(i);
      pos.RefreshPositionStates();
      pos_statics.pair_open_total++;
      if(pos.Type()==POSITION_TYPE_BUY)
        {
         pos_statics.pair_open_buy++;
         pos_statics.pair_buy_profit+=pos.Profits();
        }
      else
        {
         pos_statics.pair_open_sell++;
         pos_statics.pair_sell_profit+=pos.Profits();
        }
     }
  }
//+------------------------------------------------------------------+
//|                              平仓                                |
//+------------------------------------------------------------------+
void CTwoSymbolArbitrage::ClosePosition(CCombinePositionState *pos)
  {
   CArrayLong *tickets=pos.PosTickets();
   for(int i=0;i<tickets.Total();i++)
     {
      Trade.PositionClose(tickets.At(i),-1,close_tag);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTwoSymbolArbitrage::OpenLongCondition()
  {

   if(indicator_values[0]<ind_down_open_long && pos_statics.pair_open_buy<=0)
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTwoSymbolArbitrage::OpenShortCondition()
  {
   if(indicator_values[0]>ind_up_open_short && pos_statics.pair_open_sell<=0)
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTwoSymbolArbitrage::CloseCondition(CCombinePositionState *pos)
  {
   if(pos.Profits()/pos.Lots()>win_points)
     {
      close_tag="TP:"+DoubleToString(pos.Profits()/pos.Lots(),2);
      return true;
     }

   if(pos.Holdtime()/24>time_out_days)
     {
      close_tag="OutTime:"+DoubleToString(pos.Holdtime()/24,2);
      return true;
     }

   if(pos.Type()==POSITION_TYPE_BUY && indicator_values[0]>ind_up_close_long)
     {
      close_tag="OutInd:"+DoubleToString(indicator_values[0],2);
      return true;
     }
   if(pos.Type()==POSITION_TYPE_SELL && indicator_values[0]<ind_down_close_short)
     {
      close_tag="OutInd:"+" Ind:"+DoubleToString(indicator_values[0],2);
      return true;
     }

   if(levels_to_close)
     {
      for(int i=0;i<num_levels;i++)
        {
         if(pos.Type()==POSITION_TYPE_BUY && indicator_values[0]>ind_close_long_levels[i] && pos.Profits()/pos.Lots()>win_levels[i])
           {
            close_tag="OutLevel:"+string(i)+" Ind:"+DoubleToString(indicator_values[0],2)+" Tp:"+DoubleToString(pos.Profits(),2);
            return true;
           }
         if(pos.Type()==POSITION_TYPE_SELL && indicator_values[0]<ind_close_short_levels[i] && pos.Profits()/pos.Lots()>win_levels[i])
           {
            close_tag="OutLevel:"+string(i)+" Ind:"+DoubleToString(indicator_values[0],2)+" Tp:"+DoubleToString(pos.Profits(),2);
            return true;
           }
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTwoSymbolArbitrage::CalLots(void)
  {
   if(StringSubstr(major_symbol,0,3)=="USD")
      lots_major_symbol=NormalizeDouble(base_lots*(latest_price_major.ask/SymbolInfoDouble(major_symbol,SYMBOL_POINT)/100000),2);
   else
      lots_major_symbol=base_lots;

   if(StringSubstr(minor_symbol,0,3)=="USD")
      lots_minor_symbol=NormalizeDouble(base_lots*(latest_price_minor.ask/SymbolInfoDouble(minor_symbol,SYMBOL_POINT)/100000),2);
   else
      lots_minor_symbol=base_lots;
  }
//+------------------------------------------------------------------+
