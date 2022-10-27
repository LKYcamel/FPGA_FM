module	fm (
	input wire 				sys_clk,		//系统时钟  50M
	input wire				sys_rst,		//复位  低电平有效
	input wire	[7:0]		ad_data,		//ad采集的八位数据
	
	output wire 			led,			//数据有效的标志
	output wire				ad_clk,			//高速AD的时钟
	output wire 			da_clk,			//高速DA的时钟
	output wire	[13:0]		da_data			//输出的14位数据
);

	//fm_data
	wire		[7:0]		fm_data;

	//PLL
	wire					clk1;
	wire					clk2;

	//NCO
	wire signed [9:0]		fsin_o;
	wire signed [9:0]		fcos_o;
	wire 					valid;

	//MULT
	wire signed [17:0]		mult_sin;
	wire signed [17:0]		mult_cos;

	//fir
	wire 					valid_sin;
	wire 					valid_cos;
	wire 		[27:0]		fir_sin;
	wire 		[27:0]		fir_cos;
	
	//reg
	reg 		[27:0]		fir_sin_reg;
	reg 		[27:0]		fir_cos_reg;

	
	//FINALL
	wire signed [55:0]		mult_reg_1;
	wire signed [55:0]		mult_reg_2;
	wire signed [55:0]		finall_result;
	
	
	//FINALL_FIR
	wire  		[11:0]		finall_result_fir;
	wire 		[27:0]		finall_fir_out;
	wire					valid_finall;
	
	//out_tmp
	wire		[13:0]		da_data_tmp;


	//输出
	//AD DA时钟驱动
	assign da_clk = clk2;
	assign ad_clk = clk1;
	//data flag
	assign led = valid_finall;
	//data_out
	//将滤波数据截位并且转换成无符号数输出
	assign da_data_tmp = finall_fir_out[25:12];
	assign da_data = da_data_tmp + 'd8192; 


	//将数据转换成有符号数
	assign fm_data = ad_data - 'd128;
	//////////////////////////////
	//////////////////////////////
	//FM解调
	
	//产生1M的IQ信号
	nco_st	nco_inst(
		.phi_inc_i(16'd1311),
		.clk(sys_clk),
		.reset_n(sys_rst),
		.clken(1'b1),
		.fsin_o(fsin_o),
		.fcos_o(fcos_o),
		.out_valid(valid)
	);
	
	//将FM信号与IQ信号混频
	mult	mult_inst_1 (
	.dataa ( fm_data ),
	.datab ( fsin_o ),
	.result ( mult_sin )
	);

	mult	mult_inst_2 (
	.dataa ( fm_data ),
	.datab ( fcos_o ),
	.result ( mult_cos )
	);

	//分别进行滤波
	fir	fir_inst_sin(
		.clk				(clk1),
		.reset_n			(sys_rst),
		.ast_sink_data		(mult_sin[17:6]),
		.ast_sink_valid		(1'b1),
		.ast_source_ready	(1'b1),
		.ast_sink_error		(2'b0),
		.ast_source_data	(fir_sin),
		.ast_sink_ready		(),
		.ast_source_valid	(valid_sin),
		.ast_source_error	()
		);
	//分别进行滤波
	fir	fir_inst_cos(
		.clk				(clk1),
		.reset_n			(sys_rst),
		.ast_sink_data		(mult_cos[17:6]),
		.ast_sink_valid		(1'b1),
		.ast_source_ready	(1'b1),
		.ast_sink_error		(2'b0),
		.ast_source_data	(fir_cos),
		.ast_sink_ready		(),
		.ast_source_valid	(valid_cos),
		.ast_source_error	()
		);
		
		
	//将滤波得到的数据进行打拍
	always @ (posedge clk1 or negedge sys_rst) begin
		if (~sys_rst)
			fir_sin_reg <= 'b0;
		else
			fir_sin_reg <= fir_sin;
	end

	always @ (posedge clk1 or negedge sys_rst) begin
		if (~sys_rst)
			fir_cos_reg <= 'b0;
		else
			fir_cos_reg <= fir_cos;
	end

	//最后调用乘法器根据公式计算得到数据
	mult1	mult1_inst1 (
	.dataa ( fir_sin ),
	.datab ( fir_cos_reg ),
	.result ( mult_reg_1 )
	);

	mult1	mult1_inst2 (
	.dataa ( fir_cos ),
	.datab ( fir_sin_reg ),
	.result ( mult_reg_2 )
	);
	
	
	assign finall_result = mult_reg_1 - mult_reg_2;
	
	//进行截位  并且滤波
	assign finall_result_fir = finall_result[42:31];
	
	fir	fir_inst_finall(
		.clk				(clk1),
		.reset_n			(sys_rst),
		.ast_sink_data		(finall_result_fir),
		.ast_sink_valid		(1'b1),
		.ast_source_ready	(1'b1),
		.ast_sink_error		(2'b0),
		.ast_source_data	(finall_fir_out),
		.ast_sink_ready		(),
		.ast_source_valid	(valid_finall),
		.ast_source_error	()
		);
		
		
	//调用PLL核
	pll	pll_inst (
	.inclk0 ( sys_clk ),
	.c0 ( clk1 ),	//10M
	.c1 ( clk2 ),	//10M
	.locked (  )
	);

endmodule