//разрыв роботу не страшен так как переменные остаются. а вот при перезапуске неоходимо найти открытые ордера и 
//внести их в текущее окружение робота

#include "head.mqh"

void fnRestart(stThree &MxSmb[],ulong magic,int accounttype)
   {
      string   smb1,smb2,smb3;
      long     tkt1,tkt2,tkt3;
      ulong    mg;
      uchar    count=0;    //счётик восстановленных треугольников
      
      switch(accounttype)
      {
         // с хеджевым счётом восстановить позиции просто - пройтись по всем октрытым ,по магику найти свои и 
         // после сформировать их в треугольники
         // с неттингом сложнее - нужно обратится к собственной базе в которой хранятся открытые роботом позиции
         
         // алгоритм поиска своих позиций и восстановление их в треугольник реализовано - в лоб, без изысков и 
         // оптимизации. Но так как этот этап необходим не часто, то можно пренебречь производительностью ради
         // сокращения кода
         
         case  ACCOUNT_MARGIN_MODE_RETAIL_HEDGING:
            // перебираем все открытые позиции и смотрим совпадение по магику
            // также нам необходимо запомнить магик первой найденной позиции, потому то две остальные
            // мы будем искать уже по конкретно этому магику
            
            for(int i=PositionsTotal()-1;i>=2;i--)
            {//for i
               smb1=PositionGetSymbol(i);
               mg=PositionGetInteger(POSITION_MAGIC);
               if (mg<magic || mg>(magic+MAGIC)) continue;
               
               // запоминаем тикет чтобы далее было проще обращатсья к данной позиции
               tkt1=PositionGetInteger(POSITION_TICKET);
               
               // теперь ищем вторую позицию у которой такой же магик 
               for(int j=i-1;j>=1;j--)
               {//for j
                  smb2=PositionGetSymbol(j);
                  if (mg!=PositionGetInteger(POSITION_MAGIC)) continue;  
                  tkt2=PositionGetInteger(POSITION_TICKET);          
                    
                  // осталось найти последнюю позицию
                  for(int k=j-1;k>=0;k--)
                  {//for k
                     smb3=PositionGetSymbol(k);
                     if (mg!=PositionGetInteger(POSITION_MAGIC)) continue;
                     tkt3=PositionGetInteger(POSITION_TICKET);
                     
                     // если пришли сюда значит нашли открытый треугольник. Данные все о нём уже загружены, нам осталось  
                     // только сказать роботу что этот треугольник уже открыт. Всё остальное робот подсчитает на следующем тике
                     
                     for(int m=ArraySize(MxSmb)-1;m>=0;m--)
                     {//for m
                        // пробежимся по массиву треугольников, игнорируя те, что уже открыты
                        if (MxSmb[m].status!=0) continue; 
                        
                        // перебор в лоб - грубо, но быстро
                        // на первый взгляд может показаться что мы в этом сравнении можем обратиться несколько раз к 
                        // одной и той же валютной паре. Однако это не так, потому что в циклах перебора, которые выше, 
                        // после нахождения очередной валютной пары, мы продолжаем поиск дальше, со следующей пары, а не 
                        // с самого начала.
                        if (  (MxSmb[m].smb1.name==smb1 || MxSmb[m].smb1.name==smb2 || MxSmb[m].smb1.name==smb3) &&
                              (MxSmb[m].smb2.name==smb1 || MxSmb[m].smb2.name==smb2 || MxSmb[m].smb2.name==smb3) &&
                              (MxSmb[m].smb3.name==smb1 || MxSmb[m].smb3.name==smb2 || MxSmb[m].smb3.name==smb3)); else continue;
                        
                        //значит мы нашли этот треугольник и присваиваем ему соответствующий статус
                        MxSmb[m].status=2;
                        MxSmb[m].magic=magic;
                        MxSmb[m].pl=0;
                        
                        // расставляем тикеты в нужной последовательности и всё, треугольник вновь в работе.
                        if (MxSmb[m].smb1.name==smb1) MxSmb[m].smb1.tkt=tkt1;
                        if (MxSmb[m].smb1.name==smb2) MxSmb[m].smb1.tkt=tkt2;
                        if (MxSmb[m].smb1.name==smb3) MxSmb[m].smb1.tkt=tkt3;
      
                        if (MxSmb[m].smb2.name==smb1) MxSmb[m].smb2.tkt=tkt1;
                        if (MxSmb[m].smb2.name==smb2) MxSmb[m].smb2.tkt=tkt2;
                        if (MxSmb[m].smb2.name==smb3) MxSmb[m].smb2.tkt=tkt3;   
      
                        if (MxSmb[m].smb3.name==smb1) MxSmb[m].smb3.tkt=tkt1;
                        if (MxSmb[m].smb3.name==smb2) MxSmb[m].smb3.tkt=tkt2;
                        if (MxSmb[m].smb3.name==smb3) MxSmb[m].smb3.tkt=tkt3;   
                        
                        count++;                        
                        break;   
                     }//for m              
                  }//for k              
               }//for j         
            }//for i         
         break;
         default:
         break;
      }
      

      if (count>0) Print("Restore "+(string)count+" triangles");            
   }