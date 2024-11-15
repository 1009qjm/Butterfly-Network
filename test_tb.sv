module test_tb;
parameter DW = 32 + 3;
parameter N  = 8;
//
logic          clk;
logic          rst_n;
logic [DW-1:0] i_data  [N-1:0];
logic [DW-1:0] o_data  [N-1:0];
logic          i_valid [N-1:0];
logic          i_ready [N-1:0];
logic          o_valid [N-1:0];
logic          o_ready [N-1:0];
logic          start;
logic          nxt_start;
logic [$clog2(N)-1:0] src_idx;
logic [$clog2(N)-1:0] dst_idx;
//clk rst
initial begin
    clk = 1'b0;
    forever begin
        #5 clk = ~clk;
    end
end
//rst_n
initial begin
    rst_n = 1'b0;
    #100
    rst_n = 1'b1;
end
//sanity test
generate 
    for(genvar i = 0; i < N; i++) begin:gen_o_ready
        assign o_ready[i] = 1'b1;
    end
endgenerate
//src_idx
always_ff@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        src_idx <= '0;
    end
    else if(i_valid[src_idx] && i_ready[src_idx] && dst_idx == N - 1) begin
        src_idx <= src_idx + 1'b1;
    end
end
//dst_idx
always_ff@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        dst_idx <= '0;
    end
    else if(i_valid[src_idx] && i_ready[src_idx]) begin
        dst_idx <= dst_idx + 1'b1;
    end
end
//nxt_start
always_ff@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        nxt_start <= 1'b0;
    end
    else if(i_valid[src_idx] && i_ready[src_idx]) begin
        if(src_idx == N - 1 && dst_idx == N - 1) begin
            nxt_start <= 1'b0;
        end
        else begin
            nxt_start <= 1'b1;
        end
    end
    else begin
        nxt_start <= 1'b0;
    end
end
//drv input
always_ff@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for(int i = 0; i < N; i++) begin
            i_valid[i] <= 1'b0;
            i_data[i]  <= DW'(0);
        end
    end
    else if(start == 1'b1 || nxt_start == 1'b1) begin
        i_valid[src_idx] <= 1'b1;
        i_data[src_idx]  <= {dst_idx, 32'(src_idx)};              //5--->6
        $display("src node %d send data %h to dst node %d",src_idx, 32'(src_idx), dst_idx);
    end
    else if(i_valid[src_idx] && i_ready[src_idx]) begin
        i_valid[src_idx] <= 1'b0;
        i_data[src_idx]  <= DW'(0);
    end
end
//receive data and check
always_ff@(posedge clk) begin
    for(int i = 0; i < N; i++) begin
        if(o_valid[i] && o_ready[i]) begin
            $display("dst node %d receive data %h", i[$clog2(N)-1:0], o_data[i][31:0]);
            if(o_data[i][32 +: $clog2(N)] != i[$clog2(N)-1:0]) begin
                $display("test failed");
                $finish;
            end
        end
    end
end
//start
initial begin
    start = 1'b0;
    #200
    start = 1'b1;
    #10
    start = 1'b0;
end

initial begin
    $fsdbDumpfile("butterfly.fsdb");
    $fsdbDumpvars(0);
    $fsdbDumpMDA();
end

initial begin
    #10000
    $display("test pass");
    $finish;
end
//inst
butterfly #
(.DW(DW),
 .N (N )
) butterfly_inst
(
.clk     (clk     ),
.rst_n   (rst_n   ),
.i_valid (i_valid ),
.i_ready (i_ready ),
.i_data  (i_data  ),
.o_data  (o_data  ),
.o_valid (o_valid ),
.o_ready (o_ready )
);

endmodule
