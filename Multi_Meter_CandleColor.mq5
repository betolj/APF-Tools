//+------------------------------------------------------------------+
//|                                      Multi_Meter_CandleColor.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
//--- includes
#include <Canvas\Canvas.mqh>
//+------------------------------------------------------------------+
//| Класс-окно                                                       |
//+------------------------------------------------------------------+
enum ENUM_MOUSE_STATE
  {
   MOUSE_STATE_NOT_PRESSED,
   MOUSE_STATE_PRESSED_OUTSIDE_WINDOW,
   MOUSE_STATE_PRESSED_INSIDE_WINDOW,
   MOUSE_STATE_PRESSED_INSIDE_HEADER,
   MOUSE_STATE_OUTSIDE_WINDOW,
   MOUSE_STATE_INSIDE_WINDOW,
   MOUSE_STATE_INSIDE_HEADER
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CWnd
  {
protected:
   CCanvas           m_canvas;
   CCanvas           m_field;
   long              m_chart_id;
   int               m_chart_w;
   int               m_chart_h;
   int               m_sub_wnd;
   string            m_name;
   string            m_caption;
   string            m_caption_font;
   string            m_name_gv_x;
   string            m_name_gv_y;
   color             m_color_bg;
   color             m_color_border;
   color             m_color_bg_header;
   color             m_color_caption;
   color             m_color_texts;
   uchar             m_alpha_bg;
   uchar             m_alpha_head;
   int               m_x;
   int               m_y;
   int               m_w;
   int               m_h;
   int               m_y_act;
   int               m_caption_font_size;
   uint              m_caption_alignment;
   uint              m_x_caption;
   bool              m_is_visible;
   bool              m_header_on;
   bool              m_movable;
   bool              m_wider_wnd;
   bool              m_higher_wnd;
   ENUM_PROGRAM_TYPE m_program_type;
   ENUM_MOUSE_STATE  m_mouse_state;
   ENUM_MOUSE_STATE  MouseButtonState(const int x,const int y,bool pressed);
   void              Move(int x,int y);
   bool              CreateCanvas(CCanvas &canvas,const int wnd_id,const int x,const int y,const int w,const int h);
   void              DrawHeaderArea(const string caption);
   void              RedrawHeaderArea(const color clr_area,const color clr_caption);
   string            TimeframeToString(const ENUM_TIMEFRAMES timeframe);
   int               CoordX1(void)                             const { return this.m_x;                     }
   int               CoordX2(void)                             const { return this.m_x+this.m_w;            }
   int               CoordY1(void)                             const { return this.m_y;                     }
   int               CoordY2(void)                             const { return this.m_y+this.m_h;            }
   int               CoordYAct(void)                           const { return this.m_y+this.m_y_act;        }
   color             RGBToColor(const double r,const double g,const double b);
   void              ColorToRGB(const color clr,double &r,double &g,double &b);
   double            GetR(const color clr)                           { return clr&0xff;                    }
   double            GetG(const color clr)                           { return(clr>>8)&0xff;                 }
   double            GetB(const color clr)                           { return(clr>>16)&0xff;                }
   int               ChartWidth(void)                          const { return this.m_chart_w;               }
   int               ChartHeight(void)                         const { return this.m_chart_h;               }
   bool              HigherWnd(void)                           const { return(this.m_h+2>this.m_chart_h);   }
   bool              WiderWnd(void)                            const { return(this.m_w+2>this.m_chart_w);   }
public:
   bool              CreateWindow(const string caption_text,const int x,const int y,const int w,const int h,const bool header,bool movable);
   void              Resize(const int w,const int h);
   void              SetColors(const color clr_bg,const color clr_bd,const color clr_hd,const color clr_capt,const color clr_text,uchar alpha_bg=128,uchar alpha_hd=200);
   CCanvas          *GetFieldCanvas(void) { return &this.m_field;          }
   void              DrawSeparateVLine(const int x,const int y1,const int y2,const color clr1,const color clr2,const uchar w=1);
   void              DrawSeparateHLine(const int x,const int y1,const int y2,const color clr1,const color clr2,const uchar w=1);
   color             NewColor(color base_color,int shift_red,int shift_green,int shift_blue);
   string            Caption(void)                             const { return this.m_caption;         }
   string            NameCaptionFont(void)                     const { return this.m_caption_font;    }
   color             ColorCaption(void)                        const { return this.m_color_caption;   }
   color             ColorBackground(void)                     const { return this.m_color_bg;        }
   color             ColorHeaderBackground(void)               const { return this.m_color_bg_header; }
   color             ColorTexts(void)                          const { return this.m_color_texts;     }
   void              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
                     CWnd(void);
                    ~CWnd(void);
  };
//+------------------------------------------------------------------+
//| CWnd конструктор                                                 |
//+------------------------------------------------------------------+
CWnd::CWnd(void) : m_chart_id(::ChartID()),
                   m_program_type((ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)),
                   m_name(::MQLInfoString(MQL_PROGRAM_NAME)),
                   m_name_gv_x(m_name+"_GVX"),
                   m_name_gv_y(m_name+"_GVY"),
                   m_sub_wnd(m_program_type==PROGRAM_EXPERT || m_program_type==PROGRAM_SCRIPT ? 0 : ::ChartWindowFind()),
                   m_chart_w((int)::ChartGetInteger(m_chart_id,CHART_WIDTH_IN_PIXELS,m_sub_wnd)),
                   m_chart_h((int)::ChartGetInteger(m_chart_id,CHART_HEIGHT_IN_PIXELS,m_sub_wnd)),
                   m_caption(""),
                   m_caption_font("Calibri"),
                   m_caption_font_size(-100),
                   m_alpha_bg(128),
                   m_alpha_head(200),
                   m_color_bg(C'200,200,200'),
                   m_color_bg_header(clrDarkGray),
                   m_color_border(clrDarkGray),
                   m_color_caption(clrYellow),
                   m_color_texts(clrSlateGray),
                   m_h(100),
                   m_w(160),
                   m_x(3),
                   m_y(::ChartGetInteger(m_chart_id,CHART_SHOW_ONE_CLICK) ? 79 : 20),
                   m_y_act(10),
                   m_is_visible(false),
                   m_movable(true),
                   m_header_on(true),
                   m_x_caption(4),
                   m_caption_alignment(TA_LEFT|TA_VCENTER),
                   m_mouse_state(MOUSE_STATE_NOT_PRESSED)
  {
   ::ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   if(!::GlobalVariableCheck(this.m_name_gv_x))
      ::GlobalVariableSet(this.m_name_gv_x,this.m_x);
   else
      this.m_x=(int)::GlobalVariableGet(this.m_name_gv_x);
   if(!::GlobalVariableCheck(this.m_name_gv_y))
      ::GlobalVariableSet(this.m_name_gv_y,this.m_y);
   else
      this.m_y=(int)::GlobalVariableGet(this.m_name_gv_y);
   this.m_higher_wnd=this.HigherWnd();
   this.m_wider_wnd=this.WiderWnd();
  }
//+------------------------------------------------------------------+
//| CWnd деструктор                                                  |
//+------------------------------------------------------------------+
CWnd::~CWnd(void)
  {
   ::ObjectsDeleteAll(this.m_chart_id,m_name);
   ::GlobalVariableSet(this.m_name_gv_x,this.m_x);
   ::GlobalVariableSet(this.m_name_gv_y,this.m_y);
  }
//+------------------------------------------------------------------+
//| CWnd Chart event function                                        |
//+------------------------------------------------------------------+
void CWnd::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      this.m_sub_wnd=(this.m_program_type==PROGRAM_EXPERT || this.m_program_type==PROGRAM_SCRIPT ? 0 : ::ChartWindowFind());
      int w=(int)::ChartGetInteger(this.m_chart_id,CHART_WIDTH_IN_PIXELS,this.m_sub_wnd);
      int h=(int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS,this.m_sub_wnd);
      this.m_higher_wnd=this.HigherWnd();
      this.m_wider_wnd=this.WiderWnd();
      if(this.m_chart_h!=h)
        {
         this.m_chart_h=h;
         int y=this.CoordY1();
         if(this.CoordY1()+this.m_h>h-1) y=h-this.m_h-1;
         if(y<1) y=1;
         this.Move(this.CoordX1(),y);
        }
      if(this.m_chart_w!=w)
        {
         this.m_chart_w=w;
         int x=this.CoordX1();
         if(this.CoordX1()+this.m_w>w-1) x=w-this.m_w-1;
         if(x<1) x=1;
         this.Move(x,this.CoordY1());
        }
     }
   if(!this.m_movable)
      return;
   static int diff_x=0;
   static int diff_y=0;
   bool pressed=(sparam=="1" || sparam=="" ? true : false);
   int  mouse_x=(int)lparam;
   int  mouse_y=(int)dparam-(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOW_YDISTANCE,this.m_sub_wnd);
   ENUM_MOUSE_STATE state=this.MouseButtonState(mouse_x,mouse_y,pressed);
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      if(state==MOUSE_STATE_PRESSED_INSIDE_WINDOW)
        {
         ::ChartSetInteger(0,CHART_MOUSE_SCROLL,false);
         ::ChartRedraw(this.m_chart_id);
         return;
        }
      else if(state==MOUSE_STATE_PRESSED_INSIDE_HEADER)
        {
         ::ChartSetInteger(0,CHART_MOUSE_SCROLL,false);
         this.Move(mouse_x-diff_x,mouse_y-diff_y);
         return;
        }
      else
        {
         ::ChartSetInteger(0,CHART_MOUSE_SCROLL,true);
         diff_x=mouse_x-this.CoordX1();
         diff_y=mouse_y-this.CoordY1();
        }
     }
  }
