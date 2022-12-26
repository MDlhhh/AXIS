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
parameter DATA_WD = 32 ; 
parameter DATA_BYTE_WD = DATA_WD / 8 ;
	
reg [2:0] cnt;
reg clk = 1;
reg rst_n;

wire valid_in;
wire [DATA_WD-1 : 0] data_in;
wire [DATA_BYTE_WD-1 : 0] keep_in;
wire last_in;
wire ready_in;

wire valid_out;
wire [DATA_WD-1 : 0] data_out;
wire [DATA_BYTE_WD-1 : 0] keep_out;
wire last_out;
reg ready_out;

wire valid_insert;
wire [DATA_WD-1 : 0] header_insert;
wire [DATA_BYTE_WD-1 : 0] keep_insert;
wire ready_insert;

reg s_axis_tvalid_1;
wire s_axis_tready_1;
reg [DATA_WD-1 : 0] s_axis_tdata_1;
reg s_axis_tlast_1;
reg [DATA_BYTE_WD-1 : 0] s_axis_tuser_1;

reg s_axis_tvalid_2;
wire s_axis_tready_2;
reg [DATA_WD-1 : 0] s_axis_tdata_2;
reg [DATA_BYTE_WD-1 : 0] s_axis_tuser_2;

axi_stream_insert_header #(
.DATA_WD(DATA_WD),
.DATA_BYTE_WD(DATA_BYTE_WD)
)
U_TOP (
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

fifo_test U1_fifo_test (
  .wr_rst_busy(),      // output wire wr_rst_busy
  .rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(clk),                // input wire s_aclk
  .s_aresetn(rst_n),          // input wire s_aresetn
  .s_axis_tvalid(s_axis_tvalid_1),  // input wire s_axis_tvalid
  .s_axis_tready(s_axis_tready_1),  // output wire s_axis_tready
  .s_axis_tdata(s_axis_tdata_1),    // input wire [31 : 0] s_axis_tdata
  .s_axis_tlast(s_axis_tlast_1),    // input wire s_axis_tlast
  .s_axis_tuser(s_axis_tuser_1),    // input wire [3 : 0] s_axis_tuser
  .m_axis_tvalid(valid_in),  // output wire m_axis_tvalid
  .m_axis_tready(ready_in),  // input wire m_axis_tready
  .m_axis_tdata(data_in),    // output wire [31 : 0] m_axis_tdata
  .m_axis_tlast(last_in),    // output wire m_axis_tlast
  .m_axis_tuser(keep_in)    // output wire [3 : 0] m_axis_tuser
);

fifo_test U2_fifo_test (
  .wr_rst_busy(),      // output wire wr_rst_busy
  .rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(clk),                // input wire s_aclk
  .s_aresetn(rst_n),          // input wire s_aresetn
  .s_axis_tvalid(s_axis_tvalid_2),  // input wire s_axis_tvalid
  .s_axis_tready(s_axis_tready_2),  // output wire s_axis_tready
  .s_axis_tdata(s_axis_tdata_2),    // input wire [31 : 0] s_axis_tdata
  .s_axis_tlast(),    // input wire s_axis_tlast
  .s_axis_tuser(s_axis_tuser_2),    // input wire [3 : 0] s_axis_tuser
  .m_axis_tvalid(valid_insert),  // output wire m_axis_tvalid
  .m_axis_tready(ready_insert),  // input wire m_axis_tready
  .m_axis_tdata(header_insert),    // output wire [31 : 0] m_axis_tdata
  .m_axis_tlast(),    // output wire m_axis_tlast
  .m_axis_tuser(keep_insert)    // output wire [3 : 0] m_axis_tuser
);
always #0.5 clk = ~ clk;

integer seed;
	
initial
begin
	seed = 2;
end
    
initial
begin	
    rst_n = 0;
    #10;
    rst_n = 1;
end

always @(posedge clk ) 
begin
    if(~rst_n)
    begin
        s_axis_tvalid_1 <= 0;
        s_axis_tdata_1 <= 32'h0;
        s_axis_tuser_1 <= 4'b0;
        s_axis_tlast_1 <= 0;
    end
    else
    begin
        case (cnt)
            0: begin s_axis_tvalid_1 <= 1; s_axis_tdata_1 <= {$random}%32'hFFFFFFFF; s_axis_tuser_1 <= 4'b1111; s_axis_tlast_1 <= 0; end
            1: begin s_axis_tvalid_1 <= 1; s_axis_tdata_1 <= {$random}%32'hFFFFFFFF; s_axis_tuser_1 <= 4'b1111; s_axis_tlast_1 <= 0; end
            2: begin s_axis_tvalid_1 <= 1; s_axis_tdata_1 <= {$random}%32'hFFFFFFFF; s_axis_tuser_1 <= 4'b1111; s_axis_tlast_1 <= 0; end
            3: begin s_axis_tvalid_1 <= 1; s_axis_tdata_1 <= {$random}%32'hFFFFFFFF; s_axis_tuser_1 <= 4'b1111; s_axis_tlast_1 <= 0; end
            4: begin s_axis_tvalid_1 <= 1; s_axis_tdata_1 <= {$random}%32'hFFFFFFFF; s_axis_tuser_1 <= {$random(seed)}%2?({$random(seed)}%2?4'b1111:4'b1110):({$random(seed)}%2?4'b1100:4'b1000); s_axis_tlast_1 <= 1; end
            default: s_axis_tvalid_1 <= 0;
        endcase
    end
end

always @(posedge clk ) 
begin
    if(~rst_n)
    begin
        s_axis_tvalid_2 <= 0;
        s_axis_tdata_2 <= 32'h0;
        s_axis_tuser_2 <= 4'b0;
    end
    else
    begin
        case (cnt)
            0: begin s_axis_tvalid_2 <= 1; s_axis_tdata_2 <= {$random}%32'hFFFFFFFF; s_axis_tuser_2 <= {$random(seed)}%2?({$random(seed)}%2?4'b1111:4'b1110):({$random(seed)}%2?4'b1100:4'b1000); end
            1: begin s_axis_tvalid_2 <= 1; s_axis_tdata_2 <= {$random}%32'hFFFFFFFF; s_axis_tuser_2 <= {$random(seed)}%2?({$random(seed)}%2?4'b1111:4'b1110):({$random(seed)}%2?4'b1100:4'b1000); end
            2: begin s_axis_tvalid_2 <= 1; s_axis_tdata_2 <= {$random}%32'hFFFFFFFF; s_axis_tuser_2 <= {$random(seed)}%2?({$random(seed)}%2?4'b1111:4'b1110):({$random(seed)}%2?4'b1100:4'b1000); end
            3: begin s_axis_tvalid_2 <= 1; s_axis_tdata_2 <= {$random}%32'hFFFFFFFF; s_axis_tuser_2 <= {$random(seed)}%2?({$random(seed)}%2?4'b1111:4'b1110):({$random(seed)}%2?4'b1100:4'b1000); end
            4: begin s_axis_tvalid_2 <= 1; s_axis_tdata_2 <= {$random}%32'hFFFFFFFF; s_axis_tuser_2 <= {$random(seed)}%2?({$random(seed)}%2?4'b1111:4'b1110):({$random(seed)}%2?4'b1100:4'b1000); end
            default: s_axis_tvalid_2 <= 0;
        endcase
    end
end

always @(posedge clk ) 
begin
    if(~rst_n)
        cnt <= 0;
    else if (s_axis_tready_1 & s_axis_tvalid_1) 
        cnt <= cnt + 1;
    else if (cnt == 6)
        cnt <= 0;
end

always @(posedge clk) 
begin
    if (~rst_n) 
        ready_out <= 0;
    else 
        ready_out <= 1;
end
endmodule
