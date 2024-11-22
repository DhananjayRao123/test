`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2024 14:28:00
// Design Name: 
// Module Name: Parse
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


module Parse(
    input clk,
    input inp_valid,
    input resetb,
    input [63:0] In,
    output [47:0] out,
    output  valid,
    output gimme,
    output [5:0]address,
    output done
    );
    wire [71:0] out_p_f;
    wire [5:0] valid_p_f;
    wire full_f, empty_f, r_en_f ,full_b, empty_b,w_en_f;
    reg w_en_b;
    wire [11:0] out_f_b;
    wire valid_f_b;
Parse_Super Ps1(
     clk,
     inp_valid,
     resetb,
     In,
     out_p_f,
     valid_p_f,
     w_en_f    
    );
fifom fifo1(
 clk, resetb,
 w_en_f,r_en_f,//start is a problem here as the fifo doesnt read the input as soon as it goes down
 out_p_f,
 valid_p_f,
   out_f_b,
  valid_f_b,
  full_f, empty_f
);

buffer buffer1(clk, resetb,
 w_en_b,
   out_f_b,
  valid_f_b,
 out,
  valid,
 full_b, empty_b,address,done);
 assign gimme =!full_f &!done;
assign r_en_f = !full_b;//this will turn off only at the next clk edge ..need to fix this
always@(posedge clk)
begin
    w_en_b <= !empty_f & !full_b;
end
    
endmodule
