`timescale 1ns / 1ps


`define BUF_WIDTH 6    // BUF_SIZE = 16 -> BUF_WIDTH = 4, no. of bits to be used in pointer
`define BUF_SIZE ( 1<< `BUF_WIDTH )
`define DATA_SIZE 64

module Sync_FIFO( clk, rst, buf_in, buf_out, wr_en, rd_en, buf_empty, buf_full, out_valid);

input                 rst, clk, wr_en, rd_en;   
// reset, system clock, write enable and read enable.
input [`DATA_SIZE-1:0]           buf_in;                   
// data input to be pushed to buffer
output[`DATA_SIZE-1:0]           buf_out;                  
// port to output the data using pop.
output                buf_empty, buf_full;
output                  reg out_valid;      
// buffer empty and full indication 
// output[`BUF_WIDTH:0] fifo_counter;             
// number of data pushed in to buffer   

reg[`DATA_SIZE-1:0]              buf_out;
reg                   buf_empty, buf_full;
reg[`BUF_WIDTH :0]    fifo_counter;
reg[`BUF_WIDTH -1:0]  rd_ptr, wr_ptr;           // pointer to read and write addresses  
reg[`DATA_SIZE-1:0]              buf_mem[`BUF_SIZE -1 : 0]; //  

always @(fifo_counter)
begin
   buf_empty = (fifo_counter==0);   // Checking for whether buffer is empty or not
   buf_full = (fifo_counter== `BUF_SIZE);  //Checking for whether buffer is full or not

end

//Setting FIFO counter value for different situations of read and write operations.
always @(posedge clk or posedge rst)
begin
   if( rst ) begin
       fifo_counter <= 0;		// Reset the counter of FIFO

    end
   else if( (!buf_full && wr_en) && ( !buf_empty && rd_en ) )  //When doing read and write operation simultaneously
       fifo_counter <= fifo_counter;			// At this state, counter value will remain same.

   else if( !buf_full && wr_en )			// When doing only write operation
       fifo_counter <= fifo_counter + 1;

   else if( !buf_empty && rd_en )		//When doing only read operation
       fifo_counter <= fifo_counter - 1;

   else
      fifo_counter <= fifo_counter;			// When doing nothing.
end

always @( posedge clk or posedge rst)
begin
   if( rst ) begin
      buf_out <= 0;
             out_valid <= 0;
   end		//On reset output of buffer is all 0.
   else
   begin
      if( rd_en && !buf_empty ) begin
         buf_out <= buf_mem[rd_ptr];	//Reading the 8 bit data from buffer location indicated by read pointer
        out_valid <= 1;
    end
      else begin
         buf_out <= buf_out;		
         out_valid <= 0;
     end
   end
end

always @(posedge clk)
begin
   if( wr_en && !buf_full )
      buf_mem[ wr_ptr ] <= buf_in;		//Writing 8 bit data input to buffer location indicated by write pointer

   else
      buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
end

always@(posedge clk or posedge rst)
begin
   if( rst )
   begin
      wr_ptr <= 0;		// Initializing write pointer
      rd_ptr <= 0;		//Initializing read pointer
   end
   else
   begin
      if( !buf_full && wr_en )    
			wr_ptr <= wr_ptr + 1;		// On write operation, Write pointer points to next location
      else  
			wr_ptr <= wr_ptr;

      if( !buf_empty && rd_en )   
			rd_ptr <= rd_ptr + 1;		// On read operation, read pointer points to next location to be read
      else 
			rd_ptr <= rd_ptr;
   end

end
endmodule