//+------------------------------------------------------------------+
//| Возвращает состояние кнопки мыши                                 |
//+------------------------------------------------------------------+
ENUM_MOUSE_STATE CWnd::MouseButtonState(const int x,const int y,bool pressed)
  {
//--- Если кнопка нажата
   if(pressed)
     {
      //--- Если уже зафиксировано состояние - выход
      if(this.m_mouse_state!=MOUSE_STATE_NOT_PRESSED)
         return this.m_mouse_state;
      //--- Если нажата кнопка внутри окна
      if(x>this.CoordX1() && x<this.CoordX2() && y>this.CoordY1() && y<this.CoordY2())
        {
         //--- Если нажата кнопка внутри заголовка
         if(y>this.CoordY1() && y<this.CoordYAct())
           {
            this.RedrawHeaderArea(this.NewColor(this.m_color_bg_header,30,30,30),this.m_color_caption);
            this.m_mouse_state=MOUSE_STATE_PRESSED_INSIDE_HEADER;
            return this.m_mouse_state;
           }
         //--- Если нажата кнопка внутри окна
         else if(y>this.CoordY1() && y<this.CoordY2())
           {
            this.m_mouse_state=(this.m_header_on ? MOUSE_STATE_PRESSED_INSIDE_WINDOW : MOUSE_STATE_PRESSED_INSIDE_HEADER);
            return this.m_mouse_state;
           }
        }
      //--- Кнопка нажата вне пределов окна
      else
        {
         this.m_mouse_state=MOUSE_STATE_PRESSED_OUTSIDE_WINDOW;
         return this.m_mouse_state;
        }
     }
//--- Кнопка не нажата
   else
     {
      this.m_mouse_state=MOUSE_STATE_NOT_PRESSED;
      //--- Курсор внутри окна
      if(x>this.CoordX1() && x<this.CoordX2() && y>this.CoordY1() && y<this.CoordY2())
        {
         //--- Курсор внутри заголовка
         if(y>this.CoordY1() && y<this.CoordYAct())
           {
            this.RedrawHeaderArea(this.NewColor(this.m_color_bg_header,20,20,20),this.m_color_caption);
            return MOUSE_STATE_INSIDE_HEADER;
           }
         //--- Курсор внутри окна
         else
           {
            this.RedrawHeaderArea(this.m_color_bg_header,this.m_color_caption);
            return MOUSE_STATE_INSIDE_WINDOW;
           }
        }
     }
   this.RedrawHeaderArea(this.m_color_bg_header,this.m_color_caption);
   return MOUSE_STATE_NOT_PRESSED;
  }
