// SystemVerilog Testbench for Parameterized FIFO
// Demonstrates coverage-driven testing

`timescale 1ns/1ps

module tb_fifo;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam DEPTH = 16;
    localparam ADDR_WIDTH = $clog2(DEPTH);
    
    // Signals
    logic                   clk;
    logic                   rst_n;
    logic                   wr_en;
    logic [DATA_WIDTH-1:0]  wr_data;
    logic                   full;
    logic                   rd_en;
    logic [DATA_WIDTH-1:0]  rd_data;
    logic                   empty;
    logic [ADDR_WIDTH:0]    count;
    
    // Reference queue for checking
    logic [DATA_WIDTH-1:0] ref_queue [$];
    
    // Test counters
    int tests_passed = 0;
    int tests_failed = 0;
    
    // DUT instantiation
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty),
        .count(count)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Waveform dump
    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, tb_fifo);
    end
    
    // Task: Reset DUT
    task automatic reset_dut();
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        ref_queue.delete();
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(2) @(posedge clk);
    endtask
    
    // Task: Write to FIFO
    task automatic write_fifo(input logic [DATA_WIDTH-1:0] data);
        wr_en = 1;
        wr_data = data;
        @(posedge clk);
        if (!full) begin
            ref_queue.push_back(data);
        end
        wr_en = 0;
        @(posedge clk);
    endtask
    
    // Task: Read from FIFO
    task automatic read_fifo(output logic [DATA_WIDTH-1:0] data);
        rd_en = 1;
        @(posedge clk);
        rd_en = 0;
        @(posedge clk);
        data = rd_data;
        if (ref_queue.size() > 0) begin
            void'(ref_queue.pop_front());
        end
    endtask
    
    // Task: Check test result
    task automatic check_result(input string test_name, input bit condition);
        if (condition) begin
            $display("[PASS] %s", test_name);
            tests_passed++;
        end else begin
            $display("[FAIL] %s", test_name);
            tests_failed++;
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("============================================");
        $display("  FIFO Testbench - Parameterized Module");
        $display("  DATA_WIDTH=%0d, DEPTH=%0d", DATA_WIDTH, DEPTH);
        $display("============================================");
        
        // Test 1: Reset behavior
        $display("\n--- Test 1: Reset Behavior ---");
        reset_dut();
        check_result("Empty after reset", empty == 1);
        check_result("Not full after reset", full == 0);
        check_result("Count is 0", count == 0);
        
        // Test 2: Single write/read
        $display("\n--- Test 2: Single Write/Read ---");
        write_fifo(8'hAB);
        check_result("Not empty after write", empty == 0);
        check_result("Count is 1", count == 1);
        
        logic [DATA_WIDTH-1:0] read_val;
        read_fifo(read_val);
        check_result("Read correct value", read_val == 8'hAB);
        check_result("Empty after read", empty == 1);
        
        // Test 3: Fill FIFO completely
        $display("\n--- Test 3: Fill FIFO ---");
        reset_dut();
        for (int i = 0; i < DEPTH; i++) begin
            write_fifo(i[DATA_WIDTH-1:0]);
        end
        check_result("Full when filled", full == 1);
        check_result("Count equals DEPTH", count == DEPTH);
        
        // Test 4: Drain FIFO completely
        $display("\n--- Test 4: Drain FIFO ---");
        for (int i = 0; i < DEPTH; i++) begin
            read_fifo(read_val);
            check_result($sformatf("Read value %0d correct", i), read_val == i[DATA_WIDTH-1:0]);
        end
        check_result("Empty after drain", empty == 1);
        
        // Test 5: Simultaneous read/write
        $display("\n--- Test 5: Simultaneous R/W ---");
        reset_dut();
        write_fifo(8'h11);
        write_fifo(8'h22);
        
        // Simultaneous operation
        wr_en = 1;
        rd_en = 1;
        wr_data = 8'h33;
        @(posedge clk);
        wr_en = 0;
        rd_en = 0;
        @(posedge clk);
        check_result("Count unchanged during simul R/W", count == 2);
        
        // Final report
        $display("\n============================================");
        $display("  Test Summary: %0d passed, %0d failed", tests_passed, tests_failed);
        $display("============================================");
        
        if (tests_failed == 0) begin
            $display("All tests PASSED");
        end else begin
            $display("Some tests FAILED");
        end
        
        $finish;
    end
    
    // Timeout
    initial begin
        #50000;
        $display("ERROR: Simulation timeout");
        $finish;
    end

endmodule
