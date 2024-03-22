module VGA_tb();

//Stimulus signals
logic clk, rst_n;

logic imgreg;
logic vsync;
logic hsync;
logic green;

int t1;
int t2;
int actual_time;


//////////////////////
// Instantiate VGA  //
//////////////////////
VGA_logic iDUT(.clk(clk), .rst_n(rst_n), .img_reg(imgreg), .hsync(hsync), .vsync(vsync), .green(green));

always begin
	clk = 0;		//Init signals and reset
	rst_n = 0;
	
	
	@(negedge clk)
	rst_n = 1;		//Deassert reset
	
	//Set Stimulus
	
	repeat(800) begin
	imgreg = 1;
	
	@(posedge green);
	t1 = $time;		//Get time info
	
	//Check that active period is correct length
	@(negedge green);
	t2 = $time;
	actual_time = (t2-t1)/10;
	if(actual_time !== 640)
		$display("An error has occured with the active window: %i", actual_time);
		
	t1 = $time;
	
	@(negedge hsync);
	t2 = $time;
	
	actual_time = (t2-t1)/10;
	if(actual_time !== 16)	//get number of clock periods that have elapsed (pixels)
		$display("An error has occured with front porch timing: %i", actual_time);
		
	t1 = $time;
		
	@(posedge hsync);
	t2 = $time;
	actual_time = (t2-t1)/10;
	if(actual_time !== 96)	//get number of clock periods that have elapsed (pixels)
		$display("An error has occured with sync pulse timing: %i", actual_time);
		
	t1 = $time;
	
	@(posedge green);
	t2 = $time;
	
	actual_time = (t2-t1)/10;
	if(actual_time !== 48)	//get number of clock periods that have elapsed (pixels)
		$display("An error has occured with back porch timing: %i", actual_time);
	
	end
	
	force
	
	$stop;
	
	
end



/////////////
//  Clock  //
/////////////
always #5 clk <= ~clk;

always 
	@(posedge vsync)
	$display("itfuckingworks: %t", $time);

endmodule
