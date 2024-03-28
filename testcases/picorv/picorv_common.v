/*
 *  PicoRV -- A Small and Extensible RISC-V Processor
 *
 *  Copyright (C) 2019  Claire Wolf <claire@symbioticeda.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

module picorv_ez #(
	parameter integer CPI = 2,
	parameter integer XLEN = 64,
	parameter integer ILEN = 32,
	parameter integer IALIGN = 32,
	parameter [0:0] PCPI = 1,
	parameter [0:0] PCPI_RS3 = 1,
	parameter [XLEN-1:0] SPINIT = 1,
	parameter [XLEN-1:0] RST_VECTOR = 0,
	parameter [XLEN-1:0] ISR_VECTOR = 0
) (
	// control
	input            clock,
	input            reset,

	// interrupt control
	input            irq_req,
	output           irq_ack,

	// memory interface
	output            mem_valid,
	input             mem_ready,
	output            mem_insn,
	output [XLEN-1:0] mem_addr,
	input  [XLEN-1:0] mem_rdata,
	output [XLEN-1:0] mem_wdata,
	output [XLEN/8 -1:0] mem_wstrb,

	// pcpi
	output            pcpi_valid,
	output [ILEN-1:0] pcpi_insn,
	output [    15:0] pcpi_prefix,
	output [XLEN-1:0] pcpi_pc,
	output [XLEN-1:0] pcpi_rs1_data,
	output [XLEN-1:0] pcpi_rs2_data,
	output [XLEN-1:0] pcpi_rs3_data,
	input             pcpi_ready,
	input             pcpi_wb_write,
	input  [XLEN-1:0] pcpi_wb_data,
	input             pcpi_br_enable,
	input  [XLEN-1:0] pcpi_br_nextpc,
	output halt
);
	wire pcpi_valid_raw;
	wire pcpi_rs1_valid;
	wire pcpi_rs2_valid;
	wire pcpi_rs3_valid;
	wire pcpi_wb_valid;

	wire [XLEN-1:0] pcpi_rs3_data_raw;
	assign pcpi_rs3_data = PCPI_RS3 ? pcpi_rs3_data_raw : 0;

	assign pcpi_valid = pcpi_valid_raw && pcpi_rs1_valid && pcpi_rs2_valid && (PCPI_RS3 && pcpi_rs3_valid) && pcpi_wb_valid;

	assign irq_ack = 0;
    
    wire        pcpi_mul_wr;
	wire [XLEN-1:0] pcpi_mul_rd;
	wire        pcpi_mul_ready; 
    
    picorv32_pcpi_mul #(.XLEN(XLEN))
    pcpi_mul (
			.clk       (clock          ),
			.resetn    (!reset         ),
			.pcpi_valid(pcpi_valid     ),
			.pcpi_insn (pcpi_insn      ),
			.pcpi_rs1  (pcpi_rs1_data  ),
			.pcpi_rs2  (pcpi_rs2_data  ),
			.pcpi_wr   (pcpi_mul_wr    ),
			.pcpi_rd   (pcpi_mul_rd    ),
			.pcpi_wait (               ),
			.pcpi_ready(pcpi_mul_ready )
		); 

    wire        pcpi_div_wr;
	wire [XLEN-1:0] pcpi_div_rd;
	wire        pcpi_div_ready; 

	picorv32_pcpi_div #(.XLEN(XLEN))
	pcpi_div (
			.clk       (clock          ),
			.resetn    (!reset         ),
			.pcpi_valid(pcpi_valid     ),
			.pcpi_insn (pcpi_insn      ),
			.pcpi_rs1  (pcpi_rs1_data  ),
			.pcpi_rs2  (pcpi_rs2_data  ),
			.pcpi_wr   (pcpi_div_wr    ),
			.pcpi_rd   (pcpi_div_rd    ),
			.pcpi_wait (               ),
			.pcpi_ready(pcpi_div_ready )
		);

    
    wire [XLEN-1:0] pcpi_muldiv_rd  = (pcpi_mul_ready ? pcpi_mul_rd : {XLEN{1'b0}}) | (pcpi_div_ready ? pcpi_div_rd : {XLEN{1'b0}});
    
	picorv_core #(
		.CPI(CPI),
		.XLEN(XLEN),
		.ILEN(ILEN),
		.IALIGN(IALIGN),
		.SPINIT(SPINIT)
	) core (
		.clock          (clock         ),
		.reset          (reset         ),
		.rvec           (RST_VECTOR    ),

		.mem_valid      (mem_valid     ),
		.mem_ready      (mem_ready     ),
		.mem_insn       (mem_insn      ),
		.mem_addr       (mem_addr      ),
		.mem_rdata      (mem_rdata     ),
		.mem_wdata      (mem_wdata     ),
		.mem_wstrb      (mem_wstrb     ),

		.decode_valid   (              ),
		.decode_insn    (              ),
		.decode_prefix  (              ),

		.pcpi_valid     (pcpi_valid_raw),
		.pcpi_insn      (pcpi_insn     ),
		.pcpi_prefix    (pcpi_prefix   ),
		.pcpi_pc        (pcpi_pc       ),
		.pcpi_rs1_valid (pcpi_rs1_valid),
		.pcpi_rs1_data  (pcpi_rs1_data ),
		.pcpi_rs2_valid (pcpi_rs2_valid),
		.pcpi_rs2_data  (pcpi_rs2_data ),
		.pcpi_rs3_valid (pcpi_rs3_valid),
		.pcpi_rs3_data  (pcpi_rs3_data_raw),
		.pcpi_ready     (PCPI && (pcpi_ready | pcpi_mul_ready |pcpi_div_ready)),
		.pcpi_wb_valid  (pcpi_wb_valid ),
		.pcpi_wb_async  (1'b 0         ),
		.pcpi_wb_write  (PCPI && (pcpi_ready | pcpi_mul_ready | pcpi_div_ready) ? pcpi_wb_write | pcpi_mul_wr | pcpi_div_wr : 1'b 0),
		.pcpi_wb_data   (PCPI && (pcpi_ready | pcpi_mul_ready | pcpi_div_ready) ? pcpi_wb_data | pcpi_muldiv_rd : {XLEN{1'b0}}),
		.pcpi_br_enable (PCPI && pcpi_ready ? pcpi_br_enable : 1'b 0),
		.pcpi_br_nextpc (PCPI && pcpi_ready ? pcpi_br_nextpc : {XLEN{1'b0}}),

		.awb_valid      (1'b 0         ),
		.awb_ready      (              ),
		.awb_addr       (5'd 0         ),
		.awb_data       ({XLEN{1'b0}}  ),
		.halt(halt)
	);
endmodule


/***************************************************************
 * picorv32_pcpi_mul
 ***************************************************************/

