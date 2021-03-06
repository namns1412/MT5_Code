//+------------------------------------------------------------------+
//|                                                         Tab3.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "Program.mqh"
#define TAB3_SYMBOL_CLASS_NUM 3
int tab_corr_index=2;//元素在tab中的索引位置
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_SYMBOL_CLASS
  {
   MARKET_TOTAL_SYMBOLS,
   MARKET_SELECT_SYMBOLS,
   CUSTOMER_DEFINE_SYMBOLS
  };
string customer_symbols[]={"GBPUSD","EURUSD","USDJPY","NZDUSD","AUDUSD","USDCAD","USDCHF","XAUUSD","XAGUSD"};
string symbol_class_string[]={"Total","Select","Custom"};
//+------------------------------------------------------------------+
//|            TAB3 创建复选框--品种类别选择                               |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3ComboBoxSymbolType(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   tab3_symbols_type.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_symbols_type);
//--- Properties
   tab3_symbols_type.XSize(120);
   tab3_symbols_type.ItemsTotal(TAB3_SYMBOL_CLASS_NUM);
   tab3_symbols_type.GetButtonPointer().XSize(70);
   tab3_symbols_type.GetButtonPointer().AnchorRightWindowSide(true);

//--- Populate the combo box list
   for(int i=0; i<TAB3_SYMBOL_CLASS_NUM; i++)
      tab3_symbols_type.SetValue(i,symbol_class_string[i]);
//--- List properties
   CListView *lv=tab3_symbols_type.GetListViewPointer();
//lv.YSize(183);
   lv.LightsHover(true);
   lv.SelectItem(lv.SelectedItemIndex()==WRONG_VALUE ? 2 : lv.SelectedItemIndex());
//--- Create a control
   if(!tab3_symbols_type.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,tab3_symbols_type);
   return(true);
  }

#define TAB3_PERIOD_NUM 6
ENUM_TIMEFRAMES tab3_time_frame[]={PERIOD_M1,PERIOD_M5,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1};
string tab3_period_string[]={"M1","M5","M30","H1","H4","D1"};
//+------------------------------------------------------------------+
//|            TAB3创建复选框--周期选择                                    |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3ComboBoxPeriodType(const int x_gap,const int y_gap,const string text)
  {
   tab3_period_type.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_period_type);
   tab3_period_type.XSize(120);
   tab3_period_type.ItemsTotal(TAB3_PERIOD_NUM);
   tab3_period_type.GetButtonPointer().XSize(70);
   tab3_period_type.GetButtonPointer().AnchorRightWindowSide(true);

   for(int i=0; i<TAB3_PERIOD_NUM; i++)
      tab3_period_type.SetValue(i,tab3_period_string[i]);

   CListView *lv=m_period_type.GetListViewPointer();
   lv.LightsHover(true);
   lv.SelectItem(lv.SelectedItemIndex()==WRONG_VALUE ? 1 : lv.SelectedItemIndex());
//--- Create a control
   if(!tab3_period_type.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,tab3_period_type);
   return(true);
  }
bool CProgram::CreateTab3ButtonsGroupDataRange(const int x_gap,const int y_gap,const string text)
   {
    tab3_data_range.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_data_range);
   int buttons_y_offset[]={5,48,88};
   string buttons_text[]={"Fix Time","Dynamic","Fix Num."};
   tab3_data_range.ButtonYSize(14);
   tab3_data_range.IsCenterText(true);
   tab3_data_range.RadioButtonsMode(true);
   tab3_data_range.RadioButtonsStyle(true);
//--- Add buttons to the group
   for(int i=0; i<3; i++)
      tab3_data_range.AddButton(0,buttons_y_offset[i],buttons_text[i],70);
//--- Create a group of buttons
   if(!tab3_data_range.CreateButtonsGroup(x_gap,y_gap))
      return(false);
