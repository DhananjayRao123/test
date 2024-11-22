module CBD_3(
    
    input clk,
    input reset,
    input [63:0] In,
    input ready,
    output reg [47:0]Out,
    output reg done,
    output reg give_bits,
    output reg [7:0]address
    );
     reg [3:0] state;
    wire [47:0] w1 [3:0];
    
    reg [47:0] temp_in;

     
    parameter s0 = 4'd0, s1 = 4'd1 , s2 =4'd2,s3 = 4'd3,s4 = 4'd4, s5 = 4'd5,s6 = 4'd6, s7 = 4'd7 , s8 =4'd8;
    
    //FSM setup
    always @(posedge clk or posedge reset)
        if (reset)
        begin
            address <=-1;
            state <= s0;
        end
        else         
        begin
        case(state)
                s0:begin if(!reset && ready )begin state <= s1;  end
                           else state <=s0;
                  end
                    
                s1: if(ready)state <=s2; else state<=s0;
                s2:state<=s3;
                s3: if(ready)state <=s4; else state<=s0;
                s4 : state <=s5;
                s5: if(ready)state <=s6; else state<=s0;
                s6:state<=s7;
                s7 : state <=s8;
                s8 : state <=s0;
                default: state<=s0;
        endcase
        end 
        
    // Writing 3_s into subarray
    CBD_3s c1(In[23:0],w1[0]);
    CBD_3s c2(In[47:24],w1[1]);
    CBD_3s c3(temp_in[23:0],w1[2]);
    CBD_3s c4(temp_in[47:24],w1[3]);
    
    //FSM
    always @(state)
        begin
            case(state)
            s0:begin
               Out <= 47'b0;
               done<=1'b0; 
               give_bits<=1'b1;
               address<=address;  
               end
            s1:begin    
               Out <= w1[0];
               done<=1'b1;    
               give_bits<=1'b0; 
               temp_in[15:0] <=In[63:48];
               address<=address+1; 
               end
            s2:begin
               Out <= w1[1];
               done<=1'b1;   
               give_bits<=1'b1; 
               address<=address+1;  
               end
            s3:begin
               Out <= w1[0]; 
               done<=1'b1; 
               give_bits<=1'b0;
               temp_in[31:16] <=In[63:48];
               address<=address+1;    
               end  
            s4:begin
               Out <= w1[1];
               done<=1'b1;  
               give_bits<=1'b1; 
               address<=address+1;   
               end  
            s5:begin    
               Out <= w1[0];
               done<=1'b1;  
               give_bits<=1'b0;
               temp_in[47:32] <=In[63:48];  
               address<=address+1;  
               end
            s6:begin
               Out <= w1[1];
               done<=1'b1;
               address<=address+1;      
               end
            s7:begin
               Out <= w1[2]; 
               done<=1'b1;   
               address<=address+1; 
               end  
            s8:begin
               Out <= w1[3];
               done<=1'b1;  
               address<=address+1; 
                  
               end  
            default: begin 
            Out <= 47'b0;
            done<=1'b0;       
               end    
            endcase  
        end
     
    

endmodule


module CBD_3s( 
    input [23:0] In,
    output  [47:0]Out
    );
      
genvar i;

generate
    for(i = 0;i<4;i=i+1)begin
       CBD_6b cb0(In[(i*6)+5:(i*6)],Out[(i*12)+11:i*12]);
    end
endgenerate
endmodule

module CBD_6b(
    input [5:0] In,
    output reg [11:0] Out
    );
    wire [11:0] a,b;
    assign a = In[0]+In[1]+In[2];
    assign b = In[3]+In[4]+In[5];
    always @(*)        
            begin
                Out = a - b;
            end
endmodule