`timescale 1 ns / 1 ps

module system (
	input            clk,
	input            resetn,
	output           trap,
        output reg [7:0] out_byte,
	output reg       out_byte_en
);

	// 32768 32bit words = 128kB memory
	parameter MEM_SIZE = 32768;

        integer            tb_idx;

	wire mem_valid;
	wire mem_instr;
	reg mem_ready;
	reg mem_ready_last; 
	wire [63:0] mem_addr;
	wire [63:0] mem_wdata;
	wire [7:0] mem_wstrb;
	reg [63:0] mem_rdata;

	wire [63:0] rvec;    

	picorv_ez picorv (
		.clock       (clk         ),
		.reset       (!resetn     ),
		.irq_req     ( 1'b0       ),
		.mem_valid   (mem_valid   ),
		.mem_insn    (mem_instr   ),
		.mem_ready   (mem_ready   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),
		.mem_rdata   (mem_rdata   ),
		.pcpi_ready  (1'b0),
		.pcpi_wb_data(64'b0),
		.halt(trap)
	);

       

       assign revc = 32'b0;
       assign uart_wstrb = mem_wstrb & mem_ready;
   
	reg [31:0] memory [0:MEM_SIZE-1];
	initial begin
                for (tb_idx=0; tb_idx < MEM_SIZE; tb_idx=tb_idx+1)
                       memory[tb_idx] = 32'b0;
                $readmemh(`MEM_FILENAME, memory);
        end

	reg [63:0] m_read_data;
	reg m_read_en;

	always @(posedge clk) begin
			m_read_en <= 0;
			mem_ready <= mem_valid && !mem_ready_last && !mem_ready && m_read_en;
			mem_ready_last <= mem_ready; 
                        out_byte_en <= 0;
                   			
			(* parallel_case *)
			case (1)
				mem_valid && !mem_ready && !mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					m_read_en <= 1;
				        m_read_data[31:0] <= memory[mem_addr >> 2];
				        m_read_data[63:32] <= memory[(mem_addr >> 2) + 1];
				        mem_rdata <= m_read_data;
				end
				mem_valid && !mem_ready && |mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
					if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
					if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
					if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
					if (mem_wstrb[4]) memory[(mem_addr >> 2) + 1][ 7: 0] <= mem_wdata[39:32];
					if (mem_wstrb[5]) memory[(mem_addr >> 2) + 1][15: 8] <= mem_wdata[47:40];
					if (mem_wstrb[6]) memory[(mem_addr >> 2) + 1][23:16] <= mem_wdata[55:48];
					if (mem_wstrb[7]) memory[(mem_addr >> 2) + 1][31:24] <= mem_wdata[63:56];
					mem_ready <= 1;
				end
				
                                mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h2000_0000: begin
					out_byte_en <= 1;
					out_byte <= mem_wdata;
					mem_ready <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb : begin
					mem_ready <= 1;
				end
			endcase
                        if (resetn && out_byte_en) begin
			   $write("%c", out_byte);
		        end
		end
endmodule
