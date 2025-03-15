class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)


  // Sequence item Declaration  
  apb_seq_item apb_monitor_item ;
  
  // Config class Declaration 
  apb_cnfg apb_cnfg_h ; 
  
  // Virtual Interface Declaration 
  virtual apb_intf apb_intf_h ;
  virtual apb_intf apb_monitor_intf_h ;
  
  
  // Port to send transactions to the scoreboard
  uvm_analysis_port # (apb_seq_item) apb_monitor_ap;


  // Constructor  
  function new(string name = "apb_monitor" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new
 
    
  // Build Phase 
  function void build_phase(uvm_phase phase);    
    super.build_phase(phase);
    
    // Get Interface 
    if(!(uvm_config_db #(virtual apb_intf)::get(this,"*","apb_intf_h",apb_intf_h))) 
     `uvm_error(get_type_name(),"failed to get virtual interface inside APB Monitor class")    
    
    // Get Configuartion   
    if (!uvm_config_db  #(apb_cnfg) ::get(this,"" , "apb_configuration", apb_cnfg_h ))
     `uvm_fatal(get_type_name(), "configuration not found" )  
      
    // Create APB analysis port    
    apb_monitor_ap  = new("apb_monitor_ap",this);
    
  endfunction : build_phase 
      
      
  // Connect Phase 
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
	apb_monitor_intf_h = apb_intf_h ;
  endfunction : connect_phase



  // Run Phase 
  task  run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin 
      
      // Synchronize with Driver 
      wait (apb_cnfg_h.sync_start.triggered);
      
      apb_monitor_item = apb_seq_item::type_id::create("apb_monitor_item"); 
      
      // Sample APB Interface Signals 
      @(posedge apb_monitor_intf_h.pclk)  
      apb_monitor_item.PRESETn   = apb_monitor_intf_h.PRESETn ;
      apb_monitor_item.PSEL      = apb_monitor_intf_h.PSEL    ;
      apb_monitor_item.PADDR     = apb_monitor_intf_h.PADDR   ;
      apb_monitor_item.PWDATA    = apb_monitor_intf_h.PWDATA  ;
      apb_monitor_item.PRDATA    = apb_monitor_intf_h.PRDATA  ;
      apb_monitor_item.PWRITE    = apb_monitor_intf_h.PWRITE  ;
      apb_monitor_item.PPROT     = apb_monitor_intf_h.PPROT   ;  
      apb_monitor_item.PREADY    = apb_monitor_intf_h.PREADY  ;
      apb_monitor_item.PENABLE   = apb_monitor_intf_h.PENABLE ;
      apb_monitor_item.PSTRB     = apb_monitor_intf_h.PSTRB   ;
      apb_monitor_item.PSLVERR   = apb_monitor_intf_h.PSLVERR ;
      
      // Call APB write function 
      apb_monitor_ap.write(apb_monitor_item); 
    
    end // forever block 
      
  endtask : run_phase 
        
 endclass : apb_monitor
    
