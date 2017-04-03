`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2016 08:22:59 PM
// Design Name: 
// Module Name: UltrasonicDriver
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


module UltrasonicDriver(
    input logic clk, reset,
    inout logic sig,
    output logic [15:0] distance    // distance in centimeters
    );
    
    // elapsed time
    logic [19:0] elapsedTime;
    
    logic sig_in;
    logic en;
    logic [15:0] loop;

    // distance // centimeters
    // logic [15:0] distance;

    // clock divider // clk = 100MHz // clk_en = 200 kHz
    logic [8:0] count = 9'd0;
    logic clk_en = 1'b0;
    always_ff@(posedge clk) begin
        count <= count + 1;

        if(count == 9'd499)
            count <=9'd0;
            
        if(count <= 9'd249)
            clk_en <= 1'b1;
        else
            clk_en <= 1'b0;
    end

    logic [3:0] state, nextState;
    
    // state register
    always_ff@(posedge clk_en)
        if(~reset)
            state <= 8;
        else
            state <= nextState;
            
    // next state and output logic
    always_ff@(negedge clk_en)
        case(state)
            8: begin
                en <= 1;
                nextState <= 0;
                loop <= 0;
            end
            0: begin
                sig_in <= 1'b0;
                nextState <= 1;
                elapsedTime <= 0;
                distance <= 0;
            end
            1: begin
                sig_in <= 1;
                nextState <= 2;
            end
            2: begin
                sig_in <= 0;
                nextState <= 9;
            end
            9: begin
                en <= 0;
                nextState <= 3;
            end
            3: begin
                if(sig == 1'b1)
                    nextState <= 4;
            end
            4: begin
                if(sig == 1'b1)
                    elapsedTime <= elapsedTime + 1;
                else
                    nextState <= 5;
            end
            5: begin
                elapsedTime <= elapsedTime * 5 / 2;
                nextState <= 6;
            end
            6: begin
                distance <= elapsedTime * 34 / 1000;
                nextState <= 7;
            end
            7: begin
                loop <= loop + 1;
                
                if(loop == 16'd50000)
                    nextState <= 8;
            end
        endcase
            
        assign sig = en ? sig_in : 1'bz;
endmodule
