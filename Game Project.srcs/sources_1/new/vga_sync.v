`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2026 04:11:40 PM
// Design Name: 
// Module Name: vga_sync
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


module vga_sync(
    input clk,
    output reg hsync,
    output reg vsync,
    output reg [9:0] x = 0,
    output reg [9:0] y = 0,
    output video_on
);

// 640x480 timing parameters
parameter H_VISIBLE = 640;
parameter H_FRONT   = 16;
parameter H_SYNC    = 96;
parameter H_BACK    = 48;
parameter H_TOTAL   = 800;

parameter V_VISIBLE = 480;
parameter V_FRONT   = 10;
parameter V_SYNC    = 2;
parameter V_BACK    = 33;
parameter V_TOTAL   = 525;

// ========================
// Pixel counter
// ========================
always @(posedge clk) begin
    if (x == H_TOTAL - 1) begin
        x <= 0;
        if (y == V_TOTAL - 1)
            y <= 0;
        else
            y <= y + 1;
    end else begin
        x <= x + 1;
    end
end

// ========================
// Sync signals
// ========================
always @(*) begin
    hsync = ~(x >= (H_VISIBLE + H_FRONT) &&
              x <  (H_VISIBLE + H_FRONT + H_SYNC));
end

always @(*) begin
    vsync = ~(y >= (V_VISIBLE + V_FRONT) &&
              y <  (V_VISIBLE + V_FRONT + V_SYNC));
end

// ========================
// Visible area
// ========================
assign video_on = (x < H_VISIBLE) && (y < V_VISIBLE);

endmodule
