`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2024 10:10:47
// Design Name: 
// Module Name: ParseSuper
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


  module Parse_Super(
    input clk,
    input start,
    input resetb,
    input [63:0] In,
    output [71:0] out,
    output [5:0] valid,
    output reg f_en
    
    );
    parameter s0 = 2'd0, s1 = 2'd1 , s2 = 2'd2, s3 = 2'd3;
    reg [2:0] state;
    reg [71:0] temp_in;
    reg [7:0] buffer;
    reg [7:0] buffer_in;
    wire [71:0] temp_out;
    
    always @(posedge clk or negedge resetb)
        if (!resetb | !start)
        begin
            buffer <= 0;
            state <= s0;
            
        end
        else         
        begin
        buffer <= buffer_in;
        case(state)
                s0:state <= s1;
                    
                s1:state<=s2;
                s2:state<=s3;
                s3:state<=s1;
                default: state<=s0;
        endcase
        end
    always@(state)
        begin
            
            case(state)
                s0: begin temp_in[71:0] <= {72{1'b1}};buffer_in <= 8'hff;f_en <= 0;  end
                s1: begin
                    temp_in[59:0]<= In[59:0];
                    temp_in[71:60]<= 12'hFFF;
                    buffer_in <= {4'b0 ,In[63:60]};
                    f_en <= 1;
                                        
                    end
                s2: begin
                    temp_in[59:0]<= {In[55:0],buffer[3:0]};
                    temp_in[71:60]<= 12'hFFF;
                    buffer_in <= In[63:56];
                    f_en <= 1;
                    end
                    
                s3:begin
                    temp_in[59:0]<= {In[51:0],buffer[7:0]};
                    temp_in[71:60]<= In[63:52];
                    buffer_in <= 8'b0;
                    f_en <= 1;
                    end
                default:begin temp_in[71:0] <= {72{1'b1}};buffer_in <= 8'hff; f_en <= 0;  end
            endcase
                    
        end
    Parsecore p0(temp_in [11:0],temp_out[11:0],valid[0]);
    Parsecore p1 (temp_in [ 23 : 12 ],temp_out[ 23 : 12 ],valid[ 1 ]);
    Parsecore p2 (temp_in [ 35 : 24 ],temp_out[ 35 : 24 ],valid[ 2 ]);
    Parsecore p3 (temp_in [ 47 : 36 ],temp_out[ 47 : 36 ],valid[ 3 ]);
    Parsecore p4 (temp_in [ 59 : 48 ],temp_out[ 59 : 48 ],valid[ 4 ]);
    Parsecore p5 (temp_in [ 71 : 60 ],temp_out[ 71 : 60 ],valid[ 5 ]);
    assign out = temp_out;
    
endmodule
