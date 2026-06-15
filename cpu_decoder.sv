// Project: await synapse hybrid-7
// File: cpu_decoder.sv (Universal RISC-V Custom-0 ISA Decoder)

module cpu_decoder (
    input  logic [31:0] raw_instruction,  // 32-bit machine code instruction stream
    output logic        enable_alu,       // High when running standard base math
    output logic        enable_npu,       // High when running custom AI instructions
    output logic [4:0]  rs1,              // First source register index
    output logic [4:0]  rs2,              // Second source register index
    output logic [4:0]  rd                // Target destination register index
);

    logic [6:0] opcode;
    assign opcode = raw_instruction[6:0]; // The lowest 7 bits identify the instruction type

    always_comb begin
        // Slice the raw instruction into standard RISC-V register fields
        rd  = raw_instruction[11:7];
        rs1 = raw_instruction[19:15];
        rs2 = raw_instruction[24:20];

        // Reset control signals to default low states to prevent circuit latching
        enable_alu = 1'b0;
        enable_npu = 1'b0;

        case (opcode)
            7'b0110011: begin 
                enable_alu = 1'b1; // Matches standard Base RISC-V R-Type (ADD, SUB, etc.)
            end
            
            7'b0001011: begin 
                enable_npu = 1'b1; // Matches the reserved RISC-V Custom-0 space for your NPU
            end
            
            default: ;
        endcase
    end
endmodule
