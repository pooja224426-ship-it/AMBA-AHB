module apb_interface(input Penable,Pwrite,
                      input [31:0]Pwdata,Paddr,
                      input [2:0]Psel,
                      output Penable_out,Pwrite_out,
                      output [2:0]Psel_out,
                      output [31:0]Pwdata_out,Paddr_out,
                      output reg [31:0]Prdata);
                  


always@(*)
  begin

    if(Penable && ~Pwrite)
       Prdata = {$random} ;
     
	  
	  else
    //if(~Penable && Pwrite) 
        Prdata = 32'd0;

    end


assign Penable_out = Penable;
assign Pwrite_out  = Pwrite;
assign Psel_out    = Psel;
assign Pwdata_out  = Pwdata;
assign Paddr_out   = Paddr;

endmodule   

