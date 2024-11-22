module CBD_2(

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

    parameter s0 = 3'd0, s1 = 3'd1 , s2 = 3'd2,s3 = 3'd3,s4 = 3'd4;
    
    //FSM setup
   always @(posedge clk or posedge reset)
        if (reset)
        begin
            address <= -1;
            state <= s0;
        end
        else         
        begin
        case(state)
                s0:begin if(!reset && ready)begin state <= s1;  end
                           else state <=s0;
                  end
                    
                s1: state <=s2;//if(ready)//; else state<=s1;
                s2:state<=s3;
                s3:state<=s4;
                s4 : state <=s0;
                default: state<=s0;
        endcase
        end
        
    // Writing 2_s into subarray
    CBD_2s c1(In[15:0],w1[0]);
    CBD_2s c2(In[31:16],w1[1]);
    CBD_2s c3(In[47:32],w1[2]);
    CBD_2s c4(In[63:48],w1[3]);
    
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
               address<=address+1;
               give_bits<=1'b0;    
               end
            s2:begin
               Out <= w1[1];
               done<=1'b1;
               address<=address+1;     
               end
            s3:begin
               Out <= w1[2]; 
               done<=1'b1;  
               address<=address+1;  
               end  
            s4:begin
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

module CBD_2s( 
    input [15:0] In,
    output [47:0]Out
    );
      
genvar i;

generate
    for(i = 0;i<4;i=i+1)begin
       CBD_4b cb0(In[(i*4)+3:(i*4)],Out[(i*12)+11:i*12]);
    end
endgenerate
endmodule


module CBD_4b(
    input [3:0] In,
    output reg [11:0] Out
    );
    wire [3:0] a,b;
    assign a = In[0]+In[1];
    assign b = In[3]+In[2];
    always @(*)        
            begin
                Out = a - b;
            end
endmodule