module picorv32_pcpi_mul #(
	parameter STEPS_AT_ONCE = 1,
	parameter CARRY_CHAIN = 4,
	parameter integer XLEN = 64
) (
	input clk, resetn,

	input             pcpi_valid,
	input      [31:0] pcpi_insn,
	input      [XLEN-1:0] pcpi_rs1,
	input      [XLEN-1:0] pcpi_rs2,
	output reg        pcpi_wr,
	output reg [XLEN-1:0] pcpi_rd,
	output reg        pcpi_wait,
	output reg        pcpi_ready
);
	reg instr_mul, instr_mulh, instr_mulhsu, instr_mulhu;
	wire instr_any_mul = |{instr_mul, instr_mulh, instr_mulhsu, instr_mulhu};
	wire instr_any_mulh = |{instr_mulh, instr_mulhsu, instr_mulhu};
	wire instr_rs1_signed = |{instr_mulh, instr_mulhsu};
	wire instr_rs2_signed = |{instr_mulh};

	reg pcpi_wait_q;
	wire mul_start = pcpi_wait && !pcpi_wait_q;

	always @(posedge clk) begin
		instr_mul <= 0;
		instr_mulh <= 0;
		instr_mulhsu <= 0;
		instr_mulhu <= 0;

		if (resetn && pcpi_valid && pcpi_insn[6:4] == 3'b011 && pcpi_insn[2:0] == 3'b011 &&  pcpi_insn[31:25] == 7'b0000001) begin
			case (pcpi_insn[14:12])
				3'b000: instr_mul <= 1;
				3'b001: instr_mulh <= 1;
				3'b010: instr_mulhsu <= 1;
				3'b011: instr_mulhu <= 1;
			endcase
		end

		pcpi_wait <= instr_any_mul;
		pcpi_wait_q <= pcpi_wait;
	end

	reg [2*XLEN-1:0] rs1, rs2, rd, rdx;
	reg [2*XLEN-1:0] next_rs1, next_rs2, this_rs2;
	reg [2*XLEN-1:0] next_rd, next_rdx, next_rdt;
	reg [$clog2(XLEN):0] mul_counter;
	reg mul_waiting;
	reg mul_finish;
	integer i, j;

	// carry save accumulator
	always @* begin
		next_rd = rd;
		next_rdx = rdx;
		next_rs1 = rs1;
		next_rs2 = rs2;

		for (i = 0; i < STEPS_AT_ONCE; i=i+1) begin
			this_rs2 = next_rs1[0] ? next_rs2 : 0;
			if (CARRY_CHAIN == 0) begin
				next_rdt = next_rd ^ next_rdx ^ this_rs2;
				next_rdx = ((next_rd & next_rdx) | (next_rd & this_rs2) | (next_rdx & this_rs2)) << 1;
				next_rd = next_rdt;
			end else begin
				next_rdt = 0;
				for (j = 0; j < 2*XLEN; j = j + CARRY_CHAIN)
					{next_rdt[j+CARRY_CHAIN-1], next_rd[j +: CARRY_CHAIN]} =
							next_rd[j +: CARRY_CHAIN] + next_rdx[j +: CARRY_CHAIN] + this_rs2[j +: CARRY_CHAIN];
				next_rdx = next_rdt << 1;
			end
			next_rs1 = next_rs1 >> 1;
			next_rs2 = next_rs2 << 1;
		end
	end

	always @(posedge clk) begin
		mul_finish <= 0;
		if (!resetn) begin
			mul_waiting <= 1;
		end else
		if (mul_waiting) begin
			if (instr_rs1_signed)
				rs1 <= $signed(pcpi_rs1);
			else
				rs1 <= $unsigned(pcpi_rs1);

			if (instr_rs2_signed)
				rs2 <= $signed(pcpi_rs2);
			else
				rs2 <= $unsigned(pcpi_rs2);

			rd <= 0;
			rdx <= 0;
			mul_counter <= (instr_any_mulh ? 2*XLEN-1 - STEPS_AT_ONCE : XLEN-1 - STEPS_AT_ONCE);
			mul_waiting <= !mul_start;
		end else begin
			rd <= next_rd;
			rdx <= next_rdx;
			rs1 <= next_rs1;
			rs2 <= next_rs2;

			mul_counter <= mul_counter - STEPS_AT_ONCE;
			if (mul_counter[$clog2(XLEN)]) begin
				mul_finish <= 1;
				mul_waiting <= 1;
			end
		end
	end

	always @(posedge clk) begin
		pcpi_wr <= 0;
		pcpi_ready <= 0;
		if (mul_finish && resetn) begin
			pcpi_wr <= 1;
			pcpi_ready <= 1;
			pcpi_rd <= instr_any_mulh ? rd >> 32 : rd;
		end
	end
endmodule 

module picorv32_pcpi_div
#(
	parameter integer XLEN = 64
)
 (
	input clk, resetn,

	input             pcpi_valid,
	input      [31:0] pcpi_insn,
	input      [XLEN-1:0] pcpi_rs1,
	input      [XLEN-1:0] pcpi_rs2,
	output reg        pcpi_wr,
	output reg [XLEN-1:0] pcpi_rd,
	output reg        pcpi_wait,
	output reg        pcpi_ready
);
	reg instr_div, instr_divu, instr_rem, instr_remu;
	wire instr_any_div_rem = |{instr_div, instr_divu, instr_rem, instr_remu};

	reg pcpi_wait_q;
	wire start = pcpi_wait && !pcpi_wait_q;

	always @(posedge clk) begin
		instr_div <= 0;
		instr_divu <= 0;
		instr_rem <= 0;
		instr_remu <= 0;

		if (resetn && pcpi_valid && !pcpi_ready && pcpi_insn[6:4] == 3'b011 && pcpi_insn[2:0] == 3'b011 && pcpi_insn[31:25] == 7'b0000001) begin
			case (pcpi_insn[14:12])
				3'b100: instr_div <= 1;
				3'b101: instr_divu <= 1;
				3'b110: instr_rem <= 1;
				3'b111: instr_remu <= 1;
			endcase
		end

		pcpi_wait <= instr_any_div_rem;
		pcpi_wait_q <= pcpi_wait;
	end

	reg [XLEN-1:0] dividend;
	reg [2*XLEN-2:0] divisor;
	reg [XLEN-1:0] quotient;
	reg [XLEN-1:0] quotient_msk;
	reg running;
	reg outsign;

	always @(posedge clk) begin
		pcpi_ready <= 0;
		pcpi_wr <= 0;
		pcpi_rd <= 'bx;

		if (!resetn) begin
			running <= 0;
		end else
		if (start) begin
			running <= 1;
			dividend <= (instr_div || instr_rem) && pcpi_rs1[XLEN-1] ? -pcpi_rs1 : pcpi_rs1;
			divisor <= ((instr_div || instr_rem) && pcpi_rs2[XLEN-1] ? -pcpi_rs2 : pcpi_rs2) << (XLEN-1);
			outsign <= (instr_div && (pcpi_rs1[XLEN-1] != pcpi_rs2[XLEN-1]) && |pcpi_rs2) || (instr_rem && pcpi_rs1[XLEN-1]);
			quotient <= 0;
			quotient_msk <= 1 << XLEN-1;
		end else
		if (!quotient_msk && running) begin
			running <= 0;
			pcpi_ready <= 1;
			pcpi_wr <= 1;
			if (instr_div || instr_divu)
				pcpi_rd <= outsign ? -quotient : quotient;
			else
				pcpi_rd <= outsign ? -dividend : dividend;
		end else begin
			if (divisor <= dividend) begin
				dividend <= dividend - divisor;
				quotient <= quotient | quotient_msk;
			end
			divisor <= divisor >> 1;
			quotient_msk <= quotient_msk >> 1;
		end
	end
endmodule 
