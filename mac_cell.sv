// Project: await synapse hybrid-7
// File: mac_cell.sv (Universal Signed Arithmetic Core)

module mac_cell (
    input  logic        clk,        // Hardware clock pulse
    input  logic        rst_n,      // Active-low clear/reset signal
    input  logic signed [7:0]  in_a, // 8-bit signed input (Activation)
    input  logic signed [7:0]  in_b, // 8-bit signed input (Weight)
    input  logic        start,      // Computation trigger from instruction stream
    output logic signed [15:0] out_accum // 16-bit running vector sum
);

    logic signed [15:0] accum_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accum_reg <= 16'sb0; // Clear memory to zero on reset
        end else if (start) begin
            // Math: Multiply signed A and B, then add to the running total
            accum_reg <= accum_reg + (in_a * in_b);
        end
    end

    assign out_accum = accum_reg;

endmodule
