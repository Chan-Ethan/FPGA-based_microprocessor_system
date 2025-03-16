`timescale 1ns / 1ps


module Counter(
    Reset,//to reset counter state
    CLK,
    ENABLE_IN,//to enable counting
    COUNT,//counter itself
    TRIG_OUT//trigger signal that indicates counter reached to the max value and started counting again from 0
    );
	 
    parameter Counter_Width = 8;//size of the counter register
    parameter Counter_Max = 192;//max number that counter will count up to
 
    input Reset;
    input CLK;
    input ENABLE_IN;
    output [Counter_Width-1:0] COUNT;
    output TRIG_OUT;
 
    reg [Counter_Width-1:0] Counter=0;//counter register to store counter count
    reg TriggerOut;//to hold trigger flag
	 
    //counting process
    always@(posedge CLK or posedge Reset) begin
      if(Reset)//if reset signal is high set counter to 0
         Counter <= 0;
      else begin
         if (ENABLE_IN) begin//if reset low and enable high check counter status
            if(Counter==Counter_Max) begin//if counter at its max value, reset it and raise the trigger flag
               Counter<=0;
               TriggerOut<=1;
            end
            else begin//if counter is not at its maximum, increment counter and keep trigger flag low
               Counter<=Counter+1;
               TriggerOut<=0;
            end
         end
         else begin//if enable is low, reset everything and wait for enable signal to be high
            Counter<=0;
            TriggerOut<=0;
         end   
      end
    end
	
	assign COUNT = Counter;//assign counter register to the output
	assign TRIG_OUT = TriggerOut;//assign trigger to the output

endmodule