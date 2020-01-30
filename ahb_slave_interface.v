module ahb_slave_interface(
                           input [1:0]Htrans,
                           input Hwrite,Hreadyin,Hclk,Hresetn,
                           input [31:0]Hwdata,Prdata,
                           input [31:0]Haddr,
                           output [31:0]Hrdata,
                           output reg [31:0]Hwdata1,Hwdata2,Haddr1,Haddr2,
                           output reg [2:0]tsel,
                           output reg valid,Hwrite_reg
                                );

wire interrupt,counter_timer,remap;

always@(posedge Hclk or negedge Hresetn)
  begin
    if(~Hresetn)
      begin
       Hwdata1<=0;       
       Hwdata2<=0;
       Haddr1<=0;
       Haddr2<=0;
      end
    else
      begin
        Hwdata1<=Hwdata;
        Hwdata2<=Hwdata1;         
        Haddr1<=Haddr;
        Haddr2<=Haddr1;
        Hwrite_reg<=Hwrite;
      end
end



always@(*)
 begin
    if(Hreadyin && Haddr>=32'h80000000 && Haddr<=32'h8C000000 && (Htrans==2'b10 || Htrans==2'b11))
      valid<=1'b1;
    else
      valid<=1'b0;
   
 end  
 

assign interrupt=(Haddr>=32'h80000000 && Haddr<32'h84000000)?1:0;
assign counter_timer=(Haddr>=32'h84000000 && Haddr<32'h88000000)?1:0;
assign remap=(Haddr>=32'h88000000 && Haddr<32'h8C000000)?1:0;

always@(*)
 begin
   case({remap,counter_timer,interrupt})
        3'b001: tsel=3'b001;
        3'b010: tsel=3'b010;
        3'b100: tsel=3'b100;
       default: tsel=3'b000;
      
  endcase
end

assign  Hrdata=Prdata;
//assign  Hresp=2'b00;
 
endmodule
     

