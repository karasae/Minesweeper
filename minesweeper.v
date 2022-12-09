module minesweeper(clk, rst, conf_mov, diff_sel, userx, usery, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK, test);

	input clk, rst;
	output [9:0] VGA_R;
	output [9:0] VGA_G;
	output [9:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK;
	output VGA_SYNC;
	output VGA_CLK;
	
	output reg test;
	
	reg [6:0] x;
	reg [6:0] y;
	reg [3:0] x_in;
	reg [3:0] y_in;
	reg [1:0] x_sc;
	reg [1:0] y_sc;
	reg plot;
	
	reg [3:0] curr_elem;
	reg [2:0] pix_col;
	
	reg [2:0] plc_x;
	reg [2:0] plc_y;
	
	input [6:0] userx;
	input [6:0] usery;
	input conf_mov;
	input [1:0] diff_sel;
	
	reg init_srand;
	wire [15:0] rand_num;
	
	reg [1:0]curr_diff;
	reg [4:0] diff_h;
	reg [6:0] diff_w;
	reg [8:0] diff_size;
	reg [4:0] diff_mn_num;
	
	reg [7:0] num_mines;
	
	reg [6:0] boardx;
	reg [6:0] boardy;
	reg [4:0] genx;
	reg [4:0] geny;
	
	reg [3:0] bd_in;
	wire [3:0] ez_bd_out;
	reg bd_wren;
	
	reg [3:0] old_bd_val;
	
	wire [2:0] blank_pix_col;
	wire [2:0] one_pix_col;
	wire [2:0] two_pix_col;
	wire [2:0] three_pix_col;
	wire [2:0] four_pix_col;
	wire [2:0] five_pix_col;
	wire [2:0] six_pix_col;
	wire [2:0] seven_pix_col;
	wire [2:0] eight_pix_col;
	wire [2:0] flag_pix_col;
	
	parameter	WIDTH = 9'd320,
					HEIGHT = 9'd240;
					
	parameter	EZ_BD_H = 5'd9,
					EZ_BD_W = 5'd9,
					EZ_BD_SIZE = 9'd81,
					EZ_MN_NUM = 5'd10,
					EZ_DIFF = 2'd0;
	
	reg [5:0] S;
	reg [5:0] NS;
	
	parameter	START_REV = 6'd13,
					Y_CON = 6'd1,
					X_CON = 6'd2,
					PLOT = 6'd3,
					Y_IN_CON = 6'd20,
					X_IN_CON = 6'd21,
					X_IN_INC = 6'd22,
					Y_IN_INC = 6'd23,
					Y_SC_CON = 6'd24,
					X_SC_CON = 6'd25,
					Y_SC_INC = 6'd26,
					X_SC_INC = 6'd27,
					X_INC = 6'd4,
					Y_INC = 6'd5,
					EXIT = 6'd6,
					START_GEN = 6'd7,
					MN_CON = 6'd8,
					GEN_X = 6'd9,
					GEN_Y = 6'd10,
					LOC_CHK = 6'd11,
					PLC_MN_I = 6'd12,
					PLC_MN_F = 6'd28,
					INIT_RAND = 6'd0,
					PLC_Y_CON = 6'd14,
					PLC_X_CON = 6'd15,
					CHK_INC_MN_I = 6'd16,
					CHK_INC_MN_F = 6'd31,
					INC_MN = 6'd17,
					INC_MN_C = 6'd 31,
					PLC_X_INC = 6'd18,
					PLC_Y_INC = 6'd19,
					WAIT_MOV = 6'd29,
					WR_BOARD = 6'd30;
	
	always @(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
			S <= INIT_RAND;
		else
			S <= NS;
	end
	
	always @(*)
	begin
		case (S)
			INIT_RAND: NS = START_REV; //CHANGE THIS BACK!!
			START_GEN:
			begin
				if(conf_mov == 1'b0)
					NS = MN_CON;
				else
					NS = START_GEN;
			end
			MN_CON:
			begin
				if(num_mines >= diff_mn_num)
					NS = START_REV;
				else
					NS = GEN_X;
			end
			GEN_X: NS = GEN_Y;
			GEN_Y: NS = LOC_CHK;
			LOC_CHK:
			begin
				if((curr_diff == EZ_DIFF) && (ez_bd_out != 4'd9))
				begin
					if((userx + 1 < genx) || (userx > genx + 1) || (usery + 1 < geny) || (usery > geny + 1))
						NS = PLC_MN_I;
					else
						NS = GEN_X;
				end
				else
					NS = GEN_X;
			end
			PLC_MN_I: NS = PLC_MN_F;
			PLC_MN_F: NS = PLC_Y_CON;
			PLC_Y_CON:
			begin
				if(plc_y <= 2)
					NS = PLC_X_CON;
				else
					NS = START_REV;
			end
			PLC_X_CON:
			begin
				if(plc_x <= 2)
					NS = CHK_INC_MN_I;
				else
					NS = PLC_Y_INC;
			end
			CHK_INC_MN_F:
			begin
				if(curr_diff == EZ_DIFF)
					if((boardx >= 0) && (boardx < EZ_BD_W) && (boardy >= 0) && (boardy < EZ_BD_H) && (ez_bd_out != 9))
						NS = INC_MN;
					else
						NS = PLC_X_INC;
			end
			CHK_INC_MN_I: NS = CHK_INC_MN_F;
			INC_MN: NS = INC_MN_C;
			INC_MN_C: NS = PLC_X_INC;
			PLC_X_INC: NS = PLC_X_CON;
			PLC_Y_INC: NS = PLC_Y_CON;
			//problem above here
			START_REV: NS = Y_CON;
			Y_CON:
			begin
				if(y < diff_h)
					NS <= X_CON;
				else
					NS = WAIT_MOV;//EXIT;
			end
			X_CON:
			begin
				if(x < diff_w)
					NS = Y_IN_CON;
				else
					NS = Y_INC;
			end
			Y_IN_CON:
			begin
				if(y_in < 9)
					NS = X_IN_CON;
				else
					NS = X_INC;
			end
			X_IN_CON:
			begin
				if(x_in < 9)
					NS = Y_SC_CON;
				else
					NS = Y_IN_INC;
			end
			Y_SC_CON:
			begin
				if(y_sc < 3)
					NS = X_SC_CON;
				else
					NS = X_IN_INC;
			end
			X_SC_CON:
			begin
				if(x_sc < 3)
					NS = PLOT;
				else
					NS = Y_SC_INC;
			end
			X_SC_INC: NS = X_SC_CON;
			Y_SC_INC: NS = Y_SC_CON;
			X_IN_INC: NS = X_IN_CON;
			Y_IN_INC: NS = Y_IN_CON;
			PLOT: NS = X_SC_INC;
			X_INC: NS = X_CON;
			Y_INC: NS = Y_CON;
			WAIT_MOV:
			begin
				if(conf_mov == 1'b1)
					NS = WAIT_MOV;
				else
					NS = WR_BOARD;
			end
			WR_BOARD: NS = START_REV;//PLC_Y_CON;
			EXIT: NS = EXIT;
		endcase
	end
	
	always @(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
		begin
			plot <= 0;
			x <= 9'd0;
			y <= 9'd0;
			init_srand <= 1;
			test <= 0;
		end
		else
		begin
			case (S)
				INIT_RAND:
				begin
					plot <= 0;
					num_mines <= 0;
					bd_wren <= 0;
					init_srand <= 0;
					test <= 0;
				end
				START_GEN:
				begin
					plot <= 0;
					num_mines <= 0;
					bd_wren <= 0;
					init_srand <= 0;
					curr_diff <= diff_sel;
				end
				MN_CON:
				begin
					bd_wren <= 0;
					//test <= 1;
				end
				GEN_X: genx <= rand_num[4:0];
				GEN_Y: geny <= rand_num[4:0];
				/*
				GEN_X: genx <= {rand_num} % diff_w;
				GEN_Y: geny <= {rand_num} % diff_h;
				*/
				LOC_CHK: //test <= 1;
				PLC_MN_I: // I don't know why, but it always gets stuck here
				begin
					plc_x <= 0;
					plc_y <= 0;
					bd_wren <= 1;
					//bd_wren <= 1;
					//num_mines <= num_mines + 1;
					//test <= 1;
				end
				PLC_MN_F:
				begin
					bd_in <= 9;
					boardx <= genx;
					boardy <= geny;
					//bd_wren <= 1;
					num_mines <= num_mines + 1;
					test <= 1;
				end
				PLC_Y_CON:
				begin
					bd_wren <= 0;
					plc_x <= 0;
					//test <= 1;
				end
				PLC_X_CON:
				begin
					bd_wren <= 0;
					//test <= 1;
					//boardx <= userx + plc_x - 1;
					//boardy <= usery + plc_y - 1;
				end
				CHK_INC_MN_I:
				begin
					boardx <= userx + plc_x - 1;
					boardy <= usery + plc_y - 1;
					//old_bd_val <= ez_bd_out;
				end
				CHK_INC_MN_F:
				begin
					//boardx <= userx + plc_x - 1;
					//boardy <= usery + plc_y - 1;
					old_bd_val <= ez_bd_out;
				end
				INC_MN:
				begin
					bd_wren <= 1;
					bd_in <= old_bd_val + 3'd1;
					//test <= 1;
				end
				INC_MN_C: bd_wren <= 0;
				PLC_X_INC:
				begin
					bd_wren <= 0;
					plc_x <= plc_x + 1;
					//test <= 1;
				end
				PLC_Y_INC:
				begin
					bd_wren <= 0;
					plc_y <= plc_y + 1;
				end
				
				//problem above here
				START_REV:
				begin
					bd_wren <= 0;
					plot <= 0;
					x <= 9'd0;
					y <= 9'd0;
					x_in <= 0;
					y_in <= 0;
					plc_x <= 0;
					plc_y <= 0;
					//test <= 1;
				end
				X_INC:
				begin
					x <= x + 1;
					plot <= 0;
					x_in <= 0;
					y_in <= 0;
				end
				Y_INC: 
				begin
					y <= y + 1;
					plot <= 0;
					x_in <= 0;
					y_in <= 0;
				end
				Y_IN_CON: x_in <= 0;
				X_IN_CON:
				begin
					x_sc <= 0;
					y_sc <= 0;
					//test <= 1;
				end
				X_IN_INC:
				begin
					plot <= 0;
					x_in <= x_in + 1;
				end
				Y_IN_INC: y_in <= y_in + 1;
				X_SC_INC:
				begin
					x_sc <= x_sc + 1;
					plot <= 0;
				end
				Y_SC_INC: y_sc <= y_sc + 1;
				Y_SC_CON: x_sc <= 0;
				X_SC_CON:
				begin
					//test <= 1;
					//boardx <= x;
					//boardy <= y;
					bd_wren <= 0;
				end
				PLOT: //change when displayed board changes //doesn't work rn, need to change it to also index through the art arrays
				begin
					plot <= 1;
					boardx <= x;
					boardy <= y;
					//test <= 1;
				end
				X_CON:
				begin
					plot <= 0;
					//test <= 1;
				end
				Y_CON:
				begin
					plot <= 0;
					x <= 0;
				end
				WAIT_MOV:
				begin
				
				end
				WR_BOARD:
				begin
					boardx <= userx;
					boardy <= usery;
					plc_x <= 0;
					plc_y <= 0;
					
					bd_wren <= 1;
					bd_in <= 9;
				end
				EXIT:
				begin
					plot <= 0;
					//test <= 1;
				end
			endcase
		end
	end
	
	always @(*)
	begin
		curr_elem = ez_bd_out;
		case(curr_diff)
			EZ_DIFF:
			begin
				diff_h = 5'd9;
				diff_w = 7'd9;
				diff_size = 9'd81;
				diff_mn_num = 5'd10;
			end
		endcase
		case(curr_elem)
			4'd0: pix_col = blank_pix_col;
			4'd1: pix_col = one_pix_col;
			4'd2: pix_col = two_pix_col;
			4'd3: pix_col = three_pix_col;
			4'd4: pix_col = four_pix_col;
			4'd5: pix_col = five_pix_col;
			4'd6: pix_col = six_pix_col;
			4'd7: pix_col = seven_pix_col;
			4'd8: pix_col = eight_pix_col;
			4'd9: pix_col = mine_pix_col;
			4'd10: pix_col = flag_pix_col;
		endcase
	end
	vga_adapter myVGA(rst, clk, pix_col, (x*27+ x_in*3 + x_sc), (y*27 + y_in*3 + y_sc), plot, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK); // currently not functional
	ezboard my_ez_bd((boardy*diff_w + boardx), clk, bd_in, bd_wren, ez_bd_out);
	lfsr mylfsr(clk, rst, 16'hA1F2, init_srand, rand_num);
	pixel_blank myblank(y_in*9 + x_in, clk, 0, 0, blank_pix_col);
	pixel_one myone(y_in*9 + x_in, clk, 0, 0, one_pix_col);
	pixel_two mytwo(y_in*9 + x_in, clk, 0, 0, two_pix_col);
	pixel_three mythree(y_in*9 + x_in, clk, 0, 0, three_pix_col);
	pixel_four myfour(y_in*9 + x_in, clk, 0, 0, four_pix_col);
	pixel_five myfive(y_in*9 + x_in, clk, 0, 0, five_pix_col);
	pixel_six mysix(y_in*9 + x_in, clk, 0, 0, six_pix_col);
	pixel_seven myseven(y_in*9 + x_in, clk, 0, 0, seven_pix_col);
	pixel_eight myeight(y_in*9 + x_in, clk, 0, 0, eight_pix_col);
	pixel_mine mymine(y_in*9 + x_in, clk, 0, 0, mine_pix_col);
	pixel_flag myflag(y_in*9 + x_in, clk, 0, 0, flag_pix_col);
endmodule
