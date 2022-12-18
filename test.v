`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/17 13:59:55
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test(

    );
reg [2:0] cnt = 0;
reg clk = 1;
reg rst_n;

reg valid_in = 0;
reg [32-1 : 0] data_in;
reg [4-1 : 0] keep_in;
reg last_in;
wire ready_in;

wire valid_out;
wire [32-1 : 0] data_out;
wire [4-1 : 0] keep_out;
wire last_out;
reg ready_out;

reg valid_insert = 0;
reg [32-1 : 0] header_insert;
reg [4-1 : 0] keep_insert;
wire ready_insert;

axi_stream_insert_header U_TOP(
.clk                    (clk          ),
.rst_n                  (rst_n        ),
.valid_in               (valid_in     ),
.data_in                (data_in      ),
.keep_in                (keep_in      ),
.last_in                (last_in      ),
.ready_in               (ready_in     ),
.valid_out              (valid_out    ),
.data_out               (data_out     ),
.keep_out               (keep_out     ),
.last_out               (last_out     ),
.ready_out              (ready_out    ),
.valid_insert           (valid_insert ),
.header_insert          (header_insert),
.keep_insert            (keep_insert  ),
.ready_insert           (ready_insert )
);

always #0.5 clk = ~ clk;


initial
begin	
    rst_n = 0;
    #100;
    rst_n = 1;
    #100;
    ready_out = 1;
    #10;
    valid_insert = 1;
    keep_insert = 4'b0111;
    header_insert = 32'hF0E0D0C0;

    #100;
    ready_out = 0;

    #100;
    ready_out = 1;


end

always @(posedge clk ) 
begin
    if(ready_in)
    begin
        cnt <= cnt + 1;
        case (cnt)
            0: begin valid_in <= 1; data_in <= 32'hA0B0C0D0; keep_in <= 4'b1111; last_in <= 0; end
            1: begin valid_in <= 1; data_in <= 32'hE0F00010; keep_in <= 4'b1111; last_in <= 0; end
            2: begin valid_in <= 1; data_in <= 32'h20304050; keep_in <= 4'b1111; last_in <= 0; end
            3: begin valid_in <= 1; data_in <= 32'h60708090; keep_in <= 4'b1111; last_in <= 0; end
            4: begin valid_in <= 1; data_in <= 32'h00A00000; keep_in <= 4'b1100; last_in <= 1; end
            default: valid_in <= 0;
        endcase
    end
end

endmodule
