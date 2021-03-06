//+------------------------------------------------------------------+
//|                                                      Program.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Math\Stat\Stat.mqh>
#include <EasyAndFastGUI\WndEvents.mqh>
#include <EasyAndFastGUI\TimeCounter.mqh>
//+------------------------------------------------------------------+
//| Class for creating an application                                |
//+------------------------------------------------------------------+
class CProgram : public CWndEvents
  {
protected:
   //--- Time counters
   CTimeCounter      m_counter1; // for updating the items in the status bar
   //--- Main window
   CWindow           m_window1;
   //--- Dialog box with a color picker to select a color
   CWindow           m_window2;
   //--- Status bar
   CStatusBar        m_status_bar;
   //--- Icon
   CPicture          m_picture1;
   //--- Tabs
   CTabs             m_tabs1;
   //--- Elements of the first tab
   CColorButton      m_back_color;
   CColorButton      m_back_main_color;
   CColorButton      m_back_sub_color;
   CTextEdit         m_main_text;
   CTextEdit         m_sub_text;
   CTextEdit         m_font_main_size;
   CTextEdit         m_font_sub_size;
   //--- Elements of the second tab
   CTextEdit         m_indent_left;
   CTextEdit         m_indent_right;
   CTextEdit         m_indent_up;
   CTextEdit         m_indent_down;
   CTextEdit         m_history_name_width;
   CTextEdit         m_history_name_size;
   CTextEdit         m_history_symbol_size;
   CTextEdit         m_gap_size;
   CTextEdit         m_major_mark_size;
   //--- Elements of the third tab
   CColorButton      m_grid_line_color;
   CColorButton      m_grid_axis_line_color;
   CColorButton      m_grid_back_color;
   CCheckBox         m_grid_has_circle;
   CTextEdit         m_grid_circle_radius;
   CColorButton      m_grid_circle_color;
   //--- Elements of the fourth tab
   CButtonsGroup     m_select_axes;
   CSeparateLine     m_sep_line1;
   //---
   CCheckBox         m_auto_scale;
   CTextEdit         m_axis_min;
   CTextEdit         m_axis_max;
   CTextEdit         m_axis_max_grace;
   CTextEdit         m_axis_min_grace;
   //---
   CTextEdit         m_values_size;
   CTextEdit         m_values_width;
   CTextEdit         m_name_size;
   CTextEdit         m_default_step;
   CTextEdit         m_max_labels;
   //---
   CTextEdit         m_axis_name;
   CColorButton      m_axis_color;

   //--- Color picker
   CColorPicker      m_color_picker;
   //--- Charts
   CGraph            m_graph1;

   //--- Arrays of data for output on the chart
   double            data1[];
   double            data2[];
   //---
public:
                     CProgram(void);
                    ~CProgram(void);
   //--- Initialization/deinitialization
   void              OnInitEvent(void);
   void              OnDeinitEvent(const int reason);
   //--- Timer
   void              OnTimerEvent(void);
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   //--- Create the graphical interface of the program
   bool              CreateGUI(void);
   //---
protected:
   //--- Main window
   bool              CreateWindow1(const string text);
   //--- Dialog box with a color picker to select a color
   bool              CreateWindow2(const string text);
   //--- Color picker
   bool              CreateColorPicker(const int x_gap,const int y_gap);

   //--- Status bar
   bool              CreateStatusBar(const int x_gap,const int y_gap);
   //--- Pictures
   bool              CreatePicture1(const int x_gap,const int y_gap);
   //--- Tabs
   bool              CreateTabs1(const int x_gap,const int y_gap);

   //--- Elements of the first tab
   bool              CreateBackColor(const int x_gap,const int y_gap,const string text);
   bool              CreateMainColor(const int x_gap,const int y_gap,const string text);
   bool              CreateSubColor(const int x_gap,const int y_gap,const string text);
   bool              CreateMainText(const int x_gap,const int y_gap,const string text);
   bool              CreateSubText(const int x_gap,const int y_gap,const string text);
   bool              CreateFontMainSize(const int x_gap,const int y_gap,const string text);
   bool              CreateFontSubSize(const int x_gap,const int y_gap,const string text);
   //--- Elements of the second tab
   bool              CreateIndentLeft(const int x_gap,const int y_gap,const string text);
   bool              CreateIndentRight(const int x_gap,const int y_gap,const string text);
   bool              CreateIndentUp(const int x_gap,const int y_gap,const string text);
   bool              CreateIndentDown(const int x_gap,const int y_gap,const string text);
   bool              CreateHistoryNameWidth(const int x_gap,const int y_gap,const string text);
   bool              CreateHistoryNameSize(const int x_gap,const int y_gap,const string text);
   bool              CreateHistorySymbolSize(const int x_gap,const int y_gap,const string text);
   bool              CreateGapSize(const int x_gap,const int y_gap,const string text);
   bool              CreateMajorMarkSize(const int x_gap,const int y_gap,const string text);
   //--- Elements of the third tab
   bool              CreateGridLineColor(const int x_gap,const int y_gap,const string text);
   bool              CreateGridAxisLineColor(const int x_gap,const int y_gap,const string text);
   bool              CreateGridBackColor(const int x_gap,const int y_gap,const string text);
   bool              CreateGridHasCircle(const int x_gap,const int y_gap,const string text);
   bool              CreateGridCircleRadius(const int x_gap,const int y_gap,const string text);
   bool              CreateGridCircleColor(const int x_gap,const int y_gap,const string text);
   //--- Elements of the fourth tab
   bool              CreateSelectAxes(const int x_gap,const int y_gap);
   bool              CreateSepLine1(const int x_gap,const int y_gap);
   //---
   bool              CreateAutoScale(const int x_gap,const int y_gap,const string text);
   bool              CreateAxisMin(const int x_gap,const int y_gap,const string text);
   bool              CreateAxisMax(const int x_gap,const int y_gap,const string text);
   bool              CreateAxisMinGrace(const int x_gap,const int y_gap,const string text);
   bool              CreateAxisMaxGrace(const int x_gap,const int y_gap,const string text);
   //---
   bool              CreateValuesSize(const int x_gap,const int y_gap,const string text);
   bool              CreateValuesWidth(const int x_gap,const int y_gap,const string text);
   bool              CreateNameSize(const int x_gap,const int y_gap,const string text);
   bool              CreateDefaultStep(const int x_gap,const int y_gap,const string text);
   bool              CreateMaxLabels(const int x_gap,const int y_gap,const string text);
   //---
   bool              CreateAxisName(const int x_gap,const int y_gap,const string text);
   bool              CreateAxisColor(const int x_gap,const int y_gap,const string text);

   //--- Charts
   bool              CreateGraph1(const int x_gap,const int y_gap);
   //---
private:
   //--- Update the main text of the chart
   void              UpdateFontMainSize(void);
   //--- Update the additional text of the chart
   void              UpdateFontSubSize(void);

   //--- Update the indents
   void              UpdateIndentLeft(void);
   void              UpdateIndentRight(void);
   void              UpdateIndentUp(void);
   void              UpdateIndentDown(void);
   void              UpdateGapSize(void);
   void              UpdateMajorMarkSize(void);

   //--- Update the history
   void              UpdateHistoryNameWidth(void);
   void              UpdateHistoryNameSize(void);
   void              UpdateHistorySymbolSize(void);

   //--- Update the grid
   void              UpdateGridHasCircle(void);
   void              UpdateGridCircleRadius(void);
   
   //--- Update the axes
   void              UpdateAutoScale(void);
   void              UpdateAxisMin(void);
   void              UpdateAxisMax(void);
   void              UpdateAxisMinGrace(void);
   void              UpdateAxisMaxGrace(void);
   //---
   void              UpdateValuesSize(void);
   void              UpdateValuesWidth(void);
   void              UpdateNameSize(void);
   void              UpdateDefaultStep(void);
   void              UpdateMaxLabels(void);
   //---
   void              UpdateAxisName(void);
   void              UpdateAxisColor(void);

   //--- Resize the arrays
   void              ResizeGraph1Arrays(void);
   void              ResizeGraph1Arrays(const int new_size);
   //--- Initialization of arrays
   void              InitGraph1Arrays(void);
   //--- Zero the arrays
   void              ZeroGraph1Arrays(void);
   //--- Set random value at the specified index
   void              SetGraph1Value(const int index);

   //--- Update the charts
   void              UpdateGraph(void);

   //--- Check the events
   void              CheckEvent(const long id);
   
   //---
   void              OnSelectAxis(const int index);
  };
