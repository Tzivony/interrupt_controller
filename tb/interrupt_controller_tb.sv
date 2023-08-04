module interrupt_controller_tb ();
	localparam int   NUM_OF_IRQS = 8   ;
	localparam logic ASYNC_MODE  = 1'b1;

	logic                   clk       = 1'b1;
	logic                   rst_n     = 1'b1;
	logic [NUM_OF_IRQS-1:0] irq             ;
	logic [NUM_OF_IRQS-1:0] ier             ;
	logic [NUM_OF_IRQS-1:0] isr_clear       ;
	logic [NUM_OF_IRQS-1:0] isr             ;
	logic                   inter           ;

	interrupt_controller #(
		.NUM_OF_IRQS(NUM_OF_IRQS),
		.ASYNC_MODE (ASYNC_MODE )
	) i_interrupt_controller (
		.clk      (clk      ),
		.rst_n    (rst_n    ),
		.irq      (irq      ),
		.ier      (ier      ),
		.isr_clear(isr_clear),
		.isr      (isr      ),
		.inter    (inter    )
	);

	always begin
		#5 clk = ~clk;
	end

	initial begin
		#10 rst_n = ~rst_n;
	end

	initial begin
		@(negedge rst_n);

		ier <= {NUM_OF_IRQS{1'b0}};
		irq <= {NUM_OF_IRQS{1'b0}};
		@(posedge clk);

		irq <= NUM_OF_IRQS'(1);
		@(posedge clk);

		ier <= NUM_OF_IRQS'(1);
		@(posedge clk);

		irq <= NUM_OF_IRQS'(0);
		@(posedge clk);

		$stop;
	end



endmodule : interrupt_controller_tb
