module apb_controller(input Hclk,Hresetn,valid,Hwrite,Hwrite_reg,
                      input [2:0]tsel,
                      input [31:0]Hwdata1,Hwdata2,Haddr1,Haddr2,
                      output reg Hreadyout,
                      output reg Penable,Pwrite,
                      output reg [31:0]Pwdata,Paddr,
                      output reg [2:0]Psel,
                      output reg [1:0]Hresp );


parameter ST_IDLE    =  3'b000,
          ST_READ    =  3'b001,
          ST_WWAIT   =  3'b010,
          ST_WRITE   =  3'b011,
          ST_WRITEP  =  3'b100,
          ST_RENABLE =  3'b101,
          ST_WENABLE =  3'b110,
          ST_WENABLEP=  3'b111;


reg [2:0]STATE,N_STATE;
//reg flag;

////////present state logic//////////////////
always@(posedge Hclk or negedge Hresetn)
 begin
   if(!Hresetn)
       STATE <= ST_IDLE;
    
   else
       STATE <= N_STATE;
 end


///////////////next state logic//////////////////
always@(*)
  begin
             N_STATE=ST_IDLE;
   
        case(STATE)
           ST_IDLE  :   begin
                          if(valid==1'b0)
                            N_STATE = ST_IDLE;
                         
                          else if(valid==1'b1 && Hwrite==1'b1)
                            N_STATE = ST_WWAIT;
                    
                          else if(valid==1'b1 && Hwrite==1'b0)
                            N_STATE = ST_READ;
                        end
 
           ST_READ   :   N_STATE = ST_RENABLE;
     
           ST_WWAIT  :  begin
                         if(valid)
                           N_STATE = ST_WRITEP;
                         else
                           N_STATE = ST_WRITE;
                      end
       
           ST_WRITE  :  begin
                        if(valid)
                           N_STATE = ST_WENABLEP;
                         else
                           N_STATE = ST_WENABLE;
                       end
        

           ST_WRITEP  :   N_STATE = ST_WENABLEP;
      
           ST_RENABLE  :  begin
                        if(valid==1'b0)
                         N_STATE = ST_IDLE;
                  
                        else if(valid==1'b1 && Hwrite==1'b0)
                         N_STATE = ST_READ;
                   
                        else if(valid==1'b1 && Hwrite==1'b1)
                         N_STATE =ST_WWAIT;
                      end

           ST_WENABLE : begin
                       if(valid==1'b0)
                         N_STATE = ST_IDLE;
           
                       else if(valid==1'b1 && Hwrite==1'b0)
                         N_STATE = ST_READ;
  
                       else if(valid==1'b1 &&  Hwrite==1'b1)
                         N_STATE = ST_WWAIT;
                     end
 
            ST_WENABLEP : begin
                       if(Hwrite_reg==1'b0)
                          N_STATE = ST_READ;
         
                       else if(valid==1'b0 && Hwrite_reg==1'b1)
                          N_STATE = ST_WRITE;
 
                        else if(valid==1'b1 && Hwrite_reg==1'b1)
                           N_STATE = ST_WRITEP;
                     end

     
        endcase
 end
                                              
 

///////////////////////output logic//////////////////////////
always@(posedge Hclk or negedge Hresetn)
//always@(*)
 begin
   if(!Hresetn)
      begin
         Hreadyout = 1'b0;
         Hresp     = 2'b00;         
         Penable   = 1'b0;
         Pwrite    = 1'b0;
         Pwdata    =32'd0;
         Paddr     = 1'b0;
         Psel      = 3'b000;
       end

    else
      begin
         Hreadyout = 1'b0;
         Hresp     = 2'b00;
        // Pwdata    = 32'd0;
         Penable   = 1'b0;
         Pwrite    = 0;
         //Paddr     = 0;
         Psel      = 3'b000;

       case(STATE)
            ST_IDLE:  begin
                         Psel		= 1'b0;
                         Penable	= 1'b0;
                         Hreadyout      = 1'b1;
                         Pwrite         = 0;
                      end
    
            ST_READ :  begin
		       Pwrite   =  1'b0;
                       // Penable  =  1'b1; 

                        Paddr    =  Haddr2;
                         Psel    =  tsel;
                        Hreadyout=  1'b0;
                                                   
                      end

           ST_WWAIT :  begin
                        Hreadyout	= 1;
                        Psel		= 0;
                          Pwrite=0;
                        // Paddr = Haddr2;
                        // Pwdata = Hwdata1;
                       end
              
            ST_WRITE : begin
                        Psel  		=   tsel;
                        Pwrite          =    1;
                        Penable         =    0;
                        Paddr           =   Haddr1;
                        Pwdata 		=   Hwdata1;
                        Hreadyout      =   1'b1;
                     end

            ST_WRITEP : begin
                       Paddr		=   Haddr2;
                       Psel		=   tsel;
                       Pwrite           =  1;
		       Hreadyout	=   1'b0;
                      	Pwdata = Hwdata1;
		/*  @(posedge Hclk)
	if(flag== 1)
		           begin
			     Paddr = Haddr1;                 
		        	end
			else
	                    begin
			     Paddr = Haddr2;
		      	end
*/
                     end

            ST_RENABLE : begin
			              Penable		=   1'b1;
                      // Hrdata           <=   Prdata;
                       Paddr            =  Haddr2;
                       Pwrite		=   1'b0;
                       Hreadyout	=   1'b1;
                     end

            ST_WENABLE : begin
                       Penable		=   1'b1;
                       Pwrite		=   1'b1;
                       Psel  		=   tsel;
                       Paddr            =   Haddr1;
                       Pwdata           =   Hwdata1;
                       Hreadyout        =   1'b1;
                     end
 
            ST_WENABLEP : begin
                        Pwrite		=   1'b1;
		         Penable	=  1'b1;
                       Paddr            =   Haddr2;
                       Pwdata           =   Hwdata2;
			if(Hwrite_reg)
                       Hreadyout	=  1'b1;
			else
			Hreadyout       = 0;
			
                      end
        endcase
     end
  end
//assign Pwdata=Hwdata;

/*
always@(posedge Hclk)
begin
if(STATE == ST_WWAIT)
flag <= 1;
else
flag <= 0;
end
*/
endmodule
                      
                       
          





		  

       