//+------------------------------------------------------------------+
//| Creating controls                                                |
//+------------------------------------------------------------------+
#include "MainWindow.mqh"
#include "Tab1.mqh"
#include "Tab2.mqh"
#include "Tab3.mqh"
#include "Tab4.mqh"
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CProgram::CProgram(void)
  {
//--- Setting parameters for the time counters
   m_counter1.SetParameters(16,35);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CProgram::~CProgram(void)
  {
  }
//+------------------------------------------------------------------+
//| Initialization                                                    |
//+------------------------------------------------------------------+
void CProgram::OnInitEvent(void)
  {
  }
//+------------------------------------------------------------------+
//| Uninitialization                                                 |
//+------------------------------------------------------------------+
void CProgram::OnDeinitEvent(const int reason)
  {
//--- Removing the interface
   CWndEvents::Destroy();
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CProgram::OnTimerEvent(void)
  {
   CWndEvents::OnTimerEvent();
//--- Update the chart by timer
   if(m_counter1.CheckTimeCounter())
     {
      if(m_status_bar.IsVisible())
        {
         static int index=0;
         index=(index+1>3)? 0 : index+1;
         m_status_bar.GetItemPointer(1).ChangeImage(0,index);
         m_status_bar.GetItemPointer(1).Update(true);
        }
     }
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CProgram::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Event of clicking the checkbox
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX)
     {
      if(lparam==m_grid_has_circle.Id())
        {
         UpdateGridHasCircle();
         return;
        }
      if(lparam==m_auto_scale.Id())
        {
         UpdateAutoScale();
         return;
        }
      return;
     }
//--- Event of clicking the edit box spin buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      if(lparam==m_back_color.Id())
        {
         m_color_picker.ColorButtonPointer(m_back_color);
         return;
        }
      if(lparam==m_back_main_color.Id())
        {
         m_color_picker.ColorButtonPointer(m_back_main_color);
         return;
        }
      if(lparam==m_back_sub_color.Id())
        {
         m_color_picker.ColorButtonPointer(m_back_sub_color);
         return;
        }
      if(lparam==m_grid_line_color.Id())
        {
         m_color_picker.ColorButtonPointer(m_grid_line_color);
         return;
        }
      if(lparam==m_grid_axis_line_color.Id())
        {
         m_color_picker.ColorButtonPointer(m_grid_axis_line_color);
         return;
        }
      if(lparam==m_grid_back_color.Id())
        {
         m_color_picker.ColorButtonPointer(m_grid_back_color);
         return;
        }
      if(lparam==m_grid_circle_color.Id())
        {
         m_color_picker.ColorButtonPointer(m_grid_circle_color);
         return;
        }
      if(lparam==m_axis_color.Id())
        {
         m_color_picker.ColorButtonPointer(m_axis_color);
         return;
        }
      if(lparam==m_select_axes.Id())
        {
         OnSelectAxis(m_select_axes.SelectedButtonIndex());
         return;
        }
      //---
      CheckEvent(lparam);
      return;
     }
//--- Event of entering new value in the edit box
   if(id==CHARTEVENT_CUSTOM+ON_END_EDIT)
     {
      if(lparam==m_main_text.Id())
        {
         CGraphic *graph=m_graph1.GetGraphicPointer();
         string text=m_main_text.GetValue();
         graph.BackgroundMain(text);
         graph.BackgroundMainSize((text=="")? 0 :(int)m_font_main_size.GetValue());
         UpdateGraph();
         return;
        }
      if(lparam==m_sub_text.Id())
        {
         CGraphic *graph=m_graph1.GetGraphicPointer();
         string text=m_sub_text.GetValue();
         graph.BackgroundSub(text);
         graph.BackgroundSubSize((text=="")? 0 :(int)m_font_sub_size.GetValue());
         UpdateGraph();
         return;
        }
      if(lparam==m_axis_name.Id())
        {
         CGraphic *graph=m_graph1.GetGraphicPointer();
         CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
         string text=m_axis_name.GetValue();
         axis.Name(text);
         UpdateGraph();
         return;
        }
      //---
      CheckEvent(lparam);
      return;
     }
//--- Event of holding the edit box spin buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_INC || id==CHARTEVENT_CUSTOM+ON_CLICK_DEC)
     {
      CheckEvent(lparam);
      return;
     }
//--- Event of changing the color
   if(id==CHARTEVENT_CUSTOM+ON_CHANGE_COLOR)
     {
      if(sparam==m_back_color.LabelText())
        {
         CGraphic *graph=m_graph1.GetGraphicPointer();
         graph.BackgroundColor(::ColorToARGB(m_back_color.CurrentColor()));
         UpdateGraph();
         return;
        }
      if(sparam==m_back_main_color.LabelText())
        {
         CGraphic *graph=m_graph1.GetGraphicPointer();
         graph.BackgroundMainColor(::ColorToARGB(m_back_main_color.CurrentColor()));
         UpdateGraph();
         return;
        }
      if(sparam==m_back_sub_color.LabelText())
        {
         CGraphic *graph=m_graph1.GetGraphicPointer();
         graph.BackgroundSubColor(::ColorToARGB(m_back_sub_color.CurrentColor()));
         UpdateGraph();
         return;
        }
      if(sparam==m_grid_line_color.LabelText())
        {
         CGraphic *graph=m_graph1.GetGraphicPointer();
         graph.GridLineColor(::ColorToARGB(m_grid_line_color.CurrentColor()));
         UpdateGraph();
         return;
        }
      if(sparam==m_grid_axis_line_color.LabelText())
        {
         CGraphic *graph=m_graph1.GetGraphicPointer();
         graph.GridAxisLineColor(::ColorToARGB(m_grid_axis_line_color.CurrentColor()));
         UpdateGraph();
         return;
        }
      if(sparam==m_grid_back_color.LabelText())
        {
         CGraphic *graph=m_graph1.GetGraphicPointer();
         graph.GridBackgroundColor(::ColorToARGB(m_grid_back_color.CurrentColor()));
         UpdateGraph();
         return;
        }
      if(sparam==m_grid_circle_color.LabelText())
        {
         CGraphic *graph=m_graph1.GetGraphicPointer();
         graph.GridCircleColor(::ColorToARGB(m_grid_circle_color.CurrentColor()));
         UpdateGraph();
         return;
        }
      if(sparam==m_axis_color.LabelText())
        {
         CGraphic *graph=m_graph1.GetGraphicPointer();
         CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
         axis.Color(::ColorToARGB(m_axis_color.CurrentColor()));
         UpdateGraph();
         return;
        }
      return;
     }
  }
