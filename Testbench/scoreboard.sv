`uvm_analysis_imp_decl(_ahb_port) 
`uvm_analysis_imp_decl(_apb_port)


class scoreboard extends uvm_scoreboard  ;
  `uvm_component_utils(scoreboard);

  // Ports Declaration 
  uvm_analysis_imp_ahb_port #(ahb_seq_item, scoreboard) ahb_ap ;
  uvm_analysis_imp_apb_port #(apb_seq_item, scoreboard) apb_ap ;
  
  
  // AHB Sequence items declaration 
  ahb_seq_item ahb_sb   ; // Holds AHB monitor transaction To prevent unwanted change
  ahb_seq_item ahb_p    ; // Holds AHB predicted transaction 
  ahb_seq_item ahb_prev ; // Holds the previous AHB transaction 
  
  // APB Sequence items declaration
  apb_seq_item apb_sb   ; // Holds APB monitor transaction To prevent unwanted change
  apb_seq_item apb_p    ; // Hold APB predicted transaction  
  apb_seq_item apb_prev ; // Holds the previous APB transaction 
  
  // Some usefull signals 
  bit       write_command  ; // Asserted when write transfer is requested (stay high for one cycle)
  bit       read_command   ; // Asserted when read transfer is requested (stay high for one cycle)  
  bit       apb_pending    ; // Goes high at receiving apb transaction and stay high untill ack strobe goes back to AHB 
  bit       read_done      ; // Goes high after finishing read transfer 
  bit       error_done     ; // Asserted when error happens
  bit       write_done     ; // Asserted when write operation completed 
  bit       apb_sample     ; // Goes High when new data asserted on PWDATA or PRDATA bus to trigger the pridict function    
  bit [6:0] beats          ; // Holds the number of beats 
  bit [6:0] apb_count      ; // Counter to check if the beats are done 
  bit       next_beat      ; // Asserted at start of beats 
  bit       apb_psel       ; // Control predicted PSEL along write process 
  bit       apb_enable     ; // Used to Assert predicted PENABLE in setup phase 
  bit       HREADYOUT_temp ; // Control predicted HREADYOUT
  bit       hwrite         ; // Indicates write operation Pending
  bit       pslverr        ; // temp storage for PSLVERR 
  bit       hresp          ; // temp storage for HRESP 	
  bit       seq , nonseq   ; // HTRANS types 
  
  // Crossing domain signals 
  bit   [             3:0] ahb2apb_count       ; // Counter for AHB to APB domains transition during read and write 
  bit   [             3:0] apb2ahb_write_count ; // Counter for APB to AHB domains transition 
  bit   [             3:0] apb2ahb_read_count  ; // Counter for APB to AHB domains transition 
  
  // Temporary storage signals
  logic [HDATA_SIZE  -1:0] HWDATA_temp ; // Holds AHB write data untill transaction is received by APB
  logic [HADDR_SIZE  -1:0] HADDR_temp  ; // Holds AHB Address untill transaction is received by APB
  logic [             3:0] HPROT_temp  ; // Holds AHB protection untill transaction is received by APB
  logic [             2:0] HSIZE_temp  ; // Hold AHB transfer size untill transaction is received by APB
  bit [HDATA_SIZE  -1:0] PRDATA_temp ; // Accumulate PRDATA bus along the transfer 
  
   
  
  // Constructor
  function new (string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
    ahb_ap = new ("ahb_ap" ,this); // Create AHB analysis port 
    apb_ap = new ("apb_ap" ,this); // Create APB analysis port 
  endfunction : new


  // Build Phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase) ;
    ahb_prev = ahb_seq_item::type_id::create("ahb_prev"); 
    apb_prev = apb_seq_item::type_id::create("apb_prev"); 
  endfunction : build_phase
  
  
   //--------------------------//
  // AHB port write function  //
 //--------------------------//
  virtual function void write_ahb_port(ahb_seq_item ahb_tr);  
    
    // Create Actual and Predicted transactions
    ahb_sb = ahb_seq_item::type_id::create("ahb_sb"); 
    ahb_p = ahb_seq_item::type_id::create("ahb_p"); 
    ahb_sb.copy(ahb_tr) ; 
    
    // AHB Reset Check 
    if(!ahb_sb.HRESETn) begin 
      ahb_p.Reset() ;
      ahb_compare(ahb_sb, ahb_p) ;
    end 
      
    else begin // If No Reset Asserted :
      
      seq = (ahb_sb.HTRANS == SEQ) ;
      nonseq = (ahb_sb.HTRANS == NONSEQ) ;
      read_done  = 0 ;
      write_done = 0 ;
      
      // Hold signals unchanged if PREADY is low 
      if (apb_sb.PREADY !== 0)  begin
        
        if(apb_sb.PSLVERR) begin 
          apb_enable    = 0 ;
          apb_psel      = 1 ; 
          write_command = 0 ;
          read_command  = 0 ;
          apb_sample    = 0 ;
          pslverr       = 1 ;  
        end
        
        if(pslverr) begin 
          apb2ahb_write_count = apb2ahb_write_count + 1 ;
          if (apb2ahb_write_count == 7) begin
             Reset_signals ;
             hresp = 1 ;
          end
          else if (apb2ahb_write_count == 6) begin 
             error_done = 1 ;
             hresp = 1 ; 
          end
        end
        
       else begin 
        // APB to AHB transition after transfer 
        if ((apb_count == (beats + 1)) && apb_pending ) begin 
          apb2ahb_write_count = apb2ahb_write_count + 1 ;
        end
      
        // Reset after APB to AHB transition  
        if (apb2ahb_write_count == 8) begin 
          Reset_signals ;
        end
         
        // Check if last cycle had Write command 
        if(write_command) begin 
          HWDATA_temp    = ahb_sb.HWDATA ;
          HREADYOUT_temp = 1'b1 ;
          if (ahb2apb_count == 8)begin 
            ahb2apb_count = 5 ;
            next_beat = 1 ;
          end
          else   
            ahb2apb_count = ahb2apb_count + 1 ; 
        end
           
        // Check if current transaction is Write command 
        if ((seq || nonseq) && ahb_sb.HREADY && ahb_sb.HREADYOUT && ahb_sb.HSEL && ahb_sb.HWRITE) begin 
          write_command = 1 ;
          hwrite        = 1 ;  
          HADDR_temp  = ahb_sb.HADDR ;
          HPROT_temp  = ahb_sb.HPROT ;
          HSIZE_temp  = ahb_sb.HSIZE ;
        end
      
        //  Check if last cycle had Read command   
        if(read_command) begin 
          HREADYOUT_temp = 1'b1 ;   
          if (ahb2apb_count == 8) begin 
            ahb2apb_count = 5 ;
            next_beat = 1 ;
          end
          else  
            ahb2apb_count = ahb2apb_count + 1 ; 
        end  
        
        // Check if current transaction is Read command   
        if ((seq || nonseq) && ahb_sb.HREADY && ahb_sb.HREADYOUT && ahb_sb.HSEL && (ahb_sb.HWRITE == 0)) begin 
          read_command = 1 ; 
          hwrite       = 0 ;
          
          HADDR_temp  = ahb_sb.HADDR ;
          HPROT_temp  = ahb_sb.HPROT ;
          HSIZE_temp  = ahb_sb.HSIZE ;
          
        end
       end // pslverr
      end // pready
        
      // AHB Predict and Compare Functions Call     
      ahb_predict() ;
      ahb_compare(ahb_sb, ahb_p) ;
          
    end // If No Reset Asserted End 
    
    // Save the current transaction to be used next cycle     
    ahb_prev.copy(ahb_sb) ; 
     
  endfunction // AHB write function 
  
  
   //-------------------------//
  // APB port write function //
 //-------------------------//
  virtual function void write_apb_port(apb_seq_item apb_tr);
    apb_sb = apb_seq_item::type_id::create("apb_sb");
    apb_p = apb_seq_item::type_id::create("apb_p");
    apb_sb.copy(apb_tr) ; 
    
    // APB Reset Check 
    if(!apb_sb.PRESETn) begin 
      apb_p.Reset() ;
      apb_compare(apb_sb, apb_p) ;
    end 
    
    else begin // If No Reset Asserted 
      
     apb_enable = apb_sample ? 1 : 0 ;
     beats = (write_command | read_command) ? apb_beats(HSIZE_temp) : beats ;
      
     // Hold signals unchanged if PREADY is low  
      if ((apb_sb.PREADY !== 0) && (apb_sb.PSLVERR !== 1)) begin 
      

     /* Check if a new WDATA is asserted on the bus 
      * counter goes from 0 to 8 fisrt time in transition from AHB domain to APB domain 
      * then it goes from 5 to 8 for extra beats 
      */   
     if(ahb2apb_count == 8) begin 
        apb_sample  = 1 ; 
        apb_count = apb_count + 1 ;
        apb_pending   = 1 ;
       end      
     else 
        apb_sample = 0 ;
     
       
     // end
     end 

     if(apb_sb.PENABLE) begin  
         PRDATA_temp = (PRDATA_temp << PDATA_SIZE) | (apb_sb.PRDATA << data_offset(HADDR_temp));
     end 
      
     // APB Predict and Compare Functions Call     
     apb_predict() ;
     apb_compare(apb_sb, apb_p) ; 
       
    end // If No Reset Asserted End 
    
   // Save the current transaction to be used next cycle     
   apb_prev.copy(apb_sb) ; 
  endfunction // APB write function 
  
  
  // -------------------------------- Predict Section -----------------------------------\\
  
   //----------------------//
  // AHB Predict Function //
 //----------------------// 
  function void ahb_predict () ;
    ahb_p.copy(ahb_prev) ;
    ahb_p.HREADYOUT = (HREADYOUT_temp) ? 0 : 1 ;
    ahb_p.HRESP = hresp ? 1 : 0 ;
    if (read_done || (error_done && !hwrite)) begin
      ahb_p.HRDATA = PRDATA_temp ;
      error_done = 0 ;
      //PRDATA_temp = 0 ;
    end
    
    if (write_done)
      ahb_p.HRDATA = 'hx ;
      
     hresp = 0 ;  
    
  endfunction // ahb_predict End
  
   //----------------------//
  // APB Predict Function //
 //----------------------// 
  function void apb_predict () ;
     
      // Check if slave is not ready
      if (!apb_sb.PREADY) begin 
        apb_p.copy(apb_prev) ;  
        apb_p.PREADY = 0 ; 
        apb_p.PENABLE = apb_enable ? 1 : apb_enable ; 
      end
    
      // Check for errors during transfer 
      else if (apb_sb.PSLVERR) begin 
        apb_p.copy(apb_prev) ; 
        apb_p.PENABLE = apb_enable ? 1 : apb_enable ;
      end
    
      // Check if data is received by APB side
      else if(apb_sample) begin       
      apb_p.PSEL    = 1'b1 ;
      apb_p.PENABLE = 1'b0 ; 
      apb_p.PPROT   = PROT(HPROT_temp) ;
      apb_p.PWRITE  = hwrite ? 1 : 0 ;
      
      // Check for other write beats  
      if (next_beat) begin 
        apb_p.PADDR  = apb_prev.PADDR + (1 << PDATA_SIZE/8) ;
        apb_p.PWDATA = HWDATA_temp >> data_offset(HADDR_temp) + (PDATA_SIZE*(apb_count - 1)) ;
        apb_p.PSTRB  = hwrite ? pstrb(HSIZE_temp, apb_prev.PADDR + (1 << HSIZE_temp)) : 0 ;
      end
        
      else begin 
        apb_p.PADDR   = HADDR_temp[PADDR_SIZE-1:0] ;
        apb_p.PWDATA  = hwrite ? HWDATA_temp >> data_offset(HADDR_temp) : 'hx ;
        apb_p.PSTRB   = hwrite ? pstrb(HSIZE_temp , apb_p.PADDR) : 0 ;
      end
      ahb2apb_count = ((apb_count == (beats + 1)) && apb_pending) ?  0 : ahb2apb_count ; 
    end
    
    // Pending or No Operation
    else begin 
      apb_p.copy(apb_prev) ;
      apb_p.PSEL = apb_psel ? 0 : apb_p.PSEL ;
      apb_p.PENABLE = apb_enable ? 1 : 0 ;
      apb_psel = ((apb_count == (beats + 1)) && apb_pending) ? 1 : 0 ;
      
    end
  endfunction // apb_predict End
          
  //--------------------------------- Compare Section ------------------------------------\\
  // AHB Compare Function 
  function void ahb_compare (ahb_seq_item a_item, ahb_seq_item p_item) ;   
    bit pass ; 
     
      pass = (a_item.HRDATA    === p_item.HRDATA)    &&
             (a_item.HREADYOUT ==  p_item.HREADYOUT) &&
             (a_item.HRESP     ==  p_item.HRESP) ;
    
      if (pass)
        `uvm_info(get_type_name(),"AHB PASS", UVM_HIGH)
      else  
        `uvm_error(get_type_name(),"AHB FAIL")
        
        
      
      
  endfunction 
      
      
  // APB Compare Function 
  function void apb_compare (apb_seq_item a_item, apb_seq_item p_item) ;
    bit pass ; 
    
    pass = (a_item.PSEL    ==  p_item.PSEL)    &&
           (a_item.PENABLE ==  p_item.PENABLE) &&
           (a_item.PPROT   ==  p_item.PPROT)   &&
           (a_item.PWRITE  ==  p_item.PWRITE)  &&
           (a_item.PSTRB   ==  p_item.PSTRB)   &&
           (a_item.PADDR   ==  p_item.PADDR)   &&
           (a_item.PWDATA  === p_item.PWDATA)  ;
    
    if (pass)
      `uvm_info(get_type_name(),"APB PASS", UVM_HIGH)
    else  
      `uvm_error(get_type_name(),"APB FAIL")
      
      
    
      
  endfunction 
          
  // ----------------------------- Commonly used Functions Section ------------------------- \\         
 
  // PROT function to resolve 4-bit HPROT to 3-bit PPROT 
  function bit [2:0] PROT(logic [3:0] hprot) ; 
    if (hprot[1]) // Privileged vs User access  
      PROT[0] = 1 ;   
    if (!hprot[0]) // Data vs Instruction access 
      PROT[2] = 1 ;
  endfunction
 
  
  function void Reset_signals () ; 
          apb2ahb_write_count = 0 ;
          apb_pending         = 0 ;       
          apb_psel            = 1 ;
          apb_count           = 0 ;
          write_command       = 0 ;
          read_command        = 0 ;
          HREADYOUT_temp      = 0 ;
          ahb2apb_count       = 0 ;
          next_beat           = 0 ;  
          hresp               = 0 ;
          pslverr             = 0 ;
          write_done          = hwrite ? 1 : 0 ;
          read_done           = hwrite ? 0 : 1 ;         
  endfunction 
  
endclass : scoreboard 
    
    
    
    
    
    
    
    
  