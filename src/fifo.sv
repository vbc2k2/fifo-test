// Parameterized Synchronous FIFO
// Demonstrates advanced RTL patterns for SiliconCI testing

module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    input  logic                   clk,
    input  logic                   rst_n,
    
    // Write interface
    input  logic                   wr_en,
    input  logic [DATA_WIDTH-1:0]  wr_data,
    output logic                   full,
    
    // Read interface
    input  logic                   rd_en,
    output logic [DATA_WIDTH-1:0]  rd_data,
    output logic                   empty,
    
    // Status
    output logic [ADDR_WIDTH:0]    count
);

    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    
    // Pointers
    logic [ADDR_WIDTH-1:0] wr_ptr;
    logic [ADDR_WIDTH-1:0] rd_ptr;
    logic [ADDR_WIDTH:0]   fifo_count;
    
    // Status flags
    assign full  = (fifo_count == DEPTH);
    assign empty = (fifo_count == 0);
    assign count = fifo_count;
    
    // Write logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= wr_data;
            wr_ptr <= wr_ptr + 1'b1;
        end
    end
    
    // Read logic  
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= '0;
            rd_data <= '0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1'b1;
        end
    end
    
    // Count logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_count <= '0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10:   fifo_count <= fifo_count + 1'b1;
                2'b01:   fifo_count <= fifo_count - 1'b1;
                default: fifo_count <= fifo_count;
            endcase
        end
    end
    
    // Generate block for optional debug
    generate
        if (DEPTH > 8) begin : gen_large_fifo
            // Additional monitoring for larger FIFOs
            logic almost_full;
            logic almost_empty;
            
            assign almost_full  = (fifo_count >= DEPTH - 2);
            assign almost_empty = (fifo_count <= 2);
        end
    endgenerate

endmodule