//+------------------------------------------------------------------+
//| Create the graphical interface of the program                    |
//+------------------------------------------------------------------+
bool CProgram::CreateGUI(void)
  {
//--- Creating a panel
   if(!CreateWindow1("EXPERT PANEL"))
      return(false);
//--- Status bar
   if(!CreateStatusBar(1,23))
      return(false);
//--- Pictures
   if(!CreatePicture1(10,10))
      return(false);

//--- Tabs
   if(!CreateTabs1(7,45))
      return(false);

//--- Elements of the first tab
   if(!CreateBackColor(10,10,"Back color:"))
      return(false);
   if(!CreateMainColor(10,35,"Main color:"))
      return(false);
   if(!CreateSubColor(10,60,"Sub color:"))
      return(false);
//---
   if(!CreateMainText(220,35,"Main text:"))
      return(false);
   if(!CreateSubText(220,60,"Sub text:"))
      return(false);
//---
   if(!CreateFontMainSize(385,35,"Main size:"))
      return(false);
   if(!CreateFontSubSize(385,60,"Sub size:"))
      return(false);

//--- Elements of the second tab
   if(!CreateIndentLeft(10,10,"Indent left:"))
      return(false);
   if(!CreateIndentRight(10,35,"Indent right:"))
      return(false);
   if(!CreateIndentUp(10,60,"Indent up:"))
      return(false);
   if(!CreateIndentDown(10,85,"Indent down:"))
      return(false);
//---
   if(!CreateHistoryNameWidth(160,10,"History name width:"))
      return(false);
   if(!CreateHistoryNameSize(160,35,"History name size:"))
      return(false);
   if(!CreateHistorySymbolSize(160,60,"History symbol size:"))
      return(false);
//---
   if(!CreateGapSize(345,10,"Gap size:"))
      return(false);
   if(!CreateMajorMarkSize(345,35,"Major mark size:"))
      return(false);

//--- Elements of the third tab
   if(!CreateGridLineColor(10,10,"Grid line color:"))
      return(false);
   if(!CreateGridAxisLineColor(10,35,"Grid axis line color:"))
      return(false);
   if(!CreateGridBackColor(10,60,"Grid back color:"))
      return(false);
   if(!CreateGridHasCircle(230,14,"Grid has circle"))
      return(false);
   if(!CreateGridCircleRadius(230,35,"Grid circle radius:"))
      return(false);
   if(!CreateGridCircleColor(230,60,"Grid circle color:"))
      return(false);
      
//--- Elements of the fourth tab
   if(!CreateSelectAxes(10,14))
      return(false);
   if(!CreateSepLine1(67,10))
      return(false);
   if(!CreateAutoScale(80,14,"Auto scale"))
      return(false);
   if(!CreateAxisMin(80,35,"Min:"))
      return(false);
   if(!CreateAxisMax(80,60,"Max:"))
      return(false);
   if(!CreateAxisMinGrace(80,85,"Min grace:"))
      return(false);
   if(!CreateAxisMaxGrace(80,110,"Max grace:"))
      return(false);
//---
   if(!CreateValuesSize(210,10,"Values size:"))
      return(false);
   if(!CreateValuesWidth(210,35,"Values width:"))
      return(false);
   if(!CreateNameSize(210,60,"Name size:"))
      return(false);
   if(!CreateDefaultStep(210,85,"Default step:"))
      return(false);
   if(!CreateMaxLabels(210,110,"Max labels:"))
      return(false);
//---
   if(!CreateAxisName(354,10,"Name:"))
      return(false);
   if(!CreateAxisColor(354,35,"Color:"))
      return(false);

//--- Charts
   if(!CreateGraph1(2,195))
      return(false);

//--- Creating form 2 for the color picker
   if(!CreateWindow2("COLOR PICKER"))
      return(false);
//--- Color picker
   if(!CreateColorPicker(1,20))
      return(false);

//--- Finishing the creation of GUI
   CWndEvents::CompletedGUI();
   return(true);
  }
