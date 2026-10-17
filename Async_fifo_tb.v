
module Async_fifo_tb ;

/////////////////////////////////////////////////////////
///////////////////// Parameters ////////////////////////
/////////////////////////////////////////////////////////

parameter D_SIZE = 8 ;                          // data size
parameter A_SIZE = 3  ;                         // address size
parameter P_SIZE = 4  ;                         // pointer width
parameter BURST_LEN = 9 ;                       // burst length
parameter FIFO_DEPTH = 8  ;                     // fifo depth
parameter Write_CLK_PERIOD = 10 ;               // 100 MHz
parameter Read_CLK_PERIOD  = 25 ;               // 40 MHz

/////////////////////////////////////////////////////////
//////////////////// DUT Signals ////////////////////////
/////////////////////////////////////////////////////////
  
reg                    i_w_clk;              // write domian operating clock
reg                    i_w_rstn;             // write domian active low reset  
reg                    i_w_inc;              // write control signal 
reg                    i_r_clk;              // read domian operating clock
reg                    i_r_rstn;             // read domian active low reset 
reg                    i_r_inc;              // read control signal
reg   [D_SIZE-1:0]     i_w_data;             // write data bus 
wire  [D_SIZE-1:0]     o_r_data;             // read data bus
wire                   o_full;               // fifo full flag
wire                   o_empty;              // fifo empty flag

/////////////////////////////////////////////////////////
/////////////////////// Memories ////////////////////////
/////////////////////////////////////////////////////////

reg [D_SIZE-1:0] Burst_Words [0:BURST_LEN-1] ;

/////////////////////////////////////////////////////////
///////////////// Loops Variables ///////////////////////
/////////////////////////////////////////////////////////

integer                       WR_WORD ;
integer                       RD_WORD ;


////////////////////////////////////////////////////////
//////////////// Write initial block /////////////////// 
////////////////////////////////////////////////////////

initial 
 begin
 
 // Save Waveform
 $dumpfile("Async_fifo.vcd") ;    
 $dumpvars;                       

 // Read hexadeciemal values from stimulus txt file
 $readmemh("C:/Users/Durgesh/async_fifo2/stimulus.txt",Burst_Words);             

 // Monitor Write Data Bus
 $monitor ("WRITE DATA is %h ", i_w_data);
 
 // Initialization
 initialize() ;

 // Reset
 wr_reset() ; 
 
 // Writing Successive Data into FIFO
 for (WR_WORD=0;WR_WORD<BURST_LEN;WR_WORD=WR_WORD+1)
  begin
   WR_FIFO_DATA(Burst_Words[WR_WORD]) ;                   
  end

  
 end

////////////////////////////////////////////////////////
///////////////// Read initial block /////////////////// 
//////////////////////////////////////////////////////// 

initial 
 begin             

 // Monitor Read Data Bus
 $monitor ("Read DATA is %h", o_r_data);
 
 // Read Domain Reset
 rd_reset() ; 
 
 wait(!o_empty) ;

 // Writing Successive Data into FIFO
 for (RD_WORD=0;RD_WORD<BURST_LEN;RD_WORD=RD_WORD+1)
  begin
   RD_FIFO_DATA() ;                   
  end

#(Read_CLK_PERIOD * 10);

 $stop();

 end

 
////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////

/////////////// Signals Initialization //////////////////

task initialize ;
  begin
    i_w_clk = 1'b0 ;
    i_r_clk = 1'b0 ;
    i_w_rstn = 1'b1 ;
    i_r_rstn = 1'b1 ; 
    i_w_inc = 1'b0 ;
    i_r_inc = 1'b0 ;
    i_w_data = 'd0;  	
  end
endtask

///////////////////////// RESET /////////////////////////

task wr_reset ;
 begin
  #(Write_CLK_PERIOD)
  i_w_rstn  = 'b0;           // Write Domain Rst is activated
  #(Write_CLK_PERIOD)
  i_w_rstn  = 'b1;           // Write Domain Rst is de-activated
  #(Write_CLK_PERIOD) ;
 end
endtask

task rd_reset ;
 begin
  #(Read_CLK_PERIOD/2)
  i_r_rstn  = 'b0;           // Read Domain Rst is activated  
  #(Read_CLK_PERIOD)
  i_r_rstn  = 'b1;           // Read Domain Rst is de-activated  
  #(Read_CLK_PERIOD/2) ;
 end
endtask

////////////////// Write FIFO Data ////////////////////
/*
task WR_FIFO_DATA ;
 input  [D_SIZE-1:0]  DATA ;

 begin
    i_w_data = DATA ;   
    i_w_inc = 1'b1 ;
    #(Write_CLK_PERIOD);
    //i_w_inc = 1'b0 ;
    //#(Write_CLK_PERIOD);
 end
endtask

////////////////// Read FIFO Data ////////////////////

task RD_FIFO_DATA ;

 begin
    i_r_inc = 1'b1 ;
    #(Read_CLK_PERIOD);
    //i_r_inc = 1'b0 ;
   // #(Read_CLK_PERIOD);
 end
endtask
*/

////////////////// Write FIFO Data ////////////////////

task WR_FIFO_DATA;
    input [D_SIZE-1:0] DATA;
    begin
        @(negedge i_w_clk);
        wait (o_full == 1'b0);

        i_w_data = DATA;
        i_w_inc  = 1'b1;

        @(negedge i_w_clk);
        i_w_inc = 1'b0;
    end
endtask


////////////////// Read FIFO Data ////////////////////

task RD_FIFO_DATA;
    begin
        @(negedge i_r_clk);
        wait (o_empty == 1'b0);

        i_r_inc = 1'b1;

        @(negedge i_r_clk);
        i_r_inc = 1'b0;
    end
endtask


///////////////////// Clock Generator //////////////////

always #(Write_CLK_PERIOD/2)  i_w_clk = ~i_w_clk ;     // 10 ns period (100 MHz clock frequency)  
   
always #(Read_CLK_PERIOD/2)   i_r_clk = ~i_r_clk ;     // 25 ns period (40 MHz clock frequency) 

///////////////// Module Instantiation ////////////////

Async_fifo # (.D_SIZE(D_SIZE), .F_SIZE(FIFO_DEPTH)) DUT (
.i_w_clk(i_w_clk),      
.i_r_clk(i_r_clk),      
.i_w_rstn(i_w_rstn),          
.i_r_rstn(i_r_rstn),        
.i_r_inc(i_r_inc),    
.i_w_inc(i_w_inc),       
.i_w_data(i_w_data),       
.o_r_data(o_r_data),     
.o_full(o_full),     
.o_empty(o_empty)
);

endmodule