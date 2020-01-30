smodule ahb_master( input Hclk,Hresetn,Hreadyout,
		   input [1:0]Hresp,
                   input [31:0]Hrdata,                  
 		   output reg [1:0]Htrans,
                   output reg Hwrite,Hreadyin,
                   output reg [31:0]Hwdata,Haddr,
                   output reg [2:0]Hsize);


reg [2:0]Hburst;

integer i;

////////------------------------------constants for Hsize-------------//////////
parameter  BYTE      =  3'b001,
	   HALF_WORD =  3'b010,
           WORD      =  3'b100;



////////----------------------------constants for Htrans-------------//////////
parameter NON_SEQ  = 2'b10,
          SEQ      = 2'b11,
          IDLE     = 2'b00;



////////--------------------------constants for Hburst------------//////////////
parameter SINGLE        = 3'b000,
          INCR		= 3'b001,
          WRAP4		= 3'b010,
          INCR4		= 3'b011,
          WRAP8		= 3'b100,
          INCR8		= 3'b101,
          WRAP16	= 3'b110,
          INCR16	= 3'b111;


///---------------------------single write--------------------///////////////
task single_write;
  begin
    @(posedge Hclk)
      Htrans	= NON_SEQ;
      Haddr	= 32'h8200_0000;
      Hreadyin	= 1'b1;
      Hwrite	= 1'b1;       
      Hsize=BYTE;
     @(posedge Hclk)
		begin
		 case(Hsize)
		      BYTE  : begin
		             Hwdata={$random};
                              Htrans=IDLE;
			     end

		  HALF_WORD : begin
		              Hwdata={$random}%512;
		         	Htrans=IDLE;
			      end

		  WORD     : begin
		        	Hwdata={$random}%256;
			        Htrans=IDLE;
		        	end

		endcase

		end

 
  end
endtask


////-------------------------single read---------------------//////////

task single_read;

begin
@(posedge Hclk)
  Htrans    = NON_SEQ;
  Hreadyin  = 1'b1;
  Hwrite    = 1'b0;
  Haddr     = 32'h8200_0000;
  Hsize     = HALF_WORD;
@(posedge Hclk)
 begin
   case(Hsize)
          BYTE	 :begin
                   Htrans=IDLE;
		  end

	HALF_WORD:begin									
                   Htrans=IDLE;
                  end

	WORD     :begin
	           Htrans=IDLE;
		  end

		endcase

		end
		end
endtask


////-------------------------burst write------------------////////
task burst_write;
 begin
  @(posedge Hclk)
     Hwrite   = 1'b1;

    Htrans   = NON_SEQ;
      Hreadyin = 1'b1;
    
    Haddr    = 32'h8200_0000;	 
//Hwdata={$random};
    Hsize    = BYTE;
    Hburst   = INCR4;

   case(Hsize)


