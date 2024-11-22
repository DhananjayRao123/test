// `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.11.2024 16:30:31
// Design Name: 
// Module Name: Hash
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


module Hash(
    input clk,
    input rst,
    input [2:0] mode,
    input is_last,
    input start_calc,
    input in_valid,
    input [63:0] in,
    input n,
    input i,
    input j,
    
    output ack,
    output reg [47:0] out_sample,
    output reg rhosigready, // Ready from Keccak to say that it is ready to accept the next instruciton
    // output done, // Done from parse
    output reg [5:0] SRAM_address,
    output reg out_sample_valid
);

    Parse pare(.clk(clk),//
    .inp_valid(out_valid_parse),//
    .resetb(!rst),//
    .In(out),//
    .out(out_parse),//
    .valid(done_parse), 
    .gimme(gimme_parse),//
    .address(SRAM_address_parse),// 
    .done(done)
    );
    
    CBD_Super skibidy(
    .clk(clk),//
    .reset(rst),//
    .n(n), //n = 0 for eta  = 2 mode, and n = 1 for eta = 3 mode
    .In(out),//
    .ready(out_valid_cbd),//
    .Out(out_cbd),//
    .done(done_cbd),                  //signal for mux to send output to Write buffer
    .give_bits(gimme_cbd), //signal for PRG to give bit array
    .address(SRAM_address_cbd)
    );
    
     keccak KEKKAK (
        .clk(clk),
        .rst(rst),
        .in(in_keccak), // Represents the seed
        .mode(mode[1:0]),
        .is_last(is_last_keccak), // Indicated the last input seed
        .start_calc(start_calc), // signifies vaild instruction
        .gimme(gimme), // handshaking from parse and CBD
        .ack(ack),
        .in_valid(in_valid_keccak),//total goes to padding
        .out(out),
        .out_ready(out_ready_keccak),
        .out_buf_empty(out_buf_empty), // Output FIFO is empty
        .out_valid(out_valid)
    );
    reg i_reg;
    reg j_reg;
        
    reg [2:0] mode_reg;
    reg [63:0] rho_sigma[7:0];
    reg [1:0] rho_ptr, sigma_ptr;
    reg [2:0] load_ptr;
    reg [63:0] in_keccak;
    reg in_valid_keccak;
    reg is_last_keccak;
    reg out_ready;
    wire out_ready_keccak;
    always@(*) begin
       case(mode_reg[1:0])
            0: out_ready = 0;
            1: out_ready = 0;
            2: out_ready = out_ready_keccak;
            3: out_ready = out_ready_keccak;
        endcase
    end

    
    always @ (posedge clk, posedge rst) begin
        if (rst) mode_reg <= 0;
        else if (start_calc) mode_reg <= mode;
    end

    wire parse_cbd;
    assign parse_cbd = mode_reg[2];

    // Input MUX to select between FIFO and rho or sigma
    always @ (*) begin
        case(mode_reg[1:0])
        0: in_keccak = in;
        1: in_keccak = in;
        2: in_keccak = rho_sigma[rho_ptr+4]^{i_reg,j_reg};
        3: in_keccak = rho_sigma[sigma_ptr]^{i_reg};
        endcase
    end

    always @ (posedge clk, posedge rst) begin
        if(rst) begin
            rho_sigma[0] <= 0;
            rho_sigma[1] <= 0;
            rho_sigma[2] <= 0;
            rho_sigma[3] <= 0;
            rho_sigma[4] <= 0;
            rho_sigma[5] <= 0;
            rho_sigma[6] <= 0;
            rho_sigma[7] <= 0;
            load_ptr <= 0;
            rhosigready <= 0;
        end
        else if(mode_reg[1:0] == 1 & out_valid) begin
            rho_sigma[load_ptr] <= out;
            if(load_ptr == 7) rhosigready <= 1;
            load_ptr <= load_ptr + 1;
        end
    end



    always @ (posedge clk) begin
        if(rst|start_calc) begin
            rho_ptr <= 0;
            sigma_ptr <= 0;
        end
        else begin
                case(mode_reg[1:0])
                    2: begin
                        if(rho_ptr==3) rho_ptr<=rho_ptr;
                        else rho_ptr <= rho_ptr + 1;
                    end
                    3: begin
                        if(sigma_ptr==3) sigma_ptr<=sigma_ptr;
                        else sigma_ptr <= sigma_ptr + 1;
                    end
                endcase
            
        end
    end

    always @ (posedge clk, posedge rst) begin
        if(rst) begin
            i_reg <= 0;
            j_reg <= 0;
        end
        else if((mode[1:0] == 2 | mode[1:0]==3) & start_calc) begin
            i_reg <= i;
            j_reg <= j;
        end
    end

    always @ (*) begin
        case(mode_reg[1:0])
            0: begin
                is_last_keccak <= is_last;
                in_valid_keccak <= in_valid;
            end
            1: begin
                is_last_keccak <= is_last;
                in_valid_keccak <= in_valid;
            end
            2: begin
                is_last_keccak <= rho_ptr == 3;
                in_valid_keccak <= rho_ptr <= 3;
            end
            3: begin
                is_last_keccak <=sigma_ptr == 3 ;
                in_valid_keccak <= sigma_ptr<=3 ;
            end
        endcase
    end

      
    wire gimme_parse;
    wire gimme_cbd;
    reg gimme; 
    
    wire[47:0] out_cbd, out_parse;
    
    always @ (*) begin
        case(mode_reg[1:0])
            1: begin
                gimme = 1;
                out_sample = 0;
                out_sample_valid = 0;
               end
            2: begin 
                gimme = gimme_parse;
                out_sample = out_parse;
                out_sample_valid = done_parse;
               end
            3: begin
                gimme = gimme_cbd;
                out_sample = out_cbd;
                out_sample_valid = done_cbd;
               end
            default: begin
                        gimme = 0;
                        out_sample = 0;
                        out_sample_valid = 0;
                     end
        endcase
    end
    
    wire out_valid;
    reg out_valid_parse;
    reg out_valid_cbd;
    
    wire [5:0] SRAM_address_parse;
    wire [5:0] SRAM_address_cbd;
    
    always @ (*) begin
        case(mode_reg[1:0])
            2: begin
                out_valid_parse = out_valid;
                out_valid_cbd = 0;
                SRAM_address = SRAM_address_parse;
               end
            3: begin
                out_valid_cbd = out_valid;
                out_valid_parse = 0;
                SRAM_address = SRAM_address_cbd;
               end
            default: begin
                      out_valid_cbd = 0;
                      out_valid_parse = 0;
                      SRAM_address = 0;
                     end
        endcase
    end
    // always @ (*) begin
    //     case(mode_reg)
    //         2: out_sample_valid = done_parse;
    //         3: out_sample_valid = done_cbd;
    //         default: out_sample_valid = 0;
    //     endcase
    // end

    
    wire [63:0] out;
     
    wire out_buf_empty;
    
  

endmodule
