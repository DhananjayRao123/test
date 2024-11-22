`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2024 11:28:38
// Design Name: 
// Module Name: fifom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifom #(parameter DEPTH=256 , DATA_WIDTH=13) (
  input clk, rst_n,
  input w_en,r_en,
  input [71:0] data_in,
  input [5:0] valid_in,
  output reg [11:0] data_out,
  output reg valid_out,
  output full, empty
);

  parameter PTR_WIDTH = $clog2(DEPTH);
  reg [PTR_WIDTH:0] w_ptr, r_ptr; // addition bit to detect full/empty condition
  reg [DATA_WIDTH-1:0] fifo[DEPTH-1:0];
  wire [PTR_WIDTH:0] w_ptr_next;
  wire wrap_around;
  
  // Set Default values on reset.
  always@(posedge clk) begin
    if(!rst_n) begin
      w_ptr <= 0; r_ptr <= 0;      
    end
    else  begin
          if(w_en & !full) w_ptr <= w_ptr_next;
          if(r_en & !empty) r_ptr <= r_ptr+1;
    end
  end
  // To write data to FIFO
  always@(posedge clk) begin
    if(w_en & !full)begin
        fifo[w_ptr[PTR_WIDTH-1:0] + 5'd0 ] <= {valid_in[ 0 ], data_in [ 11 : 0 ]};
        fifo[w_ptr[PTR_WIDTH-1:0]+ 5'd1 ] <= {valid_in[ 1 ], data_in [ 23 : 12 ]};
        fifo[w_ptr[PTR_WIDTH-1:0]+ 5'd2 ] <= {valid_in[ 2 ], data_in [ 35 : 24 ]};
        fifo[w_ptr[PTR_WIDTH-1:0]+ 5'd3 ] <= {valid_in[ 3 ], data_in [ 47 : 36 ]};
        fifo[w_ptr[PTR_WIDTH-1:0]+ 5'd4 ] <= {valid_in[ 4 ], data_in [ 59 : 48 ]};
        fifo[w_ptr[PTR_WIDTH-1:0]+ 5'd5 ] <= {valid_in[ 5 ], data_in [ 71 : 60 ]};
     
    end
  end
  // To read data from FIFO
  always@(posedge clk) begin
    if(rst_n& r_en & !empty ) begin
      {valid_out,data_out} <= fifo[r_ptr[PTR_WIDTH-1:0]];
      
     
    end
    else {valid_out,data_out} <= 0;
  end
  
  assign w_ptr_next = w_ptr+6;
  assign wrap_around = w_ptr_next[PTR_WIDTH] ^ r_ptr[PTR_WIDTH]; // To check MSB of write and read pointers are different  
  //Full condition: MSB of write and read pointers are different and remainimg bits are same.
  assign full = wrap_around & (w_ptr_next[PTR_WIDTH-1:0]>= r_ptr[PTR_WIDTH-1:0]);  
  //Empty condition: All bits of write and read pointers are same.
  //assign empty = !wrap_around & (w_ptr[PTR_WIDTH-1:0] == r_ptr[PTR_WIDTH-1:0]);
  //or
  assign empty = (w_ptr == r_ptr);
endmodule
