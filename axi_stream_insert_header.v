`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/17 13:57:55
// Design Name: 
// Module Name: TOP
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


module axi_stream_insert_header #(
parameter DATA_WD = 32,
parameter DATA_BYTE_WD = DATA_WD / 8
) (
input clk,
input rst_n,
// AXI Stream input original data
input valid_in,
input [DATA_WD-1 : 0] data_in,
input [DATA_BYTE_WD-1 : 0] keep_in,
input last_in,
output ready_in,
// AXI Stream output with header inserted
output reg valid_out,
output reg [DATA_WD-1 : 0] data_out,
output reg [DATA_BYTE_WD-1 : 0] keep_out,
output reg last_out,
input ready_out,
// The header to be inserted to AXI Stream input
input valid_insert,
input [DATA_WD-1 : 0] header_insert,
input [DATA_BYTE_WD-1 : 0] keep_insert,
output ready_insert
);

reg [DATA_BYTE_WD-1 : 0]    reg_r1_keep_in   ;
reg [DATA_WD-1 : 0]         reg_r1_data      ;
reg                         reg_r1_last      ;
reg                         flag         ;
reg                         valid_r1     ;
wire                        ready_r1     ;


reg [DATA_WD-1 : 0]         reg_data_p2s     ;
reg [DATA_BYTE_WD-1 : 0]    reg_keep_in_p2s  ;
reg [DATA_BYTE_WD-1 : 0]    reg_last_p2s     ;
reg [8-1 : 0]               reg_data_r2      ;
reg                         flag_p2s     ;
reg                         flag_p2s_d1  ;
reg                         flag_p2s_d2  ;
reg                         flag_p2s_d3  ;
reg                         valid_r2     ;
reg                         last_r2      ;
wire                        wire_enbale_p2s   ;
wire                        ready_r2     ;     

reg [DATA_WD-1 : 0]         reg_data_r3      ;
reg [DATA_BYTE_WD-1 : 0]    reg_keep_out_r3  ;
reg [1:0]                   reg_last_posion  ;
reg [1:0]                   cnt_s2p      ;
reg [DATA_WD-1 : 0]         reg_data_s2p     ;
reg                         last_flag    ;
reg                         flag_s2p     ;
reg                         last_r3      ;        
reg                         valid_r3     ;
wire                        ready_r3     ;

// ????????? ????????????

assign ready_in = (~valid_r1 || ready_r1 ) & (~flag);
assign ready_insert = (~valid_r1 || ready_r1) & flag;

always @(posedge clk ) 
begin
    if (~rst_n) 
    begin
        flag <= 1;
    end
    else if (valid_insert & ready_insert)
    begin
        flag <= 0;
    end
    else if (valid_in & ready_in & last_in)
    begin
        flag <= 1;
    end
end


always @(posedge clk ) 
begin
    if (~rst_n) 
    begin
        valid_r1 <= 0;
    end 
    else 
    begin
        if (ready_insert) 
        begin
            valid_r1 <= valid_insert;
        end
        else if (ready_in)
        begin
            valid_r1 <= valid_in;
        end
    end    
end

always @(posedge clk ) 
begin
    if (~rst_n) 
    begin
        reg_r1_keep_in <= 0;
        reg_r1_data <= 0;
        reg_r1_last <= 0;
    end    
    else
    begin
        if (valid_insert & ready_insert) 
        begin
            reg_r1_keep_in <= keep_insert;
            reg_r1_data <= header_insert;
            reg_r1_last <= 0;
        end
        else if (valid_in & ready_in)
        begin
            reg_r1_keep_in <= keep_in;
            reg_r1_data <= data_in;
            reg_r1_last <= last_in;
        end
    end
end

// ????????? ????????????

assign ready_r1 =  ready_r2 & ~wire_enbale_p2s;

always @(posedge clk ) 
begin
    if (~rst_n)
    begin
        flag_p2s <= 0;
    end
    else if (ready_r1)
    begin
        flag_p2s <= valid_r1;
    end
    else
    begin
        flag_p2s <= 0;
    end
end

always @(posedge clk ) 
begin
    if (~rst_n) 
    begin
        reg_last_p2s <= 0;
        reg_data_p2s <= 0;
        reg_keep_in_p2s <= 0;
    end 
    else 
    begin
        if (valid_r1 & ready_r1) 
        begin
            // flag_p2s <= 1;
            reg_data_p2s <= reg_r1_data;
            reg_keep_in_p2s <= reg_r1_keep_in;
            if (reg_r1_last) 
            begin
                case (reg_r1_keep_in)
                    4'b1111: reg_last_p2s <= 4'b0001;
                    4'b1110: reg_last_p2s <= 4'b0010;
                    4'b1100: reg_last_p2s <= 4'b0100;
                    4'b1000: reg_last_p2s <= 4'b1000;
                endcase               
            end
        end
        // else
        // begin
        //     flag_p2s <= 0;           
        // end
    end
end

always @(posedge clk ) 
begin
    flag_p2s_d1 <= flag_p2s;
    flag_p2s_d2 <= flag_p2s_d1;
    flag_p2s_d3 <= flag_p2s_d2;
end

assign wire_enbale_p2s = flag_p2s || flag_p2s_d1 || flag_p2s_d2 || flag_p2s_d3;

always @(posedge clk ) 
begin
    if (wire_enbale_p2s & ready_r2) 
    begin
        reg_keep_in_p2s <= reg_keep_in_p2s << 1;
        reg_data_p2s <= reg_data_p2s << 8;
        reg_last_p2s <= reg_last_p2s << 1;

        reg_data_r2 <= reg_data_p2s[DATA_WD-1:DATA_WD-8];
        valid_r2 <= reg_keep_in_p2s[3];
        last_r2 <= reg_last_p2s[3];
    end   
    else
    begin
        last_r2 <= 0;
        valid_r2 <= 0;
    end 
end

// ????????? ????????????

assign ready_r2 = ~valid_r3 || ready_r3;

always @(posedge clk ) 
begin
    if (~rst_n) 
    begin
        valid_r3 <= 0;
    end
    else if (ready_r2)
    begin
        valid_r3 <= flag_s2p;
    end
end

always @(posedge clk ) 
begin
    if (~rst_n) 
    begin
        cnt_s2p <= 0;
        flag_s2p <= 0;
    end 
    else 
    begin
        if (flag_s2p) 
        begin
            // valid_r3 <= 1;
            reg_data_r3 <= reg_data_s2p;           
            if (last_flag) 
            begin
                last_r3 <= 1;
                reg_keep_out_r3 <= reg_last_posion;
            end
            else
            begin
                last_r3 <= 0;
                reg_keep_out_r3 <= 0;
            end
        end
        // else
        //     // valid_r3 <= 0;

        if (valid_r2 & ready_r2) 
        begin               
            if (cnt_s2p == 3 || last_r2) 
            begin
                flag_s2p <= 1;
                cnt_s2p <= 0;     
                if (last_r2) 
                begin
                    last_flag <= 1;
                    reg_last_posion <= cnt_s2p;
                end
                else
                begin
                    last_flag <= 0;
                end          
            end 
            else 
            begin
                flag_s2p <= 0;
                cnt_s2p <= cnt_s2p + 1;
            end
            
            case (cnt_s2p)
                2'b00: reg_data_s2p[DATA_WD-1 :DATA_WD-8 ] <= reg_data_r2;
                2'b01: reg_data_s2p[DATA_WD-9 :DATA_WD-16] <= reg_data_r2;
                2'b10: reg_data_s2p[DATA_WD-17:DATA_WD-24] <= reg_data_r2;
                2'b11: reg_data_s2p[DATA_WD-25:DATA_WD-32] <= reg_data_r2;
            endcase 
        end
        else 
        begin
            flag_s2p <= 0;
        end
            
    end
end

// ????????? ??????

assign ready_r3 = ~valid_out || ready_out;

always @(posedge clk ) 
begin
    if (~rst_n) 
    begin
        valid_out <= 0;
    end
    else if (ready_r3)
    begin
        valid_out <= valid_r3;
    end
end


always @(posedge clk ) 
begin
    if (~rst_n) 
    begin
        // valid_out <= 0;
        data_out <= 0;
        keep_out <= 0;
        last_out <= 0;
    end 
    else 
    begin
        // valid_out <= valid_r3 & ready_r3;

        if (valid_r3 & ready_r3) 
        begin            
            data_out <= reg_data_r3;
            if (last_r3)
            begin
                last_out <= 1;
                case (reg_last_posion)
                    0: keep_out <= 4'b1000;
                    1: keep_out <= 4'b1100;
                    2: keep_out <= 4'b1110;
                    3: keep_out <= 4'b1111;
                endcase
            end
            else
            begin
                last_out <= 0;
                keep_out <= 4'b1111;
            end
        end
    end
end


endmodule
