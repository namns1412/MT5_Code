//+------------------------------------------------------------------
//|                                   NamedPipeServerBroadcaster.mq5 |
//|                                      Copyright 2010, Investeo.pl |
//|                                                http:/Investeo.pl |
//+------------------------------------------------------------------
#property copyright "Copyright 2010, Investeo.pl"
#property link      "http:/Investeo.pl"
#property version   "1.00"
#property script_show_inputs
#include <CNamedPipes.mqh>

input int account = 0;

CNamedPipe pipe;
//+------------------------------------------------------------------
//| Script program start function                                    |
//+------------------------------------------------------------------
void OnStart()
  {
   bool tickReceived;
   int i=0;

   if(pipe.Create(account)==true)
      while(GlobalVariableCheck("gvar0")==false)
        {
         if(pipe.Connect()==true)
            Print("管道已连接");
            i=0;
         while(true)
           {
            do
              {
               tickReceived=pipe.ReadTick();
               if(tickReceived==false)
                 {
                  if(kernel32::GetLastError()==ERROR_BROKEN_PIPE)
                    {
                     Print("客户端从管道断开 "+pipe.GetPipeName());
                     pipe.Disconnect();
                     break;
                    }
                  } else  {
                   i++; Print(IntegerToString(i)+" 服务器收到即时价.");
                  string bidask=DoubleToString(pipe.incoming.bid)+";"+DoubleToString(pipe.incoming.ask);
                  long currChart=ChartFirst(); int chart=0;
                  while(chart<100) // 我们确认没有超过 CHARTS_MAX 的打开图表
                    {
                     EventChartCustom(currChart,6666,0,(double)account,bidask);
                     currChart=ChartNext(currChart); // 我们之前已收到新图表
                     if(currChart==0) break;         // 到达图表清单结尾
                     chart++;// 不要忘记增加计数器
                    }
                     if(GlobalVariableCheck("gvar0")==true || (kernel32::GetLastError()==ERROR_BROKEN_PIPE)) break;
              
                 }
              }
            while(tickReceived==true);
            if(i>0)
              {
               Print(IntegerToString(i)+"即时价收到.");
               i=0;
              };
            if(GlobalVariableCheck("gvar0")==true || (kernel32::GetLastError()==ERROR_BROKEN_PIPE)) break;
            Sleep(100);
           }

        }


  pipe.Close(); 
  }
//+------------------------------------------------------------------

//Print("管道时间Time from pipe "+TimeToString(pipe.incoming.time)+"出价 : "+DoubleToString(pipe.incoming.bid)+" 询价: "+DoubleToString(pipe.incoming.ask));
//long currChart=ChartFirst();


//string bidask = DoubleToString(pipe.incoming.bid)+";"+DoubleToString(pipe.incoming.ask);
/*
         while(i<CHARTS_MAX)                  // 我们确认没有超过 CHARTS_MAX 的打开图表
         {
          EventChartCustom(currChart,5000,i,pipe.incoming.bid,bidask);
            currChart=ChartNext(currChart); // 我们之前已收到新图表
            if(currChart==0) break;         // 到达图表清单结尾
            i++;// 不要忘记增加计数器
         }
         */
//+------------------------------------------------------------------