//+------------------------------------------------------------------+
//| CWnd перемещение окна                                            |
//+------------------------------------------------------------------+
void CWnd::Move(int x,int y)
  {
   if(!this.m_wider_wnd)
     {
      if(x+this.m_w>this.m_chart_w-1) x=this.m_chart_w-this.m_w-1;
      if(x<1) x=1;
     }
   else
     {
      if(x>1) x=1;
      if(x<this.m_chart_w-this.m_w-1) x=this.m_chart_w-this.m_w-1;
     }
   if(!this.m_higher_wnd)
     {
      if(y+this.m_h>this.m_chart_h-2) y=this.m_chart_h-this.m_h-2;
      if(y<1) y=1;
     }
   else
     {
      if(y>1) y=1;
      if(y<this.m_chart_h-this.m_h-2) y=this.m_chart_h-this.m_h-2;
     }

   this.m_x=x;
   this.m_y=y;
   ::ObjectSetInteger(this.m_chart_id,this.m_name+"0",OBJPROP_XDISTANCE,this.m_x);
   ::ObjectSetInteger(this.m_chart_id,this.m_name+"0",OBJPROP_YDISTANCE,this.m_y);
   ::ObjectSetInteger(this.m_chart_id,this.m_name+"1",OBJPROP_XDISTANCE,this.m_x+1);
   ::ObjectSetInteger(this.m_chart_id,this.m_name+"1",OBJPROP_YDISTANCE,this.m_y+this.m_y_act+1);
   this.m_canvas.Update(true);
  }
//+------------------------------------------------------------------+
//| CWnd Создаёт холст                                               |
//+------------------------------------------------------------------+
bool CWnd::CreateCanvas(CCanvas &canvas,const int wnd_id,const int x,const int y,const int w,const int h)
  {
   if(!canvas.CreateBitmapLabel(this.m_chart_id,this.m_sub_wnd,this.m_name+(string)wnd_id,x,y,w,h,COLOR_FORMAT_ARGB_NORMALIZE))
      return false;
   if(wnd_id==0)
     {
      this.m_x=x;
      this.m_y=y;
      this.m_w=w;
      this.m_h=h;
     }
   ::ObjectSetInteger(this.m_chart_id,this.m_name+(string)wnd_id,OBJPROP_SELECTABLE,false);
   ::ObjectSetInteger(this.m_chart_id,this.m_name+(string)wnd_id,OBJPROP_SELECTED,false);
   ::ObjectSetInteger(this.m_chart_id,this.m_name+(string)wnd_id,OBJPROP_HIDDEN,true);
   return true;
  }
