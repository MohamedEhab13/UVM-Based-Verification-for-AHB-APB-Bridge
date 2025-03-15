`uvm_analysis_imp_decl(_ahb_cov_port) 
`uvm_analysis_imp_decl(_apb_cov_port)


class coverage extends uvm_subscriber #(uvm_sequence_item) ;
  `uvm_component_utils(coverage)
  
  // Ports Declaration 
  uvm_analysis_imp_ahb_cov_port #(ahb_seq_item, coverage) ahb_cov_ap ;
  uvm_analysis_imp_apb_cov_port #(apb_seq_item, coverage) apb_cov_ap ;
  
  
  // Handles declaration 
  ahb_seq_item ahb_cov_item ; // Copy the recieved AHB item from monitor here to avoid override elsewhere 
  apb_seq_item apb_cov_item ; // Copy the recieved APB item from monitor here to avoid override elsewhere 
  
  
  //================================ Covergroups =============================\\
 

  // Reset Covergroups
  covergroup AHB_Reset_cg ;
    AHB_Reset : coverpoint ahb_cov_item.HRESETn { bins OFF_ON = (0 => 1) ;
                                                  bins ON_OFF = (1 => 0) ; }
  endgroup : AHB_Reset_cg
  
  covergroup APB_Reset_cg ;
    APB_Reset : coverpoint apb_cov_item.PRESETn { bins OFF_ON = (0 => 1) ;
                                                 bins ON_OFF = (1 => 0) ; }
  endgroup : APB_Reset_cg
  
  //--------------------------------------------------------------------------
  
  // Bridge Select Covergroup
  covergroup Bridge_Select_cg ;
    Bridge_Select : coverpoint ahb_cov_item.HSEL {bins selected     = {1} ;
                                                  bins not_selected = {0} ; }
  endgroup 
  
  //--------------------------------------------------------------------------

  // Operation-type Covergroup 
  covergroup Operation_Type_cg ;
    Operation_Type : coverpoint ahb_cov_item.HWRITE {bins read_write = (0 => 1) ;
                                                     bins write_read = (1 => 0) ; }
  endgroup
  
  //--------------------------------------------------------------------------

  // Trasfer Size Covergroup 
  covergroup Trasfer_Size_cg ;
    Trasfer_Size : coverpoint ahb_cov_item.HSIZE {bins Byte     = {0} ;
                                                  bins Halfword = {1} ;
                                                  bins Word     = {2} ;}
  endgroup
  
  //--------------------------------------------------------------------------
                                                
  // Protection Covergroup 
  covergroup Protection_cg ;                                                
    Protection : coverpoint ahb_cov_item.HPROT {bins hprot[] = {[0:15]}; } 
  endgroup      
                                                
  
  // Transfer Type Covergroup 
  covergroup Transfer_Type_cg ; 
    Transfer_Type : coverpoint ahb_cov_item.HTRANS {bins Idle   = {IDLE}   ; 
                                                    bins Busy   = {BUSY}   ;
                                                    bins Seq    = {SEQ}    ;
                                                    bins Nonseq = {NONSEQ} ;}
  endgroup 
                                                
  //-------------------------------------------------------------------------- 
 
  // Ready Covergroup 
  covergroup Master_Ready_cg ;
    Master_Ready : coverpoint ahb_cov_item.HREADY {bins Master_Ready = {1} ;
                                                   bins Master_Busy  = {0} ;}                           
  endgroup
                                                   
  covergroup Slave_Ready_cg ;
    slave_Ready  : coverpoint apb_cov_item.PREADY {bins Slave_Ready = {1} ;
                                                   bins Slave_Busy  = {0} ;}                             
  endgroup
  
  //--------------------------------------------------------------------------
          
  // Error Covergroup 
  covergroup Error_cg ; 
    Error : coverpoint apb_cov_item.PSLVERR {bins error = {1} ; 
                                             bins pass  = {0} ;}
  endgroup 
  
  //--------------------------------------------------------------------------                                                  
                                                    
  // Constructor 
  function new(string name = "coverage" ,uvm_component parent);
     super.new(name,parent);
    
     // Ports Construction 
     ahb_cov_ap = new ("ahb_cov_ap" ,this);
     apb_cov_ap = new ("apb_cov_ap" ,this);
    
     // Covergroups Construction 
     AHB_Reset_cg      = new() ;
     APB_Reset_cg      = new() ;
     Bridge_Select_cg  = new() ;
     Operation_Type_cg = new() ;
     Trasfer_Size_cg   = new() ;
     Protection_cg     = new() ;
     Transfer_Type_cg  = new() ;
     Master_Ready_cg   = new() ;
     Slave_Ready_cg    = new() ;
     Error_cg          = new() ;
    
  endfunction : new
  
  
  
  // Build Phase 
  function void build_phase(uvm_phase phase);  
    super.build_phase(phase);
  endfunction
  
  // AHB write function 
  function void write_ahb_cov_port (ahb_seq_item ahb_tr);
    ahb_cov_item = ahb_seq_item::type_id::create("ahb_cov_item"); 
    ahb_cov_item.copy(ahb_tr) ;      
    
     // Sampling covergroups 
     AHB_Reset_cg      .sample() ;
     Bridge_Select_cg  .sample() ;
     Operation_Type_cg .sample() ;
     Trasfer_Size_cg   .sample() ;
     Protection_cg     .sample() ;
     Transfer_Type_cg  .sample() ;
     Master_Ready_cg   .sample() ;
    
  endfunction : write_ahb_cov_port
                                             
                                             
  
  // APB write function 
  function void write_apb_cov_port (apb_seq_item apb_tr);
    apb_cov_item = apb_seq_item::type_id::create("apb_cov_item"); 
    apb_cov_item.copy(apb_tr) ;      
    
     // Sampling covergroups 
     APB_Reset_cg      .sample() ;
     Slave_Ready_cg    .sample() ;
     Error_cg          .sample() ;
    
  endfunction : write_apb_cov_port
                                             
  function void write (uvm_sequence_item  t);
  endfunction
  
endclass : coverage
