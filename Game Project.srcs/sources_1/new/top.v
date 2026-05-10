`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2026
// Design Name: 
// Module Name: top
// Description:
// VGA + Keyboard Controlled Square
//
// Dependencies:
// clk_div.v
// vga_sync.v
// display.v
// PS2Receiver.v
//
//////////////////////////////////////////////////////////////////////////////////

module top(

    input CLK100MHZ,

    // USB HID Host -> PS/2 signals
    input PS2_CLK,
    input PS2_DATA,

    // LEDs
    output [15:0] LED,

    // VGA
    output VGA_HS,
    output VGA_VS,

    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B

);

// ======================================================
// Internal Signals
// ======================================================

wire clk25;

wire [9:0] x;
wire [9:0] y;

wire video_on;

wire [3:0] r;
wire [3:0] g;
wire [3:0] b;

// ======================================================
// Keyboard
// ======================================================

wire [31:0] keycode;

// ======================================================
// Player Position
// ======================================================

reg [9:0] player_x = 300;
reg [9:0] player_y = 220;

// ======================================================
// Slow Counter
// ======================================================

reg [20:0] slow_counter = 0;

// ======================================================
// Clock Divider
// 100MHz -> 25MHz
// ======================================================

clk_div cd (

    .clk(CLK100MHZ),
    .clk25(clk25)

);

// ======================================================
// VGA Timing Generator
// ======================================================

vga_sync sync_unit (

    .clk(clk25),
    .hsync(VGA_HS),
    .vsync(VGA_VS),
    .x(x),
    .y(y),
    .video_on(video_on)

);

// ======================================================
// PS/2 Keyboard Receiver
// ======================================================

PS2Receiver keyboard (

    .clk(clk25),
    .kclk(PS2_CLK),
    .kdata(PS2_DATA),
    .keycodeout(keycode)

);

// ======================================================
// Player Movement
// ======================================================

always @(posedge CLK100MHZ) begin

    slow_counter <= slow_counter + 1;

    // Slow movement speed
    if (slow_counter == 0) begin

        // ==========================================
        // A key -> Move Left
        // Scan code = 1C
        // ==========================================

        if (keycode[7:0] == 8'h1C && player_x > 0)
            player_x <= player_x - 5;

        // ==========================================
        // D key -> Move Right
        // Scan code = 23
        // ==========================================

        if (keycode[7:0] == 8'h23 && player_x < 600)
            player_x <= player_x + 5;

    end
end

// ======================================================
// Display Renderer
// ======================================================

display disp_unit (

    .video_on(video_on),
    .x(x),
    .y(y),

    .player_x(player_x),
    .player_y(player_y),

    .r(r),
    .g(g),
    .b(b)

);

// ======================================================
// VGA Outputs
// ======================================================

assign VGA_R = r;
assign VGA_G = g;
assign VGA_B = b;

// ======================================================
// Debug LEDs
// ======================================================

// LED0 lights when A key received
assign LED[0] = (keycode[7:0] == 8'h1C);

// LED1 lights when D key received
assign LED[1] = (keycode[7:0] == 8'h23);

endmodule