//--- Highlight the second button in the group
   tab3_data_range.SelectButton(2);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,tab3_data_range);
   return(true);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3CalendarFrom(const int x_gap,const int y_gap,const string text)
  {
   tab3_calendar_from.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_calendar_from);
   if(!tab3_calendar_from.CreateDropCalendar(text,x_gap,y_gap))
      return false;
   tab3_calendar_from.SelectedDate(TimeCurrent()-7*24*60*60);
   CWndContainer::AddToElementsArray(0,tab3_calendar_from);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3CalendarTo(const int x_gap,const int y_gap,const string text)
  {
   tab3_calendar_to.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_calendar_to);
   if(!tab3_calendar_to.CreateDropCalendar(text,x_gap,y_gap))
      return false;
   tab3_calendar_to.SelectedDate(TimeCurrent()-(int)MathMod(TimeCurrent(),24*60*60));
   CWndContainer::AddToElementsArray(0,tab3_calendar_to);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3CalendarBegin(const int x_gap,const int y_gap,const string text)
  {
   tab3_calendar_begin.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_calendar_begin);
   if(!tab3_calendar_begin.CreateDropCalendar(text,x_gap,y_gap))
      return false;
   tab3_calendar_begin.SelectedDate(TimeCurrent()-7*24*60*60);
   CWndContainer::AddToElementsArray(0,tab3_calendar_begin);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3TimeEditFrom(const int x_gap,const int y_gap,const string text)
  {
   tab3_edit_from.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_edit_from);
   if(!tab3_edit_from.CreateTimeEdit(text,x_gap,y_gap))
      return false;
   tab3_edit_from.XGap(x_gap+7);
   tab3_edit_from.SetHours(0);
   tab3_edit_from.SetMinutes(0);
   CWndContainer::AddToElementsArray(0,tab3_edit_from);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3TimeEditTo(const int x_gap,const int y_gap,const string text)
  {
   tab3_edit_to.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_edit_to);
   if(!tab3_edit_to.CreateTimeEdit(text,x_gap,y_gap))
      return false;
   tab3_edit_to.XGap(x_gap+7);
   tab3_edit_to.SetHours(0);
   tab3_edit_to.SetMinutes(0);
   CWndContainer::AddToElementsArray(0,tab3_edit_to);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3TimeEditBegin(const int x_gap,const int y_gap,const string text)
  {
   tab3_edit_begin.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_edit_begin);
   if(!tab3_edit_begin.CreateTimeEdit(text,x_gap,y_gap))
      return false;
   tab3_edit_begin.XGap(x_gap+7);
   tab3_edit_begin.SetHours(0);
   tab3_edit_begin.SetMinutes(0);
   CWndContainer::AddToElementsArray(0,tab3_edit_begin);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateTab3TextEditFixNum(const int x_gap,const int y_gap,const string text)
  {
   tab3_fix_num.MainPointer(m_tabs1);
   m_tabs1.AddToElementsArray(2,tab3_fix_num);

//--- Properties
   tab3_fix_num.XSize(100);
   tab3_fix_num.MaxValue(1000);
   tab3_fix_num.MinValue(60);
   tab3_fix_num.StepValue(10);
   tab3_fix_num.SetDigits(0);
   tab3_fix_num.SpinEditMode(true);
   tab3_fix_num.SetValue((string)500);
   tab3_fix_num.GetTextBoxPointer().XSize(50);
   tab3_fix_num.GetTextBoxPointer().AutoSelectionMode(true);
   tab3_fix_num.GetTextBoxPointer().AnchorRightWindowSide(true);

   if(!tab3_fix_num.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,tab3_fix_num);
   return(true);

  }
bool CProgram::CreateTab3CorrTable(const int x_gap,const int y_gap)
   {
    tab3_corr_table.MainPointer(m_tabs1);
    m_tabs1.AddToElementsArray(2,tab3_corr_table);
    string table_title[]={"symbol-1","symbol-2","M1","M5","M30","H1","H4","D1","Res"};
    tab3_corr_table.TableSize(ArraySize(table_title),500);
    tab3_corr_table.CellYSize(25);
    tab3_corr_table.AutoXResizeMode(false);
    tab3_corr_table.AutoYResizeMode(false);
    tab3_corr_table.IsSortMode(true);
    //tab3_corr_table.AutoXResizeRightOffset(10);
    //tab3_corr_table.AutoYResizeBottomOffset(10);
    tab3_corr_table.ShowHeaders(true);
    tab3_corr_table.HeaderYSize(30);
    //tab3_corr_table.ChangeWidthByRightWindowSide();
    
    for(int i=0;i<ArraySize(table_title);i++)
      {
       tab3_corr_table.SetHeaderText(i,table_title[i]);
      }
    tab3_corr_table.HeadersColor(clrGreenYellow);
    if(!tab3_corr_table.CreateTable(x_gap,y_gap))
        return false;
    CWndContainer::AddToElementsArray(0,tab3_corr_table); 
    return true; 
   }
   