/////=================================   byte  =======================///////
     BYTE : begin
                 case(Hburst)
                                INCR  :  begin
                                      wait(Hreadyout)
                                      
                                  	 @(negedge Hclk)
                                   	Hwdata  =  {$random};
                                   	Htrans  =  SEQ;
                                   	Haddr   =  Haddr + 1'b1;
                                    
                                        Htrans  =  IDLE;
                                end
                               



                      WRAP4  :  begin
                                     
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = {Haddr[31:2],Haddr[1:0] + 1'b1};

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<2;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = {Haddr[31:2],Haddr[1:0] + 1'b1};
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
                                              @(posedge Hclk)
                              //                @(posedge Hclk)

                                              Htrans = IDLE;
                                      

                                      end


            
                       INCR4 : begin
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 1'b1;

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<2;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                Haddr  = Haddr + 1'b1;
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
                                              
                                              @(posedge Hclk)
                                     //         @(posedge Hclk)
                                              Htrans = IDLE;
                                      
                                 end
                           

                        
                      WRAP8  :  begin
                                       
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = {Haddr[31:3],Haddr[2:0] + 1'b1};

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<6;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = {Haddr[31:3],Haddr[2:0] + 1'b1};
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
                                                @(posedge Hclk)
                                      //        @(posedge Hclk)

                                              Htrans = IDLE;
                                      


                                end


            
                       INCR8 : begin
                                 
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 1'b1;

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<6;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = Haddr + 1'b1;
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
                                                   @(posedge Hclk)
                                    //          @(posedge Hclk)

                                              Htrans = IDLE;
                                      

                                       end
                                

                        

                         
                      WRAP16  :  begin
                                      
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = {Haddr[31:4],Haddr[3:0] + 1'b1};

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<14;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = {Haddr[31:4],Haddr[3:0] + 1'b1};
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
                                                @(posedge Hclk)
                                      //        @(posedge Hclk)

                                              Htrans = IDLE;
                                      

                                      

                                       end
                                 

            
                       INCR16 : begin
                                 
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 1'b1;

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<14;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = Haddr + 1'b1;
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
                                                @(posedge Hclk)
                                       //       @(posedge Hclk)

                                              Htrans = IDLE;
                                      

                                       end
                                 

                    endcase
              end
    

              
/////======================   half word =======================//////

HALF_WORD : begin
                 case(Hburst)
                                INCR  :  begin
                                      wait(Hreadyout)
                                      
                                  	 @(negedge Hclk)
                                   	Hwdata  =  {$random};
                                   	Htrans  =  SEQ;
                                   	Haddr   =  Haddr + 1'b1;
                                    
                                        Htrans  =  IDLE;
                                end
                               



                      WRAP4  :  begin
                                     
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = {Haddr[31:3],Haddr[2:1] + 1'b1,Haddr[0]};

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<2;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                   Haddr  = {Haddr[31:3],Haddr[2:1] + 1'b1,Haddr[0]};
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
                                                @(posedge Hclk)
                                     //         @(posedge Hclk)

                                              Htrans = IDLE;
                                      

                                      end


            
                       INCR4 : begin
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 2'd2;

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<2;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                Haddr  = Haddr + 2'd2;
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
                                                @(posedge Hclk)
                                   //           @(posedge Hclk)

                                              Htrans = IDLE;
                                      
                                 end
                           

                        
                      WRAP8  :  begin
                                       
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                           Haddr  = {Haddr[31:4],Haddr[3:1] + 1'b1,Haddr[0]};

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<6;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                Haddr  = {Haddr[31:4],Haddr[3:1] + 1'b1,Haddr[0]};
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
                                                   @(posedge Hclk)
                                        //      @(posedge Hclk)

                                              Htrans = IDLE;
                                      


                                end


            
                       INCR8 : begin
                                 
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 2'd2;

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<6;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = Haddr + 2'd2;
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
 						  @(posedge Hclk)
                                        //      @(posedge Hclk)

                                              Htrans = IDLE;
                                      

                                       end
                                

                        

                         
                      WRAP16  :  begin
                                      
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                           Haddr  = {Haddr[31:5],Haddr[4:1] + 1'b1,Haddr[0]};
					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<14;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = {Haddr[31:5],Haddr[4:1] + 1'b1,Haddr[0]};
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
					     @(posedge Hclk)
                                        //      @(posedge Hclk)

                                              Htrans = IDLE;
                                      

                                      

                                       end
                                 

            
                       INCR16 : begin
                                 
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 2'd2;

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<14;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = Haddr + 2'd2;
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
						  @(posedge Hclk)
                                           //   @(posedge Hclk)

                                              Htrans = IDLE;
                                      

                                       end
                                 

                    endcase
              end
    


      
///////=========================  word  ==========================///////
WORD : begin
                 case(Hburst)
                                INCR  :  begin
                                      wait(Hreadyout)
                                      
                                  	 @(negedge Hclk)
                                   	Hwdata  =  {$random};
                                   	Htrans  =  SEQ;
                                   	Haddr   =  Haddr + 1'b1;
                                    
                                        Htrans  =  IDLE;
                                end
                               



                      WRAP4  :  begin
                                     
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = {Haddr[31:4],Haddr[3:2] + 1'b1,Haddr[1:0]};

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<2;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                   Haddr  = {Haddr[31:4],Haddr[3:2] + 1'b1,Haddr[1:0]};
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
						  @(posedge Hclk)
                                   //           @(posedge Hclk)

                                              Htrans = IDLE;
                                      

                                      end


            
                       INCR4 : begin
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 3'd4;

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<2;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                Haddr  = Haddr + 3'd4;
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
						  @(posedge Hclk)
                                     //         @(posedge Hclk)

                                              Htrans = IDLE;
                                      
                                 end
                           

                        
                      WRAP8  :  begin
                                       
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                           Haddr  = {Haddr[31:5],Haddr[4:2] + 1'b1,Haddr[1:0]};

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<6;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                Haddr  = {Haddr[31:5],Haddr[4:2] + 1'b1,Haddr[1:0]};
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
						  @(posedge Hclk)
                                    //          @(posedge Hclk)

                                              Htrans = IDLE;
                                      


                                end


            
                       INCR8 : begin
                                 
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 3'd4;

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<6;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = Haddr + 3'd4;
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
						  @(posedge Hclk)
                                     //         @(posedge Hclk)

                                              Htrans = IDLE;
                                      

                                       end
                                

                        

                         
                      WRAP16  :  begin
                                      
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                           Haddr  = {Haddr[31:6],Haddr[5:2] + 1'b1,Haddr[1:0]};
					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<14;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = {Haddr[31:6],Haddr[5:2] + 1'b1,Haddr[1:0]};
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
						  @(posedge Hclk)
                                      //        @(posedge Hclk)

                                              Htrans = IDLE;
                                      

                                      

                                       end
                                 

            
                       INCR16 : begin
                                 
                                            @(posedge Hclk)
                                            wait(Hreadyout)
                                            Hwdata = {$random};


                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 3'd4;

					 wait(Hreadyout)
                                         @(posedge Hclk)
   					 Hwdata =  {$random};

                                         
                                       for(i=0;i<14;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = Haddr + 3'd4;
                                              
                                             wait(Hreadyout)
                                              @(posedge Hclk)
                                                Hwdata={$random};
					     end
                                           
                                             Hwdata={$random};
						  @(posedge Hclk)
                                         //     @(posedge Hclk)

                                              Htrans = IDLE;
                                      

                                       end
                                 

                    endcase
              end
    

              



      endcase
    
end
endtask
 



//////////++++++++++++++++++++++++++++++++  BURST READ  +++++++++++++++++++++++++++++++/////////


task burst_read;
  begin
  //@(posedge Hclk)
     Hwrite   = 1'b0;
     Hreadyin = 1'b1;
     Htrans   = NON_SEQ;
     Haddr    = 32'h8500_0000;
     
     Hsize    = WORD;
    
    Hburst    = INCR16;

@(posedge Hclk)
begin
  case(Hsize)
       
  //////======================   byte  =====================/////
       BYTE :  begin
                     
                case(Hburst)
                
                 WRAP4 :  begin 
                               // @(posedge Hclk)
			        wait(Hreadyout)
                              	@(posedge Hclk)
                              //  @(posedge Hclk)
                                 Htrans = SEQ;
                                 Haddr  = {Haddr[31:2],Haddr[1:0]+1'b1};
                           
                               // @(posedge Hclk)
                              //  @(posedge Hclk)
                                //  wait(Hreadyout)
                                 
                                for(i=0;i<=2;i=i+1)
                                 begin
                                  // @(posedge Hclk)
                                 wait(Hreadyout)
                                 @(posedge Hclk)
                                 @(posedge Hclk)
                                   Htrans = SEQ; 
                                   Haddr = {Haddr[31:2],Haddr[1:0]+1'b1};
                                  //  Htrans = SEQ;

                                 end
				 @(posedge Hclk)
                              //   @(posedge Hclk)

                              //   @(posedge Hclk)
                                  Htrans =IDLE;
                                


                            end
   
              
                       INCR4 : begin
                                          //  @(posedge Hclk)
                                            wait(Hreadyout)
                                           @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 2'd1;

				                                         
                                       for(i=0;i<=2;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                 @(posedge Hclk)

                                                Htrans = SEQ;
                                                Haddr  = Haddr + 2'd1;
                                              
                                               end
                                        
                                                @(posedge Hclk)
						// @(posedge Hclk)
                                 		//@(posedge Hclk)

                                              Htrans = IDLE;
                                      
                                 end
                           

                        
                      WRAP8  :  begin
                                       
                                            //@(posedge Hclk)
                                            wait(Hreadyout)
                                            @(posedge Hclk)

					  Htrans = SEQ;
                                           Haddr  = {Haddr[31:4],Haddr[3:1] + 1'b1,Haddr[0]};

					
                                         
                                       for(i=0;i<=6;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                 @(posedge Hclk)

                                                Htrans = SEQ;
                                                Haddr  = {Haddr[31:4],Haddr[3:1] + 1'b1,Haddr[0]};
                                              
                                            	end
                                           
                                              @(posedge Hclk)
					 //    @(posedge Hclk)
                                          //    @(posedge Hclk)

                                             Htrans = IDLE;
                                      


                                end


            
                       INCR8 : begin
                                 
                                           // @(posedge Hclk)
                                            wait(Hreadyout)
                                             @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 2'd2;

					                                         
                                       for(i=0;i<=6;i=i+1)
                                             begin
                                              wait(Hreadyout)
           					 @(posedge Hclk)

                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = Haddr + 2'd2;
                                              
                                             end
						 @(posedge Hclk)
					//	 @(posedge Hclk)
                                	  //       @(posedge Hclk)

                                               Htrans = IDLE;
                                      

                                       end
                                

                        

                         
                      WRAP16  :  begin
                                      
                                            wait(Hreadyout)
					 @(posedge Hclk)
                                           
					  Htrans = SEQ;
                                           Haddr  = {Haddr[31:5],Haddr[4:1] + 1'b1,Haddr[0]};
				
                                         
                                       for(i=0;i<14;i=i+1)
                                             begin
                                              wait(Hreadyout)
						 @(posedge Hclk)

                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = {Haddr[31:5],Haddr[4:1] + 1'b1,Haddr[0]};
                                              
                                                end	
					 @(posedge Hclk)
  				//	 @(posedge Hclk)
                                //         @(posedge Hclk)

                                            Htrans = IDLE;
                                      

                                      

                                       end
                                 

            
                       INCR16 : begin
                                 
                                           
                                            wait(Hreadyout)
                                             @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 2'd2;

				
                                         
                                       for(i=0;i<14;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
						 @(posedge Hclk)
                                                Htrans = SEQ;
                                                 Haddr  = Haddr + 2'd2;
                                              
                                              end
                                            @(posedge Hclk)
				//	     @(posedge Hclk)
                                //            @(posedge Hclk)

                                            Htrans = IDLE;
                                      

                                       end
                                 

                    endcase
              end
    





              
/////======================   half word =======================//////

HALF_WORD : begin
                 case(Hburst)                               



                      WRAP4  :  begin
                                     
                                            wait(Hreadyout)
                                             @(posedge Hclk)


       					  Htrans = SEQ;
                                          Haddr  = {Haddr[31:3],Haddr[2:1] + 1'b1,Haddr[0]};

				
                                         
                                       for(i=0;i<=2;i=i+1)
                                             begin
                                              wait(Hreadyout)
						 @(posedge Hclk)

                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                   Haddr  = {Haddr[31:3],Haddr[2:1] + 1'b1,Haddr[0]};
                                              
                       			     end
                                            @(posedge Hclk)
                                     //       @(posedge Hclk)
				     //	    @(posedge Hclk)
                                              Htrans = IDLE;
                                      

                                      end


            
                       INCR4 : begin
                                           

                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 2'd2;

					for(i=0;i<=2;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
						 @(posedge Hclk)

                                                Htrans = SEQ;
                                                Haddr  = Haddr + 2'd2;
                                              
           				    end
                                           
                                             @(posedge Hclk)
                                              Htrans = IDLE;
                                      
                                 end
                           

                        
                      WRAP8  :  begin
                                       
                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                           Haddr  = {Haddr[31:4],Haddr[3:1] + 1'b1,Haddr[0]};

				
                                         
                                       for(i=0;i<=6;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
						 @(posedge Hclk)

                                                Htrans = SEQ;
                                                Haddr  = {Haddr[31:4],Haddr[3:1] + 1'b1,Haddr[0]};
                                              
                                             end
                                           
  				        	@(posedge Hclk)
                                           //     @(posedge Hclk)
                                           //     @(posedge Hclk)
                                              Htrans = IDLE;
                                      


                                end


            
                       INCR8 : begin
                                 
                                           
                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 2'd2;

					 
                                         
                                       for(i=0;i<=6;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                 @(posedge Hclk)

                                                Htrans = SEQ;
                                                 Haddr  = Haddr + 2'd2;
                                              
                                              end
                                            @(posedge Hclk)
                                        //     @(posedge Hclk)
                                         //     @(posedge Hclk)
                                              Htrans = IDLE;
                                      

                                       end
                                

                        

                         
                      WRAP16  :  begin
                                      
                                         
                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                           Haddr  = {Haddr[31:5],Haddr[4:1] + 1'b1,Haddr[0]};
					                                          
                                       for(i=0;i<=14;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
						 @(posedge Hclk)

                                                Htrans = SEQ;
                                                 Haddr  = {Haddr[31:5],Haddr[4:1] + 1'b1,Haddr[0]};
                                              
      					     end
                                           
                                              @(posedge Hclk)
                               	//	      @(posedge Hclk)
                                    //         @(posedge Hclk)
                                              Htrans = IDLE;
                                      

                                      

                                       end
                                 

            
                       INCR16 : begin
                                 

                                          wait(Hreadyout)
                                         @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 2'd2;

                                         
                                       for(i=0;i<=14;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
						 @(posedge Hclk)

                                                Htrans = SEQ;
                                                 Haddr  = Haddr + 2'd2;
                                              
    					     end

                                            @(posedge Hclk)
                                    //        @(posedge Hclk)
                                    //        @(posedge Hclk)
                                              Htrans = IDLE;
                                      

                                       end
                                 

                    endcase
              end

   


      
///////=========================  word  ==========================///////
WORD : begin
                 case(Hburst)
                                                               



                      WRAP4  :  begin
                                     
                                           
                                            wait(Hreadyout)
					 @(posedge Hclk)

                                            Htrans = SEQ;
                                            Haddr  = {Haddr[31:4],Haddr[3:2] + 1'b1,Haddr[1:0]};

					  for(i=0;i<=2;i=i+1)
                                             begin
                                              wait(Hreadyout)
						 @(posedge Hclk)
                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                   Haddr  = {Haddr[31:4],Haddr[3:2] + 1'b1,Haddr[1:0]};
                                              
                                               end
                                           
 				 @(posedge Hclk)
                             //    @(posedge Hclk)
 			     //	 @(posedge Hclk)
                                 Htrans = IDLE;
                                      

                                      end


            
                       INCR4 : begin
                                           wait(Hreadyout)
        				 @(posedge Hclk)
  
	                                 Htrans = SEQ;
                                          Haddr  = Haddr + 3'd4;

					                                      
                                       for(i=0;i<2;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
						 @(posedge Hclk)

                                                Htrans = SEQ;
                                                Haddr  = Haddr + 3'd4;
                                              
                                          
					     end
                                            @(posedge Hclk)
 					 //    @(posedge Hclk)
                                         //   @(posedge Hclk)
                                           Htrans = IDLE;
                                      
                                 end
                           

                        
                      WRAP8  :  begin
                                       
                                           		                                          													  wait(Hreadyout)
                                             @(posedge Hclk)

					  Htrans = SEQ;
                                           Haddr  = {Haddr[31:5],Haddr[4:2] + 1'b1,Haddr[1:0]};

				                                         
                                       for(i=0;i<6;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                 @(posedge Hclk)

                                                @(posedge Hclk)
                                                Htrans = SEQ;
                                                Haddr  = {Haddr[31:5],Haddr[4:2] + 1'b1,Haddr[1:0]};
                                              
                                             end

                                            @(posedge Hclk)
                                      //      @(posedge Hclk)
                                       //     @(posedge Hclk)
                                           Htrans = IDLE;
                                      


                                end


            
                       INCR8 : begin
                                            wait(Hreadyout)
                                            @(posedge Hclk)

  					  Htrans = SEQ;
                                          Haddr  = Haddr + 3'd4;

				
                                        
                                       for(i=0;i<6;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
                                                 @(posedge Hclk)

                                                Htrans = SEQ;
                                                 Haddr  = Haddr + 3'd4;
                                              
                                                 end
                                            @(posedge Hclk)
				//	    @(posedge Hclk)
                                //	    @(posedge Hclk)
                                              Htrans = IDLE;
                                      

                                       end
                                

                        

                         
                      WRAP16  :  begin
                                      
                                           wait(Hreadyout)
        				  @(posedge Hclk)
  
                                           Htrans = SEQ;
                                           Haddr  = {Haddr[31:6],Haddr[5:2] + 1'b1,Haddr[1:0]};
					                                         
                                       for(i=0;i<=14;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
						 @(posedge Hclk)

                                                Htrans = SEQ;
                                                 Haddr  = {Haddr[31:6],Haddr[5:2] + 1'b1,Haddr[1:0]};
                                              
                                                end
                                            @(posedge Hclk)
 				//	    @(posedge Hclk)
                                //            @(posedge Hclk)
                                             Htrans = IDLE;
                                      

                                      

                                       end
                                 

            
                       INCR16 : begin
                                            wait(Hreadyout)
                                          @(posedge Hclk)

					  Htrans = SEQ;
                                          Haddr  = Haddr + 3'd4;
                                         
                                       for(i=0;i<=14;i=i+1)
                                             begin
                                              wait(Hreadyout)
                                                @(posedge Hclk)
  						 @(posedge Hclk)

                                                Htrans = SEQ;
                                                 Haddr  = Haddr + 3'd4;
                                              
                                             end
                                            @(posedge Hclk)
                                     //       @(posedge Hclk)
                                    //        @(posedge Hclk)
                                           Htrans = IDLE;
                                      

                                       end
                                 

                    endcase

            end
   
   endcase
 end
 end
endtask
          


/////=============================  back to back  ===================//////
task back_to_back;
  begin
    @(posedge Hclk)
    Hwrite   =   1'b1;
    Htrans   =   NON_SEQ;
    Hreadyin =   1'b1;
    Haddr    =   32'h8300_0000;
    Hsize    =   BYTE;

      //@(posedge Hclk)
       

   wait(Hreadyout)
    @(posedge Hclk)
    Hwrite   =  1'b0;
    Hwdata   =  {$random};

    Htrans   =  NON_SEQ;
    Haddr    =  32'h8500_0000;                                                                                                                                                                                                                                  
    Hsize    = BYTE;  

   wait(Hreadyout)
	@(posedge Hclk)
    @(posedge Hclk)
     Hwrite   =  1'b1;
     Hsize    =  BYTE;
     Htrans   = NON_SEQ;
     Haddr    = 32'h8600_0000;


   

   
   wait(Hreadyout)
   @(posedge Hclk)
    @(posedge Hclk)
    @(posedge Hclk)
    @(posedge Hclk)

     Hwrite   =  1'b0;
     Hwdata   =  {$random};
     Htrans   =  NON_SEQ;
     Haddr    =  32'h8700_0000;  
     Hsize    =  BYTE; 

 /* wait(Hreadyout)
    @(posedge Hclk)
     Hwrite  = 1'b1;
     Htrans  = NON_SEQ;
     Haddr   = 32'h8c00_0000;
    Hsize    = BYTE;
  
   @(posedge Hclk)
    Hwrite  = 1'b0;
    Hwdata ={$random};
    Haddr  = $random;
    Htrans =NON_SEQ;*/

    @(posedge Hclk)
    @(posedge Hclk) 
    @(posedge Hclk)
    Htrans    =  IDLE;
   
  end
endtask
    
       
               
endmodule    

