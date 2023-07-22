module interrupt_controller #(
	parameter int   NUM_OF_IRQS = 8   ,
	parameter logic ASYNC_MODE  = 1'b0  // In asynchronous mode, the interrupt output is simply an OR of the masked irqs
) (
	input  logic                   clk      ,
	input  logic                   rst_n    ,

	input  logic [NUM_OF_IRQS-1:0] irq      , // Interrupt requests
	input  logic [NUM_OF_IRQS-1:0] ier      , // Interrupt enable register
	input  logic [NUM_OF_IRQS-1:0] isr_clear, // Status clear command
	output logic [NUM_OF_IRQS-1:0] isr      , // Interrupt status register
	
	output logic                   inter      // Output interrupt
);

	// Definitions

	logic [NUM_OF_IRQS-1:0] masked_irqs;
	logic [NUM_OF_IRQS-1:0] new_isr    ;

	// Logic

	always_comb begin : proc_calc_isr
		masked_irqs = irq & ier;

		new_isr = isr & ~isr_clear; // Retain previous value, unless requested clear
		new_isr |= masked_irqs; // Update isr according to incomming irqs

	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_isr
		if(~rst_n) begin
			isr <= {NUM_OF_IRQS{1'b0}};
		end else begin
			isr <= new_isr;
		end
	end

	assign inter = (ASYNC_MODE ? |masked_irqs : |isr);

endmodule : interrupt_controller
