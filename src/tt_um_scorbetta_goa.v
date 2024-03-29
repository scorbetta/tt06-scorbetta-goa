`default_nettype none
`define default_netname none

// User IN
`define UI_IN_CLOCK     0
`define UI_IN_SCI_CSN   1
`define UI_IN_SCI_REQ   2

// User OUT
`define UO_OUT_SCI_RESP 0
`define UO_OUT_SCI_ACK  1

module tt_um_scorbetta_goa
(
    input wire [7:0]    ui_in, // Dedicated inputs
    output wire [7:0]   uo_out, // Dedicated outputs
    input wire [7:0]    uio_in, // IOs: Input path
    output wire [7:0]   uio_out, // IOs: Output path
    output wire [7:0]   uio_oe, // IOs: Enable path (active high: 0=input, 1=output)
    input wire          ena, // will go high when the design is enabled
    input wire          clk, // clock
    input wire          rst_n // reset_n - low to reset
);

    wire [9:0] counter;

    // Use main clock to check power
    COUNTER #(
        .WIDTH  (10)
    )
    COUNTER (
        .CLK        (clk),
        .RSTN       (rst_n),
        .EN         (ena),
        .VALUE      (counter),
        .OVERFLOW   () // Unused
    );

    // Check 6 MSBs
    assign uo_out[7:2] = counter[9:4];

    // User design uses a custom clock, generated by remote FPGA
    NEURON_WRAPPER NEURON_WRAPPER (
        .CLK        (ui_in[`UI_IN_CLOCK]),
        .RSTN       (rst_n),
        .SCI_CSN    (ui_in[`UI_IN_SCI_CSN]),
        .SCI_REQ    (ui_in[`UI_IN_SCI_REQ]),
        .SCI_RESP   (uo_out[`UO_OUT_SCI_RESP]),
        .SCI_ACK    (uo_out[`UO_OUT_SCI_ACK])
    );

    // Bidirectional pins are not used
    assign uio_out  = 0;
    assign uio_oe   = 0;
endmodule

`default_nettype wire
