`timescale 1ns / 1ps

module top_VGA_OV7670 (
    input  logic       clk,
    input  logic       reset,
    // ov7670 side
    output logic       xclk,
    input  logic       pclk,
    input  logic       href,
    input  logic       vsync,
    input  logic [7:0] data,
    // vga port side
    output logic       h_sync,
    output logic       v_sync,
    output logic [3:0] port_red,
    output logic [3:0] port_green,
    output logic [3:0] port_blue,

    // board -> borad Tx
    output logic bd_tx
);
    logic                       clk_100m;
    logic [                9:0] x_pixel;
    logic [                9:0] y_pixel;
    logic                       DE;
    logic [$clog2(320*240)-1:0] rAddr;
    logic [               16:0] imgData;
    logic                       we;
    logic [$clog2(320*240)-1:0] wAddr;
    logic [               15:0] wData;
    logic [               15:0] rData;
    logic w_tx_empty, w_tx_rdata;
    logic [7:0] tx_fifo_mux_out;

    clk_wiz_0 instance_name (
        // Clock out ports
        .clk_out1(clk_100m),  // output clk_out1 100MHz
        .clk_out2(xclk),  // output clk_out2 25MHZ
        // Status and control signals
        .reset   (reset),     // input reset
        .locked  (locked),    // output locked
        // Clock in ports
        .clk_in1 (clk)    // input clk_in1
    );

    VGA_Decoder u_VGA_Decoder (
        .clk    (clk_100m),
        .reset  (reset),
        .pclk   (rclk),
        .h_sync (h_sync),
        .v_sync (v_sync),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .DE     (DE)
    );

    imgMemReader u_imgMemReader (
        .DE        (DE),
        .x_pixel   (x_pixel),
        .y_pixel   (y_pixel),
        .addr      (rAddr),
        .imgData   (rData),
        .port_red  (port_red),
        .port_green(port_green),
        .port_blue (port_blue)
    );



    frameBuffer u_frameBuffer (
        .wclk (pclk),
        .we   (we),
        .wAddr(wAddr),
        .wData(wData),
        .rclk (rclk),
        .rAddr(rAddr),
        .rData(rData)
    );

    OV7670_MemController u_OV7670_MemController (
        .pclk (pclk),
        .reset(reset),
        .href (href),
        .vsync(vsync),
        .data (data),
        .we   (we),
        .wAddr(wAddr),
        .wData(wData)
    );

    // asdasda

    // ----------------------------------------------------
    // ----------Board -> Board 출력 tx 부분----------------
    // ----------------------------------------------------
    mux_nx1 #(
        .NUM  (2),
        .WIDTH(8)
    ) tx_fifo_src_mux (
        .sel(),
        .x  (),
        .y  (tx_fifo_mux_out)
    );

    FIFO u_tx_fifo (
        .clk  (clk),
        .reset(reset),
        .wr   (),
        .rd   (~w_tx_busy),
        .wdata(tx_fifo_mux_out),
        .rdata(w_tx_rdata),
        .full (),
        .empty(w_tx_empty)
    );

    uart_tx #(
        .BPS(9600)
    ) u_uart_tx (
        .clk     (clk),
        .reset   (reset),
        .tx_data (w_tx_rdata),
        .tx_start(~w_tx_empty),
        .tx      (bd_tx),
        .tx_busy (w_tx_busy)
    );

    // ----------------------------------------------------
    // ----------Board -> PC 출력 tx 부분-------------------
    // ----------------------------------------------------
endmodule