CArrayObj *CProgram::GetCorrData(void)
   {
   //---获取需要监控的品种列表
    string symbols_focus[];
    int symbol_choose=tab3_symbols_type.GetListViewPointer().SelectedItemIndex();
    switch(symbol_choose)
      {
       case 0:
          ArrayResize(symbols_focus,SymbolsTotal(false));
          for(int i=0;i<SymbolsTotal(false);i++)
            {
             symbols_focus[i]=SymbolName(i,false);
             Print("Add Symbol:", SymbolName(i,false));
            }
          break;
       case 1:
          ArrayResize(symbols_focus,SymbolsTotal(true));
          for(int i=0;i<SymbolsTotal(true);i++)
            {
             symbols_focus[i]=SymbolName(i,true);
             Print("Add Symbol:", SymbolName(i,true));
            }
          break;
            
       default:
         ArrayCopy(symbols_focus,customer_symbols);
         break;   
      }
    Print("当前监控的品种数:",ArraySize(symbols_focus), " ", symbol_choose);
    //---获取时间间隔
    datetime from=tab3_calendar_from.SelectedDate()+tab3_edit_from.GetHours()*60*60+tab3_edit_from.GetMinutes()*60;
    datetime to=tab3_calendar_to.SelectedDate()+tab3_edit_to.GetHours()*60*60+tab3_edit_to.GetMinutes()*60;
    datetime begin=tab3_calendar_begin.SelectedDate()+tab3_edit_begin.GetHours()*60*60+tab3_edit_begin.GetMinutes()*60;
    int p_num=(int)tab3_fix_num.GetValue();
    
    CForexMarketDataManager *dm=new CForexMarketDataManager();
    dm.SetParameter(symbols_focus,tab3_time_frame);
    CForexMarketDataAnalyzier *da=new CForexMarketDataAnalyzier();
    CArrayObj *correlation_res=new CArrayObj();
    switch(tab3_data_range.SelectedButtonIndex())
      {
       case 0 :
          Print("选择相关系数计算数据周期：Begin to End");
          Print("正在计算相关系数,请稍后...");
          dm.RefreshSymbolsPrice(from,to);
          da.SetDataManager(dm);
          da.GetPearsonCorrN(correlation_res);
           Print("相关系数计算完成！");
         break;
       case 1:
         Print("选择相关系数计算数据周期：Begin to Current");
         Print("正在计算相关系数,请稍后...");
          dm.RefreshSymbolsPrice(begin);
          da.SetDataManager(dm);
          da.GetPearsonCorrN(correlation_res);
           Print("相关系数计算完成！");
          break;
       default:
          Print("选择相关系数计算数据周期：Fix Num To Current");
          Print("正在计算相关系数,请稍后...");
          dm.RefreshSymbolsPrice(p_num);
          da.SetDataManager(dm);
          da.GetPearsonCorrN(correlation_res);
          Print("相关系数计算完成！");
         break;
      }
    delete dm;
    delete da;
    return correlation_res;
   }
bool CProgram::UpdateTab3CorrTable(void)
   {
    CArrayObj *corr = new CArrayObj();
    corr=GetCorrData();
    Print("开始写入数据...");
    ClearTab3CorrTableText();
    for(int i=0;i<corr.Total();i++)
      {
       CArrayObj *corr_period=corr.At(i);
       for(int j=0;j<corr_period.Total();j++)
         {
          CForexCorr *fc=corr_period.At(j);
          tab3_corr_table.SetValue(0,j,fc.symbol1,0,true); 
          tab3_corr_table.SetValue(1,j,fc.symbol2,0,true); 
          tab3_corr_table.SetValue(i+2,j,DoubleToString(fc.r,2),0,true);
          if(fc.r>=0.795) tab3_corr_table.TextColor(i+2,j,clrBlue);
          else if(fc.r<=-0.795) tab3_corr_table.TextColor(i+2,j,clrRed); 
          else tab3_corr_table.TextColor(i+2,j,clrBlack);
          tab3_corr_table.Update(true);
         }
      }
    Print("数据写入完成...");
    delete corr;
    return true;
   }
void CProgram::ClearTab3CorrTableText(void)
   {
    for(uint i=0;i<tab3_corr_table.RowsTotal();i++)
      {
       for(uint j=0;j<tab3_corr_table.ColumnsTotal();j++)
         {
          tab3_corr_table.SetValue(j,i,NULL,0,true);
         }
      }
   }
//+------------------------------------------------------------------+
