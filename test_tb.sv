module test_tb;
parameter DW = 32+3;
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
//drv input
always_ff@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for(int i = 0; i < N; i++) begin
            i_valid[i] <= 1'b0;
            i_data[i]  <= DW'(0);
        end
    end
    else if(start == 1'b1) begin
        i_valid[5] <= 1'b1;
        i_data[5]  <= {3'd6, 32'h1234};              //5--->6
    end
    else if(i_valid[5] && i_ready[5]) begin
        i_valid[5] <= 1'b0;
        i_data[5]  <= DW'(0);
    end
end
//start
initial begin
    start = 1'b0;
    #400
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
    #1000
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
