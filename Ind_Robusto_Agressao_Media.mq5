
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 4
#property indicator_buffers 4 
//---- only three plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a three-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- Gray, Lime and Magenta colors are used for the three-color histogram
#property indicator_color1 Gray,Lime,Magenta
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "MACD"

//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//---- use blue color for the line
#property indicator_color2 Blue
//---- indicator line is a solid curve
#property indicator_style2 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width2 2
//---- displaying the signal line label
#property indicator_label2  "Signal Line"

//---- drawing the indicator as a line
#property indicator_type3 DRAW_LINE
//---- use red color for the line
#property indicator_color3 Red
//---- the indicator line is a dash-dotted curve
#property indicator_style3 STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width3 1
//---- displaying the signal line
#property indicator_label3  "Zona Morta"

#property  indicator_minimum 0.0
//+------------------------------------+
//|  Indicator input parameters        |
//+------------------------------------+
input int Fast_MA = 20;       // Period of the fast MACD moving average
input int Slow_MA = 40;       // Period of the slow MACD moving average
input int BBPeriod=20;        // Bollinger period
input double BBDeviation=2.0; // Number of Bollinger deviations
input int  Sensetive=150;
input int  DeadZonePip=400;
input int  ExplosionPower=15;
input int  TrendPower=150;
input bool AlertWindow=false;
input int  AlertCount=2;
input bool AlertLong=false;
input bool AlertShort=false;
input bool AlertExitLong=false;
input bool AlertExitShort=false;
//+-----------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int MACD_Handle,BB_Handle;
//---- declaration of global variables

//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double IndBuffer1[],ColorIndBuffer1[],IndBuffer2[],IndBuffer3[];
//+------------------------------------------------------------------+    
//| MACD indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=BBPeriod+1;
//---- initialization of variables

//---- getting handle of the iMACD indicator
   MACD_Handle=iMACD(NULL,0,Fast_MA,Slow_MA,9,PRICE_CLOSE);
   if(MACD_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iMACD indicator");
//---- getting handle of the iBands indicator
   BB_Handle=iBands(NULL,0,BBPeriod,0,BBDeviation,PRICE_CLOSE);
   if(BB_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iBands indicator");

//---- set IndBuffer1[] dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(IndBuffer1,true);

//---- set ColorIndBuffer1[] as a colored index buffer   
   SetIndexBuffer(1,ColorIndBuffer1,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ColorIndBuffer1,true);

//---- set IndBuffer2[] as an indicator buffer
   SetIndexBuffer(2,IndBuffer2,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(IndBuffer2,true);

//---- set IndBuffer3[] as an indicator buffer
   SetIndexBuffer(3,IndBuffer3,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(IndBuffer3,true);

//---- creating a name for displaying in a separate sub-window and in a tooltip
   //IndicatorSetString(INDICATOR_SHORTNAME,"Waddah Attar Explosion");
   IndicatorSetString(INDICATOR_SHORTNAME,"RobustoAgressãoMedia");
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| MACD iteration function                                          | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,     // number of bars in history at the current tick
                const int prev_calculated, // number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(MACD_Handle)<rates_total
      || BarsCalculated(BB_Handle)<rates_total
      || rates_total<min_rates_total)
      return(0);
//---- declarations of local variables 
   int limit,to_copy,bar;
   double MACD[],BandsUp[],BandsDn[];
   double Trend1,Explo1,Dead;
   //double pwrt,pwre,Ask,Bid;
   string SirName;
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(spread,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(MACD,true);
   ArraySetAsSeries(BandsUp,true);
   ArraySetAsSeries(BandsDn,true);
//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated;   // starting index for calculation of new bars
     }

   to_copy=limit+2;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(BB_Handle,1,0,to_copy,BandsUp)<=0) return(0);
   if(CopyBuffer(BB_Handle,2,0,to_copy,BandsDn)<=0) return(0);
   to_copy+=2;
   if(CopyBuffer(MACD_Handle,0,0,to_copy,MACD)<=0) return(0);

//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      Trend1=(MACD[bar] - MACD[bar+1])*Sensetive;
      Explo1=BandsUp[bar] - BandsDn[bar];
      Dead=_Point*DeadZonePip;

      IndBuffer1[bar]=MathAbs(Trend1);

      if(Trend1>0) ColorIndBuffer1[bar]=1;
      if(Trend1<0) ColorIndBuffer1[bar]=2;
      IndBuffer2[bar]=Explo1;
      IndBuffer3[bar]=Dead;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
