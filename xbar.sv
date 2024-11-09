module xbar 
#(
    parameter DW = 32+3
)
(
input logic           clk,
input logic           rst_n,
//input
input logic           i_valid0,
output logic          i_ready0,
input logic [DW-1:0]  i_data0,
input logic           i_valid1,
output logic          i_ready1,
input logic [DW-1:0]  i_data1,
input logic           dir0,              //direction, to port 0 or port1
input logic           dir1,
//output
output logic [DW-1:0] o_data0,
output logic          o_valid0,
input logic           o_ready0,
output logic          o_valid1,
input logic           o_ready1,
output logic [DW-1:0] o_data1
);

//i_ready0, priority 0 > 1
always_comb begin
    case({dir1, dir0})
        2'b00:i_ready0 = o_ready0;
        2'b01:i_ready0 = o_ready1;
        2'b10:i_ready0 = o_ready0;
        2'b11:i_ready0 = o_ready1;
    endcase
end
//i_ready1
always_comb begin
    case({dir1, dir0})
        2'b00:i_ready1 = (i_valid0 == 1'b1) ? 1'b0 : o_ready0;
        2'b01:i_ready1 = o_ready0;
        2'b10:i_ready1 = o_ready1;
        2'b11:i_ready1 = (i_valid0 == 1'b1) ? 1'b0 : o_ready1;
    endcase
end
//o_valid0
always_comb begin
    case({dir1, dir0})
        2'b00:begin 
                  o_valid0 = i_valid0 | i_valid1; 
                  o_data0 = (i_valid0 == 1'b1) ? i_data0 : i_data1;
              end
        2'b01:begin 
                  o_valid0 = i_valid1;            
                  o_data0 = i_data1;
              end
        2'b10:begin 
                  o_valid0 = i_valid0;            
                  o_data0 = i_data0;
              end
        2'b11:begin 
                  o_valid0 = 1'b0;                
                  o_data0 = DW'(0);
              end
    endcase
end
//o_valid1
always_comb begin
    case({dir1,dir0})
        2'b00:begin o_valid1 = 1'b0;                o_data1 = DW'(0);  end
        2'b01:begin o_valid1 = i_valid0;            o_data1 = i_data0; end
        2'b10:begin o_valid1 = i_valid1;            o_data1 = i_data1; end
        2'b11:begin o_valid1 = i_valid0 | i_valid1; o_data1 = (i_valid0) ? i_data0 : i_data1; end
    endcase
end
endmodule
