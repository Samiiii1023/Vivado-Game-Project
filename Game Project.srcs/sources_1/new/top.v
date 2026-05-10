`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2026 04:12:57 PM
// Design Name: 
// Module Name: top
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


module top(
    input CLK100MHZ,

    output VGA_HS,
    output VGA_VS,

    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B
);

wire clk25;
wire [9:0] x, y;
wire video_on;

wire [3:0] r, g, b;

// Clock divider
clk_div cd (
    .clk(CLK100MHZ),
    .clk25(clk25)
);

// VGA sync
vga_sync sync_unit (
    .clk(clk25),
    .hsync(VGA_HS),
    .vsync(VGA_VS),
    .x(x),
    .y(y),
    .video_on(video_on)
);

// Display
display disp_unit (
    .video_on(video_on),
    .x(x),
    .y(y),
    .r(r),
    .g(g),
    .b(b)
);

// Output to VGA
assign VGA_R = r;
assign VGA_G = g;
assign VGA_B = b;

endmodule
