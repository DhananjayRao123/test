/*
Module Hierarchy :
CBD_Super : Main module - switches on/off CBD_2 and CBD_3 according to n and gives output to Write Buffer along with done signal, seeks input from generation unit with give_bits signal
CBD_2, CBD_3 : Maintain FSM for handiling systamatic 4 coeff output at each clock cycle across the output line for either case of n
CBD_2s, CBD_3s : Use base CBD_4b,CBD_6b units to generate 4 coeff sets for corresponding input using CBD algorithm.
*/



module CBD_Super(
    input clk,
    input reset,
    input n, //n = 0 for eta  = 2 mode, and n = 1 for eta = 3 mode
    input [63:0] In,
    input ready,
    output reg [47:0]Out,
    output reg done,//signal for mux to send output to Write buffer
    output reg give_bits, //signal for PRG to give bit array
    output reg [7:0]address
    );
    
    wire s2,s3;
    wire [47:0] Out2, Out3;
    wire done2, done3;
    wire give_bits2,give_bits3;
    wire [7 :0] address2, address3;
    reg done_64;
    or(s2,n,reset,done_64);
    or(s3,~n,reset,done_64);
    
    CBD_2 c2(clk,s2,In,ready,Out2,done2, give_bits2,address2);
    CBD_3 c3(clk,s3,In,ready,Out3,done3, give_bits3,address3);
  
  always @(posedge clk)
   begin
      case(n)
      1'b1 : begin
             Out <= Out3;
             done <= done3;
             give_bits <= give_bits3;
             
             if(address3 == 7'h3f)
             begin
             address<=0;
             done_64 <=1;
             end
             else 
             begin
             address<=address3;
             done_64<=0;
             end
             end
      1'b0 : begin
             Out <= Out2;
             done <= done2;
             give_bits <= give_bits2;
             if(address2 == 7'h3f)
             begin
             address<=0;
             done_64 <=1;
             end
             else 
             begin
             address<=address2;
             done_64<=0;
             end
             end
      endcase 
   end  
    

endmodule