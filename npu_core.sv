// Project: await synapse hybrid-7
// File: npu_core.sv (Universal 2x2 Parallel Matrix NPU Core)

module npu_core (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] bus_address,       // Mapped register target from host CPU
    input  logic [7:0]  bus_write_data,    // Incoming matrix operand payload data
    input  logic        bus_write_enable,  // Validation flag for memory write operations
    output logic signed [15:0] bus_read_data // Outgoing calculation data sent back to CPU
);

    // Operational storage registers to hold input matrices for the grid
    logic signed [7:0] act_0, act_1;
    logic signed [7:0] wgt_0, wgt_1;
    logic              reg_start;

    // Output wires carrying results from individual MAC cells
    logic signed [15:0] out_m00, out_m01, out_m10, out_m11;

    // --- INSTANTIATE THE 2x2 SYSTOLIC MAC GRID ---
    mac_cell cell_00 (.clk(clk), .rst_n(rst_n), .in_a(act_0), .in_b(wgt_0), .start(reg_start), .out_accum(out_m00));
    mac_cell cell_01 (.clk(clk), .rst_n(rst_n), .in_a(act_0), .in_b(wgt_1), .start(reg_start), .out_accum(out_m01));
    mac_cell cell_10 (.clk(clk), .rst_n(rst_n), .in_a(act_1), .in_b(wgt_0), .start(reg_start), .out_accum(out_m10));
    mac_cell cell_11 (.clk(clk), .rst_n(rst_n), .in_a(act_1), .in_b(wgt_1), .start(reg_start), .out_accum(out_m11));

    // Address Decoder: Routes CPU data inputs to the correct storage registers
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            act_0 <= 8'sb0; act_1 <= 8'sb0;
            wgt_0 <= 8'sb0; wgt_1 <= 8'sb0;
            reg_start <= 1'b0;
        end else if (bus_write_enable) begin
            case (bus_address)
                32'h40000000: act_0     <= bus_write_data; // Target: Activation 0
                32'h40000004: act_1     <= bus_write_data; // Target: Activation 1
                32'h40000008: wgt_0     <= bus_write_data; // Target: Weight 0
                32'h4000000C: wgt_1     <= bus_write_data; // Target: Weight 1
                32'h40000010: reg_start <= bus_write_data[0]; // Target: Pull the START lever
                default: ;
            endcase
        end
    end

    // Output Multiplexer: Sends the requested matrix cell's sum back onto the CPU read bus
    always_comb begin
        case (bus_address)
            32'h40000014: bus_read_data = out_m00;
            32'h40000018: bus_read_data = out_m01;
            32'h4000001C: bus_read_data = out_m10;
            32'h40000020: bus_read_data = out_m11;
            default:      bus_read_data = 16'sb0;
        endcase
    end

endmodule
