module bridge_top(input Hclk,Hresetn,Hwrite,Hreadyin,
                  input [1:0]Htrans,
                  input [31:0]Hwdata,Haddr,Prdata,
                  output Hreadyout,Penable,Pwrite,
                  output [1:0]Hresp,
                  output [2:0]Psel,
                  output [31:0]Pwdata,Hrdata,Paddr) ;
 
 wire valid,Hwrite_reg;
 wire [31:0]Hwdata1,Hwdata2,Haddr1,Haddr2;
 wire [2:0]tsel;


ahb_slave_interface AHB(Htrans,Hwrite,Hreadyin,Hclk,Hresetn,Hwdata,Prdata,Haddr,Hrdata,Hwdata1,Hwdata2,Haddr1,Haddr2,tsel,valid,Hwrite_reg);


                  
apb_controller APB(Hclk,Hresetn,valid,Hwrite,Hwrite_reg,tsel,Hwdata1,Hwdata2,Haddr1,Haddr2,Hreadyout,Penable,Pwrite,Pwdata,Paddr,Psel,Hresp);

endmodule

                                               

