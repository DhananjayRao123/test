`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2024 14:13:58
// Design Name: 
// Module Name: buffer
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

module buffer #(parameter DEPTH=8, DATA_WIDTH=12) (
  input clk, rst_n,
  input w_en,
  input [DATA_WIDTH-1:0] data_in,
  input valid_in,
  output reg [47:0] data_out,
  output reg valid_out,  
  output full, empty,
  output reg[6:0] counter,
  output done
);
  
  parameter PTR_WIDTH = $clog2(DEPTH);
  reg [PTR_WIDTH:0] w_ptr, r_ptr; // addition bit to detect full/empty condition
  reg [DATA_WIDTH-1:0] fifo[DEPTH - 1:0];
  wire wrap_around;
  
  // Set Default values on reset.
  always@(posedge clk) begin
    if(!rst_n) begin
      w_ptr <= 0; r_ptr <= 0;
      counter <=127;
    end
    else begin
        if(w_en & !full & valid_in) w_ptr <= w_ptr+1;
        if(rst_n & !empty & (w_ptr[PTR_WIDTH-1:0] == 4|w_ptr[PTR_WIDTH-1:0] == 0)) begin
        r_ptr <= r_ptr+4;
        if(counter <63|&counter == 1) counter<= counter+1;
        end
    end
  end  
  // To write data to FIFO
  always@(posedge clk) begin
    if(w_en & !full & valid_in&!done)begin
      fifo[w_ptr[PTR_WIDTH-1:0]] <= data_in;
      
    end
  end  
  // To read data from FIFO
  always@(posedge clk) begin
    if(rst_n & w_ptr[PTR_WIDTH-1:0] == 4 & !empty &!done )begin
      data_out <= {fifo[3],fifo[2],fifo[1],fifo[0]};
      valid_out <=1;
    end
    else if(rst_n & w_ptr[PTR_WIDTH-1:0]==0 & !empty &!done) begin
      data_out <= {fifo[7],fifo[6],fifo[5],fifo[4]};
      valid_out <=1;     
    end
    else begin
        data_out <= 0;
        valid_out<=0;
        end
  end  
  assign wrap_around = w_ptr[PTR_WIDTH] ^ r_ptr[PTR_WIDTH]; // To check MSB of write and read pointers are different
  //Full condition: MSB of write and read pointers are different and remainimg bits are same.
  assign full = wrap_around & (w_ptr[PTR_WIDTH-1:0] == r_ptr[PTR_WIDTH-1:0]);
  //Empty condition: All bits of write and read pointers are same.
  //assign empty = !wrap_around & (w_ptr[PTR_WIDTH-1:0] == r_ptr[PTR_WIDTH-1:0]);
  //or
  assign empty = (w_ptr == r_ptr);
  assign done = (counter == 63);
endmodule
