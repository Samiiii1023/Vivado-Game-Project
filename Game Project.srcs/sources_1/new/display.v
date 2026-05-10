`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2026 04:12:17 PM
// Design Name: 
// Module Name: display
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


module display(
    input video_on,
    input [9:0] x,
    input [9:0] y,

    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b
);

// ======================================
// Player square position
// ======================================
parameter PLAYER_X = 300;
parameter PLAYER_Y = 220;
parameter PLAYER_SIZE = 40;

always @(*) begin

    // Outside visible screen
    if (!video_on) begin
        r = 0;
        g = 0;
        b = 0;
    end

    // Draw player square
    else if (
        x >= PLAYER_X &&
        x < PLAYER_X + PLAYER_SIZE &&
        y >= PLAYER_Y &&
        y < PLAYER_Y + PLAYER_SIZE
    ) begin
        r = 4'b1111;
        g = 4'b1111;
        b = 4'b1111;
    end

    // Background
    else begin
        r = 0;
        g = 0;
        b = 0;
    end
end

endmodule
