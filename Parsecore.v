`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2024 10:28:10
// Design Name: 
// Module Name: Parsecore
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

module Parsecore(
    input [11:0] In,
    output reg [11:0] Out,
    output reg valid

    );
    always @(*)    
    begin         
        Out[11:0]  = In[11:0]; 
        valid= 1'b0;        
        if (Out[11:0] <12'hd01)
            valid =1'b1;                    
        
    end
endmodule
