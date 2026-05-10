`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA Platformer Engine
// Nexys A7-100T
// VGA + USB Keyboard (J5 HID)
//
// Features:
// - VGA 640x480
// - Smooth A/D movement
// - W jump
// - Gravity
// - Floor collision
// - Proper key state handling
//////////////////////////////////////////////////////////////////////////////////

module top(

    input CLK100MHZ,

    // Keyboard
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

// =====================================================
// VGA Signals
// =====================================================

wire clk25;

wire [9:0] x;
wire [9:0] y;

wire video_on;

wire [3:0] r;
wire [3:0] g;
wire [3:0] b;

// =====================================================
// Keyboard
// =====================================================

wire [31:0] keycode;

// =====================================================
// Constants
// =====================================================

parameter SCREEN_WIDTH  = 640;
parameter SCREEN_HEIGHT = 480;

parameter PLAYER_SIZE   = 40;

parameter FLOOR_Y       = 440;

parameter MOVE_SPEED    = 4;

parameter JUMP_FORCE    = -14;

parameter GRAVITY       = 1;

// =====================================================
// Player
// =====================================================

reg signed [15:0] player_x = 300;
reg signed [15:0] player_y = FLOOR_Y;

reg signed [15:0] velocity_y = 0;

// =====================================================
// Key States
// =====================================================

reg key_a = 0;
reg key_d = 0;
reg key_w = 0;

// =====================================================
// Physics
// =====================================================

reg on_ground = 1;

// =====================================================
// Game Tick Generator
// =====================================================

reg [18:0] tick_counter = 0;

wire game_tick;

assign game_tick = (tick_counter == 0);

// =====================================================
// Clock Divider
// 100MHz -> 25MHz
// =====================================================

clk_div clk_div_inst (

    .clk(CLK100MHZ),
    .clk25(clk25)

);

// =====================================================
// VGA Sync Generator
// =====================================================

vga_sync vga_sync_inst (

    .clk(clk25),

    .hsync(VGA_HS),
    .vsync(VGA_VS),

    .x(x),
    .y(y),

    .video_on(video_on)

);

// =====================================================
// Keyboard Receiver
// =====================================================

PS2Receiver keyboard_inst (

    .clk(clk25),

    .kclk(PS2_CLK),
    .kdata(PS2_DATA),

    .keycodeout(keycode)

);

// =====================================================
// Keyboard State Logic
// =====================================================

always @(posedge CLK100MHZ) begin

    // ==============================================
    // KEY RELEASE
    // ==============================================

    if (keycode[15:8] == 8'hF0) begin

        case (keycode[7:0])

            8'h1C: key_a <= 0; // A
            8'h23: key_d <= 0; // D
            8'h1D: key_w <= 0; // W

        endcase

    end

    // ==============================================
    // KEY PRESS
    // ==============================================

    else begin

        case (keycode[7:0])

            8'h1C: key_a <= 1; // A
            8'h23: key_d <= 1; // D
            8'h1D: key_w <= 1; // W

        endcase

    end

end

// =====================================================
// Tick Counter
// =====================================================

always @(posedge CLK100MHZ) begin

    tick_counter <= tick_counter + 1;

end

// =====================================================
// Game Logic
// =====================================================

always @(posedge CLK100MHZ) begin

    if (game_tick) begin

        // ==========================================
        // Horizontal Movement
        // ==========================================

        if (key_a && player_x > 0)
            player_x <= player_x - MOVE_SPEED;

        if (key_d && player_x < (SCREEN_WIDTH - PLAYER_SIZE))
            player_x <= player_x + MOVE_SPEED;

        // ==========================================
        // Jump
        // ==========================================

        if (key_w && on_ground) begin

            velocity_y <= JUMP_FORCE;

            on_ground <= 0;

        end

        // ==========================================
        // Gravity
        // ==========================================

        velocity_y <= velocity_y + GRAVITY;

        // ==========================================
        // Apply Vertical Velocity
        // ==========================================

        player_y <= player_y + velocity_y;

        // ==========================================
        // Ceiling Collision
        // ==========================================

        if (player_y < 0) begin

            player_y <= 0;

            velocity_y <= 0;

        end

        // ==========================================
        // Floor Collision
        // ==========================================

        if (player_y >= FLOOR_Y) begin

            player_y <= FLOOR_Y;

            velocity_y <= 0;

            on_ground <= 1;

        end

        else begin

            on_ground <= 0;

        end

    end

end

// =====================================================
// Display Renderer
// =====================================================

display display_inst (

    .video_on(video_on),

    .x(x),
    .y(y),

    .player_x(player_x[9:0]),
    .player_y(player_y[9:0]),

    .r(r),
    .g(g),
    .b(b)

);

// =====================================================
// VGA Outputs
// =====================================================

assign VGA_R = r;
assign VGA_G = g;
assign VGA_B = b;

// =====================================================
// Debug LEDs
// =====================================================

assign LED[0] = key_a;
assign LED[1] = key_d;
assign LED[2] = key_w;

assign LED[15:3] = 13'b0;

endmodule