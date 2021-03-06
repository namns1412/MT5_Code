//+------------------------------------------------------------------+
//|                                                  ProgressBar.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
//+------------------------------------------------------------------+
//| Class for creating a progress bar                                |
//+------------------------------------------------------------------+
class CProgressBar : public CElement
  {
private:
   //--- Color of the progress bar background and background frame
   color             m_bar_back_color;
   //--- Progress bar sizes
   int               m_bar_x_size;
   int               m_bar_y_size;
   //--- Offset of the progress bar along the two axes
   int               m_bar_x_gap;
   int               m_bar_y_gap;
   //--- Frame width of the progress bar
   int               m_bar_border_width;
   //--- Color of the indicator
   color             m_indicator_color;
   //--- Offset of the percentage indication label
   int               m_percent_x_gap;
   int               m_percent_y_gap;
   //--- Number of decimal places
   int               m_digits;
   //--- The number of range steps
   double            m_steps_total;
   //--- The current position of the indicator
   double            m_current_index;
   //---
public:
                     CProgressBar(void);
                    ~CProgressBar(void);
   //--- Methods for creating the control
   bool              CreateProgressBar(const string text,const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const string text,const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   //---
public:
   //--- Color (1) of the background and (2) the progress bar frame, (3) indicator color
   void              IndicatorBackColor(const color clr) { m_bar_back_color=clr;     }
   void              IndicatorColor(const color clr)     { m_indicator_color=clr;    }
   //--- (1) Border width, (2) Y-size of the indicator area
   void              BarBorderWidth(const int width)     { m_bar_border_width=width; }
   void              BarYSize(const int y_size)          { m_bar_y_size=y_size;      }
   //--- (1) Offset of the progress bar along the two axes, (2) Offset of the percentage indication label
   void              BarXGap(const int x_gap)            { m_bar_x_gap=x_gap;        }
   void              BarYGap(const int y_gap)            { m_bar_y_gap=y_gap;        }
   //--- (1) Offset of the text label (percentage of the process), (2) the number of decimal places
   void              PercentXGap(const int x_gap)        { m_percent_x_gap=x_gap;    }
   void              PercentYGap(const int y_gap)        { m_percent_y_gap=y_gap;    }
   void              SetDigits(const int digits)         { m_digits=::fabs(digits);  }
   //--- Update the indicator with the specified values
   void              Update(const int index,const int total);
   //--- Draws the control
   virtual void      Draw(void);
   //---
private:
   //--- Draws the indicator
   void              DrawIndicator(void);
   //--- Draws the percentage indication of the progress
   void              DrawPercent(void);

   //--- Set new values ​​for the indicator
   void              CurrentIndex(const int index);
   void              StepsTotal(const int total);

   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CProgressBar::CProgressBar(void) : m_digits(0),
                                   m_steps_total(1),
                                   m_current_index(0),
                                   m_bar_x_gap(0),
                                   m_bar_y_gap(0),
                                   m_bar_border_width(0),
                                   m_percent_x_gap(7),
                                   m_percent_y_gap(0),
                                   m_bar_back_color(C'225,225,225'),
                                   m_indicator_color(clrMediumSeaGreen)
  {
//--- Store the name of the control class in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CProgressBar::~CProgressBar(void)
  {
  }
//+------------------------------------------------------------------+
//| Create the "Progress bar" control                                |
//+------------------------------------------------------------------+
bool CProgressBar::CreateProgressBar(const string text,const int x_gap,const int y_gap)
  {
//--- Leave, if there is no pointer to the main control
   if(!CElement::CheckMainPointer())
      return(false);
//--- Initialization of the properties
   InitializeProperties(text,x_gap,y_gap);
//--- Create control
   if(!CreateCanvas())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of the properties                                 |
//+------------------------------------------------------------------+
void CProgressBar::InitializeProperties(const string text,const int x_gap,const int y_gap)
  {
   m_x          =CElement::CalculateX(x_gap);
   m_y          =CElement::CalculateY(y_gap);
   m_label_text =text;
   m_x_size     =(m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
//--- Default properties
   m_back_color  =(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
   m_label_color =(m_label_color!=clrNONE)? m_label_color : clrBlack;
   m_label_y_gap =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 0;
//--- Offsets from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
//| Creates the canvas for drawing                                   |
//+------------------------------------------------------------------+
bool CProgressBar::CreateCanvas(void)
  {
//--- Forming the object name
   string name=CElementBase::ElementName("progress");
//--- Creating an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Update the progress bar                                          |
//+------------------------------------------------------------------+
void CProgressBar::Update(const int index,const int total)
  {
//--- Set the new index
   CurrentIndex(index);
//--- Set the new range
   StepsTotal(total);
//--- Redraw the control
   Update(true);
  }
//+------------------------------------------------------------------+
//| Draws the control                                                |
//+------------------------------------------------------------------+
void CProgressBar::Draw(void)
  {
//--- Draw the background
   CElement::DrawBackground();
//--- Draw icon
   CElement::DrawImage();
//--- Draw text
   CElement::DrawText();
//--- Draw the indicator
   DrawIndicator();
//--- Draw the progress percentage
   DrawPercent();
  }
//+------------------------------------------------------------------+
//| Draws the indicator                                              |
//+------------------------------------------------------------------+
void CProgressBar::DrawIndicator(void)
  {
   int x1 =m_bar_x_gap;
   int y1 =m_bar_y_gap;
   int x2 =m_x_size-40;
   int y2 =m_bar_y_gap+m_bar_y_size;
//--- Indicator background size
   m_bar_x_size=x2-m_bar_x_gap;
//--- Draw the indicator background
   m_canvas.FillRectangle(x1,y1,x2,y2,::ColorToARGB(m_bar_back_color));
//--- Calculate the indicator width
   double new_width=(m_current_index/m_steps_total)*m_bar_x_size;
//--- Adjust if less than 1
   if((int)new_width<1)
      new_width=1;
   else
     {
      //--- Adjust with consideration of the frame width
      int x_size=m_bar_x_size-(m_bar_border_width*2);
      //--- Adjust, if out of range
      if((int)new_width>=x_size)
         new_width=x_size;
     }
//--- Set the new width to the indicator
   x1 =x1+m_bar_border_width;
   y1 =y1+m_bar_border_width;
   x2 =x1+(int)new_width;
   y2 =y2-m_bar_border_width;
//--- Draw the indicator
   m_canvas.FillRectangle(x1,y1,x2,y2,::ColorToARGB(m_indicator_color));
  }
//+------------------------------------------------------------------+
//| Draws the percentage indication of the progress                  |
//+------------------------------------------------------------------+
void CProgressBar::DrawPercent(void)
  {
   int x =m_x_size-m_percent_x_gap;
   int y =m_percent_y_gap;
//--- Calculate the percentage and generate a string
   double percent =m_current_index/m_steps_total*100;
   string text    =::DoubleToString((percent>100)? 100 : percent,m_digits)+"%";
//--- Draw text
   m_canvas.TextOut(x,y,text,::ColorToARGB(m_label_color),TA_RIGHT);
  }
//+------------------------------------------------------------------+
//| The number of progress bar steps                                 |
//+------------------------------------------------------------------+
void CProgressBar::StepsTotal(const int total)
  {
//--- Adjust if less than 0
   m_steps_total=(total<1)? 1 : total;
//--- Adjust the index, if out of range
   if(m_current_index>m_steps_total)
      m_current_index=m_steps_total;
  }
//+------------------------------------------------------------------+
//| The current position of the indicator                            |
//+------------------------------------------------------------------+
void CProgressBar::CurrentIndex(const int index)
  {
//--- Adjust if less than 0
   if(index<0)
      m_current_index=1;
//--- Adjust the index, if out of range
   else
      m_current_index=(index>m_steps_total)? m_steps_total : index;
  }
//+------------------------------------------------------------------+
//| Change the width at the right edge of the form                   |
//+------------------------------------------------------------------+
void CProgressBar::ChangeWidthByRightWindowSide(void)
  {
//--- Size
   int x_size=0;
//--- Calculate and set the new size to the control background
   x_size=m_main.X2()-m_canvas.X()-m_auto_xresize_right_offset;
   CElementBase::XSize(x_size);
   m_canvas.XSize(x_size);
   m_canvas.Resize(x_size,m_y_size);
//--- Redraw the control
   Update(true);
//--- Update the position of objects
   Moving();
  }
//+------------------------------------------------------------------+