//+------------------------------------------------------------------+
//| CWnd Создаёт окно                                                |
//+------------------------------------------------------------------+
bool CWnd::CreateWindow(const string caption_text,const int x,const int y,const int w,const int h,const bool header,bool movable)
  {
   if(!this.CreateCanvas(this.m_canvas,0,x,y,w,h))
      return false;
   this.m_header_on=header;
   if(!header)
      this.m_y_act=0;
   this.m_movable=movable;
   this.m_caption=caption_text;
   this.m_canvas.Erase(::ColorToARGB(this.m_color_bg,this.m_alpha_bg));
   this.m_canvas.Rectangle(0,0,this.m_w-1,this.m_h-1,::ColorToARGB(this.m_color_border));
   this.DrawHeaderArea(this.m_caption);
   this.m_canvas.Update(true);

   if(!this.CreateCanvas(this.m_field,1,this.m_x+1,this.m_y+this.m_y_act+1,this.m_w-2,this.m_h-this.m_y_act-2))
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Изменяет размеры окна                                            |
//+------------------------------------------------------------------+
void CWnd::Resize(const int w,const int h)
  {
   this.m_w=w;
   this.m_h=h;
   this.m_canvas.Resize(this.m_w,this.m_h);
   this.m_field.Resize(this.m_w-2,this.m_h-this.m_y_act-2);
   this.m_canvas.Erase(::ColorToARGB(this.m_color_bg,this.m_alpha_bg));
   this.m_canvas.Rectangle(0,0,this.m_w-1,this.m_h-1,::ColorToARGB(this.m_color_border));
   this.DrawHeaderArea(this.m_caption);
   this.m_canvas.Update(false);
   this.m_field.Update(true);
  }
//+------------------------------------------------------------------+
//| CWnd Рисует заголовок                                            |
//+------------------------------------------------------------------+
void CWnd::DrawHeaderArea(const string caption)
  {
   if(!this.m_header_on) return;
   this.m_canvas.FillRectangle(0,0,this.m_w,this.m_y_act,::ColorToARGB(this.m_color_bg_header,this.m_alpha_head));
   this.m_canvas.FontSet(this.m_caption_font,this.m_caption_font_size,FW_NORMAL);
   this.m_canvas.TextOut(this.m_x_caption,this.m_y_act/2,caption,::ColorToARGB(this.m_color_caption),this.m_caption_alignment);
  }
//+------------------------------------------------------------------+
//| CWnd Перерисовывает заголовок                                    |
//+------------------------------------------------------------------+
void CWnd::RedrawHeaderArea(const color clr_area,const color clr_caption)
  {
   if(!this.m_header_on) return;
   this.m_canvas.FillRectangle(0,0,this.m_w,this.m_y_act,::ColorToARGB(clr_area,this.m_alpha_head));
   this.m_canvas.FontSet(this.m_caption_font,this.m_caption_font_size,FW_NORMAL);
   this.m_canvas.TextOut(this.m_x_caption,this.m_y_act/2,this.m_caption,::ColorToARGB(clr_caption),this.m_caption_alignment);
   this.m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Рисует вертикальную разделительную линию                         |
//+------------------------------------------------------------------+
void CWnd::DrawSeparateVLine(const int x,const int y1,const int y2,const color clr1,const color clr2,const uchar w=1)
  {
   this.m_field.LineVertical(x,y1,y2,::ColorToARGB(clr1,this.m_alpha_bg));
   this.m_field.LineVertical(x+w,y1,y2,::ColorToARGB(clr2,this.m_alpha_bg));
  }
//+------------------------------------------------------------------+
//| Рисует горизонтальную разделительную линию                       |
//+------------------------------------------------------------------+
void CWnd::DrawSeparateHLine(const int x1,const int x2,const int y,const color clr1,const color clr2,const uchar w=1)
  {
   this.m_field.LineHorizontal(x1,x2,y,::ColorToARGB(clr1,this.m_alpha_bg));
   this.m_field.LineHorizontal(x1,x2,y+w,::ColorToARGB(clr2,this.m_alpha_bg));
  }
//+------------------------------------------------------------------+
//| Возвращает цвет с новой цветовой составляющей                    |
//+------------------------------------------------------------------+
color CWnd::NewColor(color base_color,int shift_red,int shift_green,int shift_blue)
  {
   double clR=0,clG=0,clB=0;
   this.ColorToRGB(base_color,clR,clG,clB);
   double clRn=(clR+shift_red  < 0 ? 0 : clR+shift_red  > 255 ? 255 : clR+shift_red);
   double clGn=(clG+shift_green< 0 ? 0 : clG+shift_green> 255 ? 255 : clG+shift_green);
   double clBn=(clB+shift_blue < 0 ? 0 : clB+shift_blue > 255 ? 255 : clB+shift_blue);
   return this.RGBToColor(clRn,clGn,clBn);
  }
//+------------------------------------------------------------------+
//| Преобразование RGB в const color                                 |
//+------------------------------------------------------------------+
color CWnd::RGBToColor(const double r,const double g,const double b)
  {
   int int_r=(int)::round(r);
   int int_g=(int)::round(g);
   int int_b=(int)::round(b);
   int clr=0;
//---
   clr=int_b;
   clr<<=8;
   clr|=int_g;
   clr<<=8;
   clr|=int_r;
//---
   return (color)clr;
  }
//+------------------------------------------------------------------+
//| Получение значений компонентов RGB                               |
//+------------------------------------------------------------------+
void CWnd::ColorToRGB(const color clr,double &r,double &g,double &b)
  {
   r=GetR(clr);
   g=GetG(clr);
   b=GetB(clr);
  }
//+------------------------------------------------------------------+
//| Возвращает наименование таймфрейма                               |
//+------------------------------------------------------------------+
string CWnd::TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  {
   return ::StringSubstr(::EnumToString(timeframe==PERIOD_CURRENT ? Period() : timeframe),7);
  }
//+------------------------------------------------------------------+
//| Устанавливает цвета панели                                       |
//+------------------------------------------------------------------+
void CWnd::SetColors(const color clr_bg,const color clr_bd,const color clr_hd,const color clr_capt,const color clr_text,uchar alpha_bg=128,uchar alpha_hd=200)
  {
   this.m_color_bg=clr_bg;
   this.m_color_border=clr_bd;
   this.m_color_bg_header=clr_hd;
   this.m_color_caption=clr_capt;
   this.m_color_texts=clr_text;
   this.m_alpha_bg=alpha_bg;
   this.m_alpha_head=alpha_hd;
  }
//+------------------------------------------------------------------+
//| Класс счётчик таймера                                            |
//+------------------------------------------------------------------+
class CTimerCounter
  {
private:  
   ulong             m_timer_counter;
   ulong             m_timer_step;
   ulong             m_timer_pause;
public:
   void              SetParams(const ulong step,const ulong pause)   { this.m_timer_step=step; this.m_timer_pause=pause;   }
   bool              IsTimeDone(void);
                     CTimerCounter(void) : m_timer_counter(0),m_timer_step(16),m_timer_pause(250){;}
                    ~CTimerCounter(void){;}
  };
//+------------------------------------------------------------------+
//| CTimerCounter проверяет окончание паузы                          |
//+------------------------------------------------------------------+
bool CTimerCounter::IsTimeDone(void)
  {
   if(this.m_timer_counter>ULONG_MAX)
      this.m_timer_counter=0;
   if(this.m_timer_counter<this.m_timer_pause)
     {
      this.m_timer_counter+=this.m_timer_step;
      return false;
     }
   this.m_timer_counter=0;
   return true;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Перечисление типов свечей                                        |
//+------------------------------------------------------------------+
enum ENUM_CANDLE_TYPE
  {
   CANDLE_TYPE_BULLISH  =  0,
   CANDLE_TYPE_BEARISH  =  1,
   CANDLE_TYPE_DOJI     =  2,
   CANDLE_TYPE_NONE     =  WRONG_VALUE
  };
//+------------------------------------------------------------------+
//| Класс Candle                                                     |
//+------------------------------------------------------------------+
class CCandle : public CObject
  {
protected:
   CTimerCounter     m_counter_time;
   CTimerCounter     m_counter_refresh;
   bool              m_counter_refresh_done;
   bool              m_counter_time_done;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   ENUM_CANDLE_TYPE  m_type_candle;
   int               m_index_x;
   int               m_index_y;
   int               m_digits;
   double            m_point;
   void              SetSymbolPeriod(const string symbol_name,const ENUM_TIMEFRAMES timeframe);
public:
   bool              GetData(const int shift,MqlRates &data_candle);
   bool              IsCounterRefreshDone(void)          { return this.m_counter_refresh_done;  }
   bool              IsCounterTimeDone(void)             { return this.m_counter_time_done;     }
   ENUM_CANDLE_TYPE  GetType(const int shift);
   void              SetIndexX(const int x)              { this.m_index_x=x;              }
   void              SetIndexY(const int y)              { this.m_index_y=y;              }
   void              SetCounterTime(const uint step,const uint pause);
   void              SetCounterRefresh(const uint step,const uint pause);
   int               IndexX(void)                  const { return this.m_index_x;         }
   int               IndexY(void)                  const { return this.m_index_y;         }
   int               Digits(void)                  const { return this.m_digits;          }
   double            Point(void)                   const { return this.m_point;           }
   string            Symbol(void)                  const { return this.m_symbol;          }
   ENUM_TIMEFRAMES   Timeframe(void)               const { return this.m_timeframe;       }
   string            TimeframeDescription(void)    const { return ::StringSubstr(::EnumToString(this.m_timeframe==PERIOD_CURRENT ? ::Period() : this.m_timeframe),7);   }
   double            Open(const int shift)         const { double array[];   return(::CopyOpen(this.m_symbol,this.m_timeframe,1,1,array)==1  ? array[0] : 0);           }
   double            High(const int shift)         const { double array[];   return(::CopyHigh(this.m_symbol,this.m_timeframe,1,1,array)==1  ? array[0] : 0);           }
   double            Low(const int shift)          const { double array[];   return(::CopyLow(this.m_symbol,this.m_timeframe,1,1,array)==1   ? array[0] : 0);           }
   double            Close(const int shift)        const { double array[];   return(::CopyClose(this.m_symbol,this.m_timeframe,1,1,array)==1 ? array[0] : 0);           }
   datetime          Time(const int shift)         const { datetime array[]; return(::CopyTime(this.m_symbol,this.m_timeframe,1,1,array)==1  ? array[0] : 0);           }
   void              OnTimer(void);
                     CCandle(const string symbol_name,const ENUM_TIMEFRAMES timeframe);
                    ~CCandle(void){;}
  };
//+------------------------------------------------------------------+
//| CCandle конструктор                                              |
//+------------------------------------------------------------------+
CCandle::CCandle(const string symbol_name,const ENUM_TIMEFRAMES timeframe) : m_index_x(0),
                                                                             m_index_y(0),
                                                                             m_type_candle(CANDLE_TYPE_NONE),
                                                                             m_counter_refresh_done(false),
                                                                             m_counter_time_done(false)
  {
   this.SetSymbolPeriod(symbol_name,timeframe);
   this.m_digits=(int)::SymbolInfoInteger(this.m_symbol,SYMBOL_DIGITS);
   this.m_point=::SymbolInfoDouble(this.m_symbol,SYMBOL_POINT);
   this.SetCounterRefresh(16,250);
   this.SetCounterTime(16,90000);
  }
//+------------------------------------------------------------------+
//| Таймер                                                           |
//+------------------------------------------------------------------+
void CCandle::OnTimer(void)
  {
   this.m_counter_time_done=this.m_counter_time.IsTimeDone();
   if(this.m_counter_time_done)
      this.Time(1);
   this.m_counter_refresh_done=this.m_counter_refresh.IsTimeDone();
  }
//+------------------------------------------------------------------+
//| Установка счётчика таймера времени                               |
//+------------------------------------------------------------------+
void CCandle::SetCounterTime(const uint step,const uint pause)
  {
   this.m_counter_time.SetParams(step,pause);
  }
//+------------------------------------------------------------------+
//| Установка счётчика таймера обновления                            |
//+------------------------------------------------------------------+
void CCandle::SetCounterRefresh(const uint step,const uint pause)
  {
   this.m_counter_refresh.SetParams(step,pause);
  }
//+------------------------------------------------------------------+
//| Установка символа и периода графика                              |
//+------------------------------------------------------------------+
void CCandle::SetSymbolPeriod(const string symbol_name,const ENUM_TIMEFRAMES timeframe)
  {
   this.m_symbol=(symbol_name=="" || symbol_name==NULL ? Symbol() : symbol_name);
   this.m_timeframe=(timeframe==PERIOD_CURRENT ? Period() : timeframe);
  }  
//+------------------------------------------------------------------+
//| Возвращает данные свечи                                          |
//+------------------------------------------------------------------+
bool CCandle::GetData(const int shift,MqlRates &data_candle)
  {
   MqlRates array[];
   if(::CopyRates(this.m_symbol,this.m_timeframe,shift,1,array)!=1)
      return false;
   data_candle.open=array[0].open;
   data_candle.high=array[0].high;
   data_candle.low=array[0].low;
   data_candle.close=array[0].close;
   data_candle.time=array[0].time;
   data_candle.spread=array[0].spread;
   data_candle.real_volume=array[0].real_volume;
   data_candle.tick_volume=array[0].tick_volume;
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает тип свечи                                             |
//+------------------------------------------------------------------+
ENUM_CANDLE_TYPE CCandle::GetType(const int shift)
  {
   MqlRates candle;
   if(this.GetData(shift,candle)!=1)
      return CANDLE_TYPE_NONE;
   return(candle.open<candle.close ? CANDLE_TYPE_BULLISH : candle.open>candle.close ? CANDLE_TYPE_BEARISH : CANDLE_TYPE_DOJI);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Индикатор                                                        |
//+------------------------------------------------------------------+
#property version   "1.00"
#property description "Multi Meter Candle Color panel"
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayString.mqh>
#include <Arrays\ArrayInt.mqh>
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,    // Yes
   INPUT_NO    =  0     // No
  };
//--- input parameters
input string               InpSymbols        =  "";               // Symbols list (Comma Separated Pairs, empty - current symbol)
input uint                 InpCandleNum      =  0;                // Candle number
input ENUM_INPUT_YES_NO    InpUseM1          =  INPUT_YES;        // Use 1 minute timeframe
input ENUM_INPUT_YES_NO    InpUseM2          =  INPUT_NO;         // Use 2 minute timeframe
input ENUM_INPUT_YES_NO    InpUseM3          =  INPUT_NO;         // Use 3 minute timeframe
input ENUM_INPUT_YES_NO    InpUseM4          =  INPUT_NO;         // Use 4 minute timeframe
input ENUM_INPUT_YES_NO    InpUseM5          =  INPUT_YES;        // Use 5 minute timeframe
input ENUM_INPUT_YES_NO    InpUseM6          =  INPUT_NO;         // Use 6 minute timeframe
input ENUM_INPUT_YES_NO    InpUseM10         =  INPUT_NO;         // Use 10 minute timeframe
input ENUM_INPUT_YES_NO    InpUseM12         =  INPUT_NO;         // Use 12 minute timeframe
input ENUM_INPUT_YES_NO    InpUseM15         =  INPUT_YES;        // Use 15 minute timeframe
input ENUM_INPUT_YES_NO    InpUseM20         =  INPUT_NO;         // Use 20 minute timeframe
input ENUM_INPUT_YES_NO    InpUseM30         =  INPUT_YES;        // Use 30 minute timeframe
input ENUM_INPUT_YES_NO    InpUseH1          =  INPUT_YES;        // Use 1 hour timeframe
input ENUM_INPUT_YES_NO    InpUseH2          =  INPUT_NO;         // Use 2 hour timeframe
input ENUM_INPUT_YES_NO    InpUseH3          =  INPUT_NO;         // Use 3 hour timeframe
input ENUM_INPUT_YES_NO    InpUseH4          =  INPUT_YES;        // Use 4 hour timeframe
input ENUM_INPUT_YES_NO    InpUseH6          =  INPUT_NO;         // Use 6 hour timeframe
input ENUM_INPUT_YES_NO    InpUseH8          =  INPUT_NO;         // Use 8 hour timeframe
input ENUM_INPUT_YES_NO    InpUseH12         =  INPUT_NO;         // Use 12 hour timeframe
input ENUM_INPUT_YES_NO    InpUseD1          =  INPUT_YES;        // Use 1 Day timeframe
input ENUM_INPUT_YES_NO    InpUseW1          =  INPUT_YES;        // Use 1 Week timeframe
input ENUM_INPUT_YES_NO    InpUseMN1         =  INPUT_YES;        // Use 1 Month timeframe
input uint                 InpCoordX         =  10;               // Panel X-coordinate
input uint                 InpCoordY         =  10;               // Panel Y-coordinate
input color                InpColorPanel     =  C'240,240,240';   // Panel: Background color
input color                InpColorBorder    =  C'200,200,200';   // Panel: Border color
input color                InpColorHeader    =  clrDarkGray;      // Panel: Header color
input color                InpColorCaption   =  clrBeige;         // Panel: Caption color
input color                InpColorLabels    =  clrSlateGray;     // Panel: Texts color
input color                InpColorUP        =  clrGreen;         // Panel: Bullish direction candle color
input color                InpColorDN        =  clrRed;           // Panel: Bearish direction candle color
input color                InpColorNL        =  clrLightGray;     // Panel: Neutral direction candle color
input uchar                InpAlphaBackgrnd  =  128;              // Panel: Background opacity
//--- global variables
CArrayString   list_symbols;
CArrayInt      list_timeframes;
CArrayObj      list_candles;
CWnd           panel;
string         array_symbols[];
string         gv_name;
int            candle_num;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetMillisecondTimer(16);
//--- setting indicator parameters
   gv_name="Multi_Meter_CandleColor";
   candle_num=(int)InpCandleNum;
//---
   if(!ArraysPreparing())
     {
      Print("Error. Failed to prepare working arrays.");
      return INIT_FAILED;
     }
//---
   list_candles.Clear();
   int total_sym=list_symbols.Total();
   int total_tfs=list_timeframes.Total();
   for(int s=0;s<total_sym;s++)
     {
      for(int t=0;t<total_tfs;t++)
        {
         ENUM_TIMEFRAMES timeframe=(ENUM_TIMEFRAMES)list_timeframes.At(t);
         CCandle *candle=new CCandle(list_symbols.At(s),timeframe);
         if(candle==NULL)
            continue;
         list_candles.Add(candle);
         candle.SetIndexX(t);
         candle.SetIndexY(s);
        }
     }

//--- Панель
   int w=180,h=74;
   int x=int(!GlobalVariableCheck(gv_name+"_GVX") ? int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)-w-InpCoordX) : GlobalVariableGet(gv_name+"_GVX"));
   int y=int(!GlobalVariableCheck(gv_name+"_GVY") ? (int)InpCoordY : GlobalVariableGet(gv_name+"_GVY"));
   panel.SetColors(InpColorPanel,InpColorBorder,clrNONE,clrNONE,InpColorLabels,InpAlphaBackgrnd,255);
   string name=gv_name;
   StringReplace(name,"_"," ");
   if(!panel.CreateWindow(name,x,y,w,h,false,true))
     {
      Print("Failed to create panel. Please restart the indicator");
      return INIT_FAILED;
     }
   RedrawField();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Обновление панели
   RedrawField();

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   static long last_time=0;
   MqlTick tick;
   bool refresh=false;
   int total=list_candles.Total();
   for(int i=0;i<total;i++)
     {
      CCandle *candle=list_candles.At(i);
      if(candle==NULL)
         continue;
      candle.OnTimer();
      if(candle.IsCounterRefreshDone())
        {
         if(SymbolInfoTick(candle.Symbol(),tick))
           {
            if(tick.time_msc>last_time)
              {
               last_time=tick.time_msc;
               refresh=true;
              }
           }
        }
     }
   if(refresh)
      RedrawField();
  }
//+------------------------------------------------------------------+
//| Cart event function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   panel.OnChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//| Обновляет данные панели                                          |
//+------------------------------------------------------------------+
void RedrawField(void)
  {
   int row=list_symbols.Total();
   int col=list_timeframes.Total();
   CCanvas *canvas=panel.GetFieldCanvas();
   if(canvas==NULL)
     {
      Print(__FUNCTION__,": Error: Canvas not available.");
      return;
     }
   int shiftV=14,shiftH=30,startH=90,startV=15;
   panel.Resize(startH+col*shiftH,shiftV+row*shiftV+3);
   canvas.Erase(ColorToARGB(panel.ColorBackground(),0));
   panel.DrawSeparateHLine(1,canvas.Width()-2,13,panel.NewColor(panel.ColorBackground(),-5,-5,-5),panel.NewColor(panel.ColorBackground(),45,45,45));
   panel.DrawSeparateVLine(startH,14,canvas.Height()-2,panel.NewColor(panel.ColorBackground(),-5,-5,-5),panel.NewColor(panel.ColorBackground(),45,45,45));

//---
   int total=list_candles.Total();
   for(int i=0;i<total;i++)
     {
      CCandle* candle=list_candles.At(i);
      if(candle==NULL)
         continue;
      int bars=Bars(candle.Symbol(),candle.Timeframe());
      int num=(candle_num>bars-1 ? bars-1 : candle_num);
      MqlRates data_candle;
      if(!candle.GetData(num,data_candle))
        {
         Print(candle.Symbol(),": loading history ",candle.TimeframeDescription(),". Please wait");
         return;
        }
      int x=candle.IndexX();
      int y=candle.IndexY();
      if(y==0)
        {
         string tf=candle.TimeframeDescription();
         canvas.FontSet(panel.NameCaptionFont(),-80,FW_BLACK);
         canvas.TextOut(startH-2+shiftH/2+x*shiftH,0,tf,ColorToARGB(panel.ColorTexts()),TA_CENTER);
         if(x==0)
            canvas.TextOut(22,0,"Pairs",ColorToARGB(panel.ColorTexts()),TA_CENTER);
        }
      if(x==0)
        {
         canvas.FontSet(panel.NameCaptionFont(),-80,FW_BLACK);
         canvas.TextOut(4,startV+y*shiftV,candle.Symbol()+" Candle "+(string)num,ColorToARGB(panel.ColorTexts()));
        }

      ENUM_CANDLE_TYPE type_candle=candle.GetType(num);
      int gx=startH+12+x*shiftH;
      int gy=startV+6+y*shiftV;
      
      color clr_candle=(type_candle==CANDLE_TYPE_BULLISH ? InpColorUP : type_candle==CANDLE_TYPE_BEARISH ? InpColorDN : InpColorNL);
      int clr_shift_up=(type_candle==CANDLE_TYPE_DOJI ? 20 : type_candle==CANDLE_TYPE_NONE ? 200 : 90);
      int clr_shift_dn=(type_candle==CANDLE_TYPE_BEARISH ? -60 : 0);
      Rectangle(canvas,gx,gy,shiftH-6,shiftV-6,panel.NewColor(clr_candle,clr_shift_dn,clr_shift_dn,clr_shift_dn),panel.NewColor(clr_candle,clr_shift_up,clr_shift_up,clr_shift_up));
     }
   canvas.Update(true);
  }
//+------------------------------------------------------------------+
//| Рисует прямоугольник                                             |
//+------------------------------------------------------------------+
void Rectangle(CCanvas* canvas,const int x,const int y,const int h,const int w,const color clr_bd,const color clr_bg)
  {
   if(canvas==NULL)
      return;
   int h2=(int)ceil(h/2);
   int w2=(int)ceil(w/2);
   int x1=x-h2;
   int y1=y-w2;
   int x2=x+h2;
   int y2=y+w2;
   canvas.FillRectangle(x1,y1,x2,y2,ColorToARGB(clr_bg));
   canvas.Rectangle(x1,y1,x2,y2,ColorToARGB(clr_bd));
  }
//+------------------------------------------------------------------+
//| Проверка символа                                                 |
//+------------------------------------------------------------------+
bool SymbolCheck(const string symbol_name)
  {
   long select=0;
   ResetLastError();
   if(!SymbolInfoInteger(symbol_name,SYMBOL_SELECT,select))
     {
      int err=GetLastError();
      Print("Error: ",err," Symbol ",symbol_name," does not exist");
      return false;
     }
   else
     {
      if(select) return true;
      ResetLastError();
      if(!SymbolSelect(symbol_name,true))
        {
         int err=GetLastError();
         Print("Error selected ",symbol_name,": ",err);
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Возвращает факт наличия символа в списке                         |
//+------------------------------------------------------------------+
bool IsPresentSymbol(const string symbol)
  {
   list_symbols.Sort();
   return(list_symbols.Search(symbol)>WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс символа в списке                               |
//+------------------------------------------------------------------+
int IndexSymbol(const string symbol_name)
  {
   int total=list_symbols.Total();
   for(int i=0;i<total;i++)
      if(list_symbols.At(i)==symbol_name)
         return i;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс таймфрейма в списке                            |
//+------------------------------------------------------------------+
int IndexTimeframe(const ENUM_TIMEFRAMES timeframe)
  {
   int total=list_timeframes.Total();
   for(int i=0;i<total;i++)
      if((ENUM_TIMEFRAMES)list_timeframes.At(i)==timeframe)
         return i;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Подготовка массивов                                              |
//+------------------------------------------------------------------+
bool ArraysPreparing(void)
  {
   if(InpSymbols=="" || InpSymbols==NULL)
     {
      ArrayResize(array_symbols,1);
      array_symbols[0]=Symbol();
     }
   else
     {
      string value=","+InpSymbols;
      int total=StringSplit(InpSymbols,StringGetCharacter(value,0),array_symbols);
      ResetLastError();
      if(total<=0)
        {
         string end=(total==0 ? "Symbols string is empty." : "Error: "+(string)GetLastError());
         Print("Failed to get the array of symbols. ",end);
         return false;
        }
      for(int i=0;i<total;i++)
         SymbolCheck(array_symbols[i]);
     }
   int total=ArraySize(array_symbols);
   list_symbols.Clear();
   for(int i=0;i<total;i++)
     {
      if(!IsPresentSymbol(array_symbols[i]))
         if(SymbolCheck(array_symbols[i]))
            list_symbols.Add(array_symbols[i]);
     }
//---
   list_timeframes.Clear();
   for(int i=0;i<21;i++)
     {
      int tf=GetInputTimeframe(i);
      if(tf==WRONG_VALUE)
         continue;
      list_timeframes.Add((int)tf);
     }
   if(list_timeframes.Total()==0)
      list_timeframes.Add(Period());
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает входной параметр таймфрейма по индексу                |
//+------------------------------------------------------------------+
int GetInputTimeframe(const int index)
  {
   switch(index)
     {
      case 0   : return (InpUseM1   ? PERIOD_M1    : WRONG_VALUE);
      case 1   : return (InpUseM2   ? PERIOD_M2    : WRONG_VALUE);
      case 2   : return (InpUseM3   ? PERIOD_M3    : WRONG_VALUE);
      case 3   : return (InpUseM4   ? PERIOD_M4    : WRONG_VALUE);
      case 4   : return (InpUseM5   ? PERIOD_M5    : WRONG_VALUE);
      case 5   : return (InpUseM6   ? PERIOD_M6    : WRONG_VALUE);
      case 6   : return (InpUseM10  ? PERIOD_M10   : WRONG_VALUE);
      case 7   : return (InpUseM12  ? PERIOD_M12   : WRONG_VALUE);
      case 8   : return (InpUseM15  ? PERIOD_M15   : WRONG_VALUE);
      case 9   : return (InpUseM20  ? PERIOD_M20   : WRONG_VALUE);
      case 10  : return (InpUseM30  ? PERIOD_M30   : WRONG_VALUE);
      case 11  : return (InpUseH1   ? PERIOD_H1    : WRONG_VALUE);
      case 12  : return (InpUseH2   ? PERIOD_H2    : WRONG_VALUE);
      case 13  : return (InpUseH3   ? PERIOD_H3    : WRONG_VALUE);
      case 14  : return (InpUseH4   ? PERIOD_H4    : WRONG_VALUE);
      case 15  : return (InpUseH6   ? PERIOD_H6    : WRONG_VALUE);
      case 16  : return (InpUseH8   ? PERIOD_H8    : WRONG_VALUE);
      case 17  : return (InpUseH12  ? PERIOD_H12   : WRONG_VALUE);
      case 18  : return (InpUseD1   ? PERIOD_D1    : WRONG_VALUE);
      case 19  : return (InpUseW1   ? PERIOD_W1    : WRONG_VALUE);
      default  : return (InpUseMN1  ? PERIOD_MN1   : WRONG_VALUE);
     }
  }
//+------------------------------------------------------------------+
