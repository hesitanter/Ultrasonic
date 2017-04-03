`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2016 10:27:24 PM
// Design Name: 
// Module Name: Motor
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


module Motor(
    input logic clk, reset,
    input logic [1:0] speed,
    output logic A, B, Ab, Bb
    ); 
    
    typedef enum logic [1:0] {S0, S1, S2, S3} statetype;
    statetype [1:0] s, nextS;
    
    // clock divider
    logic clk_en;
    logic [20:0] divider;
    logic [20:0] count = 21'd0;
    always@(posedge clk) begin
            case(speed)
                2'b00: divider = 21'd800000;
                2'b01: divider = 21'd600000;
                2'b10: divider = 21'd400000;
                2'b11: divider = 21'd200000;
            endcase
            count <= count + 1;
            if (count == divider) begin
                count <= 21'd0;
                clk_en <= 1'b1;
            end
            else
                clk_en <= 1'b0;
    end    
    
    // state register
    always_ff@(posedge clk_en)
        if(~reset) begin
            s <= S0;
            divider <= 3'b000;
        end
        else
            s <= nextS;
            
    // next state logic
    always_comb
       case(s)
           S0: nextS = S1;
           S1: nextS = S2;
           S2: nextS = S3;
           S3: nextS = S0;
       endcase
        
    // output logic
    always_comb
        case(s)
            S0: begin A = 1'b1; B = 1'b1; Ab = ~A; Bb = ~B; end
            S1: begin A = 1'b0; B = 1'b1; Ab = ~A; Bb = ~B; end
            S2: begin A = 1'b0; B = 1'b0; Ab = ~A; Bb = ~B; end
            S3: begin A = 1'b1; B = 1'b0; Ab = ~A; Bb = ~B; end
        endcase
endmodule