//+------------------------------------------------------------------+
//| Update the main text of the chart                                |
//+------------------------------------------------------------------+
void CProgram::UpdateFontMainSize(void)
  {
   if(m_main_text.GetValue()=="")
      return;
//---
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.BackgroundMainSize((int)m_font_main_size.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the additional text of the chart                          |
//+------------------------------------------------------------------+
void CProgram::UpdateFontSubSize(void)
  {
   if(m_sub_text.GetValue()=="")
      return;
//---
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.BackgroundSubSize((int)m_font_sub_size.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the indent from the left                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateIndentLeft(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.IndentLeft((int)m_indent_left.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the indent from the right                                 |
//+------------------------------------------------------------------+
void CProgram::UpdateIndentRight(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.IndentRight((int)m_indent_right.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the indent from the top                                   |
//+------------------------------------------------------------------+
void CProgram::UpdateIndentUp(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.IndentUp((int)m_indent_up.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the indent from the bottom                                |
//+------------------------------------------------------------------+
void CProgram::UpdateIndentDown(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.IndentDown((int)m_indent_down.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the common indents                                        |
//+------------------------------------------------------------------+
void CProgram::UpdateGapSize(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.GapSize((int)m_gap_size.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the main scale lines                                      |
//+------------------------------------------------------------------+
void CProgram::UpdateMajorMarkSize(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.MajorMarkSize((int)m_major_mark_size.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the common indents                                        |
//+------------------------------------------------------------------+
void CProgram::UpdateHistoryNameWidth(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.HistoryNameWidth((int)m_history_name_width.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the common indents                                        |
//+------------------------------------------------------------------+
void CProgram::UpdateHistoryNameSize(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.HistoryNameSize((int)m_history_name_size.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the common indents                                        |
//+------------------------------------------------------------------+
void CProgram::UpdateHistorySymbolSize(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.HistorySymbolSize((int)m_history_symbol_size.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the grid                                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateGridHasCircle(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.GridHasCircle(m_grid_has_circle.IsPressed());
   graph.GridCircleRadius((int)m_grid_circle_radius.GetValue());
   graph.GridCircleColor(::ColorToARGB(m_grid_circle_color.CurrentColor()));
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the grid                                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateGridCircleRadius(void)
  {
   if(!m_grid_has_circle.IsPressed())
     return;
//---
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.GridCircleRadius((int)m_grid_circle_radius.GetValue());
   graph.GridCircleColor(::ColorToARGB(m_grid_circle_color.CurrentColor()));
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the axis                                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateAutoScale(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
   axis.AutoScale(m_auto_scale.IsPressed());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the axis                                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateAxisMin(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
   axis.Min((double)m_axis_min.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the axis                                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateAxisMax(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
   axis.Max((double)m_axis_max.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the axis                                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateAxisMinGrace(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
   axis.MinGrace((double)m_axis_min_grace.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the axis                                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateAxisMaxGrace(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
   axis.MaxGrace((double)m_axis_max_grace.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the axis                                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateValuesSize(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
   axis.ValuesSize((int)m_values_size.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the axis                                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateValuesWidth(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
   axis.ValuesWidth((int)m_values_width.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the axis                                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateNameSize(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
   axis.NameSize((int)m_name_size.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the axis                                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateDefaultStep(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
   axis.DefaultStep((int)m_default_step.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the axis                                                  |
//+------------------------------------------------------------------+
void CProgram::UpdateMaxLabels(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
   axis.MaxLabels((int)m_max_labels.GetValue());
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Update the chart                                                 |
//+------------------------------------------------------------------+
void CProgram::UpdateGraph(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.Redraw(true);
   graph.Update();
  }
//+------------------------------------------------------------------+
//| Check the events                                                 |
//+------------------------------------------------------------------+
void CProgram::CheckEvent(const long id)
  {
   if(id==m_font_main_size.Id())
     {
      UpdateFontMainSize();
      return;
     }
   if(id==m_font_sub_size.Id())
     {
      UpdateFontSubSize();
      return;
     }
   if(id==m_indent_left.Id())
     {
      UpdateIndentLeft();
      return;
     }
   if(id==m_indent_right.Id())
     {
      UpdateIndentRight();
      return;
     }
   if(id==m_indent_up.Id())
     {
      UpdateIndentUp();
      return;
     }
   if(id==m_indent_down.Id())
     {
      UpdateIndentDown();
      return;
     }
   if(id==m_history_name_width.Id())
     {
      UpdateHistoryNameWidth();
      return;
     }
   if(id==m_history_name_size.Id())
     {
      UpdateHistoryNameSize();
      return;
     }
   if(id==m_history_symbol_size.Id())
     {
      UpdateHistorySymbolSize();
      return;
     }
   if(id==m_gap_size.Id())
     {
      UpdateGapSize();
      return;
     }
   if(id==m_major_mark_size.Id())
     {
      UpdateMajorMarkSize();
      return;
     }
   if(id==m_grid_circle_radius.Id())
     {
      UpdateGridCircleRadius();
      return;
     }
   if(id==m_axis_min.Id())
     {
      UpdateAxisMin();
      return;
     }
   if(id==m_axis_max.Id())
     {
      UpdateAxisMax();
      return;
     }
   if(id==m_axis_min_grace.Id())
     {
      UpdateAxisMinGrace();
      return;
     }
   if(id==m_axis_max_grace.Id())
     {
      UpdateAxisMaxGrace();
      return;
     }
   if(id==m_values_size.Id())
     {
      UpdateValuesSize();
      return;
     }
   if(id==m_values_width.Id())
     {
      UpdateValuesWidth();
      return;
     }
   if(id==m_name_size.Id())
     {
      UpdateNameSize();
      return;
     }
   if(id==m_default_step.Id())
     {
      UpdateDefaultStep();
      return;
     }
   if(id==m_max_labels.Id())
     {
      UpdateMaxLabels();
      return;
     }
  }
//+------------------------------------------------------------------+
//| Update the chart                                                 |
//+------------------------------------------------------------------+
void CProgram::OnSelectAxis(const int index)
  {
//--- Get the pointer to the chart
   CGraphic *graph=m_graph1.GetGraphicPointer();
//--- Get the pointer to the axis
   CAxis *axis=(m_select_axes.SelectedButtonIndex()<1)? graph.XAxis() : graph.YAxis();
//---
   m_auto_scale.IsPressed(axis.AutoScale());
   m_axis_min.SetValue((string)axis.Min(),false);
   m_axis_max.SetValue((string)axis.Max(),false);
   m_axis_min_grace.SetValue((string)axis.MinGrace(),false);
   m_axis_max_grace.SetValue((string)axis.MaxGrace(),false);
//---
   m_values_size.SetValue((string)axis.ValuesSize(),false);
   m_values_width.SetValue((string)axis.ValuesWidth(),false);
   m_name_size.SetValue((string)axis.NameSize(),false);
   m_default_step.SetValue((string)axis.DefaultStep(),false);
   m_max_labels.SetValue((string)axis.MaxLabels(),false);
//---
   m_axis_name.SetValue((string)axis.Name(),false);
   m_axis_color.CurrentColor(::ColorToARGB(axis.Color()));
//---
   m_auto_scale.Update(true);
   m_axis_min.GetTextBoxPointer().Update(true);
   m_axis_max.GetTextBoxPointer().Update(true);
   m_axis_min_grace.GetTextBoxPointer().Update(true);
   m_axis_max_grace.GetTextBoxPointer().Update(true);
//---
   m_values_size.GetTextBoxPointer().Update(true);
   m_values_width.GetTextBoxPointer().Update(true);
   m_name_size.GetTextBoxPointer().Update(true);
   m_default_step.GetTextBoxPointer().Update(true);
   m_max_labels.GetTextBoxPointer().Update(true);
//---
   m_axis_name.GetTextBoxPointer().Update(true);
   m_axis_color.GetButtonPointer().Update(true);
//---
   UpdateGraph();
  }
//+------------------------------------------------------------------+
