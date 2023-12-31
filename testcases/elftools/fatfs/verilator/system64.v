`timescale 1 ns / 1 ps

module system (
	input            clk,
	input            resetn
        `ifndef verilator
            output txd,
	    input rxd
        `endif
);

	// 32768 32bit words = 64kB memory
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
   


        wire uart_cs;
        wire uart_done;
        wire mem_cs;
        wire wr;
        wire rd;        
        wire [31:0] spi_rdata;
        wire spi_done;     
        wire [31:0] uart_rdata;
		  

	picorv_ez #(.XLEN(64)) picorv (
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


        `ifdef verilator
            simsd sd(
		.clk(clk),
		.cs(spi_cs),
		.bus_addr(mem_addr),
		.bus_wr_val(mem_wdata),
		.bus_bytesel(mem_wstrb && mem_ready),
		.bus_ack(spi_done),
		.bus_data(spi_rdata)
             );
        `else

				 
		 rs232 uart(
		 .clk(clk),
		 .resetn(resetn),
		 .ctrl_wr(uart_cs && wr),
		 .ctrl_rd(uart_cs && rd),
		 .ctrl_addr(mem_addr),
		 .ctrl_wdat(mem_wdata),
		 .ctrl_rdat(uart_rdata),
		 .ctrl_done(uart_done),
		 .rxd(rxd),
		 .txd(txd)
		 );
         `endif
       assign spi_cs =  mem_addr[31:4] == 28'h4000000 && mem_valid; 
       assign uart_cs = mem_addr[31:4] == 28'h2000000 && mem_valid;
       assign mem_cs = (mem_addr >> 2) < MEM_SIZE && mem_valid; 
       //assign mem_cs = (mem_addr >> 2) < MEM_SIZE && mem_valid;
       assign wr = |mem_wstrb && !mem_ready;
       assign rd = !mem_wstrb && !mem_ready;

		 
   
        reg [31:0] memory [0:MEM_SIZE-1];
	initial begin
                //for (tb_idx=0; tb_idx < MEM_SIZE; tb_idx=tb_idx+1)
                //       memory[tb_idx] = 32'b0;
                       $readmemh("firmware.hex", memory);
        end

	reg [63:0] m_read_data;
	reg m_read_en;

	always @(posedge clk) begin
			m_read_en <= 0;
			mem_ready <= mem_valid && !mem_ready_last && !mem_ready && m_read_en;
            mem_ready_last <= mem_ready;
			(* parallel_case *)
			case (1)
			    mem_cs: begin
					m_read_en <= 1;
				        m_read_data[31:0] <= memory[mem_addr >> 2];
				        m_read_data[63:32] <= memory[(mem_addr >> 2) + 1];
				        mem_rdata <= m_read_data;		
				if(wr) begin
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
				end
                spi_cs : begin
                                if(rd) begin
										m_read_en <= spi_done;
                                        mem_rdata <= spi_rdata;
                                end
                                if(wr) mem_ready <= spi_done;

				end 
				uart_cs: begin
                                    if(rd) begin
                                	m_read_en <= uart_done;
                                        mem_rdata <= uart_rdata;
                                    end
                                    if(wr) begin
                                       mem_ready <= uart_done;
                                      `ifdef verilator
                                           if (resetn) $write("%c", mem_wdata);
	  				   mem_ready <= 1;
				       `endif
			            end
                                end
			endcase
		end
endmodule
