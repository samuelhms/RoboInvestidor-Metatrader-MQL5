//+------------------------------------------------------------------+
//|                                                    LILPRINCE.mq5 |
//|                                        Copyright 2020, Sam H Mac |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Sam H Mac"
#property link      ""
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;
input bool comentarios = false;
input bool useluna = false;
input int lote = 100;
input int nCandle = 20;
input double nDesvio = 2.5;

double upBand[];
double midBand[];
double lowBand[];
MqlRates rates[];

double ASK, BID,LM,PAGR,PCOM,LAP;

int handle;


int OnInit()
  {
//---
   handle = iBands(Symbol(),Period(),nCandle,0,nDesvio,PRICE_CLOSE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
  PAGR = SymbolInfoDouble(_Symbol,SYMBOL_LAST);
  PCOM = PositionGetDouble(POSITION_PRICE_OPEN);
  LAP = AccountInfoDouble(ACCOUNT_PROFIT);
//+------------------------------------------------------------------+
 // if(isNewBar()){
  
  
  
//---
   ArraySetAsSeries(rates, true);
   ArraySetAsSeries(upBand, true);
   ArraySetAsSeries(midBand, true);
   ArraySetAsSeries(lowBand, true);
   
   
   CopyRates(Symbol(),Period(),0,5,rates);
   CopyBuffer(handle,0,0,5,midBand);
   CopyBuffer(handle,1,0,5,upBand);
   CopyBuffer(handle,2,0,5,lowBand);
   

   bool sinalCompra = false;
   bool sinalVenda = false;
   
//+------------------------------------------------------------------+
// Condiçoes de sinais de compra e venda   
//+------------------------------------------------------------------+

      //COMPRA
       if (rates[2].close < lowBand[2] && rates[1].close>lowBand[1]){
       //ObjectCreate(0,rates[1].time +"",OBJ_ARROW_UP,0,rates[1].time,rates[1].low);
  
       sinalCompra = true;
  
       }
      //VENDA 
       if (rates[2].close > upBand[2] && rates[1].close< upBand[1]){
       //ObjectCreate(0,rates[1].time +"",OBJ_ARROW_DOWN,0,rates[1].time,rates[1].low);
  
       sinalVenda = true;
       }
  
//+------------------------------------------------------------------+
//| VERIFICAR SE ESTOU POSICIONADO                                   |
//+------------------------------------------------------------------+
      bool comprado = false;
      bool vendido = false;
      
      
  
      
      if(PositionSelect(_Symbol))
        {
         //--- se a posição for comprada
         if( PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY )
           {
            comprado = true;
            trade.OrderDelete(trade.ResultOrder());
           }
         //--- se a posição for vendida
         if( PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL )
           {
            vendido = true;
           }
        }
         ASK = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
  
         
//+------------------------------------------------------------------+
//| LÓGICA DE ROTEAMENTO MOVENDO STOP LUNA
      if(useluna){                     
//+------------------------------------------------------------------+
//(USESTOP = True)
      
      //if( !comprado && !vendido  )//--- ZERADO
      //  {
      //   //--- sinal de compra
      //   if( sinalCompra)// || sinalCompra )
      //     {
      //      BID = SymbolInfoDouble(_Symbol,SYMBOL_LAST);
      //      trade.Buy(lote,_Symbol,0,0,BID+1,"Compra a mercado");
      //      trade.OrderDelete(trade.ResultOrder());
      //      trade.PositionModify(_Symbol,ASK+1,0);
      //      LM = BID;
      //     }
      //  }
      //else
      //  {
      //   //--- estou comprado
      //   if( comprado && ASK>BID+0.5 && ASK>LM)
      //     {
      //      ASK = SymbolInfoDouble(_Symbol,SYMBOL_LASTHIGH);
      //      //trade.BuyStop(lote,ASK,_Symbol,0,0,0,0,"stop loss");
      //      trade.PositionModify(_Symbol,ASK-0.05,0);
      //      LM = ASK;
      //     }
      //  } 
  
//+------------------------------------------------------------------+
    } //| FIM LÓGICA DE ROTEAMENTO MOVENDO STOP 
    else
    { //| INICO LÓGICA DE COMPRA VENDA OUTRO                    
//+------------------------------------------------------------------+
//(USESTOP = false)

         if(!comprado && !vendido){   //--- ZERADO NEM COMPRADO NEM VENDIDO
        
         //--- sinal de compra
           if( sinalCompra ){            
           
               BID = SymbolInfoDouble(_Symbol,SYMBOL_LAST);
              //trade.Buy(lote,_Symbol,rates[1].low,0,BID+1,"Compra a mercado");
              trade.BuyLimit(lote,lowBand[1],_Symbol,0,0,ORDER_TIME_SPECIFIED,0,"Buy limit");
              
              
           }
           
        }
        
        if(comprado){ //---  COMPRADO COM PAPEIS NA MÃO

        //--- sinal de venda
           if( sinalVenda && PAGR > PCOM){           
               //trade.Sell(lote,_Symbol,rates[1].high,0,0,"Compra a mercado");
               trade.PositionModify(_Symbol,PAGR-0.02,0);
           }
        
        }
        
  
  
  
  

    }
//+------------------------------------------------------------------+
  //} //end isNewBar()
  if(comentarios){
     Comment("up: "+ upBand[1]+"\nmid: "+midBand[1]+"\nlow :"+lowBand[1]+"\n\n Close :"+rates[0].close
     +"\nComprado: "+comprado+ "\nPAGR: "+PAGR+"\nPCOM: "+PCOM
         );
      }
  
  
  } //end onTick()
//+------------------------------------------------------------------+

bool isNewBar() {
//--- memorize the time of opening of the last bar in the static variable
   static datetime last_time=0;
//--- current time
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(last_time==0)
     {
      //--- set the time and exit
      last_time=lastbar_time;
      return(false);
     }

//--- if the time differs
   if(last_time!=lastbar_time)
     {
      //--- memorize the time and return true
      last_time=lastbar_time;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }