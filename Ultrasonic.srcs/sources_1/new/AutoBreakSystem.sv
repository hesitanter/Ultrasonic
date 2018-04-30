`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2016 10:38:25 PM
// Design Name: 
// Module Name: AutoBreakSystem
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


module AutoBreakSystem(
    input logic clk, reset,
    inout logic sig,
    output logic A, B, Ab, Bb,
    output logic a, b, c, d, e, f, g, DP,
    output [3:0] an
    );

    // clock divider
    logic [25:0] count = 26'd0;
    logic clk_en = 1'b0;
    always_ff@(posedge clk) begin
        count <= count + 1;

        if(count == 26'd49_999_999)
            count <=26'd0;
            
        if(count <= 26'd24_999_999)
            clk_en <= 1'b1;
        else
            clk_en <= 1'b0;
    end

    logic [15:0] distance;
    UltrasonicDriver usd(clk, reset, sig, distance);

    logic [1:0] speed;
    Motor mt(clk, reset, speed, A, B, Ab, Bb);
    
    logic [3:0] in0, in1, in2, in3;
    SevSeg_4digit svg(clk, in0, in1, in2, in3, a, b, c, d, e, f, g, DP, an);

    logic [2:0] state, nextState;

    // state register
    always_ff@(posedge clk_en)
        if(~reset)
            state <= 0;
        else
            state <= nextState;
    
    // output and next state logic
    always_ff@(negedge clk_en)
        case(state)
            0: begin
                speed <= 3;
                nextState <= 1;
            end
            1: begin
                if(distance < 4)
                    nextState <= 2;
                else if (distance < 8)
                    nextState <= 3;
                else if(distance < 16)
                    nextState <= 4;
                else if(distance > 16)
                    nextState <= 5;
            end
            2: begin
                speed <= 0;
                nextState <= 1;
            end
            3: begin
                speed <= 1;
                nextState <= 1;
            end
            4: begin
                speed <= 2;
                nextState <= 1;
            end
            5: begin
                speed <= 3;
                nextState <= 1;
            end
    endcase
    
    assign {in3, in2, in1, in0} = speed;
endmodule
