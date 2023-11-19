`timescale 1ns / 1ps

`define DEF_BOARD_CLOCK 	 32*1000*1000
`define DEF_SYSTEM_CLOCK 	(`DEF_BOARD_CLOCK)

`define DEF_MFPCLOCK_DIV         8
`define DEF_MFP_UART_CLOCK      (115200*16)
`define DEF_MFP_UART_CLOCK_DIV  (((`DEF_BOARD_CLOCK) + (`DEF_MFP_UART_CLOCK)/2) / (`DEF_MFP_UART_CLOCK))

module sysctl #(
	parameter BOARD_CLOCK        = `DEF_BOARD_CLOCK,
	parameter SYSTEM_CLOCK       = `DEF_SYSTEM_CLOCK,
	parameter MFPCLOCK_DIV       = `DEF_MFPCLOCK_DIV,
	parameter MFP_UART_CLOCK     = `DEF_MFP_UART_CLOCK,
	parameter MFP_UART_CLOCK_DIV = `DEF_MFP_UART_CLOCK_DIV
	// 1024 refresh cycles every 16ms (= 62.5 times in a second) 
) (
	input         clk2,
	input         reset_async_n,
	output  reg   reset,
	input [31:30] addr,
	input         den_n,
	input         w_rn,
	input         as_n,
	input         lock_n,
	input         inta_n,
	input         blast_n,
	input         dt_rn,
//-----------------------------------
	output        we_ram_n,
	output        cs_rom_n,
	output        cs_ram_n,
	output  reg   a0_rom,
	output  reg   ready_n,
//-----------------------------------
	output [6:0] dbg,
//-----------------------------------
	output     mfp_iack_n,
	output     mfp_cs_n,
	output     mfp_ds_n,
	input      mfp_dtack_n,
	output reg mfp_clk_out,
	output reg mfp_uart_clk_out
//-----------------------------------
);
	assign dbg[0] = ready_n;
	assign dbg[1] = 1'b1;
	assign dbg[2] = 1'b1;
	assign dbg[3] = 1'b1;
	assign dbg[4] = 1'b1;
	assign dbg[5] = pclk;
	assign dbg[6] = clk2;

	
	reg [2:0] clk_div_mfp;
	reg [4:0] clk_div_mfp_uart;

	initial begin
		clk_div_mfp <= 0;
		clk_div_mfp_uart <= 0;
	end

	always @(posedge clk2) begin
		clk_div_mfp_uart <= clk_div_mfp_uart + 1'b1;
		mfp_uart_clk_out <= mfp_uart_clk_out;
		if( clk_div_mfp_uart == ((MFP_UART_CLOCK_DIV/2) - 1) ) begin
			mfp_uart_clk_out <= 0;
		end else if( clk_div_mfp_uart == (MFP_UART_CLOCK_DIV - 1) ) begin
			mfp_uart_clk_out <= 1;
			clk_div_mfp_uart <= 0;
		end
	end

	always @(posedge clk2) begin
		if( clk_div_mfp == ((MFPCLOCK_DIV/2) - 1) ) begin
			clk_div_mfp <= 0;
			mfp_clk_out <= ~mfp_clk_out;
		end else begin
			clk_div_mfp <= clk_div_mfp + 1'b1;
			mfp_clk_out <= mfp_clk_out;
		end
	end
	//-----------------------------------------
	
	
	
localparam BUSSTATE_UNKNOWN  = 0;
localparam BUSSTATE_Ti       = 1;
localparam BUSSTATE_T1       = 2;
localparam BUSSTATE_T2       = 3;

	reg [1:0] bus_state;
	reg       pclk;

	initial begin
		bus_state  <= BUSSTATE_UNKNOWN;
		pclk       <= 0;
	end

	reg t1count;
	always @(posedge clk2) begin
		t1count <= 0;
		if( bus_state == BUSSTATE_T1 ) begin
			t1count <= (t1count | ~pclk);
		end
	end
	

	reg [1:0] w_next_bus_state;
	
	always @(*) begin

		if( reset == 0 ) begin

			w_next_bus_state = BUSSTATE_UNKNOWN;

		end else if( bus_state == BUSSTATE_Ti ) begin

			w_next_bus_state = ( pclk & ~as_n  ) ? BUSSTATE_T1 : BUSSTATE_Ti;

		end else if( bus_state == BUSSTATE_T1 ) begin
			
			if( ~memarea_rom ) begin
				w_next_bus_state = (~pclk          ) ? BUSSTATE_T2 : BUSSTATE_T1;
			end else begin
				w_next_bus_state = (~pclk & t1count) ? BUSSTATE_T2 : BUSSTATE_T1;
			end

		end else if( bus_state == BUSSTATE_T2 ) begin
			
			if( pclk | ready_n ) begin
				w_next_bus_state = BUSSTATE_T2;
			end else begin
				if ( ~blast_n ) begin
					w_next_bus_state = BUSSTATE_Ti;
				end else begin
					w_next_bus_state = wait_insert ? BUSSTATE_T1 : BUSSTATE_T2;
				end
			end
		end else begin

			// the next cycle is phi2 of the first Ts if the condition is satisfied
			w_next_bus_state = (~as_n) ? BUSSTATE_T1 : BUSSTATE_UNKNOWN;

		end
	end


	always @(posedge clk2) begin
		bus_state <= w_next_bus_state;
	end

	always @(posedge clk2) begin
		pclk <= ~pclk;
		if( bus_state == BUSSTATE_UNKNOWN && as_n == 1'b0 && reset == 1'b1 ) begin
			pclk <= 1'b0; // the next cycle is the first phi2 of the first T1
		end
	end

	//-----------------------------------------
	wire memarea_rom  = (addr[31:30] == 2'b00) ? 1'b1 : 1'b0;
	wire memarea_ram  = (addr[31:30] == 2'b01) ? 1'b1 : 1'b0;
	wire ioarea_mfp   = (addr[31]    == 1'b1 ) ? 1'b1 : 1'b0;

	assign cs_rom_n      = ~( inta_n & memarea_rom & ~den_n & ~w_rn );
	assign cs_ram_n      = ~( inta_n & memarea_ram & ~den_n & (bus_state == BUSSTATE_T2? 1'b1 : 1'b0));
	assign mfp_cs_n      = ~( inta_n & ioarea_mfp  & ~den_n         );
	assign mfp_iack_n    = ~(~inta_n & lock_n      & ~blast_n       );
	assign mfp_ds_n      = mfp_cs_n & mfp_iack_n;

	assign we_ram_n = (cs_ram_n | pclk | ~w_rn);

	wire wait_insert = 
				(memarea_rom & inta_n & ~w_rn) |
				(ioarea_mfp  & inta_n);
	
	reg [1:0] prev_state;
	always @(posedge clk2) begin
		ready_n <= ready_n;
		prev_state <= bus_state;

		if( ~pclk ) begin
			a0_rom <= (((bus_state==BUSSTATE_T1) && (memarea_rom==1'b1)) ? 1'b1 : 1'b0);
		end else begin
			a0_rom <= a0_rom;
		end
		
		if( bus_state == BUSSTATE_T2 && prev_state == BUSSTATE_T1 ) begin
			// flash ROM, DRAM, MFP access, and 2nd cycle of int. ack.
			ready_n <= (
				(memarea_rom & inta_n & ~w_rn) | 
				(ioarea_mfp  & inta_n) | 
				(~inta_n & lock_n ) ) ? 1'b1 : 1'b0;
		end else if( bus_state == BUSSTATE_T2 && (memarea_rom & ~w_rn) == 1 ) begin
			ready_n <= ready_n & (a0_rom | pclk);
		end else if( bus_state == BUSSTATE_T1 ) begin
			ready_n <= 1;
		end else begin
			ready_n <= (ready_n & cs_rom_n & cs_ram_n & mfp_dtack_n);
		end
	end
	
	reg r_reset_n;
	always @(posedge clk2) begin
		r_reset_n <= reset_async_n;
		reset   <= r_reset_n;
	end
	
endmodule

