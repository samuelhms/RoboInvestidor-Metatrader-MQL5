//+------------------------------------------------------------------+
//|                                             Robô Média Móvel.mq5 |
//|                                                      DeltaTrader |
//|                                           www.deltatrader.com.br |
//+------------------------------------------------------------------+
#property copyright "DeltaTrader"
#property link      "www.deltatrader.com.br"
#property version   "1.00"
//+------------------------------------------------------------------+
//| INCLUDES                                                         |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh> // biblioteca-padrão CTrade
//+------------------------------------------------------------------+
//| INPUTS                                                           |
//+------------------------------------------------------------------+
input int lote = 100;
input double lucro = 0.5;

input int PERIODOMEDIA = 1;
input int periodoCurta = 5;
input int PERIODOm4 = 10;
input int periodoLonga = 20;


input double PRECO = 100.00;
input double RAZAO1 = 1.005;//RAZAO DE ESTRATEGIA %
input double RAZAO2 = 1.030;//RAZAO DE VENDA RAPIDA%
input double MINIMO = 1;
//+------------------------------------------------------------------+
//| GLOBAIS                                                          |
//+------------------------------------------------------------------+
//--- manipuladores dos indicadores de média móvel
int curtaHandle = INVALID_HANDLE;
int longaHandle = INVALID_HANDLE;
int MEDIAHandle = INVALID_HANDLE;
int m4Handle = INVALID_HANDLE;

//--- vetores de dados dos indicadores de média móvel
double mediaCurta[];
double mediaLonga[];
double MEDIAMEDIA[];
double MEDIAm4[];
double ASK, BID;
//--- declarara variável trade
CTrade trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  //PositionSelect(_Symbol)
  BID = PRECO;
//---
   ArraySetAsSeries(mediaCurta,true);
   ArraySetAsSeries(mediaLonga,true);
   ArraySetAsSeries(MEDIAMEDIA,true);
   ArraySetAsSeries(MEDIAm4,true);

//--- atribuir p/ os manupuladores de média móvel
   curtaHandle = iMA(_Symbol,_Period,periodoCurta,0,MODE_SMA,PRICE_CLOSE);
   longaHandle = iMA(_Symbol,_Period,periodoLonga,0,MODE_SMA,PRICE_CLOSE);
   MEDIAHandle = iMA(_Symbol,_Period,PERIODOMEDIA,0,MODE_SMA,PRICE_CLOSE);
   m4Handle = iMA(_Symbol,_Period,PERIODOm4,0,MODE_SMA,PRICE_CLOSE);
   
//---

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(isNewBar())
     {
      // execute a lógica operacional do robô
      
      //+------------------------------------------------------------------+
      //| OBTENÇÃO DOS DADOS                                               |
      //+------------------------------------------------------------------+
      int copied1 = CopyBuffer(curtaHandle,0,0,5,mediaCurta);
      int copied2 = CopyBuffer(longaHandle,0,0,5,mediaLonga);
      int copied3 = CopyBuffer(MEDIAHandle,0,0,5,MEDIAMEDIA);
      int copied4 = CopyBuffer(m4Handle,0,0,5,MEDIAm4);
      
      //---
      bool sinalCompra = false;
      bool sinalVenda = false;
      //--- se os dados tiverem sido copiados corretamente
      if(copied1==5 && copied2==5 && copied3==5 && copied4==5)
        {
         //--- sinal de compra
         //if( mediaCurta[0]<mediaLonga[0] && mediaCurta[1]>mediaLonga[1] && (MEDIAMEDIA[0]*RAZAO1) < mediaLonga[0] )
          if(MEDIAMEDIA[0] < mediaCurta[0] && mediaCurta[0] < MEDIAm4[0] && MEDIAm4[0] < mediaLonga[0])
           {
            sinalCompra = true;
            
           }
          
           
         //--- sinal de venda
         if( mediaCurta[0]>mediaLonga[0] && mediaCurta[1]<mediaLonga[1] && MEDIAMEDIA[0]> (mediaLonga[0]*RAZAO1) )
           {
           sinalVenda = true;
           }
           
           
           //variaçao muito relevante ganhar 2 reais 
          
         
           if( (MEDIAMEDIA[0]*RAZAO2) < mediaLonga[1] )
           {
            sinalCompra = true;
            }
          if( (MEDIAMEDIA[0])> (mediaLonga[1]*RAZAO2) )
           {
            sinalVenda = true;
           }
         
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
           }
         //--- se a posição for vendida
         if( PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL )
           {
            vendido = true;
           }
        }
         ASK = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         
      //+------------------------------------------------------------------+
      //| LÓGICA DE ROTEAMENTO                                             |
      //+------------------------------------------------------------------+
      //--- ZERADO
      if( !comprado && !vendido )
        {
        
         //--- sinal de compra
         if( sinalCompra)// || sinalVenda )
           {
            BID = SymbolInfoDouble(_Symbol,SYMBOL_LAST);
            trade.Buy(lote,_Symbol,0,0,BID+lucro,"Compra a mercado");
            
           }
         //--- sinal de venda
         if( sinalVenda )
           {
            //trade.Sell(lote,_Symbol,0,0,0,"Venda a mercado");
           }
        }
      else
        {
         //--- estou comprado
         if( comprado )
           {
            ASK = SymbolInfoDouble(_Symbol,SYMBOL_LAST);
            
            
            
            
            
            
             // if(( sinalVenda && (ASK > (BID+MINIMO)))|| ASK >(BID+2))
             // {
             // trade.Sell(lote,_Symbol,0,0,0,"Virada de mão (compra->venda)");
             // }
           }
         //--- estou vendido
         else if( vendido )
           {
            if( sinalCompra )
              {
               //trade.Buy(lote*2,_Symbol,0,0,0,"Virada de mão (venda->compra)");
              }
           }
        }
      
      
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewBar()
  {
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