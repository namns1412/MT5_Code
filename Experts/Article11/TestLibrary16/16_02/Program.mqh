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
   CTimeCounter      m_counter1; // for updating the execution process
   CTimeCounter      m_counter2; // for updating the items in the status bar
   //--- Main window
   CWindow           m_window;
   //--- Status bar
   CStatusBar        m_status_bar;
   //--- Icon
   CPicture          m_picture1;
   //--- Controls for managing the chart
   CCheckBox         m_animate;
   CTextEdit         m_array_size;
   CButton           m_random;
   //---
   CSeparateLine     m_sep_line2;
   //---
   CTextEdit         m_ind_period;
   CComboBox         m_curve_type;
   CComboBox         m_point_type;
   //--- Charts
   CGraph            m_graph1;
   CGraph            m_graph2;

   //--- Arrays of data for output on the chart
   double            data1[];
   double            data2[];
   //---
   double            data3[];
   double            data4[];
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
   bool              CreateWindow(const string text);
   //--- Status bar
   bool              CreateStatusBar(const int x_gap,const int y_gap);
   //--- Pictures
   bool              CreatePicture1(const int x_gap,const int y_gap);
   //--- Controls for managing the chart
   bool              CreateCheckBoxAnimate(const int x_gap,const int y_gap,const string text);
   bool              CreateSpinEditArraySize(const int x_gap,const int y_gap,const string text);
   bool              CreateButtonRandom(const int x_gap,const int y_gap,const string text);
   //---
   bool              CreateSepLine2(const int x_gap,const int y_gap);
   //---
   bool              CreateSpinEditIndPeriod(const int x_gap,const int y_gap,const string text);
   bool              CreateComboBoxCurveType(const int x_gap,const int y_gap,const string text);
   bool              CreateComboBoxPointType(const int x_gap,const int y_gap,const string text);
   //--- Charts
   bool              CreateGraph1(const int x_gap,const int y_gap);
   bool              CreateGraph2(const int x_gap,const int y_gap);
   //---
private:
   //--- Resize the arrays
   void              ResizeGraph1Arrays(void);
   void              ResizeGraph2Arrays(void);
   void              ResizeGraph1Arrays(const int new_size);
   void              ResizeGraph2Arrays(const int new_size);
   //--- Initialization of arrays
   void              InitGraph1Arrays(void);
   void              InitGraph2Arrays(void);
   //--- Zero the arrays
   void              ZeroGraph1Arrays(void);
   void              ZeroGraph2Arrays(void);
   //--- Set random value at the specified index
   void              SetGraph1Value(const int index);
   void              SetGraph2Value(const int index);
   //--- Update the series on the chart
   void              UpdateGraph(void);
   void              UpdateGraph1(void);
   void              UpdateGraph2(void);
   
   //--- Recalculate the series on the chart
   void              RecalculatingSeries(void);
   //--- Add one more value tp the end of the arrays
   void              AddValue(void);
   //--- Remove one value at the end of the arrays
   void              DeleteValue(void);

   //--- Update the chart by timer
   void              UpdateGraphByTimer(void);
   //--- Animate the chart series
   void              AnimateGraphSeries(void);
  };
//+------------------------------------------------------------------+
//| Creating controls                                                |
//+------------------------------------------------------------------+
#include "MainWindow.mqh"
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CProgram::CProgram(void)
  {
//--- Setting parameters for the time counters
   m_counter1.SetParameters(16,16);
   m_counter2.SetParameters(16,35);
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
      UpdateGraphByTimer();
     }
//---
   if(m_counter2.CheckTimeCounter())
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
//--- Selection of item in combobox event
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_ITEM)
     {
      if(lparam==m_curve_type.Id() || lparam==m_point_type.Id())
        {
         //--- Update the series on the chart
         UpdateGraph();
         return;
        }
      return;
     }
//--- Event of entering new value in the edit box
   if(id==CHARTEVENT_CUSTOM+ON_END_EDIT)
     {
      if(lparam==m_array_size.Id() || lparam==m_ind_period.Id())
        {
         //--- Recalculate the series on the chart
         RecalculatingSeries();
         return;
        }
      return;
     }
//--- Event of clicking the edit box spin buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      if(lparam==m_random.Id())
        {
         //--- Recalculate the series on the chart
         RecalculatingSeries();
         return;
        }
      //---
      if(lparam==m_array_size.Id())
        {
         if(dparam==0)
           {
            AddValue();
            UpdateGraph();
            return;
           }
         if(dparam==1)
           {
            DeleteValue();
            UpdateGraph();
            return;
           }
         return;
        }
      //---
      if(lparam==m_ind_period.Id())
        {
         ZeroGraph2Arrays();
         InitGraph2Arrays();
         UpdateGraph2();
         return;
        }
      return;
     }
//--- Event of holding the edit box spin buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_INC)
     {
      if(lparam==m_array_size.Id())
        {
         if(dparam==0)
           {
            AddValue();
            UpdateGraph();
            return;
           }
         return;
        }
      if(lparam==m_ind_period.Id())
        {
         if(dparam==0)
           {
            ZeroGraph2Arrays();
            InitGraph2Arrays();
            UpdateGraph2();
            return;
           }
         return;
        }
      return;
     }
//--- Event of holding the edit box spin buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_DEC)
     {
      if(lparam==m_array_size.Id())
        {
         if(dparam==1)
           {
            DeleteValue();
            UpdateGraph();
            return;
           }
         return;
        }
      if(lparam==m_ind_period.Id())
        {
         if(dparam==1)
           {
            ZeroGraph2Arrays();
            InitGraph2Arrays();
            UpdateGraph2();
            return;
           }
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
   if(!CreateWindow("EXPERT PANEL"))
      return(false);
//--- Status bar
   if(!CreateStatusBar(1,23))
      return(false);
//--- Pictures
   if(!CreatePicture1(10,10))
      return(false);
//--- Controls for managing the chart
   if(!CreateCheckBoxAnimate(7,29,"Animate"))
      return(false);
   if(!CreateSpinEditArraySize(7,50,"Array size:"))
      return(false);
   if(!CreateButtonRandom(7,75,"RANDOM"))
      return(false);
//---
   if(!CreateSepLine2(165,25))
      return(false);
//---
   if(!CreateSpinEditIndPeriod(180,25,"Period:"))
      return(false);
   if(!CreateComboBoxCurveType(180,50,"Curve type:"))
      return(false);
   if(!CreateComboBoxPointType(180,75,"Point type:"))
      return(false);
//--- Charts
   if(!CreateGraph1(2,100))
      return(false);
   if(!CreateGraph2(2,238))
      return(false);
//--- Finishing the creation of GUI
   CWndEvents::CompletedGUI();
   return(true);
  }
//+------------------------------------------------------------